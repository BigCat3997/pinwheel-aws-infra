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

variable "ec2_associate_public_ip" {
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
  description = "Additional subnet names (beyond ec2_subnet_name) to place SSM interface endpoints in"
  type        = list(string)
  default     = []
}

variable "ec2_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ec2_ami_id" {
  description = "AMI ID. If null, the latest Amazon Linux 2023 AMI is resolved from SSM (it ships with the SSM agent)"
  type        = string
  default     = null
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_subnet_name" {
  description = "Subnet name for the EC2 instance (public when ec2_associate_public_ip is true)"
  type        = string
}

variable "ec2_volume_size" {
  description = "Root volume size (GiB)"
  type        = number
  default     = 20
}

variable "ec2_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "ec2_volume_encrypted" {
  description = "Whether the root volume is encrypted"
  type        = bool
  default     = true
}

variable "ec2_volume_tags" {
  description = "Tags applied to the EC2 volumes"
  type        = map(string)
  default     = {}
}

variable "rhel_ec2_name" {
  description = "Name of the RHEL EC2 instance"
  type        = string
}

variable "rhel_ec2_version" {
  description = "RHEL release used to look up the AMI when rhel_ec2_ami_id is null"
  type        = string
  default     = "9.7"
}

variable "rhel_ec2_ami_id" {
  description = "RHEL AMI ID. If null, the latest RHEL rhel_ec2_version AMI is looked up"
  type        = string
  default     = null
}

variable "rhel_ec2_instance_type" {
  description = "RHEL EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_create_key_pair" {
  description = "Whether to create the key pair for the Amazon Linux EC2"
  type        = bool
  default     = true
}

variable "ec2_key_pair_name" {
  description = "Key pair name for the Amazon Linux EC2"
  type        = string
}

variable "ec2_public_key_secret_name" {
  description = "Secrets Manager secret name containing the SSH public key for the Amazon Linux EC2"
  type        = string
}

variable "rhel_ec2_create_key_pair" {
  description = "Whether to create the key pair for the RHEL EC2"
  type        = bool
  default     = true
}

variable "rhel_ec2_key_pair_name" {
  description = "Key pair name for the RHEL EC2"
  type        = string
}

variable "rhel_ec2_public_key_secret_name" {
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
