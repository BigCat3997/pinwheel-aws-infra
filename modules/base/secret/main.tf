resource "aws_secretsmanager_secret" "this" {
  for_each = { for s in var.secrets : s.name => s }

  name       = each.key
  kms_key_id = var.kms_key_id
  tags       = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = aws_secretsmanager_secret.this

  secret_id = each.value.id
  secret_string = lookup(
    { for s in var.secrets : s.name => s.value },
    each.key,
    ""
  )
}
