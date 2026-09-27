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

    dynamic "processing_configuration" {
      for_each = var.processing_lambda_arn == null ? [] : [1]

      content {
        enabled = true

        processors {
          type = "Lambda"

          parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${var.processing_lambda_arn}:$LATEST"
          }

          parameters {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = tostring(var.processing_buffer_size)
          }

          parameters {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = tostring(var.processing_buffer_interval)
          }
        }
      }
    }
  }

  tags = var.tags
}
