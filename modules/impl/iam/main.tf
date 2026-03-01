module "iam_policy" {
  source = "../../base/iam-policy"
  count  = var.create_policy ? 1 : 0

  name        = var.name
  path        = var.path
  policy      = var.policy_json
  policy_file = var.policy_json_file
  tags        = var.tags
}


module "user_iam" {
  source = "../../base/iam"

  name                 = var.user_name
  path                 = var.path
  permissions_boundary = var.permissions_boundary
  force_destroy        = var.force_destroy
  tags                 = var.tags

  create_access_key = var.create_access_key
  attach_policy_arn = try(module.iam_policy[0].policy_arn, var.policy_arn)
  attach_policy     = var.create_user && (var.create_policy || var.policy_arn != "")
}

