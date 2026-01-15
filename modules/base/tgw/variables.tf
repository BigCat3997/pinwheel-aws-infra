variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "amazon_side_asn" {
  type    = number
  default = 64512
}

variable "auto_accept_shared_attachments" {
  type    = string
  default = "disable"
}

variable "default_route_table_association" {
  type    = string
  default = "enable"
}

variable "default_route_table_propagation" {
  type    = string
  default = "enable"
}

variable "dns_support" {
  type    = string
  default = "enable"
}

variable "vpn_ecmp_support" {
  type    = string
  default = "enable"
}

variable "tags" {
  type    = map(string)
  default = {}
}
