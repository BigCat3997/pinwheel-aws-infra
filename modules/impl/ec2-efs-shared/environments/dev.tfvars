aws_region = "us-east-1"

common_tags = {
  Environment = "dev"
  Project     = "ec2-efs-shared"
  Version     = "1.0.0"
  Created_By  = "terraform"
  Managed_By  = "terraform"
}

# VPC
create_vpc     = true
vpc_name       = "bc-vpc-efs-dev-0"
vpc_cidr_block = "10.130.0.0/20"

public_subnets = [
  {
    name = "bc-subnet-bastion-efs-dev-0"
    cidr = "10.130.1.0/24"
    az   = "us-east-1a"
  }
]

internet_gateway_name          = "bc-igw-efs-dev-0"
public_route_table_name        = "bc-rtb-public-efs-dev-0"
private_route_table_name       = "bc-rtb-private-efs-dev-0"
nat_gateway_name               = "bc-nat-efs-dev-0"
nat_gateway_public_subnet_name = "bc-subnet-bastion-efs-dev-0"

private_subnets = [
  {
    name = "bc-subnet-efs-dev-0"
    cidr = "10.130.11.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-efs-dev-1"
    cidr = "10.130.12.0/24"
    az   = "us-east-1b"
  }
]

# Key pair
key_pair_name              = "bc-key-efs-dev-0"
sm_ec2_ssh_public_key_name = "ec2-rookie-dev-0-public-key"

# Security groups
sg_ec2_name              = "bc-sg-ec2-efs-dev-0"
sg_bastion_name          = "bc-sg-bastion-efs-dev-0"
sg_efs_name              = "bc-sg-efs-dev-0"
sg_ec2_ssh_ingress_cidrs = []
bastion_ingress_cidrs    = ["0.0.0.0/0"]

# Bastion
bastion_name               = "bc-ec2-bastion-efs-dev-0"
bastion_public_subnet_name = "bc-subnet-bastion-efs-dev-0"
bastion_instance_type      = "t3.micro"
bastion_volume_size        = 50
bastion_volume_type        = "gp3"

# EC2
ec2_ami_id        = "ami-0d8d3b1122e36c000"
ec2_instance_type = "t3.medium"
ec2_volume_size   = 50
ec2_volume_type   = "gp3"

ec2_node1_name        = "bc-ec2-efs-dev-0"
ec2_node1_subnet_name = "bc-subnet-efs-dev-0"
ec2_node1_role_name   = "bc-ec2-efs-dev-0-role"
ec2_node1_instance_profile_name = "bc-ec2-efs-dev-0-instance-profile"

ec2_node2_name        = "bc-ec2-efs-dev-1"
ec2_node2_subnet_name = "bc-subnet-efs-dev-1"
ec2_node2_role_name   = "bc-ec2-efs-dev-1-role"
ec2_node2_instance_profile_name = "bc-ec2-efs-dev-1-instance-profile"

efs_mount_path = "/mnt/efs"
efs_mount_access_point_name = "bc-efs-ap-app-data-dev-0"

# EFS
efs_name              = "bc-efs-dev-0"
efs_enable_encryption = true
efs_performance_mode  = "generalPurpose"
efs_throughput_mode   = "bursting"
efs_transition_to_ia  = "AFTER_30_DAYS"
efs_enforce_role_based_mount = true

efs_access_points = [
  {
    name        = "bc-efs-ap-app-data-dev-0"
    path        = "/app-data"
    owner_uid   = 1000
    owner_gid   = 1000
    permissions = "755"
    posix_uid   = 1000
    posix_gid   = 1000
  }
]
