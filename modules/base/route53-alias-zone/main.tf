resource "aws_route53_zone" "this" {
  name          = var.zone_name
  comment       = var.zone_comment
  force_destroy = var.force_destroy

  vpc {
    vpc_id = var.vpc_id
  }

  # Extra VPCs are managed by aws_route53_zone_association below
  lifecycle {
    ignore_changes = [vpc]
  }

  tags = merge(var.tags, {
    Name = var.zone_name
  })
}

resource "aws_route53_record" "alias" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.zone_name
  type    = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_zone_association" "this" {
  for_each = var.associated_vpc_ids

  zone_id = aws_route53_zone.this.zone_id
  vpc_id  = each.value
}
