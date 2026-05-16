variable "name" {
  type = string
}

variable "enable_public_access" {
  description = "Whether the ALB should be internet-facing (public) or internal. If true, ALB will be internet-facing; if false, ALB will be internal."
  type        = bool
  default     = false
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

variable "vpc_id" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "target_port" {
  type = number
}

variable "target_protocol" {
  type = string
}

variable "listener_port" {
  type = number
}

variable "listener_protocol" {
  type = string
}

variable "autoscaling_group_name" {
  type    = string
  default = null
}

variable "target_instance_ids" {
  description = "List of standalone EC2 instance IDs to register into the ALB target group"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "maintenance_mode" {
  description = "When true, the ALB listener forwards to the lambda maintenance target group instead of the web target group"
  type        = bool
  default     = false
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to register as maintenance target. If set, creates a lambda target group, ALB permission, and target group attachment."
  type        = string
  default     = null
}

variable "lambda_function_name" {
  description = "Name of the Lambda function (required when lambda_function_arn is set)"
  type        = string
  default     = null
}

variable "lambda_target_group_name" {
  description = "Name for the lambda maintenance target group (required when lambda_function_arn is set)"
  type        = string
  default     = null
}

variable "health_check_enabled" {
  type    = bool
  default = true
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}

variable "health_check_matcher" {
  description = "HTTP status codes considered healthy (e.g. \"200\" or \"200-399\")"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_timeout" {
  type    = number
  default = 5
}

variable "health_check_healthy_threshold" {
  type    = number
  default = 3
}

variable "health_check_unhealthy_threshold" {
  type    = number
  default = 3
}
