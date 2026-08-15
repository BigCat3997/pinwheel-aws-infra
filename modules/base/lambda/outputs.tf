output "id" {
  description = "ID of the Lambda function"
  value       = aws_lambda_function.this.id
}

output "arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = var.role_arn
}

output "function_url" {
  description = "Public Lambda Function URL (only set when create_function_url = true)"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
}
