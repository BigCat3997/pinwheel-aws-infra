variable "zone_name" {
  description = "Route 53 hosted zone name, for example bigcat.com"
  type        = string
}

variable "record_name" {
  description = "Record name inside the zone. Use @ or an empty string for the zone apex."
  type        = string
  default     = "@"
}

variable "ip_address" {
  description = "IPv4 address for the A record"
  type        = string

  validation {
    condition     = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\\.|$)){4}$", var.ip_address))
    error_message = "ip_address must be a valid IPv4 address."
  }
}

variable "ttl" {
  description = "TTL for the A record in seconds"
  type        = number
  default     = 300
}

variable "create_zone" {
  description = "Whether to create the hosted zone in Route 53"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "Existing hosted zone ID to use when create_zone is false"
  type        = string
  default     = null
}

variable "private_zone" {
  description = "Whether the hosted zone is private and attached to a VPC"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for a private hosted zone"
  type        = string
  default     = null

  #   validation {
  #     condition     = !(var.create_zone && var.private_zone && var.vpc_id == null)
  #     error_message = "vpc_id must be provided when create_zone = true and private_zone = true."
  #   }
}

variable "vpc_region" {
  description = "AWS region for the VPC association when creating a private hosted zone"
  type        = string
  default     = null
}

variable "zone_comment" {
  description = "Optional comment for the hosted zone"
  type        = string
  default     = "Managed by Terraform"
}

variable "force_destroy" {
  description = "Allow destroying the hosted zone even if it still contains records"
  type        = bool
  default     = false
}

variable "allow_overwrite" {
  description = "Allow Terraform to overwrite an existing Route 53 record with the same name and type"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}
