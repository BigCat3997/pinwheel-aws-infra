variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "create_vpc" {
  description = "Whether to create a new VPC (true) or use an existing VPC by name (false)"
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
  default     = null
}

variable "opt_ec2_tags" {
  description = "Optional additional tags to apply to EC2 instances"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "Public subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Private subnets configuration"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "eips" {
  description = "Elastic IPs for NAT Gateways"
  type = list(object({
    name = string
  }))
  default = []
}

variable "nat_gateways" {
  description = "NAT Gateway configuration"
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "internet_gateway_name" {
  description = "Name tag for Internet Gateway"
  type        = string
  default     = null
}

variable "public_route_tables" {
  description = "Public route tables"
  type = list(object({
    name = string
  }))
}

variable "private_route_tables" {
  description = "Private route tables"
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
}

variable "private_rtb_assoc" {
  description = "Private route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "public_rtb_assoc" {
  description = "Public route table to subnet associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "nsg_definitions" {
  description = "Security group definitions"
  type = list(object({
    name = string
    security_rules = list(object({
      from_port         = number
      to_port           = number
      protocol          = string
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      security_group_id = optional(string)
      description       = optional(string)
    }))
    egress_rules = list(
      object({
        from_port        = number
        to_port          = number
        protocol         = string
        cidr_blocks      = optional(list(string))
        ipv6_cidr_blocks = optional(list(string))
        description      = optional(string)
    }))
  }))
  default = []
}

variable "bastion_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the bastion EC2 instance"
  default     = true
}

variable "bastion_key_pair_name" {
  type        = string
  description = "Name of the key pair for the bastion EC2 instance"
}

variable "bastion_public_key_path" {
  type        = string
  description = "Path to the public key for the bastion EC2 instance"
}

variable "bastion_name" {
  type        = string
  description = "Bastion EC2 instance name"
}

variable "bastion_ami_id" {
  type        = string
  description = "Bastion AMI ID"
}

variable "bastion_instance_type" {
  type        = string
  description = "Bastion EC2 instance type"
}

variable "bastion_subnet_name" {
  type        = string
  description = "Public subnet name for bastion"
}

variable "bastion_private_ip" {
  type        = string
  description = "Fixed private IP for bastion EC2 (null to auto-pick deterministic value from subnet CIDR)"
  default     = null
}

variable "bastion_security_group_names" {
  type        = list(string)
  description = "Security group names for bastion"
  default     = []
}

variable "bastion_associate_public_ip" {
  type        = bool
  description = "Whether to associate a public IP with the bastion instance"
  default     = true
}

variable "bastion_ssh_user" {
  description = "Default SSH user for the bastion instance"
  type        = string
  default     = "ec2-user"
}

variable "bastion_user_data" {
  type        = string
  description = "User data for bastion instance"
  default     = null
}

variable "bastion_volume_size" {
  type        = number
  description = "Bastion volume size"
  default     = 8
}

variable "bastion_volume_type" {
  type        = string
  description = "Bastion volume type"
  default     = "gp3"
}

variable "bastion_volume_encrypted" {
  type        = bool
  description = "Whether the bastion volume is encrypted"
  default     = false
}

variable "bastion_volume_delete_on_termination" {
  type        = bool
  description = "Whether to delete bastion volume on termination"
  default     = true
}

variable "bastion_create_external_volume" {
  type        = bool
  description = "Whether to create an external volume for the bastion EC2 instance"
  default     = false
}

variable "app_ec2_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the EC2 instance"
  default     = true
}

variable "app_ec2_key_pair_name" {
  type        = string
  description = "Name of the key pair for the EC2 instance"
}

variable "app_ec2_name" {
  type        = string
  description = "EC2 instance name"
}

variable "app_ec2_ami_id" {
  type        = string
  description = "AMI ID"
}

variable "app_ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "app_ec2_subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "app_ec2_private_ip" {
  type        = string
  description = "Fixed private IP for app EC2 (null to auto-pick deterministic value from subnet CIDR)"
  default     = null
}

variable "app_ec2_security_group_names" {
  type    = list(string)
  default = []
}

variable "app_ec2_associate_public_ip" {
  type    = bool
  default = false
}

variable "app_ec2_ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "app_ec2_user_data" {
  type    = string
  default = null
}

variable "app_ec2_volume_size" {
  type = number
}

variable "app_ec2_volume_type" {
  type = string
}

variable "app_ec2_volume_encrypted" {
  type    = bool
  default = false
}

