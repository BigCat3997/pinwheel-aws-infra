resource "aws_lb_listener" "this" {
  for_each = { for listener in var.listeners : listener.target_group_name => listener }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = each.value.type
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}
