locals {
  lambda_role_name = coalesce(var.role_name, "${var.name}-role")
}
