module "local_vpc" {
  source     = "../../base/vpc"
  create     = var.create_vpc
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.common_tags
}

module "local_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.common_tags

  depends_on = [module.local_vpc]
}

module "local_internet_gateway" {
  source = "../../base/internet-gateway"
  vpc_id = module.local_vpc.id
  name   = var.internet_gateway_name
  tags   = var.common_tags
}

module "local_nat_gateway_eip" {
  source = "../../base/eip"
  count  = var.create_nat_gateway ? 1 : 0

  name = "${var.nat_gateway_name}-eip"
  tags = var.common_tags
}

module "local_nat_gateway" {
  source = "../../base/nat-gateway"
  count  = var.create_nat_gateway ? 1 : 0

  name      = var.nat_gateway_name
  eip_id    = module.local_nat_gateway_eip[0].id
  subnet_id = module.local_subnet.public_subnets[var.nat_gateway_public_subnet_name]
  tags      = var.common_tags

  depends_on = [module.local_nat_gateway_eip]
}

module "local_route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.local_vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.local_internet_gateway.id
  nat_gateway_ids      = var.create_nat_gateway ? { (var.nat_gateway_name) = module.local_nat_gateway[0].id } : {}
  tags                 = var.common_tags

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

module "local_bastion_key_pair" {
  source = "../../base/key-pair"

  create     = var.bastion_create_key_pair
  name       = var.bastion_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.bastion_ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_windows_bastion_key_pair" {
  source = "../../base/key-pair"

  create     = var.windows_bastion_create_key_pair
  name       = var.windows_bastion_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.windows_bastion_ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_private_ec2_key_pair" {
  source = "../../base/key-pair"

  create     = true
  name       = var.private_ec2_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.private_ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_private_ec2_secondary_key_pair" {
  source = "../../base/key-pair"

  create     = true
  name       = var.private_ec2_secondary_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.private_ec2_secondary_public_key.secret_string
  tags       = var.common_tags
}

module "local_bastion_sg" {
  source = "../../base/sg"

  name   = "${var.bastion_name}-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.bastion_ingress_cidrs
      description = "SSH access to Linux bastion"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = var.bastion_ingress_cidrs
      description = "Grafana access to Linux bastion"
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = var.bastion_ingress_cidrs
      description = "Prometheus access to Linux bastion"
    }
  ]

  egress_rules = [local.allow_all_egress_rule]

  tags = var.common_tags
}

module "local_windows_bastion_sg" {
  source = "../../base/sg"

  name   = "${var.windows_bastion_name}-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = length(var.windows_bastion_ingress_cidrs) > 0 ? var.windows_bastion_ingress_cidrs : var.bastion_ingress_cidrs
      description = "RDP access to Windows bastion"
    }
  ]

  egress_rules = [local.allow_all_egress_rule]

  tags = var.common_tags
}

module "local_private_ec2_sg" {
  source = "../../base/sg"

  name   = "${var.private_ec2_name}-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      # security_group_id = module.local_bastion_sg.id
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH to private EC2 from bastion only"
    },
    {
      from_port         = 3000
      to_port           = 3000
      protocol          = "tcp"
      security_group_id = module.local_bastion_sg.id
      description       = "Grafana access from bastion"
    },
    {
      from_port         = 9090
      to_port           = 9090
      protocol          = "tcp"
      security_group_id = module.local_bastion_sg.id
      description       = "Prometheus access from bastion"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Node exporter scrape from VPC"
    }
  ]

  egress_rules = [local.allow_all_egress_rule]

  tags = var.common_tags
}

module "local_vpc_endpoints_sg" {
  source = "../../base/sg"

  name   = "${var.private_ec2_name}-vpce-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      security_group_id = module.local_private_ec2_sg.id
      description       = "HTTPS from private EC2 to interface endpoints"
    }
  ]

  egress_rules = [local.allow_all_egress_rule]

  tags = var.common_tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.local_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private_ec2_endpoint_subnet_ids
  security_group_ids  = [module.local_vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.private_ec2_name}-ssm-vpce"
  })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.local_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private_ec2_endpoint_subnet_ids
  security_group_ids  = [module.local_vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.private_ec2_name}-logs-vpce"
  })
}

module "local_ec2_cloudwatch_agent_iam_policy" {
  source = "../../base/iam-policy"

  name        = "${var.private_ec2_name}-cloudwatch-policy"
  path        = "/"
  description = "IAM policy for private EC2 CloudWatch agent"
  policy_file = "${path.module}/resources/iam/cloudwatch-policy.json"

  tags = var.common_tags
}

module "local_ec2_cloudwatch_agent_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.private_ec2_name}-cloudwatch-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/resources/iam/cloudwatch-role.json"
  managed_policy_arns = [
    module.local_ec2_cloudwatch_agent_iam_policy.policy_arn
  ]

  tags = var.common_tags
}

module "local_cloudwatch_log_groups" {
  source = "../../base/cloudwatch-log-groups"

  log_groups = [
    {
      key               = "system_logs"
      name              = "/aws/ec2/${var.private_ec2_name}/system"
      retention_in_days = var.cloudwatch_logs_retention_in_days
      tags = merge(var.common_tags, {
        Name = "${var.private_ec2_name}-system-logs"
      })
    }
  ]
}

module "local_cloudwatch_config_ssm" {
  source = "../../base/ssm-parameter"

  name  = var.cloudwatch_config_parameter_name
  type  = "String"
  value = local.cloudwatch_agent_config

