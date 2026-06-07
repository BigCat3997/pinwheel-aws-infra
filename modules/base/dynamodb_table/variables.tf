variable "tags" {
  description = "Tags map"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
}

variable "range_key" {
  description = "Sort key attribute name"
  type        = string
  default     = null
}

variable "attributes" {
  description = "Attribute definitions for table and index keys"
  type = list(object({
    name = string
    type = string
  }))
}

variable "read_capacity" {
  description = "Read capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "table_class" {
  description = "Storage class of the table (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection for the table"
  type        = bool
  default     = false
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When stream_enabled is true, stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for table encryption (null uses AWS owned key)"
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "ttl_enabled" {
  description = "Enable TTL for the table"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "TTL attribute name (required when ttl_enabled is true)"
  type        = string
  default     = null
}

variable "local_secondary_indexes" {
  description = "Local secondary index definitions"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = "Global secondary index definitions. Prefer key_schema; hash_key/range_key are kept for compatibility."
  type = list(object({
    name      = string
    hash_key  = optional(string)
    range_key = optional(string)
    key_schema = optional(list(object({
      attribute_name = string
      key_type       = string
    })), [])
    projection_type    = string
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []

  validation {
    condition     = alltrue([for gsi in var.global_secondary_indexes : length(gsi.key_schema) > 0 || gsi.hash_key != null])
    error_message = "Each global_secondary_indexes item must set either key_schema or hash_key."
  }
}
