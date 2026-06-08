variable "tf_locks_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "terraform-locks"
}

variable "tf_locks_table_billing_mode" {
  description = "Billing mode for the table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "tf_locks_table_hash_key" {
  description = "Partition key attribute name"
  type        = string
  default     = "LockID"
}

variable "tf_locks_table_range_key" {
  description = "Sort key attribute name"
  type        = string
  default     = null
}

variable "tf_locks_table_attributes" {
  description = "Attribute definitions for table and index keys"
  type = list(object({
    name = string
    type = string
  }))
  default = [{ name = "LockID", type = "S" }]
}

variable "tf_locks_table_read_capacity" {
  description = "Read capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "tf_locks_table_write_capacity" {
  description = "Write capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "tf_locks_table_class" {
  description = "Storage class of the table (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"
}

variable "tf_locks_table_deletion_protection_enabled" {
  description = "Enable deletion protection for the table"
  type        = bool
  default     = false
}

variable "tf_locks_table_stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "tf_locks_table_stream_view_type" {
  description = "When stream_enabled is true, stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "tf_locks_table_server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "tf_locks_table_kms_key_arn" {
  description = "KMS key ARN for table encryption (null uses AWS owned key)"
  type        = string
  default     = null
}

variable "tf_locks_table_point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "tf_locks_table_ttl_enabled" {
  description = "Enable TTL for the table"
  type        = bool
  default     = false
}

variable "tf_locks_table_ttl_attribute_name" {
  description = "TTL attribute name (required when ttl_enabled is true)"
  type        = string
  default     = null
}

variable "tf_locks_table_local_secondary_indexes" {
  description = "Local secondary index definitions"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "tf_locks_table_global_secondary_indexes" {
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
}

variable "tf_locks_table_tags" {
  description = "Tags applied specifically to the DynamoDB table"
  type        = map(string)
  default     = {}
}

variable "tf_state_s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "tf_state_s3_force_destroy" {
  description = "Whether to force destroy the S3 bucket"
  type        = bool
  default     = false
}

variable "tf_state_s3_enable_versioning" {
  description = "Whether to enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "tf_state_s3_enable_encryption" {
  description = "Whether to enable encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "tf_state_s3_enable_public_access" {
  description = "Whether to enable public access for the S3 bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all DynamoDB tables"
  type        = map(string)
  default     = {}
}
