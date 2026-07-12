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
  type = map(object({
    target_group_name = string
    target_id         = string
    port              = optional(number)
  }))
  default = {}
}
