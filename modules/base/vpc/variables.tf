variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "name" {
  description = "Name tag for VPC"
  type        = string
}

variable "internet_gateway_name" {
  description = "Name tag for Internet Gateway"
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

variable "nat_gateways" {
  description = "NAT Gateway configuration — each entry creates an EIP + NAT GW in the named public subnet"
  type = list(object({
    name        = string
    eip_name    = string
    subnet_name = string
  }))
  default = []
}

variable "public_route_tables" {
  description = "Public route tables — each manages its own subnets and routes to the internet gateway"
  type = list(object({
    name         = string
    subnet_names = list(string)
  }))
}

variable "private_route_tables" {
  description = "Private route tables — each manages its own subnets and optionally references a NAT gateway"
  type = list(object({
    name         = string
    nat_gw_name  = optional(string)
    subnet_names = list(string)
  }))
}
