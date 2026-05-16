env        = "prd"
aws_region = "us-east-1"

create_iam_policy_admin = true
iam_custom_policy_name  = "bc-policy-admin-prd-0"
iam_path                = "/"

iam_name                                  = "pinwheel4-user"
iam_permissions_boundary                  = null
iam_force_destroy                         = false
iam_create_access_key                     = true
iam_access_key_count                      = 2
iam_create_codecommit_https_credential    = true
iam_create_login_profile                  = true
iam_login_profile_password_length         = 20
iam_login_profile_password_reset_required = true

repositories = [
  {
    repository_name = "bigcat-infrastructure-provisioning"
    description     = "Repository for infrastructure provisioning code"
    default_branch  = "main"
  },
  {
    repository_name = "bigcat-orchestration"
    description     = "Repository for orchestration code"
    default_branch  = "main"
  }
]

codebuild_role_name            = "bc-role-codebuild-tfrunner"
codebuild_policy_name          = "bc-policy-codebuild-tfrunner"
codebuild_target_tf_module_dir = "modules/impl/iam"

cb_tf_validate_project_name     = "terraform-validate"
cb_tf_validate_description      = "CodeBuild project to run Terraform validation using buildspec-tf-validate.yml"
cb_tf_validate_buildspec        = "base/terraform/buildspec-tf-validate.yml"
cb_tf_validate_source_type      = "CODEPIPELINE"
cb_tf_validate_source_location  = null
cb_tf_validate_source_version   = null
cb_tf_validate_artifacts_type   = "CODEPIPELINE"
cb_tf_validate_environment_type = "LINUX_CONTAINER"
cb_tf_validate_compute_type     = "BUILD_GENERAL1_SMALL"
cb_tf_validate_image            = "aws/codebuild/standard:8.0"

cb_checkov_validate_project_name     = "checkov-validate"
cb_checkov_validate_description      = "CodeBuild project to run Checkov validation using buildspec-checkov-validate.yml"
cb_checkov_validate_buildspec        = "base/terraform/buildspec-checkov-validate.yml"
cb_checkov_validate_source_type      = "CODEPIPELINE"
cb_checkov_validate_source_location  = null
cb_checkov_validate_source_version   = null
cb_checkov_validate_artifacts_type   = "CODEPIPELINE"
cb_checkov_validate_environment_type = "LINUX_CONTAINER"
cb_checkov_validate_compute_type     = "BUILD_GENERAL1_SMALL"
cb_checkov_validate_image            = "aws/codebuild/standard:8.0"

cb_tf_plan_project_name     = "terraform-plan"
cb_tf_plan_description      = "CodeBuild project to run Terraform plan using buildspec-plan.yml"
cb_tf_plan_buildspec        = "base/terraform/buildspec-plan.yml"
cb_tf_plan_source_type      = "CODEPIPELINE"
cb_tf_plan_source_location  = null
cb_tf_plan_source_version   = null
cb_tf_plan_artifacts_type   = "CODEPIPELINE"
cb_tf_plan_environment_type = "LINUX_CONTAINER"
cb_tf_plan_compute_type     = "BUILD_GENERAL1_SMALL"
cb_tf_plan_image            = "aws/codebuild/standard:8.0"

cb_tf_apply_project_name     = "terraform-apply"
cb_tf_apply_description      = "CodeBuild project to run Terraform apply using buildspec-apply.yml"
cb_tf_apply_buildspec        = "base/terraform/buildspec-apply.yml"
cb_tf_apply_source_type      = "CODEPIPELINE"
cb_tf_apply_source_location  = null
cb_tf_apply_source_version   = null
cb_tf_apply_artifacts_type   = "CODEPIPELINE"
cb_tf_apply_environment_type = "LINUX_CONTAINER"
cb_tf_apply_compute_type     = "BUILD_GENERAL1_SMALL"
cb_tf_apply_image            = "aws/codebuild/standard:8.0"

codepipeline_name                                  = "bc-codepipeline-terraform-infra-provision-prd"
codepipeline_role_name                             = "bc-role-codepipeline-tfinfra"
codepipeline_policy_name                           = "bc-policy-codepipeline-tfinfra"
codepipeline_artifact_bucket_name                  = "bc-s3-codepipeline-artifacts-tfinfra-prd-05"
codepipeline_codecommit_repository_name            = "bigcat-infrastructure-provisioning"
codepipeline_codecommit_branch                     = "main"
codepipeline_poll_for_source_changes               = true
codepipeline_orchestration_repository_name         = "bigcat-orchestration"
codepipeline_orchestration_branch                  = "main"
codepipeline_orchestration_poll_for_source_changes = false
codepipeline_approval_message                      = "Review Terraform plan output in CodeBuild logs and approve to continue apply."

tags = {
  Environment = "prd"
  Project     = "rookie"
  Managed_By  = "terraform"
  Created_By  = "terraform"
  Version     = "1.0.0"
  Deployed_By = "manual"
}
