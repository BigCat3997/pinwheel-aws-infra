resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.db_subnet_group_subnet_ids

  tags = merge(
    var.db_subnet_group_tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}

resource "aws_cloudwatch_log_group" "rds" {
  for_each = toset(local.effective_enabled_cloudwatch_logs_exports)

  name              = "/aws/rds/instance/${var.identifier}/${each.value}"
  retention_in_days = var.cloudwatch_log_retention_in_days

  tags = merge(var.tags, {
    Name = "/aws/rds/instance/${var.identifier}/${each.value}"
  })
}

resource "aws_db_instance" "this" {
  count = var.manage_master_user_password ? 0 : 1

  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.primary_database_name
  username = var.master_username
  password = var.master_password
  port     = var.port

  db_subnet_group_name   = local.effective_db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  apply_immediately         = var.apply_immediately
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  parameter_group_name            = var.parameter_group_name
  option_group_name               = var.option_group_name
  ca_cert_identifier              = var.ca_cert_identifier
  enabled_cloudwatch_logs_exports = local.effective_enabled_cloudwatch_logs_exports

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.skip_final_snapshot || var.final_snapshot_identifier != null
      error_message = "final_snapshot_identifier must be set when skip_final_snapshot is false."
    }

    precondition {
      condition     = var.manage_master_user_password || var.master_password != null
      error_message = "master_password must be provided when manage_master_user_password is false."
    }

    precondition {
      condition     = !var.bootstrap_enabled || !var.manage_master_user_password
      error_message = "bootstrap_enabled cannot be true when manage_master_user_password is true."
    }

    precondition {
      condition     = var.create_db_subnet_group || var.db_subnet_group_name != null
      error_message = "db_subnet_group_name must be provided when create_db_subnet_group is false."
    }

    precondition {
      condition     = !var.create_db_subnet_group || length(var.db_subnet_group_subnet_ids) > 0
      error_message = "db_subnet_group_subnet_ids must contain at least one subnet when create_db_subnet_group is true."
    }
  }
}

resource "aws_db_instance" "this_managed" {
  count = var.manage_master_user_password ? 1 : 0

  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name                     = var.primary_database_name
  username                    = var.master_username
  manage_master_user_password = true
  port                        = var.port
  db_subnet_group_name        = local.effective_db_subnet_group_name
  vpc_security_group_ids      = var.vpc_security_group_ids
  multi_az                    = var.multi_az
  publicly_accessible         = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  apply_immediately         = var.apply_immediately
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot

  parameter_group_name            = var.parameter_group_name
  option_group_name               = var.option_group_name
  ca_cert_identifier              = var.ca_cert_identifier
  enabled_cloudwatch_logs_exports = local.effective_enabled_cloudwatch_logs_exports

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.skip_final_snapshot || var.final_snapshot_identifier != null
      error_message = "final_snapshot_identifier must be set when skip_final_snapshot is false."
    }

    precondition {
      condition     = !var.bootstrap_enabled
      error_message = "bootstrap_enabled cannot be true when manage_master_user_password is true."
    }

    precondition {
      condition     = var.create_db_subnet_group || var.db_subnet_group_name != null
      error_message = "db_subnet_group_name must be provided when create_db_subnet_group is false."
    }

    precondition {
      condition     = !var.create_db_subnet_group || length(var.db_subnet_group_subnet_ids) > 0
      error_message = "db_subnet_group_subnet_ids must contain at least one subnet when create_db_subnet_group is true."
    }
  }
}

resource "null_resource" "bootstrap_databases" {
  count = var.bootstrap_enabled ? 1 : 0

  triggers = {
    endpoint           = local.effective_db_instance_address
    port               = tostring(local.effective_db_instance_port)
    primary_database   = var.primary_database_name
    secondary_database = var.secondary_database_name
    dump_sha256        = var.primary_database_dump_file != null ? filesha256(var.primary_database_dump_file) : ""
    dump_file          = var.primary_database_dump_file != null ? var.primary_database_dump_file : ""
    force_run_token    = var.bootstrap_force_run_token != null ? var.bootstrap_force_run_token : ""
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "chmod +x '${path.module}/scripts/bootstrap_mysql.sh' && '${path.module}/scripts/bootstrap_mysql.sh'"

    environment = {
      DB_HOST      = local.effective_db_instance_address
      DB_PORT      = tostring(local.effective_db_instance_port)
      DB_USER      = var.master_username
      MYSQL_PWD    = var.manage_master_user_password ? "" : coalesce(var.master_password, "")
      PRIMARY_DB   = var.primary_database_name
      SECONDARY_DB = var.secondary_database_name
      DUMP_FILE    = var.primary_database_dump_file != null ? var.primary_database_dump_file : ""
      FORCE_TOKEN  = var.bootstrap_force_run_token != null ? var.bootstrap_force_run_token : ""
    }
  }

  depends_on = [aws_db_instance.this, aws_db_instance.this_managed]
}
