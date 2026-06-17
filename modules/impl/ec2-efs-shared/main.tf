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

  name = "${var.nat_gateway_name}-eip"
  tags = var.common_tags
}

module "local_nat_gateway" {
  source = "../../base/nat-gateway"

  name      = var.nat_gateway_name
  eip_id    = module.local_nat_gateway_eip.id
  subnet_id = module.local_subnet.public_subnets[var.nat_gateway_public_subnet_name]
  tags      = var.common_tags

  depends_on = [module.local_nat_gateway_eip, module.local_internet_gateway]
}

module "local_route_table" {
  source = "../../base/route-table"

  vpc_id = module.local_vpc.id
  public_route_tables = [
    {
      name = var.public_route_table_name
    }
  ]
  private_route_tables = [
    {
      name        = var.private_route_table_name
      nat_gw_name = var.nat_gateway_name
    }
  ]
  internet_gateway_id = module.local_internet_gateway.id
  nat_gateway_ids     = { (var.nat_gateway_name) = module.local_nat_gateway.id }
  tags                = var.common_tags

  depends_on = [module.local_nat_gateway]
}

module "local_route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc = [
    {
      key              = "bastion-public-assoc"
      subnet_name      = var.bastion_public_subnet_name
      route_table_name = var.public_route_table_name
    }
  ]
  private_rtb_assoc = [
    {
      key              = "private-node1-assoc"
      subnet_name      = var.ec2_node1_subnet_name
      route_table_name = var.private_route_table_name
    },
    {
      key              = "private-node2-assoc"
      subnet_name      = var.ec2_node2_subnet_name
      route_table_name = var.private_route_table_name
    }
  ]
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = module.local_subnet.private_subnets
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = module.local_route_table.private_route_table_ids

  depends_on = [module.local_subnet, module.local_route_table]
}

module "local_key_pair" {
  source = "../../base/key-pair"

  create     = true
  name       = var.key_pair_name
  public_key = data.aws_secretsmanager_secret_version.ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_ec2_sg" {
  source = "../../base/sg"

  name   = var.sg_ec2_name
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      security_group_id = module.local_bastion_sg.id
      description       = "SSH from bastion only"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress"
    }
  ]

  tags = var.common_tags
}

module "local_bastion_sg" {
  source = "../../base/sg"

  name   = var.sg_bastion_name
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.bastion_ingress_cidrs
      description = "SSH to bastion"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress"
    }
  ]

  tags = var.common_tags
}

module "local_efs_sg" {
  source = "../../base/sg"

  name   = var.sg_efs_name
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 2049
      to_port           = 2049
      protocol          = "tcp"
      security_group_id = module.local_ec2_sg.id
      description       = "NFS from EC2 SG"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress"
    }
  ]

  tags = var.common_tags

  depends_on = [module.local_ec2_sg]
}

module "local_ec2_node1_role" {
  source = "../../base/iam-role"

  name = local.ec2_node1_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"]
  tags                = var.common_tags
}

module "local_ec2_node2_role" {
  source = "../../base/iam-role"

  name = local.ec2_node2_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"]
  tags                = var.common_tags
}

module "local_efs" {
  source = "../../base/efs"

  name                      = var.efs_name
  efs_policy                = local.efs_policy
  enable_encryption         = var.efs_enable_encryption
  performance_mode          = var.efs_performance_mode
  throughput_mode           = var.efs_throughput_mode
  transition_to_ia          = var.efs_transition_to_ia
  access_points             = var.efs_access_points
  enable_file_system_policy = var.efs_enforce_role_based_mount
  allowed_principal_arns = [
    module.local_ec2_node1_role.role_arn,
    module.local_ec2_node2_role.role_arn
  ]
  allow_client_root_access = false
  enable_mount             = true
  subnet_ids               = values(module.local_subnet.private_subnets)
  security_group_ids       = [module.local_efs_sg.id]
  backup_policy_status     = "ENABLED"
  tags                     = var.common_tags

  depends_on = [
    module.local_subnet,
    module.local_efs_sg,
    module.local_ec2_node1_role,
    module.local_ec2_node2_role
  ]
}

module "local_bastion_ec2" {
  source = "../../base/ec2"

  name                = var.bastion_name
  ami_id              = var.ec2_ami_id
  instance_type       = var.bastion_instance_type
  subnet_id           = module.local_subnet.public_subnets[var.bastion_public_subnet_name]
  security_group_ids  = [module.local_bastion_sg.id]
  associate_public_ip = true
  key_name            = module.local_key_pair.name
  user_data           = null
  volume_size         = var.bastion_volume_size
  volume_type         = var.bastion_volume_type

  tags = merge(var.common_tags, {
    Name = var.bastion_name
    Role = "bastion"
  })

  depends_on = [
    module.local_route_table_association,
    module.local_bastion_sg,
    module.local_key_pair
  ]
}

module "local_ec2_node1" {
  source = "../../base/ec2"

  name                  = var.ec2_node1_name
  ami_id                = var.ec2_ami_id
  instance_type         = var.ec2_instance_type
  subnet_id             = module.local_subnet.private_subnets[var.ec2_node1_subnet_name]
  security_group_ids    = [module.local_ec2_sg.id]
  associate_public_ip   = false
  key_name              = module.local_key_pair.name
  instance_profile_name = local.ec2_node1_instance_profile_name
  role_name             = module.local_ec2_node1_role.role_name
  user_data             = local.efs_user_data
  volume_size           = var.ec2_volume_size
  volume_type           = var.ec2_volume_type

  tags = merge(var.common_tags, {
    Name = var.ec2_node1_name
    Role = "efs-client"
  })

  depends_on = [
    module.local_subnet,
    module.local_ec2_sg,
    module.local_key_pair,
    module.local_efs,
    module.local_ec2_node1_role
  ]
}

module "local_ec2_node2" {
  source = "../../base/ec2"

  name                  = var.ec2_node2_name
  ami_id                = var.ec2_ami_id
  instance_type         = var.ec2_instance_type
  subnet_id             = module.local_subnet.private_subnets[var.ec2_node2_subnet_name]
  security_group_ids    = [module.local_ec2_sg.id]
  associate_public_ip   = false
  key_name              = module.local_key_pair.name
  instance_profile_name = local.ec2_node2_instance_profile_name
  role_name             = module.local_ec2_node2_role.role_name
  user_data             = local.efs_user_data
  volume_size           = var.ec2_volume_size
  volume_type           = var.ec2_volume_type

  tags = merge(var.common_tags, {
    Name = var.ec2_node2_name
    Role = "efs-client"
  })

  depends_on = [
    module.local_subnet,
    module.local_ec2_sg,
    module.local_key_pair,
    module.local_efs,
    module.local_ec2_node2_role
  ]
}
