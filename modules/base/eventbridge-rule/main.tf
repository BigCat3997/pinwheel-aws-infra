resource "aws_cloudwatch_event_rule" "this" {
  name                = var.name
  description         = var.description
  schedule_expression = var.schedule_expression
  event_pattern       = var.event_pattern
  event_bus_name      = var.event_bus_name
  state               = var.state

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_cloudwatch_event_target" "this" {
  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = var.event_bus_name
  target_id      = var.target_id
  arn            = var.target_arn
  input          = var.input
}

resource "aws_lambda_permission" "this" {
  count = var.lambda_function_name == null ? 0 : 1

  statement_id  = "AllowExecutionFromEventBridge-${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
