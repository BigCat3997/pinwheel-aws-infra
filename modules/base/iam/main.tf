resource "aws_iam_user" "this" {
  name                 = var.name
  path                 = var.path
  permissions_boundary = var.permissions_boundary
  force_destroy        = var.force_destroy
  tags                 = var.tags
}

resource "aws_iam_access_key" "key" {
  count = var.create_access_key ? 1 : 0
  user  = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "attach" {
  count      = var.attach_policy ? 1 : 0
  user       = aws_iam_user.this.name
  policy_arn = var.attach_policy_arn
}
