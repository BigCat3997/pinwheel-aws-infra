variable "tags" {
  description = "Common tags applied to the bucket"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Whether to create a new S3 bucket (true) or reference an existing bucket by name (false)"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "force_destroy" {
  description = "Allow deleting a non-empty bucket"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable default server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN or ID for SSE-KMS (null means SSE-S3)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable bucket keys for SSE-KMS cost optimization"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable S3 public access block settings"
  type        = bool
  default     = true
}

variable "enable_bucket_policy" {
  description = "Enable S3 bucket policy"
  type        = bool
  default     = false
}

variable "policy" {
  description = "JSON string containing the bucket policy document. Takes precedence over `bucket_policy_file`."
  type        = string
  default     = null
}

variable "policy_file" {
  description = "Path to a file containing the bucket policy JSON document. Used when `bucket_policy` is empty."
  type        = string
  default     = null
}
