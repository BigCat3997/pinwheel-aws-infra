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

output "public_key" {
  description = "The actual public key registered in AWS"
  value       = try(aws_key_pair.this[0].public_key, null)
}

output "private_key_pem" {
  description = "The generated private key in PEM format (null when external public key is provided)"
  value       = try(tls_private_key.key[0].private_key_pem, null)
  sensitive   = true
}

output "public_key_openssh" {
  description = "The generated public key in OpenSSH format (null when external public key is provided)"
  value       = try(tls_private_key.key[0].public_key_openssh, null)
  sensitive   = true
}
