resource "aws_codebuild_project" "this" {
  name         = var.project_name
  description  = var.description
  service_role = var.service_role_arn

  artifacts {
    type = var.artifacts_type
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = var.environment_type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  source {
    type            = var.source_type
    location        = var.source_location
    git_clone_depth = var.source_type == "GITHUB" ? 1 : null
    buildspec       = var.buildspec
  }

  source_version = var.source_version

  tags = var.tags
}
