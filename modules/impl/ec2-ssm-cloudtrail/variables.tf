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

variable "public_subnets" {
  description = "Public subnet definitions"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = []
}

variable "internet_gateway_name" {
  description = "Internet gateway name"
  type        = string
}

variable "public_route_tables" {
  description = "Public route table definitions"
  type = list(object({
    name = string
  }))
  default = []
}

variable "public_rtb_assoc" {
  description = "Public subnet to route table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "bastion_mon_ec2_associate_public_ip" {
  description = "Whether to attach a public IP (the instance subnet must be public)"
  type        = bool
  default     = true
}

variable "private_subnets" {
  description = "Private subnet definitions"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_route_tables" {
  description = "Private route table definitions. Use nat_gw_name = null to keep subnets fully private."
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
}

variable "private_rtb_assoc" {
  description = "Private subnet to route table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
  }))
}

variable "endpoint_extra_subnet_names" {
  description = "Additional subnet names (beyond bastion_mon_ec2_subnet_name) to place SSM interface endpoints in"
  type        = list(string)
  default     = []
}

variable "bastion_mon_ec2_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "bastion_mon_ec2_ami_id" {
  description = "AMI ID. If null, the latest Amazon Linux 2023 AMI is resolved from SSM (it ships with the SSM agent)"
  type        = string
  default     = null
}

variable "bastion_mon_ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "bastion_mon_ec2_subnet_name" {
  description = "Subnet name for the EC2 instance (public when bastion_mon_ec2_associate_public_ip is true)"
  type        = string
}

variable "bastion_mon_ec2_volume_size" {
  description = "Root volume size (GiB)"
  type        = number
  default     = 20
}

variable "bastion_mon_ec2_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "bastion_mon_ec2_volume_encrypted" {
  description = "Whether the root volume is encrypted"
  type        = bool
  default     = true
}

variable "bastion_mon_ec2_volume_tags" {
  description = "Tags applied to the EC2 volumes"
  type        = map(string)
  default     = {}
}

variable "app_mon_ec2_name" {
  description = "Name of the RHEL EC2 instance"
  type        = string
}

variable "app_mon_ec2_subnet_name" {
  description = "Private subnet name for the RHEL EC2 (no public IP; reachable only from the Amazon Linux EC2)"
  type        = string
}

variable "app_mon_ec2_version" {
  description = "RHEL release used to look up the AMI when app_mon_ec2_ami_id is null"
  type        = string
  default     = "9.7"
}

variable "app_mon_ec2_ami_id" {
  description = "RHEL AMI ID. If null, the latest RHEL app_mon_ec2_version AMI is looked up"
  type        = string
  default     = null
}

variable "app_mon_ec2_instance_type" {
  description = "RHEL EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "bastion_mon_ec2_create_key_pair" {
  description = "Whether to create the key pair for the Amazon Linux EC2"
  type        = bool
  default     = true
}

variable "bastion_mon_ec2_key_pair_name" {
  description = "Key pair name for the Amazon Linux EC2"
  type        = string
}

variable "bastion_mon_ec2_public_key_secret_name" {
  description = "Secrets Manager secret name containing the SSH public key for the Amazon Linux EC2"
  type        = string
}

variable "app_mon_ec2_create_key_pair" {
  description = "Whether to create the key pair for the RHEL EC2"
  type        = bool
  default     = true
}

variable "app_mon_ec2_key_pair_name" {
  description = "Key pair name for the RHEL EC2"
  type        = string
}

variable "app_mon_ec2_public_key_secret_name" {
  description = "Secrets Manager secret name containing the SSH public key for the RHEL EC2"
  type        = string
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

variable "cloudtrail_name" {
  description = "CloudTrail trail name"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs (globally unique)"
  type        = string
}

variable "cloudtrail_bucket_force_destroy" {
  description = "Allow deleting the CloudTrail bucket when it is not empty"
  type        = bool
  default     = false
}

variable "cloudtrail_kms_key_name" {
  description = "Alias name for the KMS key encrypting CloudTrail logs"
  type        = string
}

variable "eventbridge_kms_key_name" {
  description = "Alias name for the KMS key encrypting EventBridge event buses"
  type        = string
}

variable "cloudtrail_is_multi_region" {
  description = "Whether the trail logs events from all regions"
  type        = bool
  default     = true
}

variable "log_generator_name" {
  description = "Name of the log generator Lambda (also used for its log group, role and schedule)"
  type        = string
  default     = "bc-lambda-log-generator-dev-0"
}

variable "log_generator_schedule" {
  description = "EventBridge schedule expression for the log generator"
  type        = string
  default     = "rate(1 minute)"
}

variable "log_generator_retention_days" {
  description = "Retention in days for the log generator log group"
  type        = number
  default     = 7
}

variable "nat_gateways" {
  description = "NAT gateways (placed in public subnets) that private route tables can point to"
  type = list(object({
    name        = string
    subnet_name = string
    eip_name    = string
  }))
  default = []
}

variable "sns_topic_name" {
  description = "Name of the SNS notifications topic"
  type        = string
  default     = "bc-sns-ec2_ssm-dev-0"
}

variable "sns_display_name" {
  description = "Display name (sender name) for email notifications"
  type        = string
  default     = "Pinwheel Alerts"
}

variable "sns_email_endpoints" {
  description = "Email addresses subscribed to the SNS topic"
  type        = list(string)
  default     = []
}
