variable "vpc_id" {
  description = "VPC ID for route tables"
  type        = string
}

variable "public_route_tables" {
  description = "List of public route table objects"
  type = list(object({
    name = string
  }))
  default = []
}

variable "private_route_tables" {
  description = "List of private route table objects"
  type = list(object({
    name        = string
    nat_gw_name = string
  }))
  default = []
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
  default     = null
}

variable "nat_gateway_ids" {
  description = "Map of NAT gateway names to IDs"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
