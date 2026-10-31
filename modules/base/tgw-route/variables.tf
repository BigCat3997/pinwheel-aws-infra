variable "destination_cidr_block" {
  description = "Destination CIDR block of the Transit Gateway route"
  type        = string
}

variable "transit_gateway_route_table_id" {
  description = "Transit Gateway route table that receives the route"
  type        = string
}

variable "transit_gateway_attachment_id" {
  description = "Attachment the route sends traffic to. Leave null for a blackhole route."
  type        = string
  default     = null
}

variable "blackhole" {
  description = "Whether to drop traffic matching the route"
  type        = bool
  default     = false
}
