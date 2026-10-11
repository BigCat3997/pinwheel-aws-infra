variable "name" {
  description = "CloudTrail trail name"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket that receives the trail logs"
  type        = string
}

variable "s3_key_prefix" {
  description = "Optional S3 key prefix for log files"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ARN used to encrypt log files (null means SSE-S3)"
  type        = string
  default     = null
}

variable "is_multi_region_trail" {
  description = "Whether the trail logs events from all regions"
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Whether to include global service events (IAM, STS, ...)"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Whether to enable log file integrity validation"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether the trail is actively logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
