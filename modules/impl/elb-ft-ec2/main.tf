module "vpc" {
  source = "../../base/vpc"

  create     = var.create_vpc
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "subnet" {
  source = "../../base/subnet"

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

  name   = var.internet_gateway_name
  vpc_id = module.vpc.id
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
  source = "../../base/route-table"

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

module "primary_ec2_key_pair" {
  source = "../../base/key-pair"
  create = var.primary_ec2_create_key_pair

  name = var.primary_ec2_key_pair_name
  tags = var.tags
}

module "primary_ec2" {
  source = "../../base/ec2"

  name                         = var.primary_ec2_name
  ami_id                       = var.primary_ec2_ami_id
  instance_type                = var.primary_ec2_instance_type
  subnet_id                    = module.subnet.private_subnets[var.primary_ec2_subnet_name]
  security_group_ids           = [for sg_name in var.primary_ec2_security_group_names : module.sg[sg_name].id]
  associate_public_ip          = var.primary_ec2_associate_public_ip
  ssh_user                     = var.primary_ec2_ssh_user
  user_data                    = file("${path.module}/scripts/primary_ec2_setup.sh")
  volume_size                  = var.primary_ec2_volume_size
  volume_type                  = var.primary_ec2_volume_type
  volume_encrypted             = var.primary_ec2_volume_encrypted
  volume_delete_on_termination = var.primary_ec2_volume_delete_on_termination
  key_name                     = module.primary_ec2_key_pair.name
  tags                         = var.tags
}

module "standby_ec2_key_pair" {
  source = "../../base/key-pair"
  create = var.standby_ec2_create_key_pair

  name = var.standby_ec2_key_pair_name
  tags = var.tags
}

module "standby_ec2" {
  source = "../../base/ec2"

  name                         = var.standby_ec2_name
  ami_id                       = var.standby_ec2_ami_id
  instance_type                = var.standby_ec2_instance_type
  subnet_id                    = module.subnet.private_subnets[var.standby_ec2_subnet_name]
  security_group_ids           = [for sg_name in var.standby_ec2_security_group_names : module.sg[sg_name].id]
  associate_public_ip          = var.standby_ec2_associate_public_ip
  ssh_user                     = var.standby_ec2_ssh_user
  user_data                    = file("${path.module}/scripts/standby_ec2_setup.sh")
  volume_size                  = var.standby_ec2_volume_size
  volume_type                  = var.standby_ec2_volume_type
  volume_encrypted             = var.standby_ec2_volume_encrypted
  volume_delete_on_termination = var.standby_ec2_volume_delete_on_termination
  key_name                     = module.standby_ec2_key_pair.name
  tags                         = var.tags
}

module "nlb" {
  source = "../../base/nlb"

  name               = var.nlb_name
  enable_public      = var.nlb_enable_public
  vpc_id             = module.vpc.id
  security_group_ids = [for name in var.nlb_security_group_names : module.sg[name].id]
  subnet_mappings    = local.combined_nlb_subnet_mappings
  target_groups      = local.combined_nlb_target_groups
  attachments        = local.combined_nlb_attachments
  listeners          = var.nlb_listeners
  tags               = var.tags

  depends_on = [module.primary_ec2, module.standby_ec2]
}

module "alb" {
  source = "../../base/alb2"

  name                       = var.alb_name
  enable_public              = var.alb_enable_public
  enable_deletion_protection = var.alb_enable_deletion_protection
  vpc_id                     = module.vpc.id
  subnet_ids                 = [for name in var.alb_subnet_names : module.subnet.public_subnets[name]]
  security_group_ids         = [for name in var.alb_security_group_names : module.sg[name].id]
  target_groups              = var.alb_target_groups
  listeners                  = var.alb_listeners
  attachments                = local.combined_alb_attachments
  tags                       = var.tags

  depends_on = [module.primary_ec2, module.standby_ec2]
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
      name  = "${var.primary_ec2_key_pair_name}-private-key"
      value = module.primary_ec2_key_pair.private_key_pem
    },
    {
      name  = "${var.primary_ec2_key_pair_name}-public-key"
      value = module.primary_ec2_key_pair.public_key_openssh
    },
    {
      name  = "${var.standby_ec2_key_pair_name}-private-key"
      value = module.standby_ec2_key_pair.private_key_pem
    },
    {
      name  = "${var.standby_ec2_key_pair_name}-public-key"
      value = module.standby_ec2_key_pair.public_key_openssh
    }
  ]

  depends_on = [
    module.primary_ec2_key_pair,
    module.standby_ec2_key_pair,
    module.bastion_key_pair
  ]
  tags = var.tags
}
