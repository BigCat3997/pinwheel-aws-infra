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

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  source {
    type            = var.source_type
    location        = var.source_location
    git_clone_depth = var.source_type == "GITHUB" ? 1 : null
    buildspec       = var.buildspec
  }

  source_version = var.source_version

  logs_config {

    dynamic "cloudwatch_logs" {
      for_each = var.enable_cloudwatch_logs ? [1] : []

      content {
        status      = "ENABLED"
        group_name  = var.log_group_name
        stream_name = var.log_stream_name
      }
    }

    dynamic "s3_logs" {
      for_each = var.enable_s3_logs ? [1] : []

      content {
        status   = "ENABLED"
        location = var.s3_log_location
      }
    }
  }

  tags = var.tags
}
