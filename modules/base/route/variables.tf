variable "route_table_ids" {
  description = "Map of route table names to IDs that receive the route"
  type        = map(string)
}

variable "destination_cidr_block" {
  description = "Destination CIDR block of the route"
  type        = string
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID target"
  type        = string
  default     = null
}

variable "gateway_id" {
  description = "Internet gateway or virtual private gateway ID target"
  type        = string
  default     = null
}

variable "nat_gateway_id" {
  description = "NAT gateway ID target"
  type        = string
  default     = null
}
