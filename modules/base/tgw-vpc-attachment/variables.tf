variable "name" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "dns_support" {
  type    = string
  default = "enable"
}

variable "ipv6_support" {
  type    = string
  default = "disable"
}

variable "tags" {
  type    = map(string)
  default = {}
}
