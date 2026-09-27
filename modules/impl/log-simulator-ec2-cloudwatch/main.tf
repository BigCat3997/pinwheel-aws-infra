module "vpc" {
  source = "../../base/vpc"

  create     = true
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.common_tags
}

module "public_subnets" {
  source = "../../base/subnet"

  vpc_id          = module.vpc.id
  public_subnets  = var.public_subnets
  private_subnets = []
  tags            = var.common_tags
}

module "internet_gateway" {
  source = "../../base/internet-gateway"

  vpc_id = module.vpc.id
  name   = var.internet_gateway_name
  tags   = var.common_tags
}

module "route_tables" {
  source = "../../base/route-table"

  vpc_id = module.vpc.id
  public_route_tables = [
    {
      name = var.public_route_table_name
    }
  ]
  private_route_tables = []
  internet_gateway_id  = module.internet_gateway.id
  nat_gateway_ids      = {}
  tags                 = var.common_tags
}

module "route_table_associations" {
  source = "../../base/route-table-association"

  public_rtb_assoc = [
    for subnet in var.public_subnets : {
      key              = subnet.name
      subnet_name      = subnet.name
      route_table_name = var.public_route_table_name
    }
  ]
  private_rtb_assoc       = []
  public_subnet_ids       = module.public_subnets.public_subnets
  private_subnet_ids      = {}
  public_route_table_ids  = module.route_tables.public_route_table_ids
  private_route_table_ids = {}
}

module "ssh_key_pair" {
  source = "../../base/key-pair"

  create     = true
  name       = var.key_pair_name
  public_key = data.aws_secretsmanager_secret_version.ssh_public_key.secret_string
  tags       = var.common_tags
}

module "ec2_security_group" {
  source = "../../base/sg"

  name           = "${var.instance_name}-sg"
  vpc_id         = module.vpc.id
  security_rules = local.ingress_rules
  egress_rules   = [local.allow_all_egress_rule]
  tags           = var.common_tags
}

module "cloudwatch_agent_role" {
  source = "../../base/iam-role"

  name               = "${var.instance_name}-cloudwatch-agent-role"
  description        = "Allows the EC2 CloudWatch Agent to publish logs and host metrics"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]
  tags = var.common_tags
}

module "local_cloudwatch_log_groups" {
  source = "../../base/cloudwatch-log-groups"

  log_groups = [
    {
      key               = "app_logs"
      name              = var.log_group_name
      retention_in_days = var.log_group_retention_in_days
      tags = merge(var.common_tags, {
        Name = var.log_group_name
      })
    }
  ]
}

module "ec2" {
  source = "../../base/ec2"

  name                         = var.instance_name
  ami_id                       = local.ami_id
  instance_type                = var.instance_type
  subnet_id                    = module.public_subnets.public_subnets[var.instance_subnet_name]
  security_group_ids           = [module.ec2_security_group.id]
  associate_public_ip          = true
  monitoring                   = true
  key_name                     = module.ssh_key_pair.name
  ssh_user                     = var.ssh_user
  user_data                    = local.user_data
  instance_profile_name        = "${var.instance_name}-profile"
  role_name                    = module.cloudwatch_agent_role.role_name
  volume_size                  = var.root_volume_size
  volume_type                  = var.root_volume_type
  volume_encrypted             = var.root_volume_encrypted
  volume_delete_on_termination = true
  volume_tags                  = var.volume_tags
  tags                         = var.common_tags

  depends_on = [module.route_table_associations, module.local_cloudwatch_log_groups]
}
