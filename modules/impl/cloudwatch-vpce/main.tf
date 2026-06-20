module "local_vpc" {
  source           = "../../base/vpc"
  create           = true
  name             = var.vpc_name
  cidr_block       = var.vpc_cidr_block
  enable_flow_logs = true
  tags             = var.tags
}

module "local_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags

  depends_on = [module.local_vpc]
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
  nat_gateway_ids      = {}
  tags                 = var.tags

  depends_on = [module.local_vpc, module.local_internet_gateway]
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

module "local_app_instance_sg" {
  source = "../../base/sg"

  name           = var.app_instance_sg_name
  vpc_id         = module.local_vpc.id
  security_rules = []
  egress_rules   = [local.common_allow_all_egress_rule]

  tags = var.tags
}

module "local_vpc_endpoints_sg" {
  source = "../../base/sg"

  name   = var.logs_vpce_sg_name
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      security_group_id = module.local_app_instance_sg.id
      description       = "HTTPS from private test EC2 to CloudWatch Logs endpoint"
    }
  ]

  egress_rules = [local.common_allow_all_egress_rule]

  tags = var.tags
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.local_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [module.local_subnet.private_subnets[var.private_test_subnet_name]]
  security_group_ids  = [module.local_vpc_endpoints_sg.id]
  private_dns_enabled = true
  policy              = local.logs_vpc_endpoint_policy

  tags = merge(var.tags, {
    Name = "${var.logs_vpce_name}"
  })
}

module "local_cloudwatch_log_group" {
  source = "../../base/cloudwatch-log-group"

  log_groups = [
    {
      key               = "vpce_test"
      name              = local.cloudwatch_log_group_name
      retention_in_days = var.cloudwatch_logs_retention_in_days
      tags = merge(var.tags, {
        Name = "${var.app_instance_name}-log-group"
      })
    }
  ]
}

module "local_test_ec2_cloudwatch_policy" {
  source = "../../base/iam-policy"

  name        = "${var.app_instance_name}-cloudwatch-policy"
  path        = "/"
  description = "Allow private test EC2 to push logs to CloudWatch Logs"
  policy_file = "${path.module}/files/iam/cloudwatch-policy.json"

  tags = var.tags
}

module "local_test_ec2_role" {
  source = "../../base/iam-role"

  name                    = "${var.app_instance_name}-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/files/iam/ec2-role.json"
  managed_policy_arns = [
    module.local_test_ec2_cloudwatch_policy.policy_arn
  ]

  tags = var.tags
}

module "local_private_test_ec2" {
  source = "../../base/ec2"

  name                         = var.app_instance_name
  ami_id                       = data.aws_ssm_parameter.amzn_linux_2023_ami.value
  instance_type                = var.app_instance_type
  subnet_id                    = module.local_subnet.private_subnets[var.private_test_subnet_name]
  private_ip                   = local.app_instance_private_ip_effective
  security_group_ids           = [module.local_app_instance_sg.id]
  associate_public_ip          = false
  ssh_user                     = "ec2-user"
  user_data                    = local.app_instance_user_data
  user_data_replace_on_change  = true
  instance_profile_name        = "${var.app_instance_name}-profile"
  role_name                    = module.local_test_ec2_role.role_name
  volume_size                  = var.app_instance_volume_size
  volume_type                  = var.app_instance_volume_type
  volume_encrypted             = true
  volume_delete_on_termination = true

  tags = var.tags

  depends_on = [
    module.local_cloudwatch_log_group,
    module.local_test_ec2_role,
    aws_vpc_endpoint.logs,
  ]
}
