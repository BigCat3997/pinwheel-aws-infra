variable "create" {
  description = "Whether to create EFS resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "EFS name"
  type        = string
}

variable "enable_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN or ID for EFS encryption"
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "Provisioned throughput when throughput_mode is provisioned"
  type        = number
  default     = null
}

variable "transition_to_ia" {
  description = "Lifecycle policy transition to IA, for example AFTER_30_DAYS"
  type        = string
  default     = null
}

variable "enable_mount" {
  description = "Whether to create mount targets in provided subnets"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnet IDs for EFS mount targets"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups for EFS mount targets"
  type        = list(string)
  default     = []
}

variable "backup_policy_status" {
  description = "Backup policy status, ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"
}

variable "tags" {
  description = "Common tags applied to EFS resources"
  type        = map(string)
  default     = {}
}
