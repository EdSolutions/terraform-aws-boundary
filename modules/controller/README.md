<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.67 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.67 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | 6.9.0 |
| <a name="module_controller_acm_cert"></a> [controller\_acm\_cert](#module\_controller\_acm\_cert) | terraform-aws-modules/acm/aws | 3.4.1 |
| <a name="module_controllers"></a> [controllers](#module\_controllers) | ../boundary | n/a |
| <a name="module_database"></a> [database](#module\_database) | terraform-aws-modules/rds/aws | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [random_pet.database](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_instances.controllers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_s3_bucket.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boundary_release"></a> [boundary\_release](#input\_boundary\_release) | The version of Boundary to install | `string` | `"0.7.5"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket to upload the contents of the cloud-init-output.log file | `string` | n/a | yes |
| <a name="input_db_instance_backup_retention_period"></a> [db\_instance\_backup\_retention\_period](#input\_db\_instance\_backup\_retention\_period) | The days to retain backups for | `number` | `7` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | The instance type of the RDS instance | `string` | `"db.t3.micro"` | no |
| <a name="input_db_instance_multi_az"></a> [db\_instance\_multi\_az](#input\_db\_instance\_multi\_az) | Specifies if the RDS instance is multi-AZ | `string` | `false` | no |
| <a name="input_db_instance_snapshot_identifier"></a> [db\_instance\_snapshot\_identifier](#input\_db\_instance\_snapshot\_identifier) | Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05 | `string` | `null` | no |
| <a name="input_db_instance_subnet_group_name"></a> [db\_instance\_subnet\_group\_name](#input\_db\_instance\_subnet\_group\_name) | Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The desired capacity is the initial capacity of the Auto Scaling group at the time of its creation and the capacity it attempts to maintain. | `number` | `3` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The ID of the Amazon Machine Image (AMI) that was assigned during registration | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the instance type of the EC2 instance | `string` | `"t3.small"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key pair | `string` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the group | `number` | `3` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the group | `number` | `3` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | n/a | yes |
| <a name="input_public_route53_zone_id"></a> [public\_route53\_zone\_id](#input\_public\_route53\_zone\_id) | The public DNS zone to create a record and ACM cert validations | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnets | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | One or more tags. You can tag your Auto Scaling group and propagate the tags to -the Amazon EC2 instances it launches. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The public DNS name of the load balancer |
| <a name="output_ip_addresses"></a> [ip\_addresses](#output\_ip\_addresses) | One or more private IPv4 addresses associated with the controllers |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The unique identifier for the worker-auth key |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the controller security group |
<!-- END_TF_DOCS -->
