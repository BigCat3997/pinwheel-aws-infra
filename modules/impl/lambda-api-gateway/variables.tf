variable "aws_region" {
  description = "AWS region for this deployment"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "http-api-handler"
}

variable "lambda_handler" {
  description = "Lambda handler entry point"
  type        = string
  default     = "index.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory allocation in MB"
  type        = number
  default     = 256
}

variable "api_gateway_name" {
  description = "Name for the API Gateway HTTP API"
  type        = string
  default     = "http-api"
}

variable "api_gateway_cors_allowed_origins" {
  description = "CORS allowed origins for API Gateway"
  type        = list(string)
  default     = ["*"]
}

variable "api_gateway_cors_allowed_methods" {
  description = "CORS allowed methods for API Gateway"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "api_gateway_cors_allowed_headers" {
  description = "CORS allowed headers for API Gateway"
  type        = list(string)
  default     = ["Content-Type", "Authorization"]
}

variable "api_gateway_stages" {
  description = "API Gateway stages to create"
  type = list(object({
    name        = string
    auto_deploy = optional(bool, true)
  }))
  default = [
    { name = "dev", auto_deploy = true }
  ]
}
