aws_region = "us-east-1"

common_tags = {
  Environment = "dev"
  Project     = "co-located-ec2-rds"
  Version     = "1.0.0"
  Created_By  = "terraform"
  Managed_By  = "terraform"
  Deployed_By = "pipeline"
}

create_vpc     = true
vpc_name       = "bc-vpc-cer-dev-0"
vpc_cidr_block = "10.120.0.0/20"

private_subnets = [
  {
    name = "bc-subnet-cer-dev-0"
    cidr = "10.120.11.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-cer-dev-1"
    cidr = "10.120.12.0/24"
    az   = "us-east-1b"
  }
]

key_pair_ec2_name = "db2-failover-key"

sm_ec2_ssh_public_key_name = "ec2-rookie-dev-0-public-key"

sg_ec2_name              = "bc-sg-ec2_cer-dev-0"
sg_ec2_ssh_ingress_cidrs = []

ec2_ami_id              = "ami-0d8d3b1122e36c000"
ec2_instance_type       = "t3.medium"
initial_active_node     = "primary"
ec2_primary_name        = "bc-ec2-cer-dev-0"
ec2_primary_subnet_name = "bc-subnet-cer-dev-0"
ec2_standby_name        = "bc-ec2-cer-dev-1"
ec2_standby_subnet_name = "bc-subnet-cer-dev-1"

rds_mysql_identifier                  = "bc-db2-cer-dev-0"
rds_mysql_name                        = "APPDB"
rds_mysql_engine                      = "mysql"
rds_mysql_engine_version              = "8.0"
rds_mysql_instance_class              = "db.t3.medium"
rds_mysql_allocated_storage           = 50
rds_mysql_storage_type                = "gp3"
rds_mysql_storage_encrypted           = true
rds_mysql_master_username             = "admin"
rds_mysql_manage_master_user_password = true
rds_mysql_port                        = 3306
rds_mysql_multi_az                    = true
rds_mysql_backup_retention_period     = 35
rds_mysql_deletion_protection         = false
rds_mysql_skip_final_snapshot         = true
rds_mysql_apply_immediately           = true

lambda_function_name = "bc-lambda-cer-dev-0"
lambda_runtime       = "python3.12"
lambda_handler       = "main.lambda_handler"
lambda_timeout       = 900
