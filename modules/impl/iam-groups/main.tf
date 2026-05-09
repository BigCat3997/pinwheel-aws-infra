module "administrator_group" {
  source = "../../base/iam-group"

  name                = var.administrator_group_name
  path                = var.path
  managed_policy_arns = var.administrator_managed_policy_arns
  inline_policies     = var.administrator_inline_policies
  users               = var.administrator_users
  membership_name     = var.administrator_membership_name
}

module "developer_group" {
  source = "../../base/iam-group"

  name                = var.developer_group_name
  path                = var.path
  managed_policy_arns = var.developer_managed_policy_arns
  inline_policies     = var.developer_inline_policies
  users               = var.developer_users
  membership_name     = var.developer_membership_name
}

module "reader_group" {
  source = "../../base/iam-group"

  name                = var.reader_group_name
  path                = var.path
  managed_policy_arns = var.reader_managed_policy_arns
  inline_policies     = var.reader_inline_policies
  users               = var.reader_users
  membership_name     = var.reader_membership_name
}