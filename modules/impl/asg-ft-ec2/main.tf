module "vpc" {
  source     = "../../base/vpc"
  create     = var.create_vpc
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
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
  source   = "../../base/eip"
  for_each = { for ngw in var.nat_gateways : ngw.eip_name => ngw }

  name = each.key
  tags = var.tags
}

module "internet_gateway" {
  source = "../../base/internet-gateway"
  vpc_id = module.vpc.id
  name   = var.internet_gateway_name
  tags   = var.tags
}

module "nat_gateway" {
  source   = "../../base/nat-gateway"
  for_each = { for ngw in var.nat_gateways : ngw.name => ngw }

  name      = each.key
  eip_id    = module.eip[each.value.eip_name].id
  subnet_id = module.subnet.public_subnets[each.value.subnet_name]
  tags      = var.tags
}

module "route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.internet_gateway.id
  nat_gateway_ids      = { for name, ngw in module.nat_gateway : name => ngw.id }
  tags                 = var.tags
}

module "route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc        = var.public_rtb_subnet_assocs
  private_rtb_assoc       = var.private_rtb_subnet_assocs
  public_subnet_ids       = module.subnet.public_subnets
  private_subnet_ids      = module.subnet.private_subnets
  public_route_table_ids  = module.route_table.public_route_table_ids
  private_route_table_ids = module.route_table.private_route_table_ids
}

module "sg" {
  source   = "../../base/sg"
  for_each = { for sg in var.security_groups : sg.name => sg }

  name           = each.value.name
  vpc_id         = module.vpc.id
  security_rules = each.value.security_rules
  egress_rules   = each.value.egress_rules
  tags           = var.tags
}

module "kms" {
  source = "../../base/kms"

  kms_key_name = var.kms_key_name
  description  = var.kms_description
  tags         = var.tags
}

module "bastion_key_pair" {
  source = "../../base/key-pair"

  create = var.bastion_create_key_pair
  name   = var.bastion_key_pair_name
  tags   = var.tags
}

module "bastion_ec2" {
  source = "../../base/ec2"

  name                         = var.bastion_name
  ami_id                       = var.bastion_ami_id
  instance_type                = var.bastion_instance_type
  subnet_id                    = module.subnet.public_subnets[var.bastion_subnet_name]
  security_group_ids           = [for sg_name in var.bastion_security_group_names : module.sg[sg_name].id]
  associate_public_ip          = var.bastion_associate_public_ip
  ssh_user                     = var.bastion_ssh_user
  user_data                    = file("${path.module}/scripts/bastion_ec2_setup.sh")
  volume_size                  = var.bastion_volume_size
  volume_type                  = var.bastion_volume_type
  volume_encrypted             = var.bastion_volume_encrypted
  volume_delete_on_termination = var.bastion_volume_delete_on_termination
  create_external_volume       = var.bastion_create_external_volume
  key_name                     = module.bastion_key_pair.name

  tags = var.tags
}

module "app_ec2_key_pair" {
  source = "../../base/key-pair"
  create = var.app_ec2_create_key_pair

  name = var.app_ec2_key_pair_name
  tags = var.tags
}

module "app_ec2" {
  source = "../../base/ec2"

  name                         = var.app_ec2_name
  ami_id                       = var.app_ec2_ami_id
  instance_type                = var.app_ec2_instance_type
  subnet_id                    = module.subnet.private_subnets[var.app_ec2_subnet_name]
  security_group_ids           = [for sg_name in var.app_ec2_security_group_names : module.sg[sg_name].id]
  associate_public_ip          = var.app_ec2_associate_public_ip
  ssh_user                     = var.app_ec2_ssh_user
  user_data                    = file("${path.module}/scripts/app_ec2_setup.sh")
  volume_size                  = var.app_ec2_volume_size
  volume_type                  = var.app_ec2_volume_type
  volume_encrypted             = var.app_ec2_volume_encrypted
  volume_delete_on_termination = var.app_ec2_volume_delete_on_termination
  key_name                     = module.app_ec2_key_pair.name
  # metadata_http_endpoint               = var.app_ec2_metadata_http_endpoint
  # metadata_http_tokens                 = var.app_ec2_metadata_http_tokens
  # metadata_http_put_response_hop_limit = var.app_ec2_metadata_http_put_response_hop_limit
  # metadata_instance_metadata_tags      = var.app_ec2_metadata_instance_metadata_tags

