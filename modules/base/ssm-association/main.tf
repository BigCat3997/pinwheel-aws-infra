resource "aws_ssm_association" "this" {
  name                = var.document_name
  association_name    = var.association_name
  schedule_expression = var.schedule_expression
  parameters          = var.parameters

  dynamic "targets" {
    for_each = var.targets

    content {
      key    = targets.value.key
      values = targets.value.values
    }
  }
}
