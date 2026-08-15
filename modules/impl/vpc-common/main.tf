module "local_vpc" {
  source                     = "../../base/vpc"
  create                     = var.create_vpc
  name                       = var.vpc_name
  cidr_block                 = var.vpc_cidr_block
  enable_flow_logs           = true
  flow_logs_destination_type = "cloud-watch-logs"
  tags                       = var.common_tags
}

module "local_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.common_tags

  depends_on = [module.local_vpc]
}

module "local_eip" {
  source   = "../../base/eip"
  for_each = { for eip in var.eips : eip.name => eip }

  name = each.value.name
  tags = var.common_tags
}

module "local_nat_gateway" {
  source   = "../../base/nat-gateway"
  for_each = { for gw in var.nat_gateways : gw.name => gw }

  name      = each.value.name
  subnet_id = module.local_subnet.private_subnets[each.value.subnet_name]
  eip_id    = module.local_eip[each.value.eip_name].id
  tags      = var.common_tags

  depends_on = [module.local_subnet, module.local_eip]
}

module "local_internet_gateway" {
  source = "../../base/internet-gateway"

  vpc_id = module.local_vpc.id
  name   = var.internet_gateway_name
  tags   = var.common_tags
}

module "local_route_table" {
  source = "../../base/route-table"

  vpc_id               = module.local_vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.local_internet_gateway.id
  nat_gateway_ids      = { for name, ng in module.local_nat_gateway : name => ng.id }
  tags                 = var.common_tags

  depends_on = [module.local_vpc, module.local_internet_gateway]
}

module "local_route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc        = var.public_rtb_assoc
  private_rtb_assoc       = var.private_rtb_assoc
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = module.local_subnet.private_subnets
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = module.local_route_table.private_route_table_ids

  depends_on = [module.local_subnet, module.local_route_table]
}
