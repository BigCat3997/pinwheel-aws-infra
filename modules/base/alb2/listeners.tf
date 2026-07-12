resource "aws_lb_listener" "this" {
  for_each          = var.listeners
  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = try(each.value.ssl_policy, null)
  certificate_arn   = try(each.value.certificate_arn, null)

  default_action {
    type             = each.value.default_action_type
    target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  }

  depends_on = [aws_lb.this]
}
