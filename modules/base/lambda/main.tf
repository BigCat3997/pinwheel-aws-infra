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

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(var.tags, { Name = var.name })
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
