module "local_vpc" {
  source     = "../../base/vpc"
  create     = var.create_vpc
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "local_subnet" {
  source          = "../../base/subnet"
  vpc_id          = module.local_vpc.id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags

  depends_on = [module.local_vpc]
}

module "local_eip" {
  source   = "../../base/eip"
  for_each = { for eip in var.eips : eip.name => eip }

  name = each.value.name
  tags = var.tags
}

module "local_nat_gateway" {
  source   = "../../base/nat-gateway"
  for_each = { for gw in var.nat_gateways : gw.name => gw }

  name      = each.value.name
  subnet_id = module.local_subnet.public_subnet_ids[each.value.subnet_name]
  eip_id    = module.local_eip[each.value.eip_name].id
  tags      = var.tags

  depends_on = [module.local_subnet, module.local_eip]
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
  private_route_tables = var.private_route_tables
  internet_gateway_id  = module.local_internet_gateway.internet_gateway_id
  nat_gateway_ids      = { for name, ng in module.local_nat_gateway : name => ng.id }
  tags                 = var.tags

  depends_on = [module.local_vpc, module.local_internet_gateway, module.local_nat_gateway]
}

module "local_route_table_association" {
  source                  = "../../base/route-table-association"
  public_rtb_assoc        = var.public_rtb_assoc
  private_rtb_assoc       = var.private_rtb_assoc
  public_subnet_ids       = module.local_subnet.public_subnet_ids
  private_subnet_ids      = module.local_subnet.private_subnet_ids
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = module.local_route_table.private_route_table_ids

  depends_on = [module.local_subnet, module.local_route_table]
}

module "local_ec2_cloudwatch_agent_iam_policy" {
  source = "../../base/iam-policy"

  name        = "${var.bastion_name}-cloudwatch-policy"
  path        = "/"
  description = "IAM policy for EC2 CloudWatch agent"
  policy_file = "${path.module}/resources/iam/cloudwatch-policy.json"

  tags = var.tags
}

module "local_ec2_cloudwatch_agent_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.bastion_name}-cloudwatch-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/resources/iam/cloudwatch-role.json"
  managed_policy_arns = [
    module.local_ec2_cloudwatch_agent_iam_policy.policy_arn
  ]

  tags = var.tags
}

module "local_secrets" {
  source = "../../base/secret"

  secrets = [
    {
      name  = "${var.bastion_key_pair_name}-private-key"
      value = module.local_bastion_key_pair.private_key_pem
    },
    {
      name  = "${var.bastion_key_pair_name}-public-key"
      value = module.local_bastion_key_pair.public_key_openssh
    },
    {
      name  = "${var.app_ec2_key_pair_name}-private-key"
      value = module.local_app_ec2_key_pair.private_key_pem
    },
    {
      name  = "${var.app_ec2_key_pair_name}-public-key"
      value = module.local_app_ec2_key_pair.public_key_openssh
    },
    {
      name  = "${var.app_standby_ec2_key_pair_name}-private-key"
      value = module.local_app_standby_ec2_key_pair.private_key_pem
    },
    {
      name  = "${var.app_standby_ec2_key_pair_name}-public-key"
      value = module.local_app_standby_ec2_key_pair.public_key_openssh
    },
  ]

  tags = var.tags
}

module "local_sg" {
  source   = "../../base/sg"
  for_each = { for sg in var.nsg_definitions : sg.name => sg }

  name           = each.value.name
  vpc_id         = module.local_vpc.id
  security_rules = each.value.security_rules
  egress_rules   = each.value.egress_rules
  tags           = var.tags
}

module "local_bastion_key_pair" {
  source = "../../base/key-pair"
  create = var.bastion_create_key_pair

  name            = var.bastion_key_pair_name
  public_key_path = var.bastion_public_key_path
  tags            = var.tags
}

module "local_bastion_ec2" {
  source = "../../base/ec2"

