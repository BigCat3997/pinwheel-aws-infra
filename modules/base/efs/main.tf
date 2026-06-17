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
  security_groups = length(var.security_group_ids) > 0 ? var.security_group_ids : null
}

resource "aws_efs_backup_policy" "this" {
  count = var.create ? 1 : 0

  file_system_id = aws_efs_file_system.this[0].id

  backup_policy {
    status = var.backup_policy_status
  }
}

resource "aws_efs_access_point" "this" {
  for_each = var.create ? { for ap in var.access_points : ap.name => ap } : {}

  file_system_id = aws_efs_file_system.this[0].id

  posix_user {
    uid = each.value.posix_uid
    gid = each.value.posix_gid
  }

  root_directory {
    path = each.value.path

    creation_info {
      owner_uid   = each.value.owner_uid
      owner_gid   = each.value.owner_gid
      permissions = each.value.permissions
    }
  }

  tags = merge(var.tags, {
    Name = each.value.name
  })
}

resource "aws_efs_file_system_policy" "this" {
  count = var.create && var.enable_file_system_policy ? 1 : 0

  file_system_id = aws_efs_file_system.this[0].id
  policy         = var.efs_policy
}
