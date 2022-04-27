locals {
  desired_capacity = max(var.desired_capacity, var.min_size)

  download_url = format(
    "https://releases.hashicorp.com/boundary/%s/boundary_%s_linux_amd64.zip",
    var.boundary_release,
    var.boundary_release
  )

  user_data = {
    package_update = true
    packages       = ["unzip"]

    runcmd = concat(
      [
        "wget -O boundary.zip ${local.download_url}",
        "unzip boundary.zip -d /usr/local/bin"
      ],
      var.before_start,
      [
        "systemctl enable boundary",
        "systemctl start boundary",
      ],
      var.after_start
    )

    write_files = concat(
      [
        {
          content     = base64encode(file("${path.module}/files/boundary.service"))
          encoding    = "b64"
          owner       = "root:root"
          path        = "/etc/systemd/system/boundary.service"
          permissions = "0644"
        }
      ],
      var.write_files
    )
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.3.0"

  create_launch_template   = true
  health_check_type        = "EC2"
  iam_instance_profile_arn = var.iam_instance_profile
  image_id                 = var.image_id

  instance_refresh = {
    preferences = {
      min_healthy_percentage = 80
    }

    strategy = "Rolling"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 100
        volume_type           = "gp2"
      }
    }
  ]

  instance_type          = var.instance_type
  key_name               = var.key_name
  desired_capacity       = local.desired_capacity
  max_size               = var.max_size
  min_size               = var.min_size
  name                   = var.auto_scaling_group_name
  security_groups        = var.security_groups
  tags                   = var.tags
  target_group_arns      = var.target_group_arns
  update_default_version = true

  user_data = base64encode(<<EOF
## template: jinja
#cloud-config
${yamlencode(local.user_data)}
EOF
  )

  vpc_zone_identifier = var.vpc_zone_identifier
}
