locals {
  assume_policy = var.assume_role_policy != "" ? var.assume_role_policy : (var.assume_role_policy_file != "" ? file(var.assume_role_policy_file) : null)
}

resource "aws_iam_role" "this" {
  name                  = var.name
  path                  = var.path
  description           = var.description
  assume_role_policy    = local.assume_policy
  permissions_boundary  = var.permissions_boundary
  max_session_duration  = var.max_session_duration
  force_detach_policies = var.force_detach_policies
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = { for idx, arn in var.managed_policy_arns : tostring(idx) => arn }

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
