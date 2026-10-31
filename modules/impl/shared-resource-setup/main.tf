module "local_vpc" {
  source   = "../../base/vpc"
  for_each = var.vpcs

  create                     = each.value.create
  name                       = each.key
  cidr_block                 = each.value.cidr_block
  enable_flow_logs           = each.value.enable_flow_logs
  flow_logs_destination_type = "cloud-watch-logs"
  tags                       = var.common_tags
}

module "local_subnet" {
  source   = "../../base/subnet"
  for_each = var.vpcs

  vpc_id          = module.local_vpc[each.key].id
  create          = each.value.create
  public_subnets  = each.value.public_subnets
  private_subnets = each.value.private_subnets
  tags            = var.common_tags
}

module "local_internet_gateway" {
  source   = "../../base/internet-gateway"
  for_each = { for name, vpc in var.vpcs : name => vpc if vpc.create && length(vpc.public_subnets) > 0 }

  vpc_id = module.local_vpc[each.key].id
  name   = "${each.key}-igw"
  tags   = var.common_tags
}

module "local_route_table" {
  source   = "../../base/route-table"
  for_each = var.vpcs

  vpc_id               = module.local_vpc[each.key].id
  public_route_tables  = length(each.value.public_subnets) > 0 ? [{ name = local.vpc_public_rt_names[each.key] }] : []
  private_route_tables = [{ name = local.vpc_private_rt_names[each.key], nat_gw_name = null }]
  internet_gateway_id  = try(module.local_internet_gateway[each.key].id, null)
  tags                 = var.common_tags
}

module "local_route_table_association" {
  source   = "../../base/route-table-association"
  for_each = var.vpcs

  public_rtb_assoc = [
    for s in each.value.public_subnets : {
      key              = "${each.key}-${s.name}"
      subnet_name      = s.name
      route_table_name = local.vpc_public_rt_names[each.key]
    }
  ]
  private_rtb_assoc = [
    for s in each.value.private_subnets : {
      key              = "${each.key}-${s.name}"
      subnet_name      = s.name
      route_table_name = local.vpc_private_rt_names[each.key]
    }
  ]
  public_subnet_ids       = module.local_subnet[each.key].public_subnets
  private_subnet_ids      = module.local_subnet[each.key].private_subnets
  public_route_table_ids  = module.local_route_table[each.key].public_route_table_ids
  private_route_table_ids = module.local_route_table[each.key].private_route_table_ids
}

module "tgw" {
  source = "../../base/tgw"

  name            = var.tgw_name
  amazon_side_asn = var.tgw_amazon_side_asn
  tags            = var.common_tags
}

# Attach each VPC to the TGW using its private subnets (public ones if it has none)
module "tgw_vpc_attachment" {
  source   = "../../base/tgw-vpc-attachment"
  for_each = var.vpcs

  name               = "${each.key}-tgw-attachment"
  transit_gateway_id = module.tgw.id
  vpc_id             = module.local_vpc[each.key].id
  subnet_ids         = values(length(each.value.private_subnets) > 0 ? module.local_subnet[each.key].private_subnets : module.local_subnet[each.key].public_subnets)
  tags               = var.common_tags
}

# Route each VPC's traffic for the other VPC's CIDR through the TGW
module "local_peer_route" {
  source   = "../../base/route"
  for_each = var.vpcs

  route_table_ids = merge(
    module.local_route_table[each.key].public_route_table_ids,
    module.local_route_table[each.key].private_route_table_ids,
  )
  destination_cidr_block = local.peer_cidr[each.key]
  transit_gateway_id     = module.tgw.id

  depends_on = [module.tgw_vpc_attachment]
}

module "vpce_sg" {
  source = "../../base/sg"

  name   = "${var.endpoint_vpc_name}-vpce-sg"
  vpc_id = local.endpoint_vpc_id
  security_rules = [{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for vpc in var.vpcs : vpc.cidr_block]
    description = "HTTPS from both VPCs"
  }]
  tags = var.common_tags
}

