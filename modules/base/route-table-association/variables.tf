variable "public_rtb_assoc" {
  description = "Public route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "private_rtb_assoc" {
  description = "Private route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "public_subnet_ids" {
  description = "Map of public subnet names to IDs"
  type        = map(string)
}

variable "private_subnet_ids" {
  description = "Map of private subnet names to IDs"
  type        = map(string)
}

variable "public_route_table_ids" {
  description = "Map of public route table names to IDs"
  type        = map(string)
}

variable "private_route_table_ids" {
  description = "Map of private route table names to IDs"
  type        = map(string)
}
