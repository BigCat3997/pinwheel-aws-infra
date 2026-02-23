variable "tgw_vpc_attachment_subnet_names" {
  description = "List of private subnet names to attach to TGW"
  type        = list(string)
}

variable "tgw_name" {
  description = "Name for the Transit Gateway"
  type        = string
}

variable "tgw_description" {
  description = "Description for the Transit Gateway"
  type        = string
  default     = null
}

variable "tgw_amazon_side_asn" {
  description = "Amazon side ASN for the Transit Gateway"
  type        = number
  default     = 64512
}

variable "tgw_auto_accept_shared_attachments" {
  description = "Auto accept shared attachments for TGW"
  type        = string
  default     = "disable"
}

variable "tgw_default_route_table_association" {
  description = "Default route table association for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_default_route_table_propagation" {
  description = "Default route table propagation for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_dns_support" {
  description = "DNS support for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_vpn_ecmp_support" {
  description = "VPN ECMP support for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_vpc_attachment_name" {
  description = "Name for the TGW VPC Attachment"
  type        = string
}

variable "tgw_vpc_attachment_dns_support" {
  description = "DNS support for TGW VPC Attachment"
  type        = string
  default     = "enable"
}

variable "tgw_vpc_attachment_ipv6_support" {
  description = "IPv6 support for TGW VPC Attachment"
  type        = string
  default     = "disable"
}
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "name" {
  description = "Name tag for VPC"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
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
  description = "NAT Gateway configuration"
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
}

variable "internet_gateway_name" {
  description = "Name tag for Internet Gateway"
  type        = string
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
    nat_gw_name = string
  }))
}

variable "public_rt_subnet_associations" {
  description = "Public route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
}

variable "rt_subnet_associations" {
  description = "Private route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
}
