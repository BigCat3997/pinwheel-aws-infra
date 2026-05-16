module "local_vpc" {
  source     = "../../base/vpc"
  create     = true
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "local_subnet" {
  source         = "../../base/subnet"
  vpc_id         = module.local_vpc.id
  public_subnets = var.public_subnets
  tags           = var.tags

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
  private_route_tables = []
  internet_gateway_id  = module.local_internet_gateway.internet_gateway_id
  nat_gateway_ids      = {}
  tags                 = var.tags

  depends_on = [module.local_vpc, module.local_internet_gateway]
}

module "local_route_table_association" {
  source                  = "../../base/route-table-association"
  public_rtb_assoc        = var.public_rtb_assoc
  private_rtb_assoc       = []
  public_subnet_ids       = module.local_subnet.public_subnet_ids
  private_subnet_ids      = {}
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = {}

  depends_on = [module.local_subnet, module.local_route_table]
}

module "local_vpn_eip" {
  source = "../../base/eip"
  name   = "${var.vpn_instance_name}-eip"
  tags   = var.tags
}

module "local_key_pair" {
  source          = "../../base/key-pair"
  create          = true
  name            = var.key_pair_name
  public_key_path = var.ssh_public_key_path
  tags            = var.tags
}

module "local_vpn_sg" {
  source = "../../base/sg"

  name   = "${var.vpn_instance_name}-sg"
  vpc_id = module.local_vpc.id

  security_rules = local.vpn_ingress_rules

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = var.tags
}

module "local_vpn_ec2" {
  source = "../../base/ec2"

  name               = var.vpn_instance_name
  ami_id             = local.vpn_ami_id_effective
  instance_type      = var.vpn_instance_type
  subnet_id          = module.local_subnet.public_subnet_ids[var.vpn_subnet_name]
  private_ip         = local.vpn_private_ip_static
  security_group_ids = [module.local_vpn_sg.id]
  key_name           = module.local_key_pair.name

  associate_public_ip = true

  user_data = local.vpn_user_data

  volume_size = var.vpn_volume_size
  volume_type = var.vpn_volume_type

  tags = var.tags

  depends_on = [module.local_subnet, module.local_vpn_sg, module.local_key_pair]
}

resource "aws_eip_association" "vpn" {
  instance_id   = module.local_vpn_ec2.id
  allocation_id = module.local_vpn_eip.id
}
