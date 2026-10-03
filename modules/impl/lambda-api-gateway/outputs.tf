output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function.name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_function.arn
}

output "api_gateway_id" {
  description = "API Gateway HTTP API ID"
  value       = module.http_api.id
}

output "api_gateway_endpoint" {
  description = "API Gateway HTTP API endpoint URL"
  value       = "${module.http_api.api_endpoint}/{stage}"
}

output "api_gateway_dev_endpoint" {
  description = "API Gateway HTTP API dev stage endpoint URL"
  value       = "${module.http_api.api_endpoint}/dev"
}

output "curl_echo_example" {
  description = "Example curl command to test echo action"
  value       = "curl -X POST ${module.http_api.api_endpoint}/dev -H 'Content-Type: application/json' -d '{\"action\": \"echo\", \"data\": {\"test\": \"value\"}}'"
}

output "curl_greet_example" {
  description = "Example curl command to test greet action"
  value       = "curl -X POST ${module.http_api.api_endpoint}/dev -H 'Content-Type: application/json' -d '{\"action\": \"greet\", \"data\": {\"name\": \"Alice\"}}'"
}

output "curl_timestamp_example" {
  description = "Example curl command to test timestamp action"
  value       = "curl -X POST ${module.http_api.api_endpoint}/dev -H 'Content-Type: application/json' -d '{\"action\": \"timestamp\"}'"
}
