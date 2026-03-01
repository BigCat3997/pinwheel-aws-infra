module "local_code_commit" {
  source = "../../base/code-commit"

  repository_name = var.repository_name
  description     = var.description
  default_branch  = var.default_branch
  tags            = var.tags
}
