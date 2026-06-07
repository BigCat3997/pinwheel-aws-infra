module "local_dynamodb_table_terraform_locks" {
  source = "../../base/dynamodb"

  name                           = var.terraform_locks_table_name
  billing_mode                   = var.terraform_locks_table_billing_mode
  hash_key                       = var.terraform_locks_table_hash_key
  range_key                      = var.terraform_locks_table_range_key
  attributes                     = var.terraform_locks_table_attributes
  read_capacity                  = var.terraform_locks_table_read_capacity
  write_capacity                 = var.terraform_locks_table_write_capacity
  table_class                    = var.terraform_locks_table_class
  deletion_protection_enabled    = var.terraform_locks_table_deletion_protection_enabled
  stream_enabled                 = var.terraform_locks_table_stream_enabled
  stream_view_type               = var.terraform_locks_table_stream_view_type
  server_side_encryption_enabled = var.terraform_locks_table_server_side_encryption_enabled
  kms_key_arn                    = var.terraform_locks_table_kms_key_arn
  point_in_time_recovery_enabled = var.terraform_locks_table_point_in_time_recovery_enabled
  ttl_enabled                    = var.terraform_locks_table_ttl_enabled
  ttl_attribute_name             = var.terraform_locks_table_ttl_attribute_name
  local_secondary_indexes        = var.terraform_locks_table_local_secondary_indexes
  global_secondary_indexes       = var.terraform_locks_table_global_secondary_indexes

  tags = merge(var.tags, var.terraform_locks_table_tags)
}

module "local_s3_terraform_state" {
  source = "../../base/s3"

  bucket_name          = var.s3_tf_state_bucket_name
  force_destroy        = var.s3_force_destroy
  enable_versioning    = var.s3_enable_versioning
  enable_encryption    = var.s3_enable_encryption
  enable_public_access = var.s3_enable_public_access

  tags = var.tags
}
