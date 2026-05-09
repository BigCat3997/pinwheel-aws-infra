resource "aws_ssm_parameter" "this" {
  name        = var.name
  description = var.description
  type        = var.type
  value       = var.value
  key_id      = var.key_id
  tier        = var.tier
  overwrite   = var.overwrite

  tags = var.tags
}
