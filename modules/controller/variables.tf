variable "boundary_release" {
  default     = "0.7.5"
  description = "The version of Boundary to install"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket to upload the contents of the cloud-init-output.log file"
  type        = string
}

variable "desired_capacity" {
  description = "The desired capacity is the initial capacity of the Auto Scaling group at the time of its creation and the capacity it attempts to maintain."
  type        = number
  default     = 3
}

variable "image_id" {
  description = "The ID of the Amazon Machine Image (AMI) that was assigned during registration"
  type        = string
}

variable "instance_type" {
  description = "Specifies the instance type of the EC2 instance"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "The name of the key pair"
  type        = string
  default     = null
}

variable "max_size" {
  description = "The maximum size of the group"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "The minimum size of the group"
  type        = number
  default     = 3
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "tags" {
  description = "One or more tags. You can tag your Auto Scaling group and propagate the tags to -the Amazon EC2 instances it launches."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_instance_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = string
  default     = false
}

variable "db_instance_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type        = string
}

variable "db_instance_backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "db_instance_snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05"
  type        = string
  default     = null
}

variable "public_route53_zone_id" {
  description = "The public DNS zone to create a record and ACM cert validations"
  type        = string
}
