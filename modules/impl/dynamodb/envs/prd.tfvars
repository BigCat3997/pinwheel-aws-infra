tags = {
  Project     = "Pinwheel"
  Managed_By  = "Terraform"
  Environment = "Shared"
}

table = {
  name         = "terraformlocks-0"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Component = "DynamoDB"
    Purpose   = "TerraformStateLock"
  }
}

s3_tf_state_bucket_name = "bc-s3-terraformstate-prd-0"
