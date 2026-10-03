module "ha_vpc" {
  source = "../../base/vpc"

  create     = var.create_ha_vpc
  name       = var.ha_vpc_name
  cidr_block = var.ha_vpc_cidr_block
  tags       = var.tags
}

module "client_vpc" {
  source = "../../base/vpc"

  create     = var.create_client_vpc
  name       = var.client_vpc_name
  cidr_block = var.client_vpc_cidr_block
  tags       = var.tags
}

module "ha_subnets" {
  source = "../../base/subnet"

  create         = var.create_ha_vpc
  vpc_id         = module.ha_vpc.id
  public_subnets = var.ha_public_subnets
  tags           = var.tags
}

module "client_subnets" {
  source = "../../base/subnet"

  create         = var.create_client_vpc
  vpc_id         = module.client_vpc.id
  public_subnets = var.client_public_subnets
  tags           = var.tags
}

module "ha_internet_gateway" {
  source = "../../base/internet-gateway"

  name   = var.ha_internet_gateway_name
  vpc_id = module.ha_vpc.id
  tags   = var.tags
}

module "client_internet_gateway" {
  source = "../../base/internet-gateway"

  name   = var.client_internet_gateway_name
  vpc_id = module.client_vpc.id
  tags   = var.tags
}

module "ha_route_tables" {
  source = "../../base/route-table"

  vpc_id               = module.ha_vpc.id
  public_route_tables  = var.ha_public_route_tables
  internet_gateway_id  = module.ha_internet_gateway.id
  private_route_tables = []
  nat_gateway_ids      = {}
  tags                 = var.tags
}

module "client_route_tables" {
  source = "../../base/route-table"

  vpc_id               = module.client_vpc.id
  public_route_tables  = var.client_public_route_tables
  internet_gateway_id  = module.client_internet_gateway.id
  private_route_tables = []
  nat_gateway_ids      = {}
  tags                 = var.tags
}

module "ha_route_table_associations" {
  source = "../../base/route-table-association"

  public_rtb_assoc        = var.ha_public_rtb_subnet_assocs
  public_subnet_ids       = module.ha_subnets.public_subnets
  public_route_table_ids  = module.ha_route_tables.public_route_table_ids
  private_rtb_assoc       = []
  private_subnet_ids      = {}
  private_route_table_ids = {}
}

module "client_route_table_associations" {
  source = "../../base/route-table-association"

  public_rtb_assoc        = var.client_public_rtb_subnet_assocs
  public_subnet_ids       = module.client_subnets.public_subnets
  public_route_table_ids  = module.client_route_tables.public_route_table_ids
  private_rtb_assoc       = []
  private_subnet_ids      = {}
  private_route_table_ids = {}
}

module "ha_nodes_security_group" {
  source = "../../base/sg"

  name   = var.ha_nodes_security_group_name
  vpc_id = module.ha_vpc.id
  security_rules = [
    {
      from_port   = var.service_port
      to_port     = var.service_port
      protocol    = "tcp"
      cidr_blocks = [var.client_vpc_cidr_block]
      description = "HTTP test service from client VPC"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      self        = true
      description = "All traffic between HA nodes"
    },
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all IPv4 egress"
    },
  ]
  tags = var.tags
}

module "client_security_group" {
  source = "../../base/sg"

  name           = var.client_security_group_name
  vpc_id         = module.client_vpc.id
  security_rules = []
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all IPv4 egress"
    },
  ]
  tags = var.tags
}

module "ssm_role" {
  source = "../../base/iam-role"

  name               = var.ssm_role_name
  description        = "Allows overlay lab EC2 instances to use Systems Manager"
  assume_role_policy = local.ec2_assume_role_policy
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
  tags = var.tags
}

resource "aws_iam_instance_profile" "ssm" {
  name = var.ssm_instance_profile_name
  role = module.ssm_role.role_name
}

module "primary_ec2" {
  source = "../../base/ec2"

  name                      = var.primary_ec2_name
  ami_id                    = local.ami_id
  instance_type             = var.instance_type
  subnet_id                 = module.ha_subnets.public_subnets[var.primary_ec2_subnet_name]
  security_group_ids        = [module.ha_nodes_security_group.id]
  associate_public_ip       = var.associate_public_ip
  source_dest_check         = false
  ssh_user                  = var.ssh_user
  key_name                  = var.key_name
  iam_instance_profile_name = aws_iam_instance_profile.ssm.name
  user_data = templatefile("${path.module}/scripts/primary_ec2_setup.sh", {
    hostname     = var.primary_hostname
    overlay_cidr = local.overlay_cidr
    service_port = var.service_port
  })
  user_data_replace_on_change  = var.user_data_replace_on_change
  volume_size                  = var.root_volume_size
  volume_type                  = var.root_volume_type
  volume_encrypted             = var.root_volume_encrypted
  volume_delete_on_termination = true
  tags                         = var.tags
}

module "standby_ec2" {
  source = "../../base/ec2"

  name                      = var.standby_ec2_name
  ami_id                    = local.ami_id
  instance_type             = var.instance_type
  subnet_id                 = module.ha_subnets.public_subnets[var.standby_ec2_subnet_name]
  security_group_ids        = [module.ha_nodes_security_group.id]
  associate_public_ip       = var.associate_public_ip
  source_dest_check         = false
  ssh_user                  = var.ssh_user
  key_name                  = var.key_name
  iam_instance_profile_name = aws_iam_instance_profile.ssm.name
  user_data = templatefile("${path.module}/scripts/standby_ec2_setup.sh", {
    hostname     = var.standby_hostname
    service_port = var.service_port
  })
  user_data_replace_on_change  = var.user_data_replace_on_change
  volume_size                  = var.root_volume_size
  volume_type                  = var.root_volume_type
  volume_encrypted             = var.root_volume_encrypted
  volume_delete_on_termination = true
  tags                         = var.tags
}

module "client_ec2" {
  source = "../../base/ec2"

  name                      = var.client_ec2_name
  ami_id                    = local.ami_id
  instance_type             = var.instance_type
  subnet_id                 = module.client_subnets.public_subnets[var.client_ec2_subnet_name]
  security_group_ids        = [module.client_security_group.id]
  associate_public_ip       = var.associate_public_ip
  ssh_user                  = var.ssh_user
  key_name                  = var.key_name
  iam_instance_profile_name = aws_iam_instance_profile.ssm.name
  user_data = templatefile("${path.module}/scripts/client_ec2_setup.sh", {
    hostname = var.client_hostname
  })
  user_data_replace_on_change  = var.user_data_replace_on_change
  volume_size                  = var.root_volume_size
  volume_type                  = var.root_volume_type
  volume_encrypted             = var.root_volume_encrypted
  volume_delete_on_termination = true
  tags                         = var.tags
}

module "transit_gateway" {
  source = "../../base/tgw"

  name                            = var.transit_gateway_name
  description                     = var.transit_gateway_description
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags                            = var.tags
}

module "ha_tgw_attachment" {
  source = "../../base/tgw-vpc-attachment"

  name               = var.ha_tgw_attachment_name
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.ha_vpc.id
  subnet_ids         = [for name in var.ha_tgw_attachment_subnet_names : module.ha_subnets.public_subnets[name]]
  tags               = var.tags
}

module "client_tgw_attachment" {
  source = "../../base/tgw-vpc-attachment"

  name               = var.client_tgw_attachment_name
  transit_gateway_id = module.transit_gateway.id
  vpc_id             = module.client_vpc.id
  subnet_ids         = [for name in var.client_tgw_attachment_subnet_names : module.client_subnets.public_subnets[name]]
  tags               = var.tags
}
