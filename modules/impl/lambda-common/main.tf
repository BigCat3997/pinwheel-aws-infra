module "local_lambda_role" {
  source = "../../base/iam-role"

  name                    = "${var.lambda_function_name}-role"
  path                    = "/"
  assume_role_policy_file = "${path.module}/files/iam/lambda-role.json"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  tags = var.tags
}

module "local_lambda_function" {
  source = "../../base/lambda"

  name        = var.lambda_function_name
  handler     = var.lambda_handler
  runtime     = var.lambda_runtime
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  env_vars    = var.lambda_env_vars

  create_role         = false
  role_arn            = module.local_lambda_role.role_arn
  create_function_url = var.lambda_create_function_url

  source_dir  = local.lambda_src_dir
  output_path = local.lambda_zip_file

  tags = var.tags

  depends_on = [module.local_lambda_role]
}
