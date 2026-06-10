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

tf_state_s3_bucket_name          = "bc-s3-terraformstate-prd-3"
tf_state_s3_enable_public_access = false
tf_state_s3_enable_versioning    = true
tf_state_s3_enable_encryption    = true
tf_state_s3_lifecycle_configuration = {
  id                                     = "cleanup-noncurrent-versions"
  noncurrent_version_expiration_days     = 30
  abort_incomplete_multipart_upload_days = 7
}
