data "aws_route53_zone" "existing" {
  count        = var.create_zone || var.zone_id != null ? 0 : 1
  name         = "${local.normalized_zone_name}."
  private_zone = var.private_zone
}
