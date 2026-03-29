variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "name" {
  description = "Name tag for the NAT gateway"
  type        = string
}

variable "eip_id" {
  type        = string
  description = "EIP ID for the NAT gateway"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the NAT gateway"
}
