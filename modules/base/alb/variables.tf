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
