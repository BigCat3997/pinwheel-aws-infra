module "vault" {
  source = "../backup-vault"

  create = var.create
  name   = var.vault_name
  tags   = var.tags
}

resource "aws_iam_role" "backup" {
  count = var.create ? 1 : 0

  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "this" {
  count = var.create ? 1 : 0

  name = var.plan_name

  rule {
    rule_name         = "every-4-hours"
    target_vault_name = module.vault.name
    schedule          = var.schedule_expression
    start_window      = var.start_window
    completion_window = var.completion_window

    lifecycle {
      delete_after = var.retention_days
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "this" {
  count = var.create ? 1 : 0

  iam_role_arn = aws_iam_role.backup[0].arn
  name         = var.selection_name
  plan_id      = aws_backup_plan.this[0].id
  resources    = local.instance_arns
}
