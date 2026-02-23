variable "nat_gateways" {
  description = "List of NAT gateway objects"
  type        = list(object({
    name     = string
    eip_name = string
    subnet_name = string
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
