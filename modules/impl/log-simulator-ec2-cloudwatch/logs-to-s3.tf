module "log_archive_bucket" {
  source = "../../base/s3"

  bucket_name       = var.log_archive_bucket_name
  force_destroy     = var.log_archive_force_destroy
  enable_versioning = false
  tags              = var.common_tags

  lifecycle_configuration = {
    id                                     = "expire-logs"
    expiration_days                        = var.log_archive_expiration_days
    abort_incomplete_multipart_upload_days = 7
  }
}

module "log_transformer_role" {
  source = "../../base/iam-role"

  name               = "${var.log_archive_name}-transformer-role"
  description        = "Execution role for the CloudWatch Logs to Firehose transformer Lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
  tags = var.common_tags
}

module "log_transformer" {
  source = "../../base/lambda"

  name        = "${var.log_archive_name}-transformer"
  runtime     = "python3.12"
  handler     = "handler.lambda_handler"
  source_dir  = "${path.module}/files/lambda/log_transformer"
  output_path = "${path.module}/.build/log_transformer.zip"
  role_arn    = module.log_transformer_role.role_arn
  create_role = false
  timeout     = 60
  memory_size = 256
  tags        = var.common_tags
}

module "firehose_role" {
  source = "../../base/iam-role"

  name               = "${var.log_archive_name}-firehose-role"
  description        = "Allows Firehose to write to the log archive bucket and invoke the transformer"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
  inline_policies = {
    delivery = data.aws_iam_policy_document.firehose_delivery.json
  }
  tags = var.common_tags
}

module "log_delivery_stream" {
  source = "../../base/firehose"

  name                  = "${var.log_archive_name}-stream"
  role_arn              = module.firehose_role.role_arn
  bucket_arn            = module.log_archive_bucket.arn
  processing_lambda_arn = module.log_transformer.arn
  buffering_size        = var.log_archive_buffer_size_mb
  buffering_interval    = var.log_archive_buffer_interval_seconds
  prefix                = "logs/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{timestamp:HH}/"
  error_output_prefix   = "errors/!{firehose:error-output-type}/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/"
  tags                  = var.common_tags
}

module "log_subscription_role" {
  source = "../../base/iam-role"

  name               = "${var.log_archive_name}-subscription-role"
  description        = "Allows CloudWatch Logs to put records into the log delivery stream"
  assume_role_policy = data.aws_iam_policy_document.logs_assume_role.json
  inline_policies = {
    put_records = data.aws_iam_policy_document.logs_put_firehose.json
  }
  tags = var.common_tags
}

resource "aws_cloudwatch_log_subscription_filter" "archive" {
  name            = "${var.log_archive_name}-to-s3"
  log_group_name  = module.local_cloudwatch_log_groups.names["/ec2/log-simulator/app"]
  filter_pattern  = var.log_subscription_filter_pattern
  destination_arn = module.log_delivery_stream.arn
  role_arn        = module.log_subscription_role.role_arn
}
