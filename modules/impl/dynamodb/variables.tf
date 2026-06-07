
variable "table" {
  description = "Single DynamoDB table configuration"
  type = object({
    name                        = string
    billing_mode                = optional(string, "PAY_PER_REQUEST")
    hash_key                    = string
    range_key                   = optional(string, null)
    attributes                  = list(object({ name = string, type = string }))
    read_capacity               = optional(number, 5)
    write_capacity              = optional(number, 5)
    table_class                 = optional(string, "STANDARD")
    deletion_protection_enabled = optional(bool, false)

    stream_enabled                 = optional(bool, false)
    stream_view_type               = optional(string, "NEW_AND_OLD_IMAGES")
    server_side_encryption_enabled = optional(bool, true)
    kms_key_arn                    = optional(string, null)
    point_in_time_recovery_enabled = optional(bool, true)
    ttl_enabled                    = optional(bool, false)
    ttl_attribute_name             = optional(string, null)

    local_secondary_indexes = optional(list(object({
      name               = string
      range_key          = string
      projection_type    = string
      non_key_attributes = optional(list(string), [])
    })), [])

    global_secondary_indexes = optional(list(object({
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
    })), [])

    tags = optional(map(string), {})
  })
}

variable "s3_tf_state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "s3_force_destroy" {
  description = "Whether to force destroy the S3 bucket"
  type        = bool
  default     = false
}

variable "s3_enable_versioning" {
  description = "Whether to enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_enable_encryption" {
  description = "Whether to enable encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_enable_public_access" {
  description = "Whether to enable public access for the S3 bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all DynamoDB tables"
  type        = map(string)
  default     = {}
}
