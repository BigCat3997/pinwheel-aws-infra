tags = {
  Project     = "Pinwheel"
  Managed_By  = "Terraform"
  Environment = "Shared"
}

tf_locks_table_name         = "bc-ddbt-terraformstate-prd-1"
tf_locks_table_billing_mode = "PAY_PER_REQUEST"
tf_locks_table_hash_key     = "LockID"
tf_locks_table_attributes = [
  {
    name = "LockID"
    type = "S"
  }
]
tf_locks_table_tags = {
  Component = "DynamoDB"
  Purpose   = "TerraformStateLock"
}

tf_state_s3_bucket_name = "bc-s3-terraformstate-prd-3"
