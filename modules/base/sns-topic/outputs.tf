output "arn" {
  description = "Topic ARN"
  value       = aws_sns_topic.this.arn
}

output "name" {
  description = "Topic name"
  value       = aws_sns_topic.this.name
}

output "subscription_arns" {
  description = "Subscription ARNs by protocol:endpoint (pending confirmations show PendingConfirmation)"
  value       = { for key, sub in aws_sns_topic_subscription.this : key => sub.arn }
}