# Private DNS is off on the endpoints; the private hosted zones below resolve
# the service names to the endpoints for both VPCs.
module "local_vpce" {
  source   = "../../base/vpc-endpoint"
  for_each = toset(var.endpoint_services)

  name                = "${var.endpoint_vpc_name}-${each.key}-vpce"
  vpc_id              = local.endpoint_vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.key}"
  subnet_ids          = local.endpoint_subnet_ids
  security_group_ids  = [module.vpce_sg.id]
  private_dns_enabled = false
  tags                = var.common_tags

  depends_on = [module.local_subnet]
}

module "local_endpoint_zone" {
  source   = "../../base/route53-alias-zone"
  for_each = toset(var.endpoint_services)

  zone_name          = local.endpoint_service_domain[each.key]
  vpc_id             = local.endpoint_vpc_id
  associated_vpc_ids = { for name in local.consumer_vpc_names : name => module.local_vpc[name].id }
  alias_dns_name     = module.local_vpce[each.key].dns_name
  alias_zone_id      = module.local_vpce[each.key].hosted_zone_id
  tags               = var.common_tags
}

# Lets dnf reach the AL2023 package repos (hosted in S3) from the subnet with no internet route
module "local_s3_vpce" {
  source = "../../base/vpc-endpoint"

  name            = "${local.ec2_vpc_name}-s3-vpce"
  vpc_id          = module.local_vpc[local.ec2_vpc_name].id
  service_name    = "com.amazonaws.${data.aws_region.current.region}.s3"
  endpoint_type   = "Gateway"
  route_table_ids = values(module.local_route_table[local.ec2_vpc_name].private_route_table_ids)
  tags            = var.common_tags
}

module "local_cloudwatch_log_group" {
  source = "../../base/cloudwatch-log-groups"

  log_groups = [{
    key               = "ec2_metrics"
    name              = var.ec2_log_group_name
    retention_in_days = var.ec2_log_retention_days
    tags              = var.common_tags
  }]
}

module "ec2_iam_role" {
  source = "../../base/iam-role"

  name        = "${var.ec2_name}-ssm-role"
  description = "EC2 role for Systems Manager Session Manager access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  inline_policies = {
    push-metrics-logs = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams", "logs:PutRetentionPolicy"]
        Resource = "${module.local_cloudwatch_log_group.arns[var.ec2_log_group_name]}:*"
      }]
    })
  }
  tags = var.common_tags
}

# No inbound rules: access is through Session Manager only
module "ec2_sg" {
  source = "../../base/sg"

  name           = "${var.ec2_name}-sg"
  vpc_id         = module.local_vpc[local.ec2_vpc_name].id
  security_rules = []
  egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }]
  tags = var.common_tags
}

module "ec2" {
  source = "../../base/ec2"

  name                  = var.ec2_name
  ami_id                = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type         = var.ec2_instance_type
  subnet_id             = local.ec2_subnet_id
  security_group_ids    = [module.ec2_sg.id]
  associate_public_ip   = false
  instance_profile_name = "${var.ec2_name}-profile"
  user_data = templatefile("${path.module}/templates/ec2-user-data.sh.tftpl", {
    log_group_name    = var.ec2_log_group_name
    retention_in_days = var.ec2_log_retention_days
    interval_seconds  = var.ec2_metrics_interval_seconds
  })
  user_data_replace_on_change = true
  role_name                   = module.ec2_iam_role.role_name
  volume_size                 = var.ec2_volume_size
  volume_type                 = "gp3"
  volume_encrypted            = true
  tags                        = var.common_tags

  # SSM needs the endpoints, DNS zones and TGW routes in place to register
  depends_on = [
    module.local_vpce,
    module.local_endpoint_zone,
    module.local_peer_route,
    module.local_s3_vpce,
    module.spoke_internet_route,
    module.egress_return_route,
    module.egress_nat_gateway,
  ]
}

