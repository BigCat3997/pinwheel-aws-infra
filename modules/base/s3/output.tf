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
