aws_region = "us-east-1"

tags = {
  Project = "rookie"
  Env     = "dev"
}

lambda_function_name       = "bc-lambda-public_website-dev-0"
lambda_handler             = "index.lambda_handler"
lambda_runtime             = "python3.12"
lambda_timeout             = 30
lambda_memory_size         = 256
lambda_create_function_url = true

lambda_env_vars = {}

