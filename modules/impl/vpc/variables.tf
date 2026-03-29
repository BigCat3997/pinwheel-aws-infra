variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "create_vpc" {
  description = "Whether to create a new VPC (true) or use an existing VPC by name (false)"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = null
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

variable "public_route_tables" {
  description = "Public route tables"
  type = list(object({
    name = string
  }))
}

variable "private_route_tables" {
  description = "Private route tables"
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
}

variable "public_rtb_assoc" {
  description = "Public route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "private_rtb_assoc" {
  description = "Private route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "eips" {
  description = "Elastic IPs for NAT Gateways"
  type = list(object({
    name = string
  }))
  default = []
}

variable "nat_gateways" {
  description = "NAT Gateway configuration"
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "internet_gateway_name" {
  description = "Name tag for Internet Gateway"
  type        = string
  default     = null
}