  tags = var.common_tags
}

module "local_bastion_ec2" {
  source = "../../base/ec2"

  name                         = var.bastion_name
  ami_id                       = local.bastion_ami_id
  instance_type                = var.bastion_instance_type
  subnet_id                    = module.local_subnet.public_subnets[var.bastion_subnet_name]
  private_ip                   = local.bastion_private_ip_static
  security_group_ids           = [module.local_bastion_sg.id]
  associate_public_ip          = var.bastion_associate_public_ip
  ssh_user                     = var.bastion_ssh_user
  user_data                    = local.bastion_user_data_linux
  volume_size                  = var.bastion_volume_size
  volume_type                  = var.bastion_volume_type
  volume_encrypted             = var.bastion_volume_encrypted
  volume_delete_on_termination = var.bastion_volume_delete_on_termination
  volume_tags                  = var.bastion_volume_tags
  key_name                     = module.local_bastion_key_pair.name

  tags = var.common_tags
}

module "local_windows_bastion_ec2" {
  source = "../../base/ec2"

  name                         = var.windows_bastion_name
  ami_id                       = local.windows_bastion_ami_id
  instance_type                = var.windows_bastion_instance_type
  subnet_id                    = module.local_subnet.public_subnets[var.windows_bastion_subnet_name]
  private_ip                   = local.windows_bastion_private_ip_static
  security_group_ids           = [module.local_windows_bastion_sg.id]
  associate_public_ip          = var.windows_bastion_associate_public_ip
  ssh_user                     = var.windows_bastion_ssh_user
  user_data                    = local.bastion_user_data_windows
  volume_size                  = var.bastion_volume_size
  volume_type                  = var.bastion_volume_type
  volume_encrypted             = var.bastion_volume_encrypted
  volume_delete_on_termination = var.bastion_volume_delete_on_termination
  key_name                     = module.local_windows_bastion_key_pair.name

  tags = var.common_tags
}

module "local_private_ec2" {
  source = "../../base/ec2"

  name                         = var.private_ec2_name
  ami_id                       = var.private_ec2_ami_id
  instance_type                = var.private_ec2_instance_type
  subnet_id                    = module.local_subnet.private_subnets[var.private_ec2_subnet_name]
  private_ip                   = local.private_ec2_private_ip_static
  security_group_ids           = [module.local_private_ec2_sg.id]
  associate_public_ip          = false
  ssh_user                     = var.private_ec2_ssh_user
  user_data                    = null
  instance_profile_name        = "${var.private_ec2_name}-profile"
  role_name                    = module.local_ec2_cloudwatch_agent_iam_role.role_name
  volume_size                  = var.private_ec2_volume_size
  volume_type                  = var.private_ec2_volume_type
  volume_encrypted             = var.private_ec2_volume_encrypted
  volume_delete_on_termination = var.private_ec2_volume_delete_on_termination
  volume_tags                  = var.private_ec2_volume_tags
  key_name                     = module.local_private_ec2_key_pair.name
  tags                         = var.common_tags

  depends_on = [
    module.local_cloudwatch_config_ssm,
    module.local_ec2_cloudwatch_agent_iam_role,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.logs,
  ]
}

module "local_private_ec2_secondary" {
  source = "../../base/ec2"

  name                         = var.private_ec2_secondary_name
  ami_id                       = var.private_ec2_secondary_ami_id
  instance_type                = var.private_ec2_secondary_instance_type
  subnet_id                    = module.local_subnet.private_subnets[var.private_ec2_secondary_subnet_name]
  private_ip                   = local.private_ec2_secondary_private_ip_static
  security_group_ids           = [module.local_private_ec2_sg.id]
  associate_public_ip          = false
  ssh_user                     = var.private_ec2_secondary_ssh_user
  user_data                    = null
  instance_profile_name        = "${var.private_ec2_secondary_name}-profile"
  role_name                    = module.local_ec2_cloudwatch_agent_iam_role.role_name
  volume_size                  = var.private_ec2_secondary_volume_size
  volume_type                  = var.private_ec2_secondary_volume_type
  volume_encrypted             = var.private_ec2_secondary_volume_encrypted
  volume_delete_on_termination = var.private_ec2_secondary_volume_delete_on_termination
  volume_tags                  = var.private_ec2_secondary_volume_tags
  key_name                     = module.local_private_ec2_secondary_key_pair.name

  tags = var.common_tags

  depends_on = [
    module.local_cloudwatch_config_ssm,
    module.local_ec2_cloudwatch_agent_iam_role,
    aws_vpc_endpoint.ssm,
    aws_vpc_endpoint.logs,
  ]
}

module "kms" {
  source = "../../base/kms"

  kms_key_name = var.kms_key_name
  description  = var.kms_description
  tags         = var.common_tags
}

module "bastion_secrets" {
  source = "../../base/secret"

  secrets = [
    {
      name  = "ec2/${var.bastion_name}/ec2-user/public-key"
      value = module.local_bastion_key_pair.public_key
    },
    {
      name  = "ec2/${var.windows_bastion_name}/administrator/public-key"
      value = module.local_windows_bastion_key_pair.public_key
    },
  ]

  resource_policy = templatefile("${path.module}/templates/secrets/secret-resource-policy.json.tftpl", {
    user_arn = data.aws_caller_identity.current.arn
  })
  kms_key_id = module.kms.id

  tags = var.common_tags
}
