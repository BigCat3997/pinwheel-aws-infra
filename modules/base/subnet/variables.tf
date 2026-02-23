variable "vpc_id" {
  description = "VPC ID for the subnets"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
