output "id" {
  description = "ID of the HTTP API"
  value       = aws_apigatewayv2_api.this.id
}

output "arn" {
  description = "ARN of the HTTP API"
  value       = aws_apigatewayv2_api.this.arn
}

output "execution_arn" {
  description = "Execution ARN of the HTTP API"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "api_endpoint" {
  description = "Default endpoint of the HTTP API"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "stage_invoke_urls" {
  description = "Invoke URL for each created stage, keyed by stage name"
  value       = { for name, stage in aws_apigatewayv2_stage.this : name => stage.invoke_url }
}
