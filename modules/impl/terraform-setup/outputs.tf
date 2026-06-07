output "table_id" {
  description = "DynamoDB table ID"
  value       = module.local_tf_locks_dynamodb_table.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = module.local_tf_locks_dynamodb_table.arn
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = module.local_tf_locks_dynamodb_table.stream_arn
}

output "bucket_id" {
  description = "S3 bucket ID"
  value       = module.local_tf_state_s3.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.local_tf_state_s3.arn
}