  name                         = var.bastion_name
  ami_id                       = var.bastion_ami_id
  instance_type                = var.bastion_instance_type
  subnet_id                    = module.local_subnet.public_subnet_ids[var.bastion_subnet_name]
  private_ip                   = local.bastion_private_ip_static
  security_group_ids           = [for sg_name in var.bastion_security_group_names : module.local_sg[sg_name].id]
  associate_public_ip          = var.bastion_associate_public_ip
  ssh_user                     = var.bastion_ssh_user
  user_data                    = coalesce(var.bastion_user_data, local.cloudwatch_user_data)
  instance_profile_name        = "${var.bastion_name}-profile"
  role_name                    = module.local_ec2_cloudwatch_agent_iam_role.role_name
  volume_size                  = var.bastion_volume_size
  volume_type                  = var.bastion_volume_type
  volume_encrypted             = var.bastion_volume_encrypted
  volume_delete_on_termination = var.bastion_volume_delete_on_termination
  create_external_volume       = var.bastion_create_external_volume
  key_name                     = module.local_bastion_key_pair.name

  tags = var.tags

  depends_on = [
    module.local_cloudwatch_config_ssm,
    module.local_ec2_cloudwatch_agent_iam_role,
    module.local_secrets,
  ]
}

module "local_app_ec2_key_pair" {
  source = "../../base/key-pair"
  create = var.app_ec2_create_key_pair

  name = var.app_ec2_key_pair_name
  tags = var.tags
}

module "local_app_ec2" {
  source = "../../base/ec2"

  name                         = var.app_ec2_name
  ami_id                       = var.app_ec2_ami_id
  instance_type                = var.app_ec2_instance_type
  subnet_id                    = module.local_subnet.private_subnet_ids[var.app_ec2_subnet_name]
  private_ip                   = local.app_ec2_private_ip_static
  security_group_ids           = [for sg_name in var.app_ec2_security_group_names : module.local_sg[sg_name].id]
  associate_public_ip          = var.app_ec2_associate_public_ip
  ssh_user                     = var.app_ec2_ssh_user
  user_data                    = coalesce(var.app_ec2_user_data, local.app_nginx_user_data)
  instance_profile_name        = "${var.app_ec2_name}-profile"
  role_name                    = module.local_ec2_cloudwatch_agent_iam_role.role_name
  volume_size                  = var.app_ec2_volume_size
  volume_type                  = var.app_ec2_volume_type
  volume_encrypted             = var.app_ec2_volume_encrypted
  volume_delete_on_termination = var.app_ec2_volume_delete_on_termination
  key_name                     = module.local_app_ec2_key_pair.name

  tags = var.tags

  depends_on = [
    module.local_cloudwatch_config_ssm,
    module.local_ec2_cloudwatch_agent_iam_role,
    module.local_secrets
  ]
}

module "local_nlb" {
  source = "../../base/nlb"

  name                 = var.nlb_name
  enable_public_access = var.nlb_enable_public_access
  vpc_id               = module.local_vpc.id
  subnet_ids = distinct([
    module.local_subnet.private_subnet_ids[var.app_ec2_subnet_name],
    module.local_subnet.private_subnet_ids[var.app_standby_ec2_subnet_name]
  ])
  listener_port     = var.nlb_listener_port
  listener_protocol = var.nlb_listener_protocol
  target_group_name = var.nlb_target_group_name
  target_port       = var.nlb_target_port
  target_protocol   = var.nlb_target_protocol
  target_type       = "instance"
  target_instance_ids = [
    module.local_app_ec2.id,
    module.local_app_standby_ec2.id
  ]
  tags = var.tags
}

module "local_alb" {
  source = "../../base/alb"

  name                 = var.alb_name
  enable_public_access = var.alb_enable_public_access
  vpc_id               = module.local_vpc.id
  subnet_ids = distinct([
    module.local_subnet.private_subnet_ids[var.app_ec2_subnet_name],
    module.local_subnet.private_subnet_ids[var.app_standby_ec2_subnet_name]
  ])
  # security_group_ids     = [for name in var.lt_security_group_names : module.sg[name].id]
  security_group_ids = null
  target_group_name  = var.alb_target_group_name
  target_port        = var.alb_target_port
  target_protocol    = var.alb_target_protocol
  listener_port      = var.alb_listener_port
  listener_protocol  = var.alb_listener_protocol
  target_instance_ids = [
    module.local_app_ec2.id,
    module.local_app_standby_ec2.id
  ]
  tags = var.tags
}

module "local_app_standby_ec2_key_pair" {
  source = "../../base/key-pair"
  create = var.app_standby_ec2_create_key_pair

  name = var.app_standby_ec2_key_pair_name
  tags = var.tags
}

