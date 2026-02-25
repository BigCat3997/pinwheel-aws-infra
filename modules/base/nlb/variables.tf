variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
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
  type = string
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
