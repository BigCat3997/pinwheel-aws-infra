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
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags

  depends_on = [module.local_vpc]
}

module "local_internet_gateway" {
  source = "../../base/internet-gateway"

  vpc_id = module.local_vpc.id
  name   = var.internet_gateway_name
  tags   = var.tags
}

module "local_route_table" {
  source = "../../base/route-table"

  vpc_id               = module.local_vpc.id
  public_route_tables  = var.public_route_tables
  private_route_tables = []
  internet_gateway_id  = module.local_internet_gateway.id
  nat_gateway_ids      = {}
  tags                 = var.tags
}

module "local_route_table_association" {
  source = "../../base/route-table-association"

  public_rtb_assoc        = var.public_rtb_subnet_assocs
  private_rtb_assoc       = []
  public_subnet_ids       = module.local_subnet.public_subnets
  private_subnet_ids      = {}
  public_route_table_ids  = module.local_route_table.public_route_table_ids
  private_route_table_ids = {}
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
  db_subnet_group_subnet_ids = [for name in var.db_subnet_names : module.local_subnet.private_subnets[name]]
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

module "local_bastion_sg" {
  source = "../../base/sg"

  name   = var.bastion_sg_name
  vpc_id = module.local_vpc.id

  security_rules = [
    for cidr in var.bastion_ssh_ingress_cidrs : {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [cidr]
      description = "SSH access from ${cidr}"
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

module "local_app_sg" {
  source = "../../base/sg"

  name   = var.app_sg_name
  vpc_id = module.local_vpc.id

  security_rules = [
    {
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      security_group_id = module.local_bastion_sg.id
      description       = "SSH from bastion"
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

module "local_kms" {
  source = "../../base/kms"

  kms_key_name = var.kms_key_name
  description  = var.kms_description
  tags         = var.tags
}

module "local_bastion_key_pair" {
  source = "../../base/key-pair"

  create     = var.bastion_create_key_pair
  name       = var.bastion_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.bastion_ec2_public_key.secret_string
  tags       = var.tags
}

module "local_bastion_ec2" {
  source = "../../base/ec2"

  name                         = var.bastion_name
  ami_id                       = var.bastion_ami_id
  instance_type                = var.bastion_instance_type
  subnet_id                    = module.local_subnet.public_subnets[var.bastion_subnet_name]
  security_group_ids           = [module.local_bastion_sg.id]
  associate_public_ip          = true
  ssh_user                     = var.ec2_ssh_user
  user_data                    = file("${path.module}/scripts/bastion_ec2_setup.sh")
  volume_size                  = var.ec2_volume_size
  volume_type                  = var.ec2_volume_type
  volume_encrypted             = var.ec2_volume_encrypted
  volume_delete_on_termination = true
  key_name                     = module.local_bastion_key_pair.name
  tags                         = var.tags

  depends_on = [module.local_route_table_association]
}

module "local_app_key_pair" {
  source = "../../base/key-pair"

  create     = var.app_create_key_pair
  name       = var.app_key_pair_name
  public_key = data.aws_secretsmanager_secret_version.app_ec2_public_key.secret_string
  tags       = var.tags
}

module "local_app_ec2" {
  source = "../../base/ec2"

  name                         = var.app_name
  ami_id                       = var.app_ami_id
  instance_type                = var.app_instance_type
  subnet_id                    = module.local_subnet.private_subnets[var.app_subnet_name]
  security_group_ids           = [module.local_app_sg.id]
  associate_public_ip          = false
  ssh_user                     = var.ec2_ssh_user
  user_data                    = file("${path.module}/scripts/app_ec2_setup.sh")
  volume_size                  = var.ec2_volume_size
  volume_type                  = var.ec2_volume_type
  volume_encrypted             = var.ec2_volume_encrypted
  volume_delete_on_termination = true
  key_name                     = module.local_app_key_pair.name
  tags                         = var.tags
}

module "local_ec2_secrets" {
  source = "../../base/secret"

  secrets = [
    {
      name  = "ec2/${var.bastion_name}/${var.ec2_ssh_user}/public-key"
      value = module.local_bastion_key_pair.public_key
    },
    {
      name  = "ec2/${var.app_name}/${var.ec2_ssh_user}/public-key"
      value = module.local_app_key_pair.public_key
    },
  ]

  resource_policy = templatefile("${path.module}/templates/secrets/secret-resource-policy.json.tftpl", {
    user_arn = data.aws_caller_identity.current.arn
  })
  kms_key_id = module.local_kms.id
  tags       = var.tags
}
