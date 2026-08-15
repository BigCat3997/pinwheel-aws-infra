tags = {
  Environment = "dev"
  Project     = "pinwheel"
  Version     = "v1.0.0"
  Created_By  = "terraform"
  Managed_By  = "terraform"
  Deployed_By = "manual"
}

# VPC
create_vpc     = true
vpc_name       = "bc-vpc-eks-dev-0"
vpc_cidr_block = "10.60.0.0/16"

public_subnets = [
  {
    name = "bc-subnet-eks_public-dev-0"
    cidr = "10.60.1.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-eks_public-dev-1"
    cidr = "10.60.2.0/24"
    az   = "us-east-1b"
  }
]

private_subnets = [
  {
    name = "bc-subnet-eks_private-dev-0"
    cidr = "10.60.10.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-eks_private-dev-1"
    cidr = "10.60.11.0/24"
    az   = "us-east-1b"
  }
]

eips = [
  { name = "bc-eip-eks_nat-dev-0" },
  { name = "bc-eip-eks_nat-dev-1" }
]

nat_gateways = [
  {
    name        = "bc-nat-eks-dev-0"
    subnet_name = "bc-subnet-eks_public-dev-0"
    eip_name    = "bc-eip-eks_nat-dev-0"
  },
  {
    name        = "bc-nat-eks-dev-1"
    subnet_name = "bc-subnet-eks_public-dev-1"
    eip_name    = "bc-eip-eks_nat-dev-1"
  }
]

internet_gateway_name = "bc-igw-eks-dev-0"

public_route_tables = [
  { name = "bc-rt-eks_public-dev-0" },
  { name = "bc-rt-eks_public-dev-1" }
]

private_route_tables = [
  { name = "bc-rt-eks_private-dev-0", nat_gw_name = "bc-nat-eks-dev-0" },
  { name = "bc-rt-eks_private-dev-1", nat_gw_name = "bc-nat-eks-dev-1" }
]

public_rtb_assoc = [
  {
    key              = "bc-rtba-eks_public-dev-0"
    subnet_name      = "bc-subnet-eks_public-dev-0"
    route_table_name = "bc-rt-eks_public-dev-0"
  },
  {
    key              = "bc-rtba-eks_public-dev-1"
    subnet_name      = "bc-subnet-eks_public-dev-1"
    route_table_name = "bc-rt-eks_public-dev-1"
  }
]

private_rtb_assoc = [
  {
    key              = "bc-rtba-eks_private-dev-0"
    subnet_name      = "bc-subnet-eks_private-dev-0"
    route_table_name = "bc-rt-eks_private-dev-0"
  },
  {
    key              = "bc-rtba-eks_private-dev-1"
    subnet_name      = "bc-subnet-eks_private-dev-1"
    route_table_name = "bc-rt-eks_private-dev-1"
  }
]

# Security Group
cluster_sg_name = "bc-sg-eks_cluster-dev-0"
cluster_sg_ingress_rules = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.60.0.0/16"]
    description = "Allow HTTPS from within VPC"
  }
]

# IAM
cluster_role_name = "bc-role-eks_cluster-dev-0"
node_role_name    = "bc-role-eks_node-dev-0"

# EKS Cluster
eks_cluster_name       = "bc-eks-dev-0"
eks_kubernetes_version = "1.30"

endpoint_private_access = true
endpoint_public_access  = true

enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

node_groups = [
  {
    name            = "system"
    instance_types  = ["t3.medium"]
    capacity_type   = "ON_DEMAND"
    disk_size       = 50
    desired_size    = 1
    min_size        = 1
    max_size        = 2
    max_unavailable = 1
  },
  {
    name            = "workload"
    instance_types  = ["t3.medium"]
    capacity_type   = "ON_DEMAND"
    disk_size       = 50
    desired_size    = 2
    min_size        = 1
    max_size        = 2
    max_unavailable = 1
  }
]
