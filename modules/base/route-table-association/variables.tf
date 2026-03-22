variable "public_rt_subnet_associations" {
  description = "List of public route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
  }))
  default = []
}

variable "rt_subnet_associations" {
  description = "List of private route table to subnet associations"
  type = list(object({
    key     = string
    sn_name = string
    rt_name = string
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
