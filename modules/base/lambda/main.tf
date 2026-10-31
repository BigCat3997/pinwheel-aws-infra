resource "aws_lambda_function" "this" {
  function_name                  = var.name
  role                           = var.role_arn
  runtime                        = var.runtime
  handler                        = var.handler
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  dynamic "environment" {
    for_each = length(var.env_vars) > 0 ? [1] : []

    content {
      variables = var.env_vars
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn == null ? [] : [var.dead_letter_target_arn]

    content {
      target_arn = dead_letter_config.value
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.maximum_retry_attempts == null ? 0 : 1

  function_name          = aws_lambda_function.this.function_name
  maximum_retry_attempts = var.maximum_retry_attempts
}

resource "aws_lambda_event_source_mapping" "sqs" {
  count = var.create_sqs_event_source ? 1 : 0

  event_source_arn        = var.sqs_event_source_arn
  function_name           = aws_lambda_function.this.arn
  batch_size              = var.sqs_batch_size
  function_response_types = ["ReportBatchItemFailures"]
}

resource "aws_lambda_function_url" "this" {
  count = var.create_function_url ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "function_url" {
  count = var.create_function_url ? 1 : 0

  statement_id           = "AllowPublicFunctionUrlInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "alb_invoke" {
  # Keys must be static (known at plan); values may be unknown target group ARNs.
  for_each = var.alb_invoke_target_group_arns

  statement_id  = "AllowExecutionFromALB-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = each.value
}
