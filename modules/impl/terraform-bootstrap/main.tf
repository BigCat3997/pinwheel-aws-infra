module "local_tf_state_s3" {
  source = "../../base/s3"

  bucket_name             = var.tf_state_s3_bucket_name
  force_destroy           = var.tf_state_s3_force_destroy
  enable_versioning       = var.tf_state_s3_enable_versioning
  enable_encryption       = var.tf_state_s3_enable_encryption
  enable_public_access    = var.tf_state_s3_enable_public_access
  lifecycle_configuration = var.tf_state_s3_lifecycle_configuration
  tags                    = var.common_tags
}

module "local_tf_locks_dynamodb_table" {
  source = "../../base/dynamodb_table"

  name                           = var.tf_locks_table_name
  billing_mode                   = var.tf_locks_table_billing_mode
  hash_key                       = var.tf_locks_table_hash_key
  range_key                      = var.tf_locks_table_range_key
  attributes                     = var.tf_locks_table_attributes
  read_capacity                  = var.tf_locks_table_read_capacity
  write_capacity                 = var.tf_locks_table_write_capacity
  table_class                    = var.tf_locks_table_class
  deletion_protection_enabled    = var.tf_locks_table_deletion_protection_enabled
  stream_enabled                 = var.tf_locks_table_stream_enabled
  stream_view_type               = var.tf_locks_table_stream_view_type
  server_side_encryption_enabled = var.tf_locks_table_server_side_encryption_enabled
  kms_key_arn                    = var.tf_locks_table_kms_key_arn
  point_in_time_recovery_enabled = var.tf_locks_table_point_in_time_recovery_enabled
  ttl_enabled                    = var.tf_locks_table_ttl_enabled
  ttl_attribute_name             = var.tf_locks_table_ttl_attribute_name
  local_secondary_indexes        = var.tf_locks_table_local_secondary_indexes
  global_secondary_indexes       = var.tf_locks_table_global_secondary_indexes
  tags                           = merge(var.common_tags, var.tf_locks_table_tags)
}
