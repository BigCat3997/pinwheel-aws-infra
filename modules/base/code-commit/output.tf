output "id" {
  description = "The ID of the repository."
  value       = aws_codecommit_repository.this.id
}

output "clone_url_http" {
  description = "The URL to clone the repository over HTTPS."
  value       = aws_codecommit_repository.this.clone_url_http
}

output "clone_url_ssh" {
  description = "The URL to clone the repository over SSH."
  value       = aws_codecommit_repository.this.clone_url_ssh
}
