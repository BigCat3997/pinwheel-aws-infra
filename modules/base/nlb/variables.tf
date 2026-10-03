variable "tags" {
  type    = map(string)
  default = {}
}

variable "name" {
  type = string
}

variable "type" {
  type    = string
  default = "network"
}

variable "enable_public" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type    = set(string)
  default = []
}

variable "subnet_mappings" {
  type = set(object({
    subnet_id            = string
    private_ipv4_address = optional(string, null)
    eip_id               = optional(string, null)
  }))
  default = []
}

variable "security_group_ids" {
  type    = set(string)
  default = []
}

variable "listeners" {
  description = "NLB listeners"

  type = list(object({
    port              = number
    protocol          = string
    target_group_name = string
    type              = optional(string, "forward")
    # Required only when protocol = TLS
    certificate_arn = optional(string)
    # Optional TLS policy
    ssl_policy = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for listener in var.listeners :
      contains(
        ["TCP", "TLS", "UDP", "TCP_UDP"],
        listener.protocol
      )
    ])

    error_message = "NLB listener protocol must be TCP, TLS, UDP, or TCP_UDP."
  }
}

variable "target_groups" {
  description = "NLB target groups"
  type = map(object({
    port        = number
    protocol    = string
    vpc_id      = string
    target_type = optional(string, "instance")
    health_check = optional(object({
      enabled             = optional(bool, true)
      protocol            = optional(string, "TCP")
      port                = optional(string, "traffic-port")
      path                = optional(string)
      interval            = optional(number, 30)
      timeout             = optional(number, 10)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string)
    }), null)
    stickiness = optional(object({
      enabled = optional(bool, true)
      type    = optional(string, "source_ip")
    }), null)
    deregistration_delay = optional(number, 300)
    cross_zone_enabled   = optional(bool, true)
    tags                 = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for tg in var.target_groups :
      contains(
        ["TCP", "TLS", "UDP", "TCP_UDP"
        ],
        tg.protocol
      )
    ])
    error_message = "Target group protocol must be TCP, TLS, UDP, or TCP_UDP."
  }
}

variable "attachments" {
  description = "NLB target group attachments"

  type = list(object({
    target_group_name = string
    target_name       = string
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))

  default = []
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "enable_logging" {
  description = "Whether to deliver NLB access logs to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of an existing CloudWatch log group that receives NLB vended logs."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.cloudwatch_log_group_arn == null || can(regex("^arn:[^:]+:logs:[^:]+:[0-9]{12}:log-group:.+", var.cloudwatch_log_group_arn))
    error_message = "cloudwatch_log_group_arn must be null or a valid CloudWatch log group ARN."
  }
}

variable "cloudwatch_log_types" {
  description = "NLB vended log types to deliver when logging is enabled."
  type        = set(string)
  default     = ["NLB_ACCESS_LOGS"]

  validation {
    condition = length(var.cloudwatch_log_types) > 0 && alltrue([
      for log_type in var.cloudwatch_log_types : log_type == "NLB_ACCESS_LOGS"
    ])
    error_message = "cloudwatch_log_types must contain NLB_ACCESS_LOGS."
  }
}

variable "cloudwatch_log_output_format" {
  description = "Output format used for NLB logs delivered to CloudWatch Logs."
  type        = string
  default     = "json"

  validation {
    condition     = contains(["json", "plain", "raw"], var.cloudwatch_log_output_format)
    error_message = "cloudwatch_log_output_format must be json, plain, or raw."
  }
}
