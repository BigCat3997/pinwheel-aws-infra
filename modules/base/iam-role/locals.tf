locals {
  assume_policy = var.assume_role_policy != null ? var.assume_role_policy : (var.assume_role_policy_file != null ? file(var.assume_role_policy_file) : null)
}
