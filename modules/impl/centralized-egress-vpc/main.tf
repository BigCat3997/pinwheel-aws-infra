module "tgw" {
  source = "../../base/tgw"

  name                            = var.tgw_name
  description                     = var.tgw_description
  amazon_side_asn                 = var.tgw_amazon_side_asn
  auto_accept_shared_attachments  = var.tgw_auto_accept_shared_attachments
  default_route_table_association = var.tgw_default_route_table_association
  default_route_table_propagation = var.tgw_default_route_table_propagation
  dns_support                     = var.tgw_dns_support
  vpn_ecmp_support                = var.tgw_vpn_ecmp_support
  tags                            = var.tags
}

module "local_shared_vpc" {
  source = "../../base/vpc"

  create               = var.create_shared_vpc
  cidr_block           = var.shared_vpc_cidr_block
  name                 = var.shared_vpc_name
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

module "local_shared_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_shared_vpc.id
  public_subnets  = var.shared_public_subnets
  private_subnets = var.shared_private_subnets
  tags            = var.tags
}

module "local_shared_igw" {
  source = "../../base/internet-gateway"
  vpc_id = module.local_shared_vpc.id
  name   = var.shared_igw_name
  tags   = var.tags
}

module "local_shared_nat_gateway" {
  source            = "../../base/nat-gateway"
  nat_gateways      = var.shared_nat_gateways
  public_subnet_ids = module.local_shared_subnet.public_subnet_ids
  tags              = var.tags
}

module "local_shared_eip" {
  source       = "../../base/eip"
  nat_gateways = var.shared_nat_gateways
  tags         = var.tags
}

module "local_shared_route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.local_shared_vpc.id
  public_route_tables  = var.shared_public_route_tables
  private_route_tables = var.shared_private_route_tables
  internet_gateway_id  = module.local_shared_igw.internet_gateway_id
  nat_gateway_ids      = module.local_shared_nat_gateway.nat_gateway_ids
  tags                 = var.tags
}

module "local_shared_route_table_association" {
  source                        = "../../base/route-table-association"
  public_rt_subnet_associations = var.shared_public_rt_subnet_associations
  rt_subnet_associations        = var.shared_private_rt_subnet_associations
  public_subnet_ids             = module.local_shared_subnet.public_subnet_ids
  private_subnet_ids            = module.local_shared_subnet.private_subnet_ids
  public_route_table_ids        = module.local_shared_route_table.public_route_table_ids
  private_route_table_ids       = module.local_shared_route_table.private_route_table_ids
}

module "tgw_shared_vpc_attachment" {
  source = "../../base/tgw-vpc-attachment"

  name               = var.tgw_shared_vpc_attachment_name
  transit_gateway_id = module.tgw.id
  vpc_id             = module.local_shared_vpc.id
  subnet_ids         = [for name in var.tgw_shared_vpc_attachment_subnet_names : module.local_shared_subnet.private_subnet_ids[name]]
  dns_support        = var.tgw_shared_vpc_attachment_dns_support
  ipv6_support       = var.tgw_shared_vpc_attachment_ipv6_support
  tags               = var.tags
}

module "consumer_vpc" {
  source = "../../base/vpc"

  create               = var.create_consumer_vpc
  cidr_block           = var.consumer_vpc_cidr_block
  name                 = var.consumer_vpc_name
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

module "consumer_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.consumer_vpc.id
  public_subnets  = var.consumer_public_subnets
  private_subnets = var.consumer_private_subnets
  tags            = var.tags
}

module "consumer_igw" {
  source = "../../base/internet-gateway"
  vpc_id = module.consumer_vpc.id
  name   = var.consumer_igw_name
  tags   = var.tags
}

module "consumer_route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.consumer_vpc.id
  public_route_tables  = var.consumer_public_route_tables
  private_route_tables = var.consumer_private_route_tables
  internet_gateway_id  = module.consumer_igw.internet_gateway_id
  tags                 = var.tags
}

module "consumer_route_table_association" {
  source                        = "../../base/route-table-association"
  public_rt_subnet_associations = var.consumer_public_rt_subnet_associations
  rt_subnet_associations        = var.consumer_private_rt_subnet_associations
  public_subnet_ids             = module.consumer_subnet.public_subnet_ids
  private_subnet_ids            = module.consumer_subnet.private_subnet_ids
  public_route_table_ids        = module.consumer_route_table.public_route_table_ids
  private_route_table_ids       = module.consumer_route_table.private_route_table_ids
}

