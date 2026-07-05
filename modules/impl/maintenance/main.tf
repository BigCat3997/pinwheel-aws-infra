module "local_vpc" {
  source = "../../base/vpc"

  create               = true
  name                 = "${var.name_prefix}-vpc"
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.common_tags
}

module "local_internet_gateway" {
  source = "../../base/internet-gateway"

  vpc_id = module.local_vpc.id
  name   = "${var.name_prefix}-igw"
  tags   = local.common_tags
}

module "local_subnet" {
  source = "../../base/subnet"

  vpc_id          = module.local_vpc.id
  create          = true
  public_subnets  = var.public_subnets
  private_subnets = []
  tags            = local.common_tags
}

module "local_route_table" {
  source = "../../base/route-table"

  vpc_id               = module.local_vpc.id
  public_route_tables  = [{ name = "${var.name_prefix}-public-rt" }]
  private_route_tables = []
  internet_gateway_id  = module.local_internet_gateway.id
  tags                 = local.common_tags
}

module "local_route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc = [
    for subnet in var.public_subnets : {
      key              = "public-${subnet.name}"
      subnet_name      = subnet.name
      route_table_name = "${var.name_prefix}-public-rt"
    }
  ]
  private_rtb_assoc       = []
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = {}
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = {}
}

module "local_sg_alb" {
  source = "../../base/sg"

