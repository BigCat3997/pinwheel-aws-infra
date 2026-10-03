output "id" {
  value = aws_instance.this.id
}

output "name" {
  value = aws_instance.this.tags["Name"]
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "primary_network_interface_id" {
  description = "ID of the instance primary network interface"
  value       = aws_instance.this.primary_network_interface_id
}

output "external_volume_id" {
  description = "ID of the external EBS volume when created"
  value       = try(aws_ebs_volume.external[0].id, null)
}

output "external_volume_attachment_id" {
  description = "ID of the external EBS volume attachment when created"
  value       = try(aws_volume_attachment.external[0].id, null)
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

output "instance_profile_name" {
  description = "Effective IAM instance profile name attached to the instance"
  value       = var.iam_instance_profile_name != null ? var.iam_instance_profile_name : try(aws_iam_instance_profile.this[0].name, null)
}

output "role_name" {
  description = "IAM role name attached to the instance profile"
  value       = var.role_name
}
