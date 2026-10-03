resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for attachment in var.attachments :
    "${attachment.target_group_name}-${attachment.target_name}" => attachment
  }

  target_group_arn = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id        = each.value.target_id
  port             = try(each.value.port, null)

  depends_on = [aws_lb_target_group.this]
}
