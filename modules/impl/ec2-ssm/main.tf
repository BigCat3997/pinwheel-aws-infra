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

module "local_route_table" {
  source               = "../../base/route-table"
  vpc_id               = module.local_vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.local_internet_gateway.id
  tags                 = var.common_tags

  depends_on = [module.local_vpc, module.local_internet_gateway]
}

module "local_route_table_association" {
  source                  = "../../base/route-table-association"
  public_rtb_assoc        = var.public_rtb_assoc
  private_rtb_assoc       = var.private_rtb_assoc
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = module.local_subnet.private_subnets
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = module.local_route_table.private_route_table_ids

  depends_on = [module.local_subnet, module.local_route_table]
}

module "local_ec2_sg" {
  source = "../../base/sg"

  name   = "${var.ec2_name}-sg"
  vpc_id = module.local_vpc.id

  # No inbound rules: access is through Session Manager only.
  security_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all inbound"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = var.common_tags
}

module "local_vpc_endpoints_sg" {
  source = "../../base/sg"

  name   = "${var.ec2_name}-vpce-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      security_group_id = module.local_ec2_sg.id
      description       = "HTTPS from EC2 to SSM interface endpoints"
    }
  ]

  tags = var.common_tags
}

module "local_ssm_vpce" {
  source   = "../../base/vpce"
  for_each = local.ssm_endpoint_services

  name                = "${var.ec2_name}-${each.key}-vpce"
  vpc_id              = module.local_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.endpoint_subnet_ids
  security_group_ids  = [module.local_vpc_endpoints_sg.id]
  private_dns_enabled = true
  tags                = var.common_tags
}

module "local_ec2_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.ec2_name}-ssm-role"
  path                    = "/"
  description             = "EC2 role for Systems Manager Session Manager access"
  assume_role_policy_file = "${path.module}/resources/iam/ec2-role.json"
  managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

  tags = var.common_tags
}

module "local_ec2_key_pair" {
  source = "../../base/key-pair"

  create     = var.ec2_create_key_pair
  name       = var.ec2_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_rhel_ec2_key_pair" {
  source = "../../base/key-pair"

  create     = var.rhel_ec2_create_key_pair
  name       = var.rhel_ec2_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.rhel_ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_ec2" {
  source = "../../base/ec2"

  name                         = var.ec2_name
  ami_id                       = local.ec2_ami_id
  instance_type                = var.ec2_instance_type
  subnet_id                    = local.subnet_ids_by_name[var.ec2_subnet_name]
  security_group_ids           = [module.local_ec2_sg.id]
  associate_public_ip          = var.ec2_associate_public_ip
  user_data                    = null
  instance_profile_name        = "${var.ec2_name}-profile"
  role_name                    = module.local_ec2_iam_role.role_name
  volume_size                  = var.ec2_volume_size
  volume_type                  = var.ec2_volume_type
  volume_encrypted             = var.ec2_volume_encrypted
  volume_delete_on_termination = true
  volume_tags                  = var.ec2_volume_tags
  key_name                     = module.local_ec2_key_pair.name

  tags = var.common_tags

  depends_on = [module.local_ssm_vpce, module.local_ec2_iam_role]
}

module "local_rhel_ec2" {
  source = "../../base/ec2"

  name                         = var.rhel_ec2_name
  ami_id                       = local.rhel_ec2_ami_id
  instance_type                = var.rhel_ec2_instance_type
  ssh_user                     = "ec2-user"
  subnet_id                    = local.subnet_ids_by_name[var.ec2_subnet_name]
  security_group_ids           = [module.local_ec2_sg.id]
  associate_public_ip          = var.ec2_associate_public_ip
  user_data                    = local.rhel_user_data
  instance_profile_name        = "${var.rhel_ec2_name}-profile"
  role_name                    = module.local_ec2_iam_role.role_name
  volume_size                  = var.ec2_volume_size
  volume_type                  = var.ec2_volume_type
  volume_encrypted             = var.ec2_volume_encrypted
  volume_delete_on_termination = true
  volume_tags                  = var.ec2_volume_tags
  key_name                     = module.local_rhel_ec2_key_pair.name

  tags = var.common_tags

  depends_on = [module.local_ssm_vpce, module.local_ec2_iam_role]
}

module "kms" {
  source = "../../base/kms"

  kms_key_name = var.kms_key_name
  description  = var.kms_description
  tags         = var.common_tags
}

module "ec2_secrets" {
  source = "../../base/secret"

  secrets = [
    {
      name  = "ec2/${var.ec2_name}/ec2-user/public-key"
      value = module.local_ec2_key_pair.public_key
    },
    {
      name  = "ec2/${var.rhel_ec2_name}/ec2-user/public-key"
      value = module.local_rhel_ec2_key_pair.public_key
    },
  ]

  resource_policy = templatefile("${path.module}/templates/secrets/secret-resource-policy.json.tftpl", {
    user_arn = data.aws_caller_identity.current.arn
  })
  kms_key_id = module.kms.id

  depends_on = [
    module.local_ec2_key_pair,
    module.local_rhel_ec2_key_pair,
  ]
  tags = var.common_tags
}
