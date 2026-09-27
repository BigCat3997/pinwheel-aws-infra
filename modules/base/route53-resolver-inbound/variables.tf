variable "name" {
  description = "Name of the Route 53 Resolver inbound endpoint"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the endpoint network interfaces. They must allow TCP and UDP 53 from the querying networks."
  type        = list(string)
}

variable "ip_addresses" {
  description = "Endpoint IP addresses (at least two). Set ip to null to let AWS choose an address in the subnet."
  type = list(object({
    subnet_id = string
    ip        = optional(string)
  }))

  validation {
    condition     = length(var.ip_addresses) >= 2
    error_message = "A Route 53 Resolver inbound endpoint requires at least two IP addresses."
  }
}

variable "tags" {
  description = "Tags to apply to the endpoint"
  type        = map(string)
  default     = {}
}
