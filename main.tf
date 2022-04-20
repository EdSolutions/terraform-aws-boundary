locals {
  image_id = data.aws_ami.boundary.id
}

data "aws_route53_zone" "public" {
  zone_id = var.public_route53_zone_id
}

data "aws_availability_zones" "available" {}

data "aws_ami" "boundary" {
  most_recent = true
  name_regex  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  owners      = ["099720109477"]
}

data "aws_s3_objects" "cloudinit" {
  bucket = aws_s3_bucket.boundary.id

  depends_on = [module.controllers]
}

resource "random_string" "boundary" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_s3_bucket" "boundary" {
  bucket        = "boundary-${random_string.boundary.result}"
  force_destroy = true
}

module "controllers" {
  source = "./modules/controller"

  boundary_release              = var.boundary_release
  bucket_name                   = aws_s3_bucket.boundary.id
  desired_capacity              = var.controller_desired_capacity
  image_id                      = local.image_id
  instance_type                 = var.controller_instance_type
  key_name                      = var.key_name
  max_size                      = var.controller_max_size
  min_size                      = var.controller_min_size
  vpc_id                        = var.vpc_id
  private_subnets               = var.private_subnets
  public_subnets                = var.public_subnets
  db_instance_subnet_group_name = var.db_instance_subnet_group_name
  public_route53_zone_id        = var.public_route53_zone_id
  tags                          = var.tags
}

module "workers" {
  source = "./modules/worker"

  boundary_release  = var.boundary_release
  bucket_name       = aws_s3_bucket.boundary.id
  desired_capacity  = var.worker_desired_capacity
  image_id          = local.image_id
  instance_type     = var.worker_instance_type
  ip_addresses      = module.controllers.ip_addresses
  key_name          = var.key_name
  kms_key_id        = module.controllers.kms_key_id
  max_size          = var.worker_max_size
  min_size          = var.worker_min_size
  public_subnets    = var.public_subnets
  security_group_id = module.controllers.security_group_id
  tags              = var.tags
  vpc_id            = var.vpc_id
}
