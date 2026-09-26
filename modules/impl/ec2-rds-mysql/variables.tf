variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet definitions (minimum two AZs recommended for RDS)"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "db_sg_name" {
  description = "RDS security group name"
  type        = string
}

variable "db_ingress_cidrs" {
  description = "Allowed CIDR blocks for MySQL ingress"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "rds_identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "db_name" {
  description = "Primary database name"
  type        = string
  default     = "app_db"
}

variable "secondary_db_name" {
  description = "Secondary database name required by base rds module"
  type        = string
  default     = "app_db_aux"
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "admin"
}

variable "manage_master_user_password" {
  description = "Whether to let RDS manage master user password in Secrets Manager"
  type        = bool
  default     = false
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}

variable "allocated_storage" {
  description = "Allocated storage GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max autoscaled storage GiB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN or ID"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether RDS is publicly accessible"
  type        = bool
  default     = false
}

variable "automated_backup_retention_days" {
  description = "Retention days for RDS automated backups"
  type        = number
  default     = 7
}

variable "automated_backup_window" {
  description = "RDS automated backup window in UTC; set around 00:00 UTC"
  type        = string
  default     = "00:00-00:30"
}

variable "create_aws_backup" {
  description = "Whether to create AWS Backup resources for second backup"
  type        = bool
  default     = true
}

variable "aws_backup_vault_name" {
  description = "AWS Backup vault name"
  type        = string
  default     = "rds-mysql-dual-backup-vault"
}

variable "aws_backup_plan_name" {
  description = "AWS Backup plan name"
  type        = string
  default     = "rds-mysql-daily-12utc"
}

variable "aws_backup_selection_name" {
  description = "AWS Backup selection name"
  type        = string
  default     = "rds-mysql-selection"
}

variable "aws_backup_role_name" {
  description = "IAM role used by AWS Backup"
  type        = string
  default     = "rds-mysql-aws-backup-role"
}

variable "aws_backup_schedule_expression" {
  description = "AWS Backup cron schedule; set to 12:00 UTC"
  type        = string
  default     = "cron(0 12 * * ? *)"
}

variable "aws_backup_start_window" {
  description = "AWS Backup start window in minutes"
  type        = number
  default     = 60
}

variable "aws_backup_completion_window" {
  description = "AWS Backup completion window in minutes"
  type        = number
  default     = 180
}

variable "aws_backup_retention_days" {
  description = "AWS Backup recovery point retention days"
  type        = number
  default     = 30
}

variable "public_subnets" {
  description = "Public subnet definitions (hosts the bastion)"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "internet_gateway_name" {
  description = "Name tag for the internet gateway"
  type        = string
}

variable "public_route_tables" {
  description = "Public route tables"
  type = list(object({
    name = string
  }))
}

variable "public_rtb_subnet_assocs" {
  description = "Public route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "db_subnet_names" {
  description = "Names of the private subnets (from private_subnets) used by the RDS subnet group"
  type        = list(string)
}

variable "kms_key_name" {
  description = "Name for the KMS key used to encrypt the managed public-key secrets"
  type        = string
}

variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encrypting key pair secrets"
}

variable "ec2_ssh_user" {
  description = "Default SSH user of the EC2 AMIs"
  type        = string
  default     = "ec2-user"
}

variable "ec2_volume_size" {
  description = "Root volume size in GiB for the bastion and app instances"
  type        = number
  default     = 8
}

variable "ec2_volume_type" {
  description = "Root volume type for the bastion and app instances"
  type        = string
  default     = "gp3"
}

variable "ec2_volume_encrypted" {
  description = "Whether the root volumes of the bastion and app instances are encrypted"
  type        = bool
  default     = true
}

variable "bastion_sg_name" {
  description = "Bastion security group name"
  type        = string
}

variable "bastion_ssh_ingress_cidrs" {
  description = "CIDR blocks allowed to SSH to the bastion"
  type        = list(string)
}

variable "bastion_name" {
  description = "Bastion EC2 instance name"
  type        = string
}

variable "bastion_ami_id" {
  description = "Bastion AMI ID"
  type        = string
}

variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
}

variable "bastion_subnet_name" {
  description = "Name of the public subnet (from public_subnets) that hosts the bastion"
  type        = string
}

variable "bastion_create_key_pair" {
  description = "Whether to create the bastion EC2 key pair"
  type        = bool
  default     = true
}

variable "bastion_key_pair_name" {
  description = "Name of the key pair for the bastion EC2 instance"
  type        = string
}

variable "bastion_ec2_public_key_secret_name" {
  description = "Name of the existing Secrets Manager secret holding the bastion OpenSSH public key"
  type        = string
}

variable "app_sg_name" {
  description = "App security group name"
  type        = string
}

variable "app_name" {
  description = "App EC2 instance name"
  type        = string
}

variable "app_ami_id" {
  description = "App AMI ID"
  type        = string
}

variable "app_instance_type" {
  description = "App EC2 instance type"
  type        = string
}

variable "app_subnet_name" {
  description = "Name of the private subnet (from private_subnets) that hosts the app instance; keep it separate from db_subnet_names"
  type        = string
}

variable "app_create_key_pair" {
  description = "Whether to create the app EC2 key pair"
  type        = bool
  default     = true
}

variable "app_key_pair_name" {
  description = "Name of the key pair for the app EC2 instance"
  type        = string
}

variable "app_ec2_public_key_secret_name" {
  description = "Name of the existing Secrets Manager secret holding the app OpenSSH public key"
  type        = string
}
