resource "aws_iam_user" "this" {
  name                 = var.name
  path                 = var.path
  permissions_boundary = var.permissions_boundary
  force_destroy        = var.force_destroy
  tags                 = var.tags
}

resource "aws_iam_user_login_profile" "this" {
  count = var.create_login_profile ? 1 : 0

  user                    = aws_iam_user.this.name
  password_length         = var.login_profile_password_length
  password_reset_required = var.login_profile_password_reset_required
}

resource "aws_iam_access_key" "key" {
  count = local.effective_access_key_count
  user  = aws_iam_user.this.name
}

resource "aws_iam_service_specific_credential" "codecommit_https" {
  count = var.create_codecommit_https_credential ? 1 : 0

  service_name = "codecommit.amazonaws.com"
  user_name    = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "attach" {
  count      = var.attach_policy ? 1 : 0
  user       = aws_iam_user.this.name
  policy_arn = var.attach_policy_arn
}
