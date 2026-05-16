module "local_iam_policy_admin" {
  source = "../../base/iam-policy"
  count  = var.create_iam_policy_admin ? 1 : 0

  name   = var.iam_custom_policy_name
  path   = var.iam_path
  policy = file("${path.module}/resources/iam/bc-policy-admin-prd.json")

  tags = var.tags
}

module "local_iam_user_admin" {
  source = "../../base/iam"

  name                                  = var.iam_name
  path                                  = var.iam_path
  permissions_boundary                  = var.iam_permissions_boundary
  force_destroy                         = var.iam_force_destroy
  create_access_key                     = var.iam_create_access_key
  access_key_count                      = var.iam_access_key_count
  create_codecommit_https_credential    = var.iam_create_codecommit_https_credential
  create_login_profile                  = var.iam_create_login_profile
  login_profile_password_length         = var.iam_login_profile_password_length
  login_profile_password_reset_required = var.iam_login_profile_password_reset_required
  attach_policy_arn                     = module.local_iam_policy_admin[0].policy_arn

  tags = var.tags
}

module "local_code_commit" {
  source   = "../../base/code-commit"
  for_each = { for repository in var.repositories : repository.repository_name => repository }

  repository_name = each.value.repository_name
  description     = each.value.description
  default_branch  = each.value.default_branch
  tags            = var.tags
}

module "local_iam_policy_codebuild" {
  source = "../../base/iam-policy"

  name        = var.codebuild_policy_name
  path        = "/"
  description = "IAM policy for CodeBuild"
  policy      = file("${path.module}/resources/iam/${var.codebuild_policy_name}.json")
}

module "local_iam_role_codebuild" {
  source = "../../base/iam-role"

  name                = var.codebuild_role_name
  path                = "/"
  description         = "IAM role for CodeBuild"
  assume_role_policy  = file("${path.module}/resources/iam/${var.codebuild_role_name}.json")
  managed_policy_arns = [module.local_iam_policy_codebuild.policy_arn]

  tags = var.tags
}

module "local_cb_tf_validate" {
  source = "../../base/codebuild"

  service_role_arn  = module.local_iam_role_codebuild.role_arn
  service_role_name = module.local_iam_role_codebuild.role_name

  project_name = var.cb_tf_validate_project_name
  description  = var.cb_tf_validate_description

  source_type     = var.cb_tf_validate_source_type
  source_location = var.cb_tf_validate_source_location
  source_version  = var.cb_tf_validate_source_version
  buildspec       = var.cb_tf_validate_buildspec
  artifacts_type  = var.cb_tf_validate_artifacts_type

  environment_type = var.cb_tf_validate_environment_type
  compute_type     = var.cb_tf_validate_compute_type
  image            = var.cb_tf_validate_image

  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = "prd"
      type  = "PLAINTEXT"
    },
    {
      name  = "TARGET_TF_MODULE_DIR"
      value = var.codebuild_target_tf_module_dir
      type  = "PLAINTEXT"
    }
  ]

  enable_cloudwatch_logs = true
  log_group_name         = "/aws/codebuild/tf-infra-provision/${var.cb_tf_validate_project_name}"

  tags = var.tags
}

module "local_cb_checkov_validate" {
  source = "../../base/codebuild"

  service_role_arn  = module.local_iam_role_codebuild.role_arn
  service_role_name = module.local_iam_role_codebuild.role_name

  project_name = var.cb_checkov_validate_project_name
  description  = var.cb_checkov_validate_description

  source_type     = var.cb_checkov_validate_source_type
  source_location = var.cb_checkov_validate_source_location
  source_version  = var.cb_checkov_validate_source_version
  buildspec       = var.cb_checkov_validate_buildspec
  artifacts_type  = var.cb_checkov_validate_artifacts_type

  environment_type = var.cb_checkov_validate_environment_type
  compute_type     = var.cb_checkov_validate_compute_type
  image            = var.cb_checkov_validate_image

  environment_variables = [
    {
      name  = "TARGET_TF_MODULE_DIR"
      value = var.codebuild_target_tf_module_dir
      type  = "PLAINTEXT"
    }
  ]

  enable_cloudwatch_logs = true
  log_group_name         = "/aws/codebuild/tf-infra-provision/${var.cb_checkov_validate_project_name}"

  tags = var.tags
}

module "local_cb_tf_plan" {
  source = "../../base/codebuild"

  service_role_arn  = module.local_iam_role_codebuild.role_arn
  service_role_name = module.local_iam_role_codebuild.role_name

  project_name = var.cb_tf_plan_project_name
  description  = var.cb_tf_plan_description

  source_type     = var.cb_tf_plan_source_type
  source_location = var.cb_tf_plan_source_location
  source_version  = var.cb_tf_plan_source_version
  buildspec       = var.cb_tf_plan_buildspec
  artifacts_type  = var.cb_tf_plan_artifacts_type

