variable "zone_name" {
  description = "Private hosted zone name, also used as the alias record name at the zone apex"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID the private hosted zone is created with"
  type        = string
}

variable "associated_vpc_ids" {
  description = "Additional VPCs to associate with the zone, keyed by a name known at plan time"
  type        = map(string)
  default     = {}
}

variable "alias_dns_name" {
  description = "DNS name the apex alias record points to, for example a VPC endpoint DNS name"
  type        = string
}

variable "alias_zone_id" {
  description = "Hosted zone ID of the alias target"
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether the alias record evaluates target health"
  type        = bool
  default     = true
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

variable "tags" {
  description = "Tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}
