module "local_dlm_role" {
  source = "../../base/iam-role"

  name                    = "${var.name}-dlm-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/files/iam/dlm-role.json"
  inline_policies = {
    "DLMExecutionPolicy" = templatefile("${path.module}/templates/iam/dlm-execution-policy.json.tftpl", {
      volume_arns = jsonencode(local.dlm_volume_arns)
    })
  }

  tags = var.common_tags
}

module "local_dlm" {
  source = "../../base/dlm"

  name        = var.name
  description = var.description
  dlm_arn     = module.local_dlm_role.role_arn
  target_tags = var.target_tags
  state       = var.state
  schedules   = var.schedules
  tags        = var.common_tags

  depends_on = [module.local_dlm_role]
}
