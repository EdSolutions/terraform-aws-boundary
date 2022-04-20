## Contents

- [Usage](#usage)
- [Life cycle](#life-cycle)
- [Contributing](#contributing)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [License](#license)

**Note:** Like HashiCorp Boundary, this module is relatively new and may contain some issues. If you do experience an issue, please create a [new issue](https://github.com/jasonwalsh/terraform-aws-boundary/issues) in the repository. Pull requests are also welcome!

## Usage

This module uses Terraform to install [HashiCorp Boundary](https://www.boundaryproject.io/) in an Amazon Web Services (AWS) account.

This module uses the [official documentation](https://www.boundaryproject.io/docs/installing/high-availability) to install a highly available service.

![high-availability-service](https://www.boundaryproject.io/img/production.png)

This module creates the following resources:

- A virtual private cloud with all associated networking resources (e.g., public and private subnets, route tables, internet gateways, NAT gateways, etc)
- A PostgreSQL RDS instance used by the [Boundary controllers](https://www.boundaryproject.io/docs/installing/postgres)
- Two [AWS KMS](https://www.boundaryproject.io/docs/configuration/kms/awskms) keys, one for `root` and the other for `worker-auth`
- An application load balancer (ALB) that serves as a gateway to the Boundary UI/API
- Two auto scaling groups, one for controller instances and the other for worker instances

For more information on Boundary, please visit the [official documentation](https://www.boundaryproject.io/docs) or the [tutorials](https://learn.hashicorp.com/boundary) on HashiCorp Learn.

To use this module, the following environment variables are required:

| Name |
|------|
| `AWS_ACCESS_KEY_ID` |
| `AWS_SECRET_ACCESS_KEY` |
| `AWS_DEFAULT_REGION` |

After exporting the environment variables, simply run the following command:

```
$ terraform apply
```

## Life cycle

This module creates the controller instances *before* the worker instances. This implicit dependency ensures that the controller and worker instances share the same `worker-auth` KMS key.

The [controller](modules/controller) module also initializes the PostgreSQL database using the following command:

```
$ boundary database init -config /etc/boundary/configuration.hcl
```

After initializing the database, Boundary outputs information required to authenticate as defined [here](https://learn.hashicorp.com/tutorials/boundary/getting-started-dev?in=boundary/getting-started). Notably, the Auth Method ID, Login Name, and Password are generated.

Since initializing the database is a one-time operation, this module writes the output of the command to an S3 bucket so that the user always has access to this information.

In order to retrieve the information, you can invoke the following command:

```
$ $(terraform output s3command)
```

**Note:** The `$` before the `(` is required to run this command.

The result of running the command displays the contents of the [`cloud-init-output.log`](https://cloudinit.readthedocs.io/en/latest/topics/logging.html), which contains the output of the `boundary database init` command.

After you run this command, you can visit the Boundary UI using the `dns_name` output.

To authenticate to Boundary, you can reference [this](https://learn.hashicorp.com/tutorials/boundary/getting-started-connect?in=boundary/getting-started) guide.

**Note:** If you attempt to run the `authenticate` command and are met with this error `Error trying to perform authentication: dial tcp 127.0.0.1:9200: connect: connection refused`, you can export the `BOUNDARY_ADDR` environment variable to the value of the DNS name of the ALB. For example:

```
export BOUNDARY_ADDR="http://$(terraform output dns_name)"
```

## Contributing

As mentioned in the beginning of the README, this module is relatively new and may have issues. If you do discover an issue, please create a [new issue](https://github.com/jasonwalsh/terraform-aws-boundary/issues) or a [pull request](https://github.com/jasonwalsh/terraform-aws-boundary/pulls).

As always, thanks for using this module!

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.67 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.67 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_controllers"></a> [controllers](#module\_controllers) | ./modules/controller | n/a |
| <a name="module_workers"></a> [workers](#module\_workers) | ./modules/worker | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_string.boundary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_s3_objects.cloudinit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_objects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boundary_release"></a> [boundary\_release](#input\_boundary\_release) | The version of Boundary to install | `string` | `"0.7.6"` | no |
| <a name="input_controller_desired_capacity"></a> [controller\_desired\_capacity](#input\_controller\_desired\_capacity) | The capacity the controller Auto Scaling group attempts to maintain | `number` | `3` | no |
| <a name="input_controller_instance_type"></a> [controller\_instance\_type](#input\_controller\_instance\_type) | Specifies the instance type of the controller EC2 instance | `string` | `"t3.small"` | no |
| <a name="input_controller_max_size"></a> [controller\_max\_size](#input\_controller\_max\_size) | The maximum size of the controller group | `number` | `3` | no |
| <a name="input_controller_min_size"></a> [controller\_min\_size](#input\_controller\_min\_size) | The minimum size of the controller group | `number` | `3` | no |
| <a name="input_db_instance_subnet_group_name"></a> [db\_instance\_subnet\_group\_name](#input\_db\_instance\_subnet\_group\_name) | Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key pair | `string` | `null` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets | `list(string)` | `[]` | no |
| <a name="input_public_route53_zone_id"></a> [public\_route53\_zone\_id](#input\_public\_route53\_zone\_id) | The public DNS zone to create a record and ACM cert validations | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnets | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | One or more tags | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |
| <a name="input_worker_desired_capacity"></a> [worker\_desired\_capacity](#input\_worker\_desired\_capacity) | The capacity the worker Auto Scaling group attempts to maintain | `number` | `3` | no |
| <a name="input_worker_instance_type"></a> [worker\_instance\_type](#input\_worker\_instance\_type) | Specifies the instance type of the worker EC2 instance | `string` | `"t3.small"` | no |
| <a name="input_worker_max_size"></a> [worker\_max\_size](#input\_worker\_max\_size) | The maximum size of the worker group | `number` | `3` | no |
| <a name="input_worker_min_size"></a> [worker\_min\_size](#input\_worker\_min\_size) | The minimum size of the worker group | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_boundary_url"></a> [boundary\_url](#output\_boundary\_url) | The public URL the controller |
| <a name="output_s3command"></a> [s3command](#output\_s3command) | The S3 cp command used to display the contents of the cloud-init-output.log |
<!-- END_TF_DOCS -->

## License

[MIT License](LICENSE)
