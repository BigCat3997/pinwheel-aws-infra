module "local_code_commit" {
  source   = "../../base/code-commit"
  for_each = { for repository in var.repositories : repository.repository_name => repository }

  repository_name = each.value.repository_name
  description     = each.value.description
  default_branch  = each.value.default_branch
  tags            = var.tags
}
