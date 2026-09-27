output "shared_key_pair_name" {
  description = "Legacy output kept for compatibility"
  value       = null
}

output "ec2_key_secret_arns" {
  description = "Deprecated: key material is sourced from existing Secrets Manager public-key secrets"
  value       = {}
}

output "bastion_key_secret_arns" {
  description = "Deprecated: key material is sourced from existing Secrets Manager public-key secrets"
  value       = {}
}

output "ec2_key_pair_names" {
  description = "Per-EC2 key pair names"
  value = {
    bastion               = module.local_bastion_key_pair.name
    windows_bastion       = module.local_windows_bastion_key_pair.name
    private_ec2           = module.local_private_ec2_key_pair.name
    private_ec2_secondary = module.local_private_ec2_secondary_key_pair.name
  }
}

output "bastion_public_ip" {
  description = "Linux bastion public IP (backward-compatible output)"
  value       = module.local_bastion_ec2.public_ip
}

output "bastion_private_ip" {
  description = "Linux bastion private IP (backward-compatible output)"
  value       = module.local_bastion_ec2.private_ip
}

output "windows_bastion_public_ip" {
  description = "Windows bastion public IP"
  value       = module.local_windows_bastion_ec2.public_ip
}

output "windows_bastion_private_ip" {
  description = "Windows bastion private IP"
  value       = module.local_windows_bastion_ec2.private_ip
}

output "nat_gateway_id" {
  description = "NAT gateway ID used by private route tables"
  value       = try(module.local_nat_gateway[0].id, null)
}

output "nat_gateway_eip_id" {
  description = "Elastic IP ID attached to NAT gateway"
  value       = try(module.local_nat_gateway_eip[0].id, null)
}

output "private_ec2_private_ip" {
  value = module.local_private_ec2.private_ip
}

output "private_ec2_secondary_private_ip" {
  description = "Private IP of second private Linux EC2"
  value       = try(module.local_private_ec2_secondary.private_ip, null)
}

output "ssh_bastion" {
  description = "SSH command to Linux bastion"
  value       = "ssh -i ${var.ssh_private_key_path} -o IdentitiesOnly=yes ${var.bastion_ssh_user}@${module.local_bastion_ec2.public_ip}"
}

output "rdp_bastion" {
  description = "RDP target for Windows bastion"
  value       = "${module.local_windows_bastion_ec2.public_ip}:3389"
}

output "ssh_private_from_bastion" {
  description = "SSH command to run on bastion to reach private EC2"
  value       = "ssh ${var.private_ec2_ssh_user}@${module.local_private_ec2.private_ip}"
}

output "ssh_private_secondary_from_bastion" {
  description = "SSH command to run on bastion to reach second private EC2"
  value       = var.create_private_ec2_secondary ? "ssh ${coalesce(var.private_ec2_secondary_ssh_user, var.private_ec2_ssh_user)}@${module.local_private_ec2_secondary.private_ip}" : null
}

output "ssh_private_via_bastion" {
  description = "SSH command from your machine to private EC2 via Linux bastion using development-server private key"
  value       = "ssh -i ${var.ssh_private_key_path} -o IdentitiesOnly=yes -J ${var.bastion_ssh_user}@${module.local_bastion_ec2.public_ip} ${var.private_ec2_ssh_user}@${module.local_private_ec2.private_ip}"
}

output "ssh_private_secondary_via_bastion" {
  description = "SSH command from your machine to second private EC2 via Linux bastion using development-server private key"
  value       = var.create_private_ec2_secondary ? "ssh -i ${var.ssh_private_key_path} -o IdentitiesOnly=yes -J ${var.bastion_ssh_user}@${module.local_bastion_ec2.public_ip} ${coalesce(var.private_ec2_secondary_ssh_user, var.private_ec2_ssh_user)}@${module.local_private_ec2_secondary.private_ip}" : null
}

output "cloudwatch_config_ssm_parameter" {
  description = "CloudWatch Agent config SSM parameter"
  value       = module.local_cloudwatch_config_ssm.name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch system log group for private EC2"
  value       = module.local_cloudwatch_log_groups.names[local.private_ec2_system_log_group_name]
}
