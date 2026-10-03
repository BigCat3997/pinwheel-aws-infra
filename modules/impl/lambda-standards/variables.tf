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
  default     = "function-url-handler"
}

variable "lambda_handler" {
  description = "Lambda handler entry point (file.function)"
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

variable "lambda_env_vars" {
  description = "Environment variables passed to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_create_function_url" {
  description = "Whether to create a Lambda function URL"
  type        = bool
  default     = false
}
