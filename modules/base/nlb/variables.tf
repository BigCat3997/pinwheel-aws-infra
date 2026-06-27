variable "name" {
  type = string
}

variable "subnet_mappings" {
  type = list(object({
    subnet_id            = string
    private_ipv4_address = optional(string)
    allocation_id        = optional(string)
  }))
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "vpc_id" {
  type = string
}

variable "enable_stickiness" {
  type    = bool
  default = false
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

variable "target_type" {
  type    = string
  default = "instance"
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
  description = "List of EC2 instance IDs to attach to the NLB target group"
  type        = list(string)
  default     = []
}

variable "target_ips" {
  description = "List of IP addresses to attach to the NLB target group when target_type is ip"
  type        = list(string)
  default     = []
}

variable "enable_public_access" {
  description = "Whether to create an internet-facing NLB (true) or an internal NLB (false)"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
