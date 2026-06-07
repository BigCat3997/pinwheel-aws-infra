output "id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "DynamoDB stream label"
  value       = aws_dynamodb_table.this.stream_label
}
