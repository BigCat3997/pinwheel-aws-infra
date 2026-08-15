resource "aws_secretsmanager_secret" "this" {
  # Secret values can be sensitive. Only declassify the names needed as stable
  # resource keys; the values remain sensitive throughout Terraform evaluation.
  for_each = nonsensitive(toset([for secret in var.secrets : secret.name]))

  name       = each.value
  policy     = var.resource_policy
  kms_key_id = var.kms_key_id
  tags       = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = aws_secretsmanager_secret.this

  secret_id = each.value.id
  secret_string = one([
    for secret in var.secrets : secret.value
    if secret.name == each.key
  ])
}
