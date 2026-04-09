resource "aws_efs_file_system" "this" {
  count = var.create ? 1 : 0

  creation_token                  = var.name
  encrypted                       = var.enable_encryption
  kms_key_id                      = var.enable_encryption ? var.kms_key_id : null
  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia != null ? [1] : []
    content {
      transition_to_ia = var.transition_to_ia
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_efs_mount_target" "this" {
  for_each = var.enable_mount ? { for i, subnet_id in var.subnet_ids : tostring(i) => subnet_id } : {}

  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = each.value
  security_groups = null
}

resource "aws_efs_backup_policy" "this" {
  count = var.create ? 1 : 0

  file_system_id = aws_efs_file_system.this[0].id

  backup_policy {
    status = var.backup_policy_status
  }
}
