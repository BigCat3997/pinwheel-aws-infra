data "aws_region" "current" {}

resource "aws_route53_zone" "this" {
  count         = var.create_zone ? 1 : 0
  name          = local.normalized_zone_name
  comment       = var.zone_comment
  force_destroy = var.force_destroy

  dynamic "vpc" {
    for_each = var.private_zone ? [1] : []
    content {
      vpc_id     = var.vpc_id
      vpc_region = coalesce(var.vpc_region, data.aws_region.current.name)
    }
  }

  tags = merge(var.tags, {
    Name = local.normalized_zone_name
  })
}

resource "aws_route53_record" "this" {
  zone_id         = local.selected_zone_id
  name            = local.record_fqdn
  type            = "A"
  ttl             = var.ttl
  records         = [var.ip_address]
  allow_overwrite = var.allow_overwrite
}
