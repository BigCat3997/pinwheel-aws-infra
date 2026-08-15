output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.local_lambda_function.name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.local_lambda_function.arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = module.local_lambda_role.role_arn
}

output "function_url" {
  description = "Public Lambda Function URL"
  value       = module.local_lambda_function.function_url
}

output "curl_example" {
  description = "Example curl command to invoke the function"
  value       = "curl -X POST ${module.local_lambda_function.function_url} -H 'Content-Type: application/json' -d '{\"key\": \"value\"}'"
}
