resource "aws_iam_role" "lambda" {
  count = var.create_role ? 1 : 0

  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  tags = merge(var.tags, { Name = local.lambda_role_name })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  count = var.create_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  count = var.create_role && length(var.subnet_ids) > 0 ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_permission" "function_url" {
  count = var.create_function_url ? 1 : 0

  statement_id           = "AllowPublicFunctionUrlInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.this.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = var.create_role ? aws_iam_role.lambda[0].arn : var.role_arn
  runtime       = var.runtime
  handler       = var.handler
  timeout       = var.timeout
  memory_size   = var.memory_size

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
