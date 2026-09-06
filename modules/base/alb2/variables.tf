variable "tags" {
  type    = map(string)
  default = {}
}

variable "name" {
  type = string
}

variable "enable_public" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type = set(string)
}

variable "security_group_ids" {
  type    = set(string)
  default = []
}

variable "vpc_id" {
  type = string
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "enable_logging" {
  type    = bool
  default = false
}

variable "cloudwatch_log_group_arn" {
  type        = string
  default     = null
  nullable    = true
  description = "ARN of an existing CloudWatch log group that receives ALB vended logs. Logging is disabled when null."

  validation {
    condition     = var.cloudwatch_log_group_arn == null || can(regex("^arn:[^:]+:logs:[^:]+:[0-9]{12}:log-group:.+", var.cloudwatch_log_group_arn))
    error_message = "cloudwatch_log_group_arn must be null or a valid CloudWatch log group ARN."
  }
}

variable "cloudwatch_log_types" {
  type        = set(string)
  default     = ["ALB_ACCESS_LOGS"]
  description = "ALB vended log types to deliver when cloudwatch_log_group_arn is set."

  validation {
    condition = length(var.cloudwatch_log_types) > 0 && alltrue([
      for log_type in var.cloudwatch_log_types : contains([
        "ALB_ACCESS_LOGS",
        "ALB_CONNECTION_LOGS",
        "ALB_HEALTH_CHECK_LOGS",
      ], log_type)
    ])
    error_message = "cloudwatch_log_types must contain one or more of ALB_ACCESS_LOGS, ALB_CONNECTION_LOGS, or ALB_HEALTH_CHECK_LOGS."
  }
}

variable "cloudwatch_log_output_format" {
  type        = string
  default     = "json"
  description = "Output format used for ALB logs delivered to CloudWatch Logs."

  validation {
    condition     = contains(["json", "plain", "raw"], var.cloudwatch_log_output_format)
    error_message = "cloudwatch_log_output_format must be json, plain, or raw."
  }
}

variable "target_groups" {
  type = map(object({
    port        = number
    protocol    = string
    target_type = optional(string, "instance")
    health_check = optional(object({
      enabled             = optional(bool, true)
      path                = optional(string, "/")
      protocol            = optional(string, "HTTP")
      matcher             = optional(string, "200")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
    }), null)
    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
    }), null)
    deregistration_delay = optional(number, 300)
    tags                 = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for tg in var.target_groups : contains(["HTTP", "HTTPS"], tg.protocol)
    ])
    error_message = "ALB target group protocol must be HTTP or HTTPS."
  }
}

variable "listeners" {
  type = map(object({
    port                = number
    protocol            = string
    ssl_policy          = optional(string)
    certificate_arn     = optional(string)
    target_group_name   = string
    default_action_type = optional(string, "forward")
  }))
  default = {}

  validation {
    condition = alltrue([
      for l in var.listeners : contains(["HTTP", "HTTPS"], l.protocol)
    ])
    error_message = "ALB listener protocol must be HTTP or HTTPS."
  }
}

variable "attachments" {
  type = list(object({
    target_group_name = string
    target_name       = string
    target_id         = string
    port              = optional(number)
  }))
  default = []
}
