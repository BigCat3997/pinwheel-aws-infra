module "tgw" {
  source                          = "../../base/tgw"
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

module "tgw_vpc_attachment" {
  source             = "../../base/tgw-vpc-attachment"
  name               = var.tgw_vpc_attachment_name
  transit_gateway_id = module.tgw.id
  vpc_id             = module.vpc.id
  subnet_ids         = [for name in var.tgw_vpc_attachment_subnet_names : module.subnet.private_subnet_ids[name]]
  dns_support        = var.tgw_vpc_attachment_dns_support
  ipv6_support       = var.tgw_vpc_attachment_ipv6_support
  tags               = var.tags
}

module "vpc" {
  source     = "../../base/vpc"
  cidr_block = var.cidr_block
  name       = var.name
  tags       = var.tags
}

module "subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "eip" {
  source       = "../../base/eip"
  nat_gateways = var.nat_gateways
  tags         = var.tags
}

module "internet_gateway" {
  source                  = "../../base/internet-gateway"
  vpc_id                  = module.vpc.id
  create_internet_gateway = var.create_internet_gateway
  internet_gateway_name   = var.internet_gateway_name
  tags                    = var.tags
}

module "nat_gateway" {
  source            = "../../base/nat-gateway"
  nat_gateways      = var.nat_gateways
  public_subnet_ids = module.subnet.public_subnet_ids
  tags              = var.tags
}

module "route_table" {
  source                  = "../../base/route-table"
  vpc_id                  = module.vpc.id
  public_route_tables     = var.public_route_tables
  private_route_tables    = var.private_route_tables
  create_internet_gateway = var.create_internet_gateway
  internet_gateway_id     = module.internet_gateway.internet_gateway_id
  nat_gateway_ids         = module.nat_gateway.nat_gateway_ids
  tags                    = var.tags
}

module "route_table_association" {
  source                        = "../../base/route-table-association"
  public_rt_subnet_associations = var.public_rt_subnet_associations
  rt_subnet_associations        = var.rt_subnet_associations
  public_subnet_ids             = module.subnet.public_subnet_ids
  private_subnet_ids            = module.subnet.private_subnet_ids
  public_route_table_ids        = module.route_table.public_route_table_ids
  private_route_table_ids       = module.route_table.private_route_table_ids
}
