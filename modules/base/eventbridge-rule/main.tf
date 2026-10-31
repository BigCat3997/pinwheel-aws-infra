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
  role_arn       = var.target_role_arn
  input          = var.input_transformer == null ? var.input : null

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_arn == null ? [] : [var.dead_letter_arn]

    content {
      arn = dead_letter_config.value
    }
  }

  dynamic "retry_policy" {
    for_each = var.dead_letter_arn == null ? [] : [1]

    content {
      maximum_retry_attempts       = var.retry_maximum_attempts
      maximum_event_age_in_seconds = 3600
    }
  }

  dynamic "input_transformer" {
    for_each = var.input_transformer == null ? [] : [var.input_transformer]

    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }
}

resource "aws_lambda_permission" "this" {
  count = var.lambda_function_name == null ? 0 : 1

  statement_id  = "AllowExecutionFromEventBridge-${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
