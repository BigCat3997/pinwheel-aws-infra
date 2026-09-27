variable "name" {
  description = "Name of the HTTP API"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "API Gateway invocation ARN of the Lambda function backing every route (arn:aws:apigateway:<region>:lambda:path/2015-03-31/functions/<function_arn>/invocations)"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function backing every route, used to grant API Gateway invoke permission"
  type        = string
}

variable "payload_format_version" {
  description = "Payload format version for the Lambda proxy integration"
  type        = string
  default     = "2.0"
}

variable "routes" {
  description = "Routes to create, each targeting the shared Lambda integration"
  type = list(object({
    route_key = string
  }))
  default = [
    { route_key = "ANY /{proxy+}" },
    { route_key = "$default" },
  ]
}

variable "stages" {
  description = "Stages to create for the HTTP API"
  type = list(object({
    name        = string
    auto_deploy = optional(bool, true)
  }))
}

variable "enable_cors" {
  description = "Whether to attach a CORS configuration to the HTTP API"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS. Only used when enable_cors is true"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "Allowed HTTP methods for CORS. Only used when enable_cors is true"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_headers" {
  description = "Allowed headers for CORS. Only used when enable_cors is true"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
