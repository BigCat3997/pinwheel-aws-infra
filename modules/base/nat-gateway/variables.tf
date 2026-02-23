variable "nat_gateways" {
  description = "List of NAT gateway objects"
  type        = list(object({
    name     = string
    subnet_name = string
    eip_name = string
  }))
}

variable "public_subnet_ids" {
  description = "Map of public subnet names to IDs"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
