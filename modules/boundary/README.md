<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.67 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | 6.3.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_after_start"></a> [after\_start](#input\_after\_start) | Run arbitrary commands after starting the Boundary service | `list(string)` | `[]` | no |
| <a name="input_auto_scaling_group_name"></a> [auto\_scaling\_group\_name](#input\_auto\_scaling\_group\_name) | The name of the Auto Scaling group | `string` | n/a | yes |
| <a name="input_before_start"></a> [before\_start](#input\_before\_start) | Run arbitrary commands before starting the Boundary service | `list(string)` | `[]` | no |
| <a name="input_boundary_release"></a> [boundary\_release](#input\_boundary\_release) | The version of Boundary to install | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket to upload the contents of the<br>cloud-init-output.log file | `string` | n/a | yes |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The desired capacity is the initial capacity of the Auto Scaling group<br>at the time of its creation and the capacity it attempts to maintain. | `number` | `0` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The name or the Amazon Resource Name (ARN) of the instance profile associated<br>with the IAM role for the instance | `string` | `""` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The ID of the Amazon Machine Image (AMI) that was assigned during registration | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Specifies the instance type of the EC2 instance | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key pair | `string` | `""` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the group | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the group | `number` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list that contains the security groups to assign to the instances in the Auto<br>Scaling group | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | One or more tags. You can tag your Auto Scaling group and propagate the tags to<br>the Amazon EC2 instances it launches. | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | The Amazon Resource Names (ARN) of the target groups to associate with the Auto<br>Scaling group | `list(string)` | `[]` | no |
| <a name="input_vpc_zone_identifier"></a> [vpc\_zone\_identifier](#input\_vpc\_zone\_identifier) | A comma-separated list of subnet IDs for your virtual private cloud | `list(string)` | n/a | yes |
| <a name="input_write_files"></a> [write\_files](#input\_write\_files) | Write out arbitrary content to files, optionally setting permissions | <pre>list(object({<br>    content     = string<br>    owner       = string<br>    path        = string<br>    permissions = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_scaling_group_name"></a> [auto\_scaling\_group\_name](#output\_auto\_scaling\_group\_name) | The name of the controller Auto Scaling group |
<!-- END_TF_DOCS -->
