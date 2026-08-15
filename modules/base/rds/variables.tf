variable "identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage (GiB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage (GiB)"
  type        = number
  default     = null
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Whether storage is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN or ID for storage encryption"
  type        = string
  default     = null
}

variable "primary_database_name" {
  description = "Primary database name created by RDS"
  type        = string
}

variable "secondary_database_name" {
  description = "Secondary database name created after RDS is available"
  type        = string
}

variable "master_username" {
  description = "Master username for MySQL"
  type        = string
}

variable "master_password" {
  description = "Master password for MySQL"
  type        = string
  sensitive   = true
  default     = null
}

variable "manage_master_user_password" {
  description = "Whether to let RDS manage master user password in Secrets Manager"
  type        = bool
  default     = false
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
  default     = null
}

variable "create_db_subnet_group" {
  description = "Whether to create an RDS DB subnet group"
  type        = bool
  default     = false
}

variable "db_subnet_group_subnet_ids" {
  description = "Subnet IDs for created DB subnet group"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_tags" {
  description = "Tags for created DB subnet group"
  type        = map(string)
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "VPC security groups attached to RDS"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Whether to deploy Multi-AZ"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the instance is publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on delete"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier (required when skip_final_snapshot is false)"
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply modifications immediately"
  type        = bool
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "parameter_group_name" {
  description = "Optional DB parameter group name"
  type        = string
  default     = null
}

variable "option_group_name" {
  description = "Optional DB option group name"
  type        = string
  default     = null
}

variable "ca_cert_identifier" {
  description = "Optional CA certificate identifier"
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "MySQL log types to publish to CloudWatch Logs"
  type        = list(string)
  default     = ["audit", "error", "general", "iam-db-auth-error", "slowquery"]
}

variable "cloudwatch_log_retention_in_days" {
  description = "Retention for created RDS CloudWatch log groups"
  type        = number
  default     = 14
}

variable "bootstrap_enabled" {
  description = "Whether to bootstrap the second database and optional dump import"
  type        = bool
  default     = true
}

variable "primary_database_dump_file" {
  description = "Optional local path to SQL dump file imported into primary database"
  type        = string
  default     = null
}

variable "bootstrap_force_run_token" {
  description = "Optional token to force bootstrap null_resource to re-run (change value to trigger)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags map"
  type        = map(string)
  default     = {}
}
