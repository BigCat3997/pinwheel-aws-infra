variable "vpc_id" {
  description = "VPC ID for route tables"
  type        = string
}

variable "public_route_tables" {
  description = "List of public route table objects"
  type = list(object({
    name = string
  }))
}

variable "private_route_tables" {
  description = "List of private route table objects"
  type = list(object({
    name        = string
    nat_gw_name = string
  }))
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "nat_gateway_ids" {
  description = "Map of NAT gateway names to IDs"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
