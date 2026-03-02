output "id" {
  description = "The ID of the key pair"
  value       = try(aws_key_pair.this[0].id, null)
}

output "name" {
  description = "The name of the key pair"
  value       = try(aws_key_pair.this[0].key_name, null)
}

output "arn" {
  description = "The ARN of the key pair"
  value       = try(aws_key_pair.this[0].arn, null)
}

output "fingerprint" {
  description = "The MD5 public key fingerprint"
  value       = try(aws_key_pair.this[0].fingerprint, null)
}
