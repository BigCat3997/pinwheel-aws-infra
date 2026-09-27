resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"

  dynamic "cors_configuration" {
    for_each = var.enable_cors ? [1] : []

    content {
      allow_origins = var.cors_allowed_origins
      allow_methods = var.cors_allowed_methods
      allow_headers = var.cors_allowed_headers
    }
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  payload_format_version = var.payload_format_version

  integration_uri = var.lambda_invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  for_each = { for route in var.routes : route.route_key => route }

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  for_each = { for stage in var.stages : stage.name => stage }

  api_id      = aws_apigatewayv2_api.this.id
  name        = each.value.name
  auto_deploy = each.value.auto_deploy

  tags = merge(var.tags, {
    Stage = each.value.name
  })
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
