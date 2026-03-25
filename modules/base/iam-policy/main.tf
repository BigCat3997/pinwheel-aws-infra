resource "aws_iam_policy" "this" {
  name        = var.name
  path        = var.path
  description = var.description
  policy      = var.policy != "" ? var.policy : (var.policy_file != "" ? file(var.policy_file) : null)

  tags = var.tags
}
