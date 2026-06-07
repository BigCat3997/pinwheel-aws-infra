module "local_dynamodb_terraform_locks" {
  source = "../../base/dynamodb"

  name                        = var.table.name
  billing_mode                = var.table.billing_mode
  hash_key                    = var.table.hash_key
  range_key                   = var.table.range_key
  attributes                  = var.table.attributes
  read_capacity               = var.table.read_capacity
  write_capacity              = var.table.write_capacity
  table_class                 = var.table.table_class
  deletion_protection_enabled = var.table.deletion_protection_enabled

  stream_enabled                 = var.table.stream_enabled
  stream_view_type               = var.table.stream_view_type
  server_side_encryption_enabled = var.table.server_side_encryption_enabled
  kms_key_arn                    = var.table.kms_key_arn
  point_in_time_recovery_enabled = var.table.point_in_time_recovery_enabled
  ttl_enabled                    = var.table.ttl_enabled
  ttl_attribute_name             = var.table.ttl_attribute_name
  local_secondary_indexes        = var.table.local_secondary_indexes
  global_secondary_indexes       = var.table.global_secondary_indexes

  tags = merge(var.tags, var.table.tags)
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
