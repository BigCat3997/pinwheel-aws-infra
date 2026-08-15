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

variable "vpc_id" {
  type = string
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

variable "target_groups_attachments" {
  type = list(object({
    target_group_name  = string
    target_port        = number
    target_type        = optional(string, "instance")
    target_ip          = optional(string, null)
    target_instance_id = optional(string, null)
  }))
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
