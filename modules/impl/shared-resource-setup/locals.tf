locals {
  vpc_public_rt_names  = { for name, vpc in var.vpcs : name => "${name}-public-rt" }
  vpc_private_rt_names = { for name, vpc in var.vpcs : name => "${name}-private-rt" }

  peer_cidr = { for name, vpc in var.vpcs : name => one([for other, o in var.vpcs : o.cidr_block if other != name]) }

  endpoint_vpc_id     = module.local_vpc[var.endpoint_vpc_name].id
  endpoint_subnet_ids = values(length(var.vpcs[var.endpoint_vpc_name].private_subnets) > 0 ? module.local_subnet[var.endpoint_vpc_name].private_subnets : module.local_subnet[var.endpoint_vpc_name].public_subnets)
  endpoint_service_domain = {
    for s in var.endpoint_services : s => "${s}.${data.aws_region.current.region}.amazonaws.com"
  }
  consumer_vpc_names = [for name in keys(var.vpcs) : name if name != var.endpoint_vpc_name]

  ec2_vpc_name  = local.consumer_vpc_names[0]
  ec2_subnet_id = values(module.local_subnet[local.ec2_vpc_name].private_subnets)[0]
}

locals {
  egress_public_rt_name  = "${var.egress_vpc.name}-public-rt"
  egress_private_rt_name = "${var.egress_vpc.name}-private-rt"
  egress_nat_name        = "${var.egress_vpc.name}-nat"
  egress_nat_subnet_name = var.egress_vpc.public_subnets[0].name
}