module "local_app_standby_ec2" {
  source = "../../base/ec2"

  name                         = var.app_standby_ec2_name
  ami_id                       = var.app_standby_ec2_ami_id
  instance_type                = var.app_standby_ec2_instance_type
  subnet_id                    = module.local_subnet.private_subnet_ids[var.app_standby_ec2_subnet_name]
  private_ip                   = local.app_standby_ec2_private_ip_static
  security_group_ids           = [for sg_name in var.app_standby_ec2_security_group_names : module.local_sg[sg_name].id]
  associate_public_ip          = var.app_standby_ec2_associate_public_ip
  ssh_user                     = var.app_standby_ec2_ssh_user
  user_data                    = coalesce(var.app_standby_ec2_user_data, local.app_nginx_user_data)
  instance_profile_name        = "${var.app_standby_ec2_name}-profile"
  role_name                    = module.local_ec2_cloudwatch_agent_iam_role.role_name
  volume_size                  = var.app_standby_ec2_volume_size
  volume_type                  = var.app_standby_ec2_volume_type
  volume_encrypted             = var.app_standby_ec2_volume_encrypted
  volume_delete_on_termination = var.app_standby_ec2_volume_delete_on_termination
  key_name                     = module.local_app_standby_ec2_key_pair.name

  tags = var.tags

  depends_on = [
    module.local_cloudwatch_config_ssm,
    module.local_ec2_cloudwatch_agent_iam_role,
    module.local_secrets
  ]
}

module "local_app_s3" {
  source = "../../base/s3"

  create              = var.s3_create
  bucket_name         = var.s3_bucket_name
  force_destroy       = var.s3_force_destroy
  enable_versioning   = var.s3_enable_versioning
  enable_encryption   = var.s3_enable_encryption
  bucket_key_enabled  = var.s3_bucket_key_enabled
  block_public_access = var.s3_block_public_access
  tags                = var.tags
}

module "local_cloudwatch_logs_s3" {
  source = "../../base/s3"

  create              = true
  bucket_name         = var.cloudwatch_logs_bucket_name
  force_destroy       = var.s3_force_destroy
  enable_versioning   = true
  enable_encryption   = true
  bucket_key_enabled  = true
  block_public_access = true

  tags = merge(var.tags, {
    Name    = var.cloudwatch_logs_bucket_name
    Purpose = "cloudwatch-log-archive"
  })
}

resource "aws_vpc_endpoint" "cloudwatch_logs_archive_s3" {
  vpc_id            = module.local_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = values(module.local_route_table.private_route_table_ids)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowArchiveBucketAccessOnly"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          module.local_cloudwatch_logs_s3.arn,
          "${module.local_cloudwatch_logs_s3.arn}/${trim(var.cloudwatch_logs_archive_prefix, "/")}/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.bastion_name}-cwlogs-s3-vpce"
    Purpose = "cloudwatch-log-archive"
  })
}

module "local_app_efs_primary" {
  source = "../../base/efs"

  create            = var.efs_create
  name              = var.efs_primary_name
  enable_encryption = var.efs_enable_encryption
  # kms_key_id                      = var.efs_enable_encryption ? var.efs_kms_key_id : null
  performance_mode                = var.efs_performance_mode
  throughput_mode                 = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps
  transition_to_ia                = var.efs_transition_to_ia
  backup_policy_status            = var.efs_backup_policy_status
  subnet_ids                      = values(module.local_subnet.private_subnet_ids)
  # security_group_ids              = distinct(concat([for sg_name in var.app_ec2_security_group_names : module.local_sg[sg_name].id], [for sg_name in var.app_standby_ec2_security_group_names : module.local_sg[sg_name].id]))
  enable_mount = true
  tags         = var.tags
}

module "local_app_efs_standby" {
  source = "../../base/efs"

  create                          = var.efs_create
  name                            = var.efs_standby_name
  enable_encryption               = var.efs_enable_encryption
  performance_mode                = var.efs_performance_mode
  throughput_mode                 = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps
  transition_to_ia                = var.efs_transition_to_ia
  backup_policy_status            = var.efs_backup_policy_status
  subnet_ids                      = values(module.local_subnet.private_subnet_ids)
  enable_mount                    = false
  tags                            = var.tags
}

module "local_cloudwatch_log_groups" {
  source = "../../base/cloudwatch-log-group"

