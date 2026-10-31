resource "aws_cloudwatch_event_bus" "this" {
  name               = var.name
  description        = var.description
  kms_key_identifier = var.kms_key_identifier

  tags = merge(var.tags, { Name = var.name })
}