  environment_type = var.cb_tf_plan_environment_type
  compute_type     = var.cb_tf_plan_compute_type
  image            = var.cb_tf_plan_image

  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = "prd"
      type  = "PLAINTEXT"
    },
    {
      name  = "TARGET_TF_MODULE_DIR"
      value = var.codebuild_target_tf_module_dir
      type  = "PLAINTEXT"
    }
  ]

  enable_cloudwatch_logs = true
  log_group_name         = "/aws/codebuild/tf-infra-provision/${var.cb_tf_plan_project_name}"

  tags = var.tags
}

module "local_cb_tf_apply" {
  source = "../../base/codebuild"

  service_role_arn  = module.local_iam_role_codebuild.role_arn
  service_role_name = module.local_iam_role_codebuild.role_name

  project_name = var.cb_tf_apply_project_name
  description  = var.cb_tf_apply_description

  source_type     = var.cb_tf_apply_source_type
  source_location = var.cb_tf_apply_source_location
  source_version  = var.cb_tf_apply_source_version
  buildspec       = var.cb_tf_apply_buildspec
  artifacts_type  = var.cb_tf_apply_artifacts_type

  environment_type = var.cb_tf_apply_environment_type
  compute_type     = var.cb_tf_apply_compute_type
  image            = var.cb_tf_apply_image

  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = "prd"
      type  = "PLAINTEXT"
    },
    {
      name  = "TARGET_TF_MODULE_DIR"
      value = var.codebuild_target_tf_module_dir
      type  = "PLAINTEXT"
    }
  ]

  enable_cloudwatch_logs = true
  log_group_name         = "/aws/codebuild/tf-infra-provision/${var.cb_tf_apply_project_name}"

  tags = var.tags
}

module "local_s3_codepipeline_artifacts" {
  source = "../../base/s3"

  bucket_name          = var.codepipeline_artifact_bucket_name
  force_destroy        = true
  enable_versioning    = true
  enable_encryption    = true
  enable_public_access = false
  # enable_bucket_policy = true
  # policy = templatefile("${path.module}/resources/iam/bc-policy-s3-tfartifact.json.tftpl", {
  #   account_id        = data.aws_caller_identity.current.account_id
  #   allowed_user_name = var.codepipeline_artifact_allowed_user_name
  #   bucket_name       = var.codepipeline_artifact_bucket_name
  # })

  tags = var.tags
}

resource "aws_iam_role" "codepipeline" {
  name = var.codepipeline_role_name

  assume_role_policy = file("${path.module}/resources/iam/bc-role-codepipeline-tfrunner.json")

  tags = var.tags
}

resource "aws_iam_role_policy" "codepipeline" {
  name = var.codepipeline_policy_name
  role = aws_iam_role.codepipeline.id

  policy = templatefile("${path.module}/resources/iam/bc-policy-codepipeline-tfrunner.json.tftpl", {
    artifact_bucket_arn          = module.local_s3_codepipeline_artifacts.arn
    checkov_validate_project_arn = module.local_cb_checkov_validate.project_arn
    tf_validate_project_arn      = module.local_cb_tf_validate.project_arn
    plan_project_arn             = module.local_cb_tf_plan.project_arn
    apply_project_arn            = module.local_cb_tf_apply.project_arn
  })

  depends_on = [aws_iam_role.codepipeline]
}

resource "aws_codepipeline" "terraform_infra" {
  name          = var.codepipeline_name
  role_arn      = aws_iam_role.codepipeline.arn
  pipeline_type = "V2"

  variable {
    name          = "ENVIRONMENT"
    default_value = "prd"
    description   = "Terraform environment"
  }

  artifact_store {
    location = module.local_s3_codepipeline_artifacts.name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "ORCHESTRATION"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["ORCHESTRATION"]

      configuration = {
        RepositoryName       = var.codepipeline_orchestration_repository_name
        BranchName           = var.codepipeline_orchestration_branch
        PollForSourceChanges = tostring(var.codepipeline_orchestration_poll_for_source_changes)
      }
    }

    action {
      name             = "WORK"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["WORK"]

      configuration = {
        RepositoryName       = var.codepipeline_codecommit_repository_name
        BranchName           = var.codepipeline_codecommit_branch
        PollForSourceChanges = tostring(var.codepipeline_poll_for_source_changes)
      }
    }
  }

  stage {
    name = "Validate"

    action {
      name            = "TerraformValidate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["ORCHESTRATION", "WORK"]

      configuration = {
        ProjectName   = module.local_cb_tf_validate.project_name
        PrimarySource = "ORCHESTRATION"
      }
    }

    action {
      name            = "CheckovValidate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["ORCHESTRATION", "WORK"]

      configuration = {
        ProjectName   = module.local_cb_checkov_validate.project_name
        PrimarySource = "ORCHESTRATION"
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name            = "TerraformPlan"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["ORCHESTRATION", "WORK"]

      configuration = {
        ProjectName   = module.local_cb_tf_plan.project_name
        PrimarySource = "ORCHESTRATION"
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = var.codepipeline_approval_message
      }
    }
  }

  stage {
    name = "Apply"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["ORCHESTRATION", "WORK"]

      configuration = {
        ProjectName   = module.local_cb_tf_apply.project_name
        PrimarySource = "ORCHESTRATION"
      }
    }
  }

  tags = var.tags
}