  name   = "${var.name_prefix}-alb-sg"
  vpc_id = module.local_vpc.id
  security_rules = [
    {
      description = "HTTP from internet"
      from_port   = var.alb_port
      to_port     = var.alb_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = local.common_tags
}

module "local_sg_web" {
  source = "../../base/sg"

  name   = "${var.name_prefix}-web-sg"
  vpc_id = module.local_vpc.id
  security_rules = [
    {
      description       = "HTTP from ALB only"
      from_port         = var.instance_port
      to_port           = var.instance_port
      protocol          = "tcp"
      security_group_id = module.local_sg_alb.id
    },
    {
      description = "Optional SSH for admin access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = local.common_tags
}

module "local_sg_lambda" {
  source = "../../base/sg"

  name           = "${var.name_prefix}-lambda-sg"
  vpc_id         = module.local_vpc.id
  security_rules = []
  egress_rules = [
    {
      description = "HTTPS to S3 interface endpoint ENIs"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.local_vpc.cidr_block]
    }
  ]
  tags = local.common_tags
}

module "local_sg_s3_interface_endpoint" {
  source = "../../base/sg"

  name   = "${var.name_prefix}-s3-vpce-sg"
  vpc_id = module.local_vpc.id
  security_rules = [
    {
      description = "HTTPS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.local_vpc.cidr_block]
    }
  ]
  egress_rules = []
  tags         = local.common_tags
}

module "local_s3_interface_vpc_endpoint" {
  source = "../../base/vpce"

  vpc_id                                         = module.local_vpc.id
  service_name                                   = coalesce(var.s3_interface_service_name, "com.amazonaws.${var.aws_region}.s3")
  vpc_endpoint_type                              = var.s3_interface_vpc_endpoint_type
  auto_accept                                    = var.s3_interface_auto_accept
  policy                                         = var.s3_interface_policy
  route_table_ids                                = var.s3_interface_route_table_ids
  subnet_ids                                     = values(module.local_subnet.public_subnets)
  security_group_ids                             = [module.local_sg_s3_interface_endpoint.id]
  private_dns_enabled                            = var.s3_interface_private_dns_enabled
  ip_address_type                                = var.s3_interface_ip_address_type
  private_dns_only_for_inbound_resolver_endpoint = var.s3_interface_private_dns_only_for_inbound_resolver_endpoint
  name                                           = "${var.name_prefix}-s3-interface-vpce"
  tags                                           = local.common_tags
}

module "local_web_ec2" {
  source   = "../../base/ec2"
  for_each = module.local_subnet.public_subnets

  name                        = "${var.name_prefix}-${each.key}-nginx"
  ami_id                      = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = each.value
  security_group_ids          = [module.local_sg_web.id]
  associate_public_ip         = true
  key_name                    = var.key_pair_name
  user_data                   = templatefile("${path.module}/resources/templates/nginx_user_data.sh.tftpl", { instance_name = each.key })
  user_data_replace_on_change = true
  volume_size                 = 50
  volume_type                 = "gp3"
  tags                        = local.common_tags
  ec2_tags = {
    Role = "nginx"
  }
}


module "local_alb" {
  source = "../../base/alb"

  name                 = substr("${var.name_prefix}-alb", 0, 32)
  enable_public_access = true
  subnet_ids           = values(module.local_subnet.public_subnets)
  security_group_ids   = [module.local_sg_alb.id]
  vpc_id               = module.local_vpc.id

  target_group_name = substr("${var.name_prefix}-web-tg", 0, 32)
  target_port       = var.instance_port
  target_protocol   = "HTTP"
  target_instance_ids = [
    for _, inst in module.local_web_ec2 : inst.id
  ]

  health_check_matcher             = "200-399"
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2

  listener_port     = var.alb_port
  listener_protocol = "HTTP"

  maintenance_mode         = var.maintenance_mode
  lambda_function_arn      = module.local_maintenance_lambda.arn
  lambda_function_name     = module.local_maintenance_lambda.name
  lambda_target_group_name = substr("${var.name_prefix}-maint-tg", 0, 32)

  tags = local.common_tags
}

module "local_maintenance_s3" {
  source = "../../base/s3"

  create                       = true
  bucket_name                  = var.s3_bucket_name
  force_destroy                = var.force_destroy_bucket
  enable_versioning            = false
  enable_encryption            = false
  enable_public_access         = false
  enable_bucket_policy         = true
  enable_website_configuration = true
  website_index_document       = var.maintenance_object_key
  policy = templatefile("${path.module}/resources/iam/b3-s3-permitonlyvpce-policy.json.tftpl", {
    maintenance_bucket_arn = local.maintenance_bucket_arn
    lambda_role_arn        = module.local_lambda_iam_role.role_arn
    s3_interface_vpce_id   = module.local_s3_interface_vpc_endpoint.id
  })
  s3_objects = {
    (var.maintenance_object_key) = {
      source              = "${path.module}/resources/maintenance-site/index.html"
      content_type        = "text/html; charset=utf-8"
      content_disposition = "inline"
      cache_control       = "no-store, no-cache, must-revalidate"
    }
  }
  tags = local.common_tags
}

module "local_lambda_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.name_prefix}-lambda-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/resources/iam/lambda-assume-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
  inline_policies = {
    "bc-s3-maintenance-read-policy" = templatefile("${path.module}/resources/iam/bc-s3-readmaintenanceweb-policy.json.tftpl", {
      maintenance_bucket_arn = local.maintenance_bucket_arn
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-lambda-role"
  })
}

module "local_maintenance_lambda" {
  source = "../../base/lambda"

  name                = "${var.name_prefix}-maintenance"
  runtime             = "python3.12"
  handler             = "maintenance_handler.lambda_handler"
  timeout             = 20
  source_file         = "${path.module}/lambda/maintenance_handler.py"
  output_path         = "${path.module}/lambda/maintenance_handler.zip"
  create_role         = false
  role_name           = module.local_lambda_iam_role.role_name
  role_arn            = module.local_lambda_iam_role.role_arn
  create_function_url = true
  subnet_ids          = values(module.local_subnet.public_subnet_ids)
  security_group_ids  = [module.local_sg_lambda.id]
  env_vars = {
    BUCKET_NAME = var.s3_bucket_name
    OBJECT_KEY  = var.maintenance_object_key
  }
  tags = local.common_tags

  depends_on = [
    module.local_lambda_iam_role,
    module.local_s3_interface_vpc_endpoint,
  ]
}