# Centralized egress VPC: private subnets of the other VPCs reach the internet
# through the NAT gateway here, over the Transit Gateway.
module "egress_vpc" {
  source = "../../base/vpc"

  create                     = true
  name                       = var.egress_vpc.name
  cidr_block                 = var.egress_vpc.cidr_block
  enable_flow_logs           = var.egress_vpc.enable_flow_logs
  flow_logs_destination_type = "cloud-watch-logs"
  tags                       = var.common_tags
}

module "egress_subnet" {
  source = "../../base/subnet"

  vpc_id          = module.egress_vpc.id
  public_subnets  = var.egress_vpc.public_subnets
  private_subnets = var.egress_vpc.private_subnets
  tags            = var.common_tags
}

module "egress_internet_gateway" {
  source = "../../base/internet-gateway"

  vpc_id = module.egress_vpc.id
  name   = "${var.egress_vpc.name}-igw"
  tags   = var.common_tags
}

module "egress_eip" {
  source = "../../base/eip"

  name = "${local.egress_nat_name}-eip"
  tags = var.common_tags
}

module "egress_nat_gateway" {
  source = "../../base/nat-gateway"

  name      = local.egress_nat_name
  eip_id    = module.egress_eip.id
  subnet_id = module.egress_subnet.public_subnets[local.egress_nat_subnet_name]
  tags      = var.common_tags

  depends_on = [module.egress_internet_gateway]
}

module "egress_route_table" {
  source = "../../base/route-table"

  vpc_id               = module.egress_vpc.id
  public_route_tables  = [{ name = local.egress_public_rt_name }]
  private_route_tables = [{ name = local.egress_private_rt_name, nat_gw_name = local.egress_nat_name }]
  internet_gateway_id  = module.egress_internet_gateway.id
  nat_gateway_ids      = { (local.egress_nat_name) = module.egress_nat_gateway.id }
  tags                 = var.common_tags
}

module "egress_route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc = [
    for s in var.egress_vpc.public_subnets : {
      key              = "${var.egress_vpc.name}-${s.name}"
      subnet_name      = s.name
      route_table_name = local.egress_public_rt_name
    }
  ]
  private_rtb_assoc = [
    for s in var.egress_vpc.private_subnets : {
      key              = "${var.egress_vpc.name}-${s.name}"
      subnet_name      = s.name
      route_table_name = local.egress_private_rt_name
    }
  ]
  public_subnet_ids       = module.egress_subnet.public_subnets
  private_subnet_ids      = module.egress_subnet.private_subnets
  public_route_table_ids  = module.egress_route_table.public_route_table_ids
  private_route_table_ids = module.egress_route_table.private_route_table_ids
}

module "egress_tgw_vpc_attachment" {
  source = "../../base/tgw-vpc-attachment"

  name               = "${var.egress_vpc.name}-tgw-attachment"
  transit_gateway_id = module.tgw.id
  vpc_id             = module.egress_vpc.id
  subnet_ids         = values(module.egress_subnet.private_subnets)
  tags               = var.common_tags
}

# Internet-bound traffic in the TGW goes to the egress VPC
module "tgw_internet_route" {
  source = "../../base/tgw-route"

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = module.tgw.association_default_route_table_id
  transit_gateway_attachment_id  = module.egress_tgw_vpc_attachment.id
}

# Private subnets of each VPC send internet-bound traffic to the TGW
module "spoke_internet_route" {
  source   = "../../base/route"
  for_each = var.vpcs

  route_table_ids        = module.local_route_table[each.key].private_route_table_ids
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.tgw.id

  depends_on = [module.tgw_vpc_attachment, module.tgw_internet_route]
}

# NAT return traffic: the egress public subnets send each VPC's CIDR back to the TGW
module "egress_return_route" {
  source   = "../../base/route"
  for_each = var.vpcs

  route_table_ids        = module.egress_route_table.public_route_table_ids
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = module.tgw.id

  depends_on = [module.egress_tgw_vpc_attachment]
}
