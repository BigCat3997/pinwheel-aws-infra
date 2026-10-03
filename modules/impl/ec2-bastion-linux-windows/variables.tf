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

variable "bastion_volume_tags" {
  description = "Tags applied to bastion EC2 volumes"
  type        = map(string)
  default     = {}
}

variable "private_ec2_volume_tags" {
  description = "Tags applied to private EC2 volumes"
  type        = map(string)
  default     = {}
}

variable "private_ec2_secondary_volume_tags" {
  description = "Tags applied to the second private EC2 volumes"
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
}

variable "private_subnets" {
  description = "Private subnet definitions"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "internet_gateway_name" {
  description = "Internet gateway name"
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway for private subnet outbound internet access"
  type        = bool
  default     = true
}

variable "nat_gateway_name" {
  description = "Name tag for NAT gateway"
  type        = string
  default     = "private-nat-gw"
}

variable "nat_gateway_public_subnet_name" {
  description = "Public subnet name to host NAT gateway. If null, use bastion_subnet_name"
  type        = string
  default     = null
}

variable "public_route_tables" {
  description = "Public route table definitions"
  type = list(object({
    name = string
  }))
}

variable "private_route_tables" {
  description = "Private route table definitions. Use nat_gw_name = null to keep private subnets fully private."
  type = list(object({
    name        = string
    nat_gw_name = optional(string)
  }))
}

variable "public_rtb_assoc" {
  description = "Public subnet to route table associations"
  type = list(object({
    key              = string
    subnet_name      = string
    route_table_name = string
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

variable "ssh_public_key_path" {
  description = "Path to your current SSH public key. This single key pair is reused by bastion and private EC2."
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to your SSH private key used to connect to Linux bastion and private EC2"
  type        = string
  default     = "~/.ssh/development-server"
}

variable "shared_key_pair_name" {
  description = "Name of the shared EC2 key pair for Linux instances"
  type        = string
}

variable "bastion_create_key_pair" {
  description = "Whether to create the Linux bastion EC2 key pair"
  type        = bool
  default     = true
}

variable "bastion_ec2_public_key_secret_name" {
  description = "Secrets Manager secret name containing the Linux bastion SSH public key"
  type        = string
}

variable "windows_bastion_create_key_pair" {
  description = "Whether to create the Windows bastion EC2 key pair"
  type        = bool
  default     = true
}

variable "windows_bastion_ec2_public_key_secret_name" {
  description = "Secrets Manager secret name containing the Windows bastion SSH public key"
  type        = string
}

variable "kms_key_name" {
  description = "Name for the KMS key used to encrypt published bastion public-key secrets"
  type        = string
}

variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encrypting key pair secrets"
}

variable "bastion_key_pair_name" {
  description = "Name of the Linux bastion EC2 key pair"
  type        = string
}

variable "windows_bastion_key_pair_name" {
  description = "Name of the Windows bastion EC2 key pair"
  type        = string
}

variable "private_ec2_key_pair_name" {
  description = "Name of the primary private EC2 key pair"
  type        = string
}

variable "private_ec2_secondary_key_pair_name" {
  description = "Name of the secondary private EC2 key pair"
  type        = string
}

variable "sm_private_ec2_ssh_public_key_name" {
  description = "Secrets Manager secret name containing primary private EC2 SSH public key"
  type        = string
}

variable "sm_private_ec2_secondary_ssh_public_key_name" {
  description = "Secrets Manager secret name containing secondary private EC2 SSH public key"
  type        = string
}

variable "save_ec2_keys_to_secrets_manager" {
  description = "Whether to save generated EC2 key pair material to AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "ec2_private_key_secret_name" {
  description = "Optional override for the EC2 private key secret name"
  type        = string
  default     = null
}

variable "ec2_public_key_secret_name" {
  description = "Optional override for the EC2 public key secret name"
  type        = string
  default     = null
}

variable "ec2_key_pair_metadata_secret_name" {
  description = "Optional override for the EC2 key pair metadata secret name"
  type        = string
  default     = null
}

variable "ec2_key_secrets_kms_key_id" {
  description = "Optional KMS key ID/ARN for encrypting EC2 key secrets"
  type        = string
  default     = null
}

variable "secrets_get_value_user_name" {
  description = "IAM user name allowed in secret resource permissions to call GetSecretValue"
  type        = string
  default     = "cloud_user"
}

variable "bastion_name" {
  description = "Bastion EC2 name"
  type        = string
}

variable "bastion_ami_id" {
  description = "Amazon Linux bastion AMI ID override. If null, use the latest Amazon Linux 2023 AMI"
  type        = string
  default     = null

}

variable "windows_bastion_name" {
  description = "Name for the Windows bastion EC2 instance"
  type        = string
  default     = null
}

variable "windows_bastion_ami_id" {
  description = "Windows bastion AMI ID override. If null, use the latest Windows Server 2022 AMI"
  type        = string
  default     = null
}

variable "windows_bastion_instance_type" {
  description = "Instance type for the Windows bastion. If null, reuse bastion_instance_type"
  type        = string
  default     = null
}

variable "windows_bastion_subnet_name" {
  description = "Public subnet name for Windows bastion. If null, reuse bastion_subnet_name"
  type        = string
  default     = null
}

variable "windows_bastion_private_ip" {
  description = "Optional static private IP for Windows bastion"
  type        = string
  default     = null
}

variable "windows_bastion_associate_public_ip" {
  description = "Whether Windows bastion should receive a public IP. If null, reuse bastion_associate_public_ip"
  type        = bool
  default     = null
}

variable "windows_bastion_ingress_cidrs" {
  description = "CIDR ranges allowed to RDP to Windows bastion. If empty, reuse bastion_ingress_cidrs"
  type        = list(string)
  default     = []
}

variable "windows_bastion_ssh_user" {
  description = "Username used in generic SSH outputs for Windows bastion module"
  type        = string
  default     = "Administrator"
}

variable "bastion_instance_type" {
  description = "Bastion instance type"
  type        = string
}

variable "bastion_subnet_name" {
  description = "Public subnet name for bastion"
  type        = string
}

variable "bastion_private_ip" {
  description = "Optional static private IP for bastion"
  type        = string
  default     = null
}

variable "bastion_ssh_user" {
  description = "SSH username for bastion"
  type        = string
  default     = "ec2-user"
}

variable "bastion_associate_public_ip" {
  description = "Whether bastion should receive a public IP"
  type        = bool
  default     = true
}

variable "bastion_ingress_cidrs" {
  description = "CIDR ranges allowed to SSH to bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_volume_size" {
  type    = number
  default = 50
}

variable "bastion_volume_type" {
  type    = string
  default = "gp3"
}

variable "bastion_volume_encrypted" {
  type    = bool
  default = false
}

variable "bastion_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "private_ec2_name" {
  description = "Private EC2 name"
  type        = string
}

variable "private_ec2_ami_id" {
  description = "Private EC2 AMI ID"
  type        = string
}

variable "private_ec2_instance_type" {
  description = "Private EC2 instance type"
  type        = string
}

variable "private_ec2_subnet_name" {
  description = "Private subnet name for private EC2"
  type        = string
}

variable "private_ec2_private_ip" {
  description = "Optional static private IP for private EC2"
  type        = string
  default     = null
}

variable "private_ec2_ssh_user" {
  description = "SSH username for private EC2"
  type        = string
  default     = "ec2-user"
}

variable "private_ec2_volume_size" {
  type    = number
  default = 50
}

variable "private_ec2_volume_type" {
  type    = string
  default = "gp3"
}

variable "private_ec2_volume_encrypted" {
  type    = bool
  default = false
}

variable "private_ec2_volume_delete_on_termination" {
  type    = bool
  default = true
}

variable "create_private_ec2_secondary" {
  description = "Whether to create a second private Linux EC2"
  type        = bool
  default     = true
}

variable "private_ec2_secondary_name" {
  description = "Name of the second private Linux EC2"
  type        = string
  default     = "private-ec2-2"
}

variable "private_ec2_secondary_ami_id" {
  description = "AMI ID for the second private Linux EC2. If null, reuse private_ec2_ami_id"
  type        = string
  default     = null
}

variable "private_ec2_secondary_instance_type" {
  description = "Instance type for the second private Linux EC2"
  type        = string
  default     = null
}

variable "private_ec2_secondary_subnet_name" {
  description = "Private subnet name for the second private Linux EC2"
  type        = string
  default     = null
}

variable "private_ec2_secondary_private_ip" {
  description = "Optional static private IP for the second private Linux EC2"
  type        = string
  default     = null
}

variable "private_ec2_secondary_ssh_user" {
  description = "SSH username for the second private Linux EC2"
  type        = string
  default     = null
}

variable "private_ec2_secondary_volume_size" {
  description = "Root volume size for the second private Linux EC2"
  type        = number
  default     = null
}

variable "private_ec2_secondary_volume_type" {
  description = "Root volume type for the second private Linux EC2"
  type        = string
  default     = null
}

variable "private_ec2_secondary_volume_encrypted" {
  description = "Whether the second private Linux EC2 root volume is encrypted"
  type        = bool
  default     = null
}

variable "private_ec2_secondary_volume_delete_on_termination" {
  description = "Whether to delete second private Linux EC2 root volume on termination"
  type        = bool
  default     = null
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Retention for CloudWatch log groups"
  type        = number
  default     = 14
}

variable "cloudwatch_config_parameter_name" {
  description = "SSM parameter path holding CloudWatch agent configuration"
  type        = string
  default     = "/cloudwatch-config/private-ec2"
}