variable "app_ec2_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "create_lt_ec2_key_pair" {
  description = "Whether to create a new key pair for the launch template"
  type        = bool
  default     = true
}

variable "app_standby_ec2_create_key_pair" {
  type        = bool
  description = "Whether to create a new key pair for the EC2 instance"
  default     = true
}

variable "app_standby_ec2_key_pair_name" {
  type        = string
  description = "Name of the key pair for the EC2 instance"
}

variable "app_standby_ec2_name" {
  type        = string
  description = "EC2 instance name"
}

variable "app_standby_ec2_ami_id" {
  type        = string
  description = "AMI ID"
}

variable "app_standby_ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "app_standby_ec2_subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "app_standby_ec2_private_ip" {
  type        = string
  description = "Fixed private IP for standby app EC2 (null to auto-pick deterministic value from subnet CIDR)"
  default     = null
}

variable "app_standby_ec2_security_group_names" {
  type    = list(string)
  default = []
}

variable "app_standby_ec2_associate_public_ip" {
  type    = bool
  default = false
}

variable "app_standby_ec2_ssh_user" {
  description = "Default SSH user for the EC2 instance"
  type        = string
  default     = "ec2-user"
}

variable "app_standby_ec2_user_data" {
  type    = string
  default = null
}

variable "app_standby_ec2_volume_size" {
  type = number
}

variable "app_standby_ec2_volume_type" {
  type = string
}

variable "app_standby_ec2_volume_encrypted" {
  type    = bool
  default = false
}

variable "app_standby_ec2_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "nlb_name" {
  description = "Name for the Network Load Balancer"
  type        = string
}

variable "nlb_enable_public_access" {
  description = "Whether the NLB should be internet-facing (public) or internal. If true, NLB will be internet-facing; if false, NLB will be internal."
  type        = bool
  default     = false
}

variable "nlb_target_group_name" {
  description = "Name for the NLB target group"
  type        = string
  default     = "nlb-tg"
}

variable "nlb_target_port" {
  description = "Target port for NLB target group"
  type        = number
  default     = 8080
}

variable "nlb_target_protocol" {
  description = "Target protocol for NLB target group"
  type        = string
  default     = "TCP"
}

variable "nlb_target_type" {
  description = "Target type for NLB target group"
  type        = string
  default     = "instance"
}

variable "nlb_listener_port" {
  description = "Listener port for NLB"
  type        = number
  default     = 8080
}

variable "nlb_listener_protocol" {
  description = "Listener protocol for NLB"
  type        = string
  default     = "TCP"
}

variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
}

variable "alb_enable_public_access" {
  description = "Whether the ALB should be internet-facing (public) or internal. If true, ALB will be internet-facing; if false, ALB will be internal."
  type        = bool
  default     = false
}

variable "alb_target_group_name" {
  description = "Name for the ALB target group"
  type        = string
  default     = "alb-tg"
}

variable "alb_target_port" {
  description = "Target port for ALB target group"
  type        = number
  default     = 80
}

variable "alb_target_protocol" {
  description = "Target protocol for ALB target group"
  type        = string
  default     = "HTTP"
}

variable "alb_listener_port" {
  description = "Listener port for ALB"
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "Listener protocol for ALB"
  type        = string
  default     = "HTTP"
}

variable "kms_key_name" {
  description = "Name for the KMS key used to encrypt secrets"
  type        = string
}

variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encrypting key pair secrets"
}

variable "s3_create" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Application S3 bucket name"
  type        = string
}

variable "s3_force_destroy" {
  description = "Allow deleting non-empty S3 bucket"
  type        = bool
  default     = false
}

variable "s3_enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "s3_enable_encryption" {
  description = "Enable default S3 encryption"
  type        = bool
  default     = true
}

variable "s3_kms_key_id" {
  description = "KMS key ARN/ID for S3 encryption (null to use AES256)"
  type        = string
  default     = null
}

variable "s3_bucket_key_enabled" {
  description = "Enable S3 bucket key when using KMS"
  type        = bool
  default     = true
}

variable "s3_block_public_access" {
  description = "Enable S3 public access block"
  type        = bool
  default     = true
}

variable "efs_create" {
  description = "Whether to create EFS file systems"
  type        = bool
  default     = true
}

variable "efs_primary_name" {
  description = "Primary EFS file system name"
  type        = string
}

variable "efs_standby_name" {
  description = "Standby EFS file system name"
  type        = string
}

variable "efs_enable_encryption" {
  description = "Enable EFS encryption at rest"
  type        = bool
  default     = true
}

