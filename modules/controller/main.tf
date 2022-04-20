data "aws_instances" "controllers" {
  instance_state_names = ["running"]

  instance_tags = {
    "aws:autoscaling:groupName" = module.controllers.auto_scaling_group_name
  }
}

data "aws_route53_zone" "public" {
  zone_id = var.public_route53_zone_id
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_s3_bucket" "boundary" {
  bucket = var.bucket_name
}

module "controller_acm_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.4.1"

  domain_name = "boundary.${data.aws_route53_zone.public.name}"
  zone_id     = var.public_route53_zone_id

  wait_for_validation = true
}

resource "aws_security_group" "alb" {
  name_prefix = "boundary-alb-"
  vpc_id      = var.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  dynamic "ingress" {
    for_each = [80, 443]

    content {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = ingress.value
      protocol    = "TCP"
      to_port     = ingress.value
    }
  }

  tags = merge(
    {
      Name = "boundary-alb"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.9.0"

  load_balancer_type = "application"
  name               = "boundary"
  security_groups    = [aws_security_group.alb.id]
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.controller_acm_cert.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  target_groups = [
    {
      name             = "boundary"
      backend_protocol = "HTTP"
      backend_port     = 9200
    }
  ]

  tags = var.tags
}

resource "aws_route53_record" "controller" {
  zone_id = var.public_route53_zone_id
  name    = "boundary.${data.aws_route53_zone.public.name}"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "database" {
  name_prefix = "boundary-db-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    protocol        = "TCP"
    security_groups = [aws_security_group.controller.id]
    to_port         = 5432
  }

  tags = merge(
    {
      Name = "boundary-db"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "database" {
  keepers = {
    snapshot_identifier = var.db_instance_snapshot_identifier
  }
}

module "database" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.2.0"

  identifier = "boundary-${random_pet.database.id}"

  engine                = "postgres"
  engine_version        = "12.8"
  family                = "postgres12"
  major_engine_version  = "12"
  instance_class        = var.db_instance_class
  allocated_storage     = 50
  max_allocated_storage = 100

  db_name  = "boundary"
  username = "boundary"
  port     = 5432
  multi_az = var.db_instance_multi_az

  db_subnet_group_name   = var.db_instance_subnet_group_name
  vpc_security_group_ids = [aws_security_group.database.id]

  maintenance_window              = "Sun:00:00-Sun:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = var.db_instance_backup_retention_period
  deletion_protection     = false

  performance_insights_enabled = false

  snapshot_identifier = var.db_instance_snapshot_identifier
}

locals {
  configuration = templatefile(
    "${path.module}/templates/configuration.hcl.tpl",
    {
      # Database URL for PostgreSQL
      database_url = format(
        "postgresql://%s:%s@%s/%s",
        module.database.db_instance_username,
        module.database.db_instance_password,
        module.database.db_instance_endpoint,
        module.database.db_instance_name
      )

      keys = [
        {
          key_id  = aws_kms_key.root.key_id
          purpose = "root"
        },
        {
          key_id  = aws_kms_key.auth.key_id
          purpose = "worker-auth"
        }
      ]
    }
  )
}

resource "aws_security_group" "controller" {
  name_prefix = "boundary-controller-"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = "boundary-controller"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.controller.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "TCP"
  cidr_blocks = [data.aws_vpc.selected.cidr_block]
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.controller.id

  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "TCP"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.controller.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# https://www.boundaryproject.io/docs/configuration/kms/awskms#authentication
#
# Allows the controllers to invoke the Decrypt, DescribeKey, and Encrypt
# routines for the worker-auth and root keys.
data "aws_iam_policy_document" "controller" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt"
    ]

    effect = "Allow"

    resources = [aws_kms_key.auth.arn, aws_kms_key.root.arn]
  }

  statement {
    actions = [
      "s3:*"
    ]

    effect = "Allow"

    resources = [
      "${data.aws_s3_bucket.boundary.arn}/",
      "${data.aws_s3_bucket.boundary.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "controller" {
  name   = "boundary-controller"
  policy = data.aws_iam_policy_document.controller.json
}

resource "aws_iam_role" "controller" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "boundary-controller"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "controller" {
  policy_arn = aws_iam_policy.controller.arn
  role       = aws_iam_role.controller.name
}

resource "aws_iam_instance_profile" "controller" {
  role = aws_iam_role.controller.name
}

# The root key used by controllers
resource "aws_kms_key" "root" {
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "boundary-root" })
}

# The worker-auth AWS KMS key used by controllers and workers
resource "aws_kms_key" "auth" {
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  tags                    = merge(var.tags, { Purpose = "boundary-worker-auth" })
}

module "controllers" {
  source = "../boundary"

  auto_scaling_group_name = "boundary-controller"
  boundary_release        = var.boundary_release
  bucket_name             = var.bucket_name
  desired_capacity        = var.desired_capacity
  iam_instance_profile    = aws_iam_instance_profile.controller.arn
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  max_size                = var.max_size
  min_size                = var.min_size
  security_groups         = [aws_security_group.controller.id]
  tags                    = var.tags
  target_group_arns       = module.alb.target_group_arns
  vpc_zone_identifier     = var.private_subnets

  after_start = [
    "grep 'Initial auth information' /var/log/cloud-init-output.log && aws s3 cp /var/log/cloud-init-output.log s3://${var.bucket_name}/{{v1.local_hostname}}/cloud-init-output.log || true"
  ]

  # Initialize the DB before starting the service and install the AWS
  # CLI.
  before_start = [
    "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
    "unzip awscliv2.zip",
    "./aws/install",
    "boundary database init -config /etc/boundary/configuration.hcl -log-format json"
  ]

  write_files = [
    {
      content     = local.configuration
      owner       = "root:root"
      path        = "/etc/boundary/configuration.hcl"
      permissions = "0644"
    }
  ]
}
