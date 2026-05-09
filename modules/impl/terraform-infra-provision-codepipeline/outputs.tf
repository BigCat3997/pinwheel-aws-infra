output "cb_tf_validate_project_name" {
  value = module.local_cb_tf_validate.project_name
}

output "cb_tf_plan_project_name" {
  value = module.local_cb_tf_plan.project_name
}

output "cb_tf_apply_project_name" {
  value = module.local_cb_tf_apply.project_name
}

output "codepipeline_name" {
  value = aws_codepipeline.terraform_infra.name
}

output "codepipeline_arn" {
  value = aws_codepipeline.terraform_infra.arn
}

output "codepipeline_artifact_bucket_name" {
  value = module.local_s3_codepipeline_artifacts.name
}
