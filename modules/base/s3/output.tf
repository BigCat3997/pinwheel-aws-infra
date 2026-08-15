output "id" {
  description = "Bucket name"
  value       = var.create ? aws_s3_bucket.this[0].id : data.aws_s3_bucket.this[0].id
}

output "arn" {
  description = "Bucket ARN"
  value       = var.create ? aws_s3_bucket.this[0].arn : data.aws_s3_bucket.this[0].arn
}

output "name" {
  description = "Bucket name"
  value       = var.create ? aws_s3_bucket.this[0].bucket : data.aws_s3_bucket.this[0].bucket
}

output "bucket_domain_name" {
  description = "Bucket domain name"
  value       = var.create ? aws_s3_bucket.this[0].bucket_domain_name : data.aws_s3_bucket.this[0].bucket_domain_name
}

output "website_endpoint" {
  description = "S3 website endpoint (only set when enable_website_configuration is true)"
  value       = var.enable_website_configuration ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}
