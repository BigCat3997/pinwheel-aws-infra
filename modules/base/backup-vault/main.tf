resource "aws_backup_vault" "this" {
  count = var.create ? 1 : 0

  name = var.name
  tags = var.tags
}
