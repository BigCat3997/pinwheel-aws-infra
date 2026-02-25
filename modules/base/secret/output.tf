output "secret_arns" {
  value = {
    for k, v in aws_secretsmanager_secret.this :
    k => v.arn
  }
}

output "secret_values" {
  description = "Map of secret name to its stored value"
  sensitive   = true
  value = {
    for k, v in aws_secretsmanager_secret_version.this :
    k => v.secret_string
  }
}
