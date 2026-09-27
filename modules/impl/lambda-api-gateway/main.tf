module "lambda_role" {
  source = "../../base/iam-role"

  name                    = "${var.lambda_function_name}-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/files/iam/lambda-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = local.common_tags
}

module "lambda_function" {
  source = "../../base/lambda"

  name                = var.lambda_function_name
  handler             = var.lambda_handler
  runtime             = var.lambda_runtime
  timeout             = var.lambda_timeout
  memory_size         = var.lambda_memory_size
  create_role         = false
  role_arn            = module.lambda_role.role_arn
  create_function_url = false

  source_dir  = local.lambda_src_dir
  output_path = local.lambda_zip_file

  tags = local.common_tags

  depends_on = [module.lambda_role]
}

module "http_api" {
  source = "../../base/api-gateway-http"

  name                 = var.api_gateway_name
  lambda_function_name = module.lambda_function.name
  lambda_invoke_arn    = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${module.lambda_function.arn}/invocations"
  stages               = var.api_gateway_stages
  enable_cors          = true
  cors_allowed_origins = var.api_gateway_cors_allowed_origins
  cors_allowed_methods = var.api_gateway_cors_allowed_methods
  cors_allowed_headers = var.api_gateway_cors_allowed_headers

  tags = local.common_tags

  depends_on = [module.lambda_function]
}
