locals {
  effective_enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  effective_db_subnet_group_name            = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  effective_db_instance_address             = var.manage_master_user_password ? aws_db_instance.this_managed[0].address : aws_db_instance.this[0].address
  effective_db_instance_port                = var.manage_master_user_password ? aws_db_instance.this_managed[0].port : aws_db_instance.this[0].port
}
