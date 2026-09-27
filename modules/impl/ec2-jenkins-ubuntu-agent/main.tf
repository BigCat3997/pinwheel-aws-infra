module "vpc" {
  source = "../../base/vpc"

  create     = true
  name       = local.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "public_subnet" {
  source = "../../base/subnet"

  vpc_id = module.vpc.id
  public_subnets = [
    {
      name = local.public_subnet_name
      cidr = var.public_subnet_cidr
      az   = local.availability_zone
    }
  ]
  private_subnets = []
  tags            = var.tags
}

module "internet_gateway" {
  source = "../../base/internet-gateway"

  vpc_id = module.vpc.id
  name   = local.internet_gateway_name
  tags   = var.tags
}

module "public_route_table" {
  source = "../../base/route-table"

  vpc_id = module.vpc.id
  public_route_tables = [
    {
      name = local.public_route_table_name
    }
  ]
  private_route_tables = []
  internet_gateway_id  = module.internet_gateway.id
  nat_gateway_ids      = {}
  tags                 = var.tags
}

module "public_route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc = [
    {
      key              = local.public_subnet_name
      subnet_name      = local.public_subnet_name
      route_table_name = local.public_route_table_name
    }
  ]
  private_rtb_assoc       = []
  public_subnet_ids       = module.public_subnet.public_subnets
  private_subnet_ids      = {}
  public_route_table_ids  = module.public_route_table.public_route_table_ids
  private_route_table_ids = {}
}

module "agent_security_group" {
  source = "../../base/sg"

  name           = "${var.name_prefix}-sg"
  vpc_id         = module.vpc.id
  security_rules = local.ssh_ingress_rules
  egress_rules   = [local.allow_all_egress_rule]
  tags           = var.tags
}

module "agent_key_pair" {
  source = "../../base/key-pair"

  create     = true
  name       = "jenkins-key-pair"
  public_key = data.aws_secretsmanager_secret_version.ssh_public_key.secret_string

  tags = var.tags
}

# module "agent_key_pair" {
#   source = "../../base/key-pair"

#   create     = true
#   name       = "${var.name_prefix}-key"
#   public_key = trimspace(data.aws_secretsmanager_secret_version.ssh_public_key.secret_string)
#   tags       = var.tags
# }

module "agent_role" {
  source = "../../base/iam-role"

  name                = "${var.name_prefix}-role"
  description         = "Runtime role for the Jenkins EC2 agent"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role.json
  managed_policy_arns = local.instance_managed_policy_arns
  inline_policies     = var.instance_inline_policies
  tags                = var.tags
}

module "agent" {
  source = "../../base/ec2"

  name                         = var.name_prefix
  ami_id                       = local.ami_id
  instance_type                = var.instance_type
  subnet_id                    = module.public_subnet.public_subnets[local.public_subnet_name]
  security_group_ids           = [module.agent_security_group.id]
  associate_public_ip          = true
  monitoring                   = var.enable_detailed_monitoring
  key_name                     = module.agent_key_pair.name
  ssh_user                     = var.ssh_user
  user_data                    = local.user_data
  user_data_replace_on_change  = var.user_data_replace_on_change
  instance_profile_name        = "${var.name_prefix}-profile"
  role_name                    = module.agent_role.role_name
  volume_size                  = var.root_volume_size
  volume_type                  = var.root_volume_type
  volume_encrypted             = true
  volume_delete_on_termination = true
  tags                         = var.tags

  depends_on = [module.public_route_table_association]
}
