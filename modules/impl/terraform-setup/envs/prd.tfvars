tags = {
  Project     = "Pinwheel"
  Managed_By  = "Terraform"
  Environment = "Shared"
}

terraform_locks_table_name         = "bc-ddbt-terraformstate-prd-0"
terraform_locks_table_billing_mode = "PAY_PER_REQUEST"
terraform_locks_table_hash_key     = "LockID"
terraform_locks_table_attributes = [
  {
    name = "LockID"
    type = "S"
  }
]
terraform_locks_table_tags = {
  Component = "DynamoDB"
  Purpose   = "TerraformStateLock"
}

s3_tf_state_bucket_name = "bc-s3-terraformstate-prd-2"
