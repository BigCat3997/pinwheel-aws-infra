resource "aws_cloudtrail" "this" {
  name                          = var.name
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  kms_key_id                    = var.kms_key_id
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging

  tags = merge(var.tags, {
    Name = var.name
  })
}
