module "local_vpc" {
  source     = "../../base/vpc"
  create     = var.create_vpc
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "local_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags

  depends_on = [module.local_vpc]
}

module "local_eip" {
  source   = "../../base/eip"
  for_each = { for eip in var.eips : eip.name => eip }

  name = each.value.name
  tags = var.tags
}

module "local_nat_gateway" {
  source   = "../../base/nat-gateway"
  for_each = { for gw in var.nat_gateways : gw.name => gw }

  name      = each.value.name
  subnet_id = module.local_subnet.public_subnets[each.value.subnet_name]
  eip_id    = module.local_eip[each.value.eip_name].id
  tags      = var.tags

  depends_on = [module.local_subnet, module.local_eip]
}

module "local_internet_gateway" {
  source = "../../base/internet-gateway"
  vpc_id = module.local_vpc.id
  name   = var.internet_gateway_name
  tags   = var.tags
}

module "local_route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.local_vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.local_internet_gateway.id
  nat_gateway_ids      = { for name, ng in module.local_nat_gateway : name => ng.id }
  tags                 = var.tags

  depends_on = [module.local_vpc, module.local_internet_gateway, module.local_nat_gateway]
}

module "local_route_table_association" {
  source                  = "../../base/route-table-association"
  public_rtb_assoc        = var.public_rtb_assoc
  private_rtb_assoc       = var.private_rtb_assoc
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = module.local_subnet.private_subnets
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = module.local_route_table.private_route_table_ids

  depends_on = [module.local_subnet, module.local_route_table]
}

module "local_sg_cluster" {
  source = "../../base/sg"

  name           = var.cluster_sg_name
  vpc_id         = module.local_vpc.id
  security_rules = var.cluster_sg_ingress_rules
  egress_rules   = var.cluster_sg_egress_rules
  tags           = var.tags

  depends_on = [module.local_vpc]
}

module "local_cluster_role" {
  source = "../../base/iam-role"

  name               = var.cluster_role_name
  description        = "IAM role for EKS cluster control plane"
  assume_role_policy = file("${path.module}/files/iam/aws-eks-assume-trust-policy.json")
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  ]
  tags = var.tags
}

module "local_node_role" {
  source = "../../base/iam-role"

  name        = var.node_role_name
  description = "IAM role for EKS managed node groups"

  assume_role_policy = file("${path.module}/files/iam/aws-ec2-assume-trust-policy.json")
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
  tags = var.tags
}

module "local_eks" {
  source = "../../base/eks"

  name                      = var.eks_cluster_name
  kubernetes_version        = var.eks_kubernetes_version
  cluster_role_arn          = module.local_cluster_role.role_arn
  node_role_arn             = module.local_node_role.role_arn
  subnet_ids                = values(module.local_subnet.private_subnets)
  security_group_ids        = [module.local_sg_cluster.id]
  endpoint_private_access   = var.endpoint_private_access
  endpoint_public_access    = var.endpoint_public_access
  public_access_cidrs       = var.public_access_cidrs
  enabled_cluster_log_types = var.enabled_cluster_log_types
  node_groups               = var.node_groups
  tags                      = var.tags

  depends_on = [
    module.local_cluster_role,
    module.local_node_role,
    module.local_subnet,
    module.local_route_table_association,
  ]
}