module "tgw_consumer_vpc_attachment" {
  source = "../../base/tgw-vpc-attachment"

  name               = var.tgw_consumer_vpc_attachment_name
  transit_gateway_id = module.tgw.id
  vpc_id             = module.consumer_vpc.id
  subnet_ids         = [for name in var.tgw_consumer_vpc_attachment_subnet_names : module.consumer_subnet.private_subnet_ids[name]]
  dns_support        = var.tgw_consumer_vpc_attachment_dns_support
  ipv6_support       = var.tgw_consumer_vpc_attachment_ipv6_support
  tags               = var.tags
}


resource "aws_route" "shared_private_to_consumer_via_tgw" {
  for_each = module.local_shared_route_table.private_route_table_ids

  route_table_id         = each.value
  destination_cidr_block = var.consumer_vpc_cidr_block
  transit_gateway_id     = module.tgw.id

  depends_on = [module.tgw_shared_vpc_attachment]
}

resource "aws_route" "shared_public_to_consumer_via_tgw" {
  for_each = module.local_shared_route_table.public_route_table_ids

  route_table_id         = each.value
  destination_cidr_block = var.consumer_vpc_cidr_block
  transit_gateway_id     = module.tgw.id

  depends_on = [module.tgw_shared_vpc_attachment]
}

resource "aws_route" "consumer_private_to_shared_via_tgw" {
  for_each = module.consumer_route_table.private_route_table_ids

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.id

  depends_on = [module.tgw_shared_vpc_attachment]
}

resource "aws_ec2_transit_gateway_route" "internet_via_shared_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = module.tgw.association_default_route_table_id
  transit_gateway_attachment_id  = module.tgw_shared_vpc_attachment.id

  depends_on = [module.tgw_shared_vpc_attachment]
}

module "bastion_key_pair" {
  source = "../../base/key-pair"

  create          = var.bastion_create_key_pair
  name            = var.bastion_key_pair_name
  public_key_path = var.bastion_public_key_path
  tags            = var.tags
}

module "app_ec2_key_pair" {
  source = "../../base/key-pair"

  create          = var.app_ec2_create_key_pair
  name            = var.app_ec2_key_pair_name
  public_key_path = var.app_ec2_public_key_path
  tags            = var.tags
}

module "bastion_sg" {
  source = "../../base/sg"

  name   = var.bastion_sg_name
  vpc_id = module.consumer_vpc.id

  security_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere"
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

  tags = var.tags
}

module "app_ec2_sg" {
  source = "../../base/sg"

  name   = var.app_ec2_sg_name
  vpc_id = module.consumer_vpc.id

  security_rules = [
    {
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      security_group_id = module.bastion_sg.id
      description       = "Allow SSH from bastion"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.consumer_vpc.cidr_block]
      description = "Allow SSH from consumer VPC"
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

  tags = var.tags
}

module "bastion_ec2" {
  source = "../../base/ec2"

  name                         = var.bastion_name
  ami_id                       = var.bastion_ami_id
  instance_type                = var.bastion_instance_type
  subnet_id                    = module.consumer_subnet.public_subnet_ids[var.bastion_subnet_name]
  security_group_ids           = [module.bastion_sg.id]
  associate_public_ip          = var.bastion_associate_public_ip
  key_name                     = module.bastion_key_pair.name
  user_data                    = var.bastion_user_data
  volume_size                  = var.bastion_volume_size
  volume_type                  = var.bastion_volume_type
  volume_encrypted             = var.bastion_volume_encrypted
  volume_delete_on_termination = var.bastion_volume_delete_on_termination

  tags = var.tags

  depends_on = [module.bastion_key_pair]
}

module "app_ec2" {
  source = "../../base/ec2"

  name                         = var.app_ec2_name
  ami_id                       = var.app_ec2_ami_id
  instance_type                = var.app_ec2_instance_type
  subnet_id                    = module.consumer_subnet.private_subnet_ids[var.app_ec2_subnet_name]
  security_group_ids           = [module.app_ec2_sg.id]
  associate_public_ip          = var.app_ec2_associate_public_ip
  key_name                     = module.app_ec2_key_pair.name
  user_data                    = var.app_ec2_user_data
  volume_size                  = var.app_ec2_volume_size
  volume_type                  = var.app_ec2_volume_type
  volume_encrypted             = var.app_ec2_volume_encrypted
  volume_delete_on_termination = var.app_ec2_volume_delete_on_termination

  tags = var.tags

  depends_on = [module.app_ec2_key_pair, module.tgw_consumer_vpc_attachment]
}

