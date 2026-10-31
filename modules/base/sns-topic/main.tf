resource "aws_sns_topic" "this" {
  name         = var.name
  display_name = var.display_name

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for sub in var.subscriptions : "${sub.protocol}:${sub.endpoint}" => sub }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

resource "aws_sns_topic_policy" "this" {
  count = var.policy == null ? 0 : 1

  arn    = aws_sns_topic.this.arn
  policy = var.policy
}
