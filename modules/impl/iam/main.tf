module "local_iam_policy" {
  source = "../../base/iam-policy"
  count  = var.create_policy ? 1 : 0

  name   = var.name
  path   = var.path
  policy = file("${path.module}/resources/iam/bc-policy-admin-prd.json")

  tags = var.tags
}

module "local_user_iam" {
  source = "../../base/iam"

  name                                  = var.user_name
  path                                  = var.path
  permissions_boundary                  = var.permissions_boundary
  force_destroy                         = var.force_destroy
  create_access_key                     = var.create_access_key
  access_key_count                      = var.access_key_count
  create_codecommit_https_credential    = var.create_codecommit_https_credential
  create_login_profile                  = var.create_login_profile
  login_profile_password_length         = var.login_profile_password_length
  login_profile_password_reset_required = var.login_profile_password_reset_required
  attach_policy_arn                     = try(module.local_iam_policy[0].policy_arn, var.policy_arn)
  attach_policy                         = var.create_user && (var.create_policy || var.policy_arn != "")

  tags = var.tags
}
