module "local_vpc" {
  source = "../../base/vpc"

  create     = true
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.tags
}

module "local_subnet" {
  source = "../../base/subnet"

  vpc_id          = module.local_vpc.id
  public_subnets  = []
  private_subnets = var.private_subnets
  tags            = var.tags

  depends_on = [module.local_vpc]
}

module "local_db_sg" {
  source = "../../base/sg"

  name   = var.db_sg_name
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = var.db_ingress_cidrs
      description = "MySQL ingress"
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

  tags = var.tags
}

module "local_rds" {
  source = "../../base/rds"

  identifier                  = var.rds_identifier
  engine                      = "mysql"
  engine_version              = var.engine_version
  instance_class              = var.rds_instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = var.storage_type
  storage_encrypted           = var.storage_encrypted
  kms_key_id                  = var.kms_key_id
  primary_database_name       = var.db_name
  secondary_database_name     = var.secondary_db_name
  master_username             = var.master_username
  manage_master_user_password = var.manage_master_user_password

  create_db_subnet_group     = true
  db_subnet_group_subnet_ids = values(module.local_subnet.private_subnets)
  vpc_security_group_ids     = [module.local_db_sg.id]

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.automated_backup_retention_days
  backup_window           = var.automated_backup_window

  bootstrap_enabled = false

  tags = var.tags

  depends_on = [module.local_subnet, module.local_db_sg]
}

resource "aws_backup_vault" "this" {
  count = var.create_aws_backup ? 1 : 0

  name = var.aws_backup_vault_name
  tags = var.tags
}

module "local_aws_backup_policy_backup" {
  count  = var.create_aws_backup ? 1 : 0
  source = "../../base/iam-policy"

  name        = "${var.aws_backup_role_name}-backup-policy"
  path        = "/"
  description = "Custom backup policy for AWS Backup to protect RDS instance ${var.rds_identifier}"
  policy = templatefile("${path.module}/templates/iam/aws-backup-backup-policy.json.tftpl", {
    aws_region       = var.aws_region
    account_id       = data.aws_caller_identity.current.account_id
    rds_arn          = module.local_rds.arn
    backup_vault_arn = aws_backup_vault.this[0].arn
  })

  tags = var.tags
}

module "local_aws_backup_policy_restore" {
  count  = var.create_aws_backup ? 1 : 0
  source = "../../base/iam-policy"

  name        = "${var.aws_backup_role_name}-restore-policy"
  path        = "/"
  description = "Custom restore policy for AWS Backup recovery points"
  policy = templatefile("${path.module}/templates/iam/aws-backup-restore-policy.json.tftpl", {
    aws_region = var.aws_region
    account_id = data.aws_caller_identity.current.account_id
    rds_arn    = module.local_rds.arn
  })

  tags = var.tags
}

module "local_aws_backup_role" {
  count  = var.create_aws_backup ? 1 : 0
  source = "../../base/iam-role"

  name                    = var.aws_backup_role_name
  path                    = "/"
  description             = "Custom IAM role for AWS Backup to protect and restore RDS"
  assume_role_policy_file = "${path.module}/files/iam/aws-backup-assume-role-policy.json"
  managed_policy_arns = [
    module.local_aws_backup_policy_backup[0].policy_arn,
    module.local_aws_backup_policy_restore[0].policy_arn
  ]

  tags = var.tags
}

resource "aws_backup_plan" "this" {
  count = var.create_aws_backup ? 1 : 0

  name = var.aws_backup_plan_name

  rule {
    rule_name         = "daily-12utc"
    target_vault_name = aws_backup_vault.this[0].name
    schedule          = var.aws_backup_schedule_expression
    start_window      = var.aws_backup_start_window
    completion_window = var.aws_backup_completion_window

    lifecycle {
      delete_after = var.aws_backup_retention_days
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "this" {
  count = var.create_aws_backup ? 1 : 0

  iam_role_arn = module.local_aws_backup_role[0].role_arn
  name         = var.aws_backup_selection_name
  plan_id      = aws_backup_plan.this[0].id
  resources    = [module.local_rds.arn]
}
