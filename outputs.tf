output "boundary_url" {
  description = "The public URL the controller"
  value       = "https://boundary.${data.aws_route53_zone.public.name}"
}

output "s3command" {
  description = "The S3 cp command used to display the contents of the cloud-init-output.log"

  value = format(
    "aws s3 cp s3://%s/%s -",
    aws_s3_bucket.boundary.id,
    data.aws_s3_objects.cloudinit.keys[0]
  )
}