  tags = var.tags
}

module "lt_ec2_key_pair" {
  source = "../../base/key-pair"
  create = var.create_lt_ec2_key_pair
  name   = var.lt_ec2_key_pair_name
  tags   = var.tags
}

module "launch_template" {
  source              = "../../base/launch-template"
  name_prefix         = var.lt_name_prefix
  ami_id              = var.lt_ami_id
  instance_type       = var.lt_instance_type
  key_name            = module.lt_ec2_key_pair.name
  user_data           = file("${path.module}/scripts/lt_ec2_setup.sh")
  associate_public_ip = var.lt_associate_public_ip
  security_group_ids  = [for sg_name in var.lt_security_group_names : module.sg[sg_name].id]
  volume_type         = var.lt_volume_type
  volume_size         = var.lt_volume_size
  volume_encrypted    = var.lt_volume_encrypted
  name                = var.lt_name

  tags = var.tags
}

module "asg" {
  source                    = "../../base/asg"
  name                      = var.asg_name
  instance_name             = var.asg_instance_name
  subnet_ids                = [for name in var.asg_subnet_names : module.subnet.private_subnets[name]]
  launch_template_id        = module.launch_template.id
  launch_template_version   = module.launch_template.latest_version
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_type         = var.asg_health_check_type
  health_check_grace_period = var.asg_health_check_grace_period
  wait_for_capacity_timeout = var.asg_wait_for_capacity_timeout

  tags = var.tags
}

module "nlb" {
  source = "../../base/nlb"

  name                 = var.nlb_name
  enable_public_access = var.nlb_enable_public_access
  vpc_id               = module.vpc.id
  subnet_mappings      = local.subnet_mappings
  listener_port        = var.nlb_listener_port
  listener_protocol    = var.nlb_listener_protocol
  target_groups = [
    {
      name                   = var.nlb_target_group_name
      port                   = var.nlb_target_port
      protocol               = var.nlb_target_protocol
      target_type            = var.nlb_target_type
      enable_stickiness      = var.nlb_enable_stickiness
      autoscaling_group_name = module.asg.name
      target_ips             = var.nlb_target_ips
    }
  ]
  tags = var.tags
}

module "alb" {
  source                 = "../../base/alb"
  name                   = var.alb_name
  vpc_id                 = module.vpc.id
  subnet_ids             = [for name in var.asg_subnet_names : module.subnet.private_subnets[name]]
  security_group_ids     = [for name in var.lt_security_group_names : module.sg[name].id]
  target_group_name      = var.alb_target_group_name
  target_port            = var.alb_target_port
  target_protocol        = var.alb_target_protocol
  listener_port          = var.alb_listener_port
  listener_protocol      = var.alb_listener_protocol
  autoscaling_group_name = module.asg.name
  tags                   = var.tags
}

module "secrets" {
  source = "../../base/secret"

  kms_key_id = module.kms.id
  secrets = [
    {
      name  = "${var.bastion_key_pair_name}-private-key"
      value = module.bastion_key_pair.private_key_pem
    },
    {
      name  = "${var.bastion_key_pair_name}-public-key"
      value = module.bastion_key_pair.public_key_openssh
    },
    {
      name  = "${var.app_ec2_key_pair_name}-private-key"
      value = module.app_ec2_key_pair.private_key_pem
    },
    {
      name  = "${var.app_ec2_key_pair_name}-public-key"
      value = module.app_ec2_key_pair.public_key_openssh
    },
    {
      name  = "${var.lt_ec2_key_pair_name}-private-key"
      value = module.lt_ec2_key_pair.private_key_pem
    },
    {
      name  = "${var.lt_ec2_key_pair_name}-public-key"
      value = module.lt_ec2_key_pair.public_key_openssh
    }
  ]

  depends_on = [
    module.lt_ec2_key_pair,
    module.app_ec2_key_pair,
    module.bastion_key_pair
  ]
  tags = var.tags
}
