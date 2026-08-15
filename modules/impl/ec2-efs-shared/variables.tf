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

# ── VPC ────────────────────────────────────────────────────────────────────────

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet configuration used by the bastion host"
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

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

variable "private_route_table_name" {
  description = "Name tag for the private route table used by both private EC2 subnets"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name tag for NAT gateway"
  type        = string
}

variable "nat_gateway_public_subnet_name" {
  description = "Public subnet name (from public_subnets) where NAT gateway is placed"
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

# ── Key pair ───────────────────────────────────────────────────────────────────

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "sm_ec2_ssh_public_key_name" {
  description = "Secrets Manager secret name containing the EC2 SSH public key"
  type        = string
}

# ── Security groups ────────────────────────────────────────────────────────────

variable "sg_ec2_name" {
  description = "Name of the EC2 security group"
  type        = string
}

variable "sg_bastion_name" {
  description = "Name of the bastion security group"
  type        = string
}

variable "sg_efs_name" {
  description = "Name of the EFS security group"
  type        = string
}

variable "sg_ec2_ssh_ingress_cidrs" {
  description = "CIDRs allowed to SSH into the EC2 instances (leave empty to disallow)"
  type        = list(string)
  default     = []
}

variable "bastion_ingress_cidrs" {
  description = "CIDRs allowed to SSH into bastion"
  type        = list(string)
}

# ── Bastion ───────────────────────────────────────────────────────────────────

variable "bastion_name" {
  description = "Name tag for the bastion EC2 instance"
  type        = string
}

variable "bastion_public_subnet_name" {
  description = "Public subnet name (from public_subnets) to place the bastion in"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t3.micro"
}

variable "bastion_volume_size" {
  description = "Root EBS volume size in GB for bastion"
  type        = number
  default     = 20
}

variable "bastion_volume_type" {
  description = "Root EBS volume type for bastion"
  type        = string
  default     = "gp3"
}

# ── EC2 ────────────────────────────────────────────────────────────────────────

variable "ec2_ami_id" {
  description = "AMI ID for both EC2 instances (must have amazon-efs-utils or nfs-utils pre-installed, or have internet access)"
  type        = string
}

variable "ec2_instance_type" {
  description = "Instance type for both EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "ec2_node1_name" {
  description = "Name tag for the first EC2 instance"
  type        = string
}

variable "ec2_node1_role_name" {
  description = "IAM role name for the first EC2 instance (null to auto-generate from ec2_node1_name)"
  type        = string
  default     = null
}

variable "ec2_node1_instance_profile_name" {
  description = "IAM instance profile name for the first EC2 instance (null to auto-generate from ec2_node1_name)"
  type        = string
  default     = null
}

variable "ec2_node1_subnet_name" {
  description = "Subnet name (from private_subnets) to place the first EC2 instance in"
  type        = string
}

variable "ec2_node2_name" {
  description = "Name tag for the second EC2 instance"
  type        = string
}

variable "ec2_node2_role_name" {
  description = "IAM role name for the second EC2 instance (null to auto-generate from ec2_node2_name)"
  type        = string
  default     = null
}

variable "ec2_node2_instance_profile_name" {
  description = "IAM instance profile name for the second EC2 instance (null to auto-generate from ec2_node2_name)"
  type        = string
  default     = null
}

variable "ec2_node2_subnet_name" {
  description = "Subnet name (from private_subnets) to place the second EC2 instance in"
  type        = string
}

variable "ec2_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "ec2_volume_type" {
  description = "Root EBS volume type"
  type        = string
  default     = "gp3"
}

variable "efs_mount_path" {
  description = "Local mount path for EFS on both EC2 instances"
  type        = string
  default     = "/mnt/efs"
}

variable "efs_mount_access_point_name" {
  description = "Optional EFS access point name (from efs_access_points) used by both EC2 instances"
  type        = string
  default     = null
}

# ── EFS ────────────────────────────────────────────────────────────────────────

variable "efs_name" {
  description = "Name tag for the EFS file system"
  type        = string
}

variable "efs_enable_encryption" {
  description = "Enable EFS encryption at rest"
  type        = bool
  default     = true
}

variable "efs_performance_mode" {
  description = "EFS performance mode: generalPurpose or maxIO"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode: bursting or provisioned"
  type        = string
  default     = "bursting"
}

variable "efs_transition_to_ia" {
  description = "Lifecycle policy: e.g. AFTER_30_DAYS. Null disables it."
  type        = string
  default     = null
}

variable "efs_enforce_role_based_mount" {
  description = "When true, attaches EFS file system policy allowing mount/write only from EC2 IAM roles"
  type        = bool
  default     = true
}

variable "efs_access_points" {
  description = "List of EFS access points to create"
  type = list(object({
    name        = string
    path        = string
    owner_uid   = number
    owner_gid   = number
    permissions = string
    posix_uid   = number
    posix_gid   = number
  }))
  default = []
}
