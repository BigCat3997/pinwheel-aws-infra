resource "aws_kms_key" "this" {
  description         = var.description
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.kms_key_name}"
  target_key_id = aws_kms_key.this.key_id
}
