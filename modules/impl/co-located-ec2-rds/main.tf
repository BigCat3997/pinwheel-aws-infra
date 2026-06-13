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
  public_subnets  = []
  private_subnets = var.private_subnets
  tags            = var.common_tags

  depends_on = [module.local_vpc]
}

module "local_ec2_key_pair" {
  source = "../../base/key-pair"

  create     = true
  name       = var.key_pair_ec2_name
  public_key = data.aws_secretsmanager_secret_version.ec2_public_key.secret_string
  tags       = var.common_tags
}

module "local_ec2_sg" {
  source = "../../base/sg"

  name   = var.sg_ec2_name
  vpc_id = module.local_vpc.id

  security_rules = length(var.sg_ec2_ssh_ingress_cidrs) > 0 ? [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.sg_ec2_ssh_ingress_cidrs
      description = "SSH"
    }
  ] : []

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress"
    }
  ]

  tags = var.common_tags
}

module "local_rds_sg" {
  source = "../../base/sg"

  name   = "${var.vpc_name}-rds-sg"
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = var.rds_mysql_port
      to_port           = var.rds_mysql_port
      protocol          = "tcp"
      security_group_id = module.local_ec2_sg.id
      description       = "Allow DB2 from EC2 SG"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress"
    }
  ]

  tags = var.common_tags
}

module "local_primary_ec2" {
  source = "../../base/ec2"

  name                = var.ec2_primary_name
  ami_id              = var.ec2_ami_id
  instance_type       = var.ec2_instance_type
  subnet_id           = module.local_subnet.private_subnet_ids[var.ec2_primary_subnet_name]
  private_ip          = local.primary_private_ip
  security_group_ids  = [module.local_ec2_sg.id]
  associate_public_ip = false
  ssh_user            = "ec2-user"
  user_data           = "#!/bin/bash\necho primary > /tmp/node-role.txt\n"
  volume_size         = 50
  volume_type         = "gp3"
  key_name            = module.local_ec2_key_pair.name

  tags = merge(var.common_tags, {
    Name = var.ec2_primary_name
    Role = "primary"
  })

  depends_on = [module.local_subnet, module.local_ec2_sg, module.local_ec2_key_pair]
}

module "local_standby_ec2" {
  source = "../../base/ec2"

  name                = var.ec2_standby_name
  ami_id              = var.ec2_ami_id
  instance_type       = var.ec2_instance_type
  subnet_id           = module.local_subnet.private_subnet_ids[var.ec2_standby_subnet_name]
  private_ip          = local.standby_private_ip
  security_group_ids  = [module.local_ec2_sg.id]
  associate_public_ip = false
  ssh_user            = "ec2-user"
  user_data           = "#!/bin/bash\necho standby > /tmp/node-role.txt\n"
  volume_size         = 50
  volume_type         = "gp3"
  key_name            = module.local_ec2_key_pair.name

  tags = merge(var.common_tags, {
    Name = var.ec2_standby_name
    Role = "standby"
  })

  depends_on = [module.local_subnet, module.local_ec2_sg, module.local_ec2_key_pair]
}

resource "aws_ec2_instance_state" "primary" {
  instance_id = module.local_primary_ec2.id
  state       = var.initial_active_node == "primary" ? "running" : "stopped"
}

resource "aws_ec2_instance_state" "standby" {
  instance_id = module.local_standby_ec2.id
  state       = var.initial_active_node == "standby" ? "running" : "stopped"
}

resource "aws_iam_role" "lambda" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_failover" {
  name = "${var.lambda_function_name}-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

module "local_failover_handler_lambda" {
  source = "../../base/lambda"

  name                = var.lambda_function_name
  handler             = var.lambda_handler
  runtime             = var.lambda_runtime
  timeout             = var.lambda_timeout
  memory_size         = 1024
  create_role         = false
  role_arn            = aws_iam_role.lambda.arn
  create_function_url = false
  source_dir          = local.lambda_src_dir
  output_path         = local.lambda_zip_file

  env_vars = {
    rds_mysql_INSTANCE_IDENTIFIER  = var.rds_mysql_identifier
    PRIMARY_INSTANCE_ID            = module.local_primary_ec2.id
    STANDBY_INSTANCE_ID            = module.local_standby_ec2.id
    PRIMARY_AZ                     = local.primary_subnet_az
    STANDBY_AZ                     = local.standby_subnet_az
    FAILOVER_POLL_ATTEMPTS         = "20"
    FAILOVER_POLL_INTERVAL_SECONDS = "15"
    FAILOVER_SETTLE_READS          = "3"
  }
  tags = var.common_tags

  depends_on = [aws_iam_role.lambda]
}

resource "aws_cloudwatch_event_rule" "rds_failover" {
  name        = "${var.rds_mysql_identifier}-failover-events"
  description = "Trigger Lambda when RDS DB instance emits failover-related events"

  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["RDS DB Instance Event"]
    detail = {
      SourceIdentifier = [var.rds_mysql_identifier]
    }
  })
}

module "local_rds_mysql" {
  source = "../../base/rds"

  identifier                  = var.rds_mysql_identifier
  engine                      = var.rds_mysql_engine
  engine_version              = var.rds_mysql_engine_version
  instance_class              = var.rds_mysql_instance_class
  allocated_storage           = var.rds_mysql_allocated_storage
  storage_type                = var.rds_mysql_storage_type
  storage_encrypted           = var.rds_mysql_storage_encrypted
  primary_database_name       = var.rds_mysql_name
  secondary_database_name     = var.rds_mysql_secondary_name
  master_username             = var.rds_mysql_master_username
  manage_master_user_password = var.rds_mysql_manage_master_user_password
  port                        = var.rds_mysql_port

  create_db_subnet_group     = true
  db_subnet_group_subnet_ids = values(module.local_subnet.private_subnet_ids)
  db_subnet_group_tags       = var.common_tags

  vpc_security_group_ids = [module.local_rds_sg.id]
  multi_az               = var.rds_mysql_multi_az
  publicly_accessible    = var.rds_mysql_publicly_accessible

  backup_retention_period         = var.rds_mysql_backup_retention_period
  deletion_protection             = var.rds_mysql_deletion_protection
  skip_final_snapshot             = var.rds_mysql_skip_final_snapshot
  apply_immediately               = var.rds_mysql_apply_immediately
  enabled_cloudwatch_logs_exports = var.rds_mysql_cloudwatch_logs_exports

  bootstrap_enabled = false

  tags = merge(var.common_tags, {
    Name = var.rds_mysql_identifier
  })

  depends_on = [module.local_subnet, module.local_rds_sg]
}

resource "aws_cloudwatch_event_target" "rds_failover_lambda" {
  rule      = aws_cloudwatch_event_rule.rds_failover.name
  target_id = "InvokeFailoverLambda"
  arn       = module.local_failover_handler_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.local_failover_handler_lambda.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_failover.arn
}
