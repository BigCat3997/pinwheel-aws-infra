resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name                              = each.key
  port                              = each.value.port
  protocol                          = each.value.protocol
  target_type                       = each.value.target_type
  vpc_id                            = each.value.vpc_id
  deregistration_delay              = each.value.deregistration_delay
  load_balancing_cross_zone_enabled = each.value.cross_zone_enabled

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []
    content {
      enabled             = health_check.value.enabled
      interval            = health_check.value.interval
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      matcher             = health_check.value.matcher
    }
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness != null ? [each.value.stickiness] : []

    content {
      enabled = true
      type    = stickiness.value.type
    }
  }
}
