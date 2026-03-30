resource "aws_kinesis_firehose_delivery_stream" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.role_arn
    bucket_arn          = var.bucket_arn
    compression_format  = var.compression_format
    buffering_size      = var.buffering_size
    buffering_interval  = var.buffering_interval
    prefix              = var.prefix
    error_output_prefix = var.error_output_prefix
  }

  tags = var.tags
}
