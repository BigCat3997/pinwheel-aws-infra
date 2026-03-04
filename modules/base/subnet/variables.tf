variable "vpc_id" {
  description = "VPC ID for the subnets"
  type        = string
}

variable "create" {
  description = "Whether to create new subnets (true) or use existing ones via data source (false)"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "Public subnets configuration. When create_subnets=true, requires name/cidr/az. When create_subnets=false, only name is used for lookup."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "private_subnets" {
  description = "Private subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