variable "efs_kms_key_id" {
  description = "KMS key ARN/ID for EFS encryption"
  type        = string
  default     = null
}

variable "efs_performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
}

variable "efs_provisioned_throughput_in_mibps" {
  description = "Provisioned throughput for EFS when throughput mode is provisioned"
  type        = number
  default     = null
}

variable "efs_transition_to_ia" {
  description = "Lifecycle transition for EFS, for example AFTER_30_DAYS"
  type        = string
  default     = null
}

variable "efs_backup_policy_status" {
  description = "EFS backup policy status, ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"
}

variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_subnet_names" {
  description = "Names of the subnets for the Lambda function"
  type        = list(string)
  default     = []
}

variable "lambda_security_group_names" {
  description = "Names of the security groups for the Lambda function"
  type        = list(string)
  default     = []
}

variable "lambda_source_file" {
  description = "Lambda source filename under `resources/lambda`"
  type        = string
}

variable "lambda_output_path" {
  description = "Lambda zip output filename under `resources/lambda`"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 7
}

variable "cloudwatch_logs_bucket_name" {
  description = "Dedicated S3 bucket name for permanent CloudWatch log archival"
  type        = string
  default     = null
}

variable "cloudwatch_logs_archive_prefix" {
  description = "S3 prefix used by the CloudWatch log archival Lambda"
  type        = string
  default     = "cloudwatch-logs/permanent"
}

variable "cloudwatch_logs_archive_lambda_function_name" {
  description = "Lambda function name for permanent CloudWatch log archival"
  type        = string
  default     = null
}

variable "cloudwatch_logs_archive_lambda_source_file" {
  description = "Lambda source filename under `resources/lambda` for log archival"
  type        = string
  default     = "cloudwatch_logs_collector.py"
}

variable "cloudwatch_logs_archive_lambda_output_path" {
  description = "Lambda zip output filename under `resources/lambda` for log archival"
  type        = string
  default     = "cloudwatch_logs_collector.zip"
}

variable "cloudwatch_logs_s3_archive_enabled" {
  description = "Whether to persist CloudWatch log groups to S3 through Kinesis Firehose"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_s3_prefix" {
  description = "S3 prefix for archived CloudWatch logs"
  type        = string
  default     = "cloudwatch-logs"
}

variable "cloudwatch_logs_firehose_name" {
  description = "Optional Firehose delivery stream name. When null, a name is derived from bastion_name."
  type        = string
  default     = null
}

variable "backup_create" {
  description = "Whether to create AWS Backup resources for EC2 instances"
  type        = bool
  default     = true
}

variable "backup_vault_name" {
  description = "Backup vault name"
  type        = string
  default     = "ec2-backup-vault"
}

variable "backup_plan_name" {
  description = "Backup plan name"
  type        = string
  default     = "ec2-backup-plan"
}

variable "backup_selection_name" {
  description = "Backup selection name"
  type        = string
  default     = "ec2-backup-selection"
}

variable "backup_role_name" {
  description = "IAM role name used by AWS Backup"
  type        = string
  default     = "ec2-backup-role"
}

variable "backup_schedule_expression" {
  description = "Backup schedule expression (default: every 4 hours)"
  type        = string
  default     = "cron(0 */4 * * ? *)"
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 30
}

variable "create_route53_record" {
  description = "Whether to create a Route 53 A record for the application endpoint"
  type        = bool
  default     = false
}

variable "route53_create_zone" {
  description = "Whether to create the Route 53 hosted zone when managing the record"
  type        = bool
  default     = false
}

variable "route53_zone_name" {
  description = "Hosted zone name, for example bigcat.com"
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Existing hosted zone ID to use instead of looking it up by name"
  type        = string
  default     = null
}

variable "route53_record_name" {
  description = "Record name inside the hosted zone. Use @ for the zone apex."
  type        = string
  default     = "@"
}

variable "route53_record_ip" {
  description = "Explicit IP address for the Route 53 A record. When null, the app EC2 private IP is used."
  type        = string
  default     = null
}

variable "route53_ttl" {
  description = "TTL in seconds for the Route 53 A record"
  type        = number
  default     = 300
}

variable "route53_private_zone" {
  description = "Whether the Route 53 hosted zone should be private and associated with the VPC"
  type        = bool
  default     = true
}

variable "route53_allow_overwrite" {
  description = "Allow Terraform to overwrite an existing Route 53 record with the same name and type"
  type        = bool
  default     = true
}