  log_groups = [
    {
      key               = "app_logs"
      name              = "/aws/ec2/application"
      retention_in_days = var.log_retention_days
      tags = merge(var.tags, {
        Name = "application-logs"
      })
    },
    {
      key               = "system_logs"
      name              = "/aws/ec2/system"
      retention_in_days = var.log_retention_days
      tags = merge(var.tags, {
        Name = "system-logs"
      })
    }
  ]
}

resource "aws_lambda_permission" "app_logs_invoke_archive_lambda" {
  statement_id  = "AllowExecutionFromAppLogGroup"
  action        = "lambda:InvokeFunction"
  function_name = module.local_cloudwatch_logs_archive_lambda.name
  principal     = "logs.${var.aws_region}.amazonaws.com"
  source_arn    = "${module.local_cloudwatch_log_groups.arns["app_logs"]}:*"
}

resource "aws_lambda_permission" "system_logs_invoke_archive_lambda" {
  statement_id  = "AllowExecutionFromSystemLogGroup"
  action        = "lambda:InvokeFunction"
  function_name = module.local_cloudwatch_logs_archive_lambda.name
  principal     = "logs.${var.aws_region}.amazonaws.com"
  source_arn    = "${module.local_cloudwatch_log_groups.arns["system_logs"]}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "app_logs_to_archive_lambda" {
  name            = "app-logs-to-archive-lambda"
  log_group_name  = module.local_cloudwatch_log_groups.names["app_logs"]
  filter_pattern  = ""
  destination_arn = module.local_cloudwatch_logs_archive_lambda.arn

  depends_on = [
    aws_lambda_permission.app_logs_invoke_archive_lambda
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "system_logs_to_archive_lambda" {
  name            = "system-logs-to-archive-lambda"
  log_group_name  = module.local_cloudwatch_log_groups.names["system_logs"]
  filter_pattern  = ""
  destination_arn = module.local_cloudwatch_logs_archive_lambda.arn

  depends_on = [
    aws_lambda_permission.system_logs_invoke_archive_lambda
  ]
}

module "local_cloudwatch_config_ssm" {
  source = "../../base/ssm-parameter"

  name = "/cloudwatch-config/application"
  type = "String"
  value = templatefile("${path.module}/resources/cloudwatch-config.json.tftpl", {
    app_log_group_name    = module.local_cloudwatch_log_groups.names["app_logs"]
    system_log_group_name = module.local_cloudwatch_log_groups.names["system_logs"]
  })

  tags = var.tags
}

module "local_ec2_backup" {
  source = "../../base/backup"

  create              = var.backup_create
  vault_name          = var.backup_vault_name
  plan_name           = var.backup_plan_name
  selection_name      = var.backup_selection_name
  role_name           = var.backup_role_name
  schedule_expression = var.backup_schedule_expression
  retention_days      = var.backup_retention_days
  instance_ids = [
    module.local_bastion_ec2.id,
    module.local_app_ec2.id,
    module.local_app_standby_ec2.id
  ]

  tags = var.tags
}

module "local_failover_handler_lambda_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.lambda_function_name}-role"
  path                    = "/"
  description             = "IAM role for Lambda function ${var.lambda_function_name}"
  assume_role_policy_file = "${path.module}/resources/iam/lambda-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  tags = var.tags
}

module "local_failover_handler_lambda" {
  source = "../../base/lambda"

  name               = var.lambda_function_name
  runtime            = var.lambda_runtime
  handler            = var.lambda_handler
  create_role        = false
  role_name          = module.local_failover_handler_lambda_iam_role.role_name
  role_arn           = module.local_failover_handler_lambda_iam_role.role_arn
  subnet_ids         = [for subnet_name in var.lambda_subnet_names : module.local_subnet.private_subnet_ids[subnet_name]]
  security_group_ids = [for sg_name in var.lambda_security_group_names : module.local_sg[sg_name].id]
  source_file        = "${path.module}/resources/lambda/${var.lambda_source_file}"
  output_path        = "${path.module}/resources/lambda/${var.lambda_output_path}"
  tags               = var.tags

  depends_on = [module.local_failover_handler_lambda_iam_role]
}

module "local_cloudwatch_logs_archive_lambda_iam_role" {
  source = "../../base/iam-role"

  name                    = "${var.cloudwatch_logs_archive_lambda_function_name}-role"
  path                    = "/"
  description             = "IAM role for CloudWatch log archive Lambda ${var.cloudwatch_logs_archive_lambda_function_name}"
  assume_role_policy_file = "${path.module}/resources/iam/lambda-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  tags = merge(var.tags, {
    Purpose = "cloudwatch-log-archive"
  })
}

