output "id" {
  description = "ID of the Lambda function"
  value       = aws_lambda_function.this.id
}

output "name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "role_name" {
  description = "IAM role name used by the Lambda function"
  value       = var.create_role ? aws_iam_role.lambda[0].name : data.aws_iam_role.lambda[0].name
}

output "role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = var.create_role ? aws_iam_role.lambda[0].arn : data.aws_iam_role.lambda[0].arn
}

output "function_url" {
  description = "Public Lambda Function URL (only set when create_function_url = true)"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
}
