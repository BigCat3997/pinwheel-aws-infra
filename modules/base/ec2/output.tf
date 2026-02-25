output "id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "ssh_public" {
  description = "SSH command using public IP"
  value = aws_instance.this.public_ip != null ? (
    "ssh ${var.ssh_user}@${aws_instance.this.public_ip}"
  ) : null
}

output "ssh_private" {
  description = "SSH command using private IP (for bastion / VPN access)"
  value       = "ssh ${var.ssh_user}@${aws_instance.this.private_ip}"
}
