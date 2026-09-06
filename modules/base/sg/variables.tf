variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group is created"
  type        = string
}

variable "security_rules" {
  description = "Ingress security rules"
  type = list(object({
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = optional(list(string))
    ipv6_cidr_blocks  = optional(list(string))
    security_group_id = optional(string)
    self              = optional(bool)
    description       = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "Egress security rules"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    description      = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Common tags applied to the security group"
  type        = map(string)
  default     = {}
}
