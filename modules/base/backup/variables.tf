variable "create" {
  description = "Whether to create AWS Backup resources"
  type        = bool
  default     = true
}

variable "vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "selection_name" {
  description = "Name of the backup selection"
  type        = string
}

variable "role_name" {
  description = "IAM role name used by AWS Backup"
  type        = string
}

variable "instance_ids" {
  description = "EC2 instance IDs to include in backup"
  type        = list(string)
  default     = []
}

variable "schedule_expression" {
  description = "Backup schedule expression"
  type        = string
  default     = "cron(0 */4 * * ? *)"
}

variable "start_window" {
  description = "Start window in minutes"
  type        = number
  default     = 60
}

variable "completion_window" {
  description = "Completion window in minutes"
  type        = number
  default     = 180
}

variable "retention_days" {
  description = "Number of days to keep recovery points"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
