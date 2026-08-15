resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for att in var.attachments :
    "${att.target_group_name}-${att.target_name}" => att
  }

  target_group_arn  = aws_lb_target_group.this[each.value.target_group_name].arn
  target_id         = each.value.target_id
  port              = try(each.value.port, null)
  availability_zone = try(each.value.availability_zone, null)
}