module "local_cloudwatch_logs_archive_lambda" {
  source = "../../base/lambda"

  name               = var.cloudwatch_logs_archive_lambda_function_name
  runtime            = "python3.12"
  handler            = "cloudwatch_logs_collector.lambda_handler"
  create_role        = false
  role_name          = module.local_cloudwatch_logs_archive_lambda_iam_role.role_name
  role_arn           = module.local_cloudwatch_logs_archive_lambda_iam_role.role_arn
  subnet_ids         = [for subnet_name in var.lambda_subnet_names : module.local_subnet.private_subnet_ids[subnet_name]]
  security_group_ids = [for sg_name in var.lambda_security_group_names : module.local_sg[sg_name].id]
  source_file        = "${path.module}/resources/lambda/${var.cloudwatch_logs_archive_lambda_source_file}"
  output_path        = "${path.module}/resources/lambda/${var.cloudwatch_logs_archive_lambda_output_path}"
  timeout            = 60
  memory_size        = 256
  env_vars = {
    LOG_ARCHIVE_BUCKET = module.local_cloudwatch_logs_s3.name
    LOG_ARCHIVE_PREFIX = trim(var.cloudwatch_logs_archive_prefix, "/")
  }

  tags = merge(var.tags, {
    Purpose = "cloudwatch-log-archive"
  })

  depends_on = [module.local_cloudwatch_logs_archive_lambda_iam_role]
}

module "local_cloudwatch_logs_archive_lambda_s3_policy" {
  source = "../../base/iam-policy"

  name        = "${var.cloudwatch_logs_archive_lambda_function_name}-s3-policy"
  path        = "/"
  description = "Allow the CloudWatch log archive Lambda to persist log batches into S3"
  policy = templatefile("${path.module}/resources/iam/cloudwatch-logs-archive-lambda-s3-policy.json.tftpl", {
    archive_bucket_arn = module.local_cloudwatch_logs_s3.arn
    archive_prefix     = trim(var.cloudwatch_logs_archive_prefix, "/")
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "local_cloudwatch_logs_archive_lambda_s3" {
  role       = module.local_cloudwatch_logs_archive_lambda_iam_role.role_name
  policy_arn = module.local_cloudwatch_logs_archive_lambda_s3_policy.policy_arn
}

resource "aws_s3_bucket_policy" "local_cloudwatch_logs_archive" {
  bucket = module.local_cloudwatch_logs_s3.id

  policy = templatefile("${path.module}/resources/iam/cloudwatch-logs-archive-bucket-policy.json.tftpl", {
    current_principal_arn   = data.aws_caller_identity.current.arn
    current_account_id      = data.aws_caller_identity.current.account_id
    archive_lambda_role_arn = module.local_cloudwatch_logs_archive_lambda_iam_role.role_arn
    archive_bucket_arn      = module.local_cloudwatch_logs_s3.arn
    archive_prefix          = trim(var.cloudwatch_logs_archive_prefix, "/")
    archive_vpce_id         = aws_vpc_endpoint.cloudwatch_logs_archive_s3.id
  })

  depends_on = [
    aws_vpc_endpoint.cloudwatch_logs_archive_s3,
    aws_iam_role_policy_attachment.local_cloudwatch_logs_archive_lambda_s3
  ]
}

module "local_route53_record" {
  count  = var.create_route53_record ? 1 : 0
  source = "../../base/route53"

  create_zone     = var.route53_create_zone
  zone_name       = var.route53_zone_name
  zone_id         = var.route53_zone_id
  record_name     = var.route53_record_name
  ip_address      = coalesce(var.route53_record_ip, module.local_app_ec2.private_ip)
  ttl             = var.route53_ttl
  private_zone    = var.route53_private_zone
  vpc_id          = var.route53_private_zone ? module.local_vpc.id : null
  allow_overwrite = var.route53_allow_overwrite
  tags            = var.tags

  depends_on = [module.local_vpc, module.local_app_ec2]
}
