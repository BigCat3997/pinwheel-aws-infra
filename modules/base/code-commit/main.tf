resource "aws_codecommit_repository" "this" {
  repository_name = var.repository_name
  description     = var.description
  default_branch  = var.default_branch
  tags            = var.tags
}