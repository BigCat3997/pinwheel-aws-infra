resource "aws_ssm_document" "this" {
  name            = var.name
  document_type   = var.document_type
  document_format = var.document_format
  content         = var.content

  tags = merge(var.tags, { Name = var.name })
}
