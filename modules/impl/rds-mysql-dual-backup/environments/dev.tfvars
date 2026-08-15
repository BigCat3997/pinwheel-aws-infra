aws_region = "us-east-1"

tags = {
  Environment = "dev"
  Project     = "pinwheel"
  Managed_By  = "terraform"
}

vpc_name       = "bc-vpc-rds-dual-backup-dev-0"
vpc_cidr_block = "10.95.0.0/16"

private_subnets = [
  {
    name = "bc-subnet-rds-private-dev-0"
    cidr = "10.95.1.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-rds-private-dev-1"
    cidr = "10.95.2.0/24"
    az   = "us-east-1b"
  }
]

db_sg_name        = "bc-sg-rds-dual-backup-dev-0"
db_ingress_cidrs  = ["10.95.0.0/16"]
rds_identifier    = "bc-rds-mysql-dual-backup-dev-0"
db_name           = "app_db"
secondary_db_name = "app_db_aux"

master_username             = "admin"
manage_master_user_password = true

rds_instance_class = "db.t3.medium"
engine_version     = "8.0"

allocated_storage     = 50
max_allocated_storage = 100
storage_type          = "gp3"
storage_encrypted     = true

multi_az            = true
publicly_accessible = false

# First backup: RDS built-in automated backup at 00 UTC window
automated_backup_retention_days = 7
automated_backup_window         = "00:00-00:30"

# Second backup: AWS Backup at 12 UTC
create_aws_backup              = true
aws_backup_vault_name          = "bc-rds-dual-backup-vault-dev-0"
aws_backup_plan_name           = "bc-rds-dual-backup-plan-dev-0"
aws_backup_selection_name      = "bc-rds-dual-backup-selection-dev-0"
aws_backup_role_name           = "bc-role-rds-dual-backup-dev-0"
aws_backup_schedule_expression = "cron(0 12 * * ? *)"
aws_backup_start_window        = 60
aws_backup_completion_window   = 180
aws_backup_retention_days      = 30
