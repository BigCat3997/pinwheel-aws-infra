resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "managed" {
  for_each = { for idx, arn in var.managed_policy_arns : tostring(idx) => arn }

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

resource "aws_iam_group_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  group  = aws_iam_group.this.name
  policy = each.value
}

resource "aws_iam_group_membership" "this" {
  count = length(var.users) > 0 ? 1 : 0

  name  = coalesce(var.membership_name, "${var.name}-membership")
  users = distinct(sort(var.users))
  group = aws_iam_group.this.name
}
