variable "aws_region" {
  description = "AWS region for this deployment"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "Two private subnets in two different AZs"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "key_pair_ec2_name" {
  description = "Name of the EC2 key pair used by both app instances"
  type        = string
}

variable "sm_ec2_ssh_public_key_name" {
  description = "Name of the AWS Secrets Manager secret containing the SSH public key"
  type        = string
}

variable "sg_ec2_name" {
  description = "Name of the EC2 security group"
  type        = string
}

variable "sg_ec2_ssh_ingress_cidrs" {
  description = "CIDRs allowed to SSH to EC2 instances"
  type        = list(string)
  default     = []
}

variable "ec2_ami_id" {
  description = "AMI ID for both EC2 instances"
  type        = string
}

variable "ec2_instance_type" {
  description = "Instance type for both EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "ec2_primary_name" {
  description = "Name tag for primary EC2"
  type        = string
}

variable "ec2_primary_subnet_name" {
  description = "Private subnet name for primary EC2"
  type        = string
}

variable "ec2_standby_name" {
  description = "Name tag for standby EC2"
  type        = string
}

variable "ec2_standby_subnet_name" {
  description = "Private subnet name for standby EC2"
  type        = string
}

variable "initial_active_node" {
  description = "Initial active EC2 at deploy time: primary or standby"
  type        = string
  default     = "primary"

  validation {
    condition     = contains(["primary", "standby"], var.initial_active_node)
    error_message = "initial_active_node must be either 'primary' or 'standby'."
  }
}

variable "rds_mysql_identifier" {
  description = "RDS DB instance identifier"
  type        = string
}

variable "rds_mysql_name" {
  description = "Initial DB name"
  type        = string
}

variable "rds_mysql_secondary_name" {
  description = "Secondary DB name required by base rds module"
  type        = string
  default     = ""
}

variable "rds_mysql_engine" {
  description = "RDS engine. Use db2-ae or db2-se for Db2"
  type        = string
  default     = "db2-ae"
}

variable "rds_mysql_engine_version" {
  description = "RDS engine version"
  type        = string
}

variable "rds_mysql_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "rds_mysql_allocated_storage" {
  description = "RDS allocated storage in GiB"
  type        = number
  default     = 100
}

variable "rds_mysql_storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp3"
}

variable "rds_mysql_storage_encrypted" {
  description = "Whether RDS storage is encrypted"
  type        = bool
  default     = true
}

variable "rds_mysql_master_username" {
  description = "Master username for RDS"
  type        = string
}

variable "rds_mysql_manage_master_user_password" {
  description = "Whether to let RDS manage the master password in Secrets Manager"
  type        = bool
  default     = false
}

variable "rds_mysql_port" {
  description = "RDS port for DB2"
  type        = number
  default     = 50000
}

variable "rds_mysql_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "rds_mysql_backup_retention_period" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "rds_mysql_deletion_protection" {
  description = "Enable deletion protection on RDS"
  type        = bool
  default     = false
}

variable "rds_mysql_skip_final_snapshot" {
  description = "Skip final snapshot on destroy"
  type        = bool
  default     = true
}

variable "rds_mysql_apply_immediately" {
  description = "Apply DB changes immediately"
  type        = bool
  default     = true
}

variable "rds_mysql_cloudwatch_logs_exports" {
  description = "Log types to export to CloudWatch Logs (audit, error, general, slowquery for MySQL)"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

variable "rds_mysql_publicly_accessible" {
  description = "Whether RDS is publicly accessible"
  type        = bool
  default     = false
}

variable "lambda_function_name" {
  description = "Lambda function name for failover handler"
  type        = string
  default     = "rds-db2-ec2-failover-handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
  default     = "rds_db2_failover_handler.lambda_handler"
}

variable "lambda_timeout" {
  description = "Lambda timeout seconds"
  type        = number
  default     = 60
}
