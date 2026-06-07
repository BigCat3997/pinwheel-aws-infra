output "table_id" {
  description = "DynamoDB table ID"
  value       = module.local_dynamodb_terraform_locks.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = module.local_dynamodb_terraform_locks.arn
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = module.local_dynamodb_terraform_locks.stream_arn
}
