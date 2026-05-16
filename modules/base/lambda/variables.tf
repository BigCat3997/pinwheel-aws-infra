variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 256
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "source_file" {
  description = "Path to the Lambda function source code"
  type        = string
}

variable "output_path" {
  description = "Path to output the zipped Lambda function code"
  type        = string
}

variable "create_role" {
  description = "Whether to create a new IAM role for the Lambda function. If false, an existing role ARN must be provided."
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Optional IAM role name for the Lambda function"
  type        = string
  default     = null
}

variable "role_arn" {
  description = "Existing IAM role ARN to attach to the Lambda function. If unset, the module creates a minimal execution role."
  type        = string
  default     = null
}

variable "compression_type" {
  description = "Compression type for the Lambda deployment package (e.g., zip, tar)"
  type        = string
  default     = "zip"
}

variable "create_function_url" {
  description = "Whether to create a public Lambda Function URL (authorization type NONE)"
  type        = bool
  default     = false
}
