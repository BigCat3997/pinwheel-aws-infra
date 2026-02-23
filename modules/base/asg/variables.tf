variable "name" {
  type = string
}

variable "instance_name" {
  type        = string
  description = "Name tag applied to EC2 instances"
}

variable "subnet_ids" {
  type = list(string)
}

variable "launch_template_id" {
  type = string
}

variable "launch_template_version" {
  type    = string
  default = "$Latest"
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "health_check_type" {
  type    = string
  default = "EC2"
}

variable "health_check_grace_period" {
  type    = number
  default = 300
}

variable "wait_for_capacity_timeout" {
  description = "Maximum duration Terraform waits for ASG instances to become healthy. Set to '0' to skip."
  type        = string
  default     = "10m"
}

variable "tags" {
  type    = map(string)
  default = {}
}
