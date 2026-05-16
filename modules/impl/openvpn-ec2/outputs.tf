output "vpn_public_ip" {
  description = "Static Elastic IP of the OpenVPN server — add this to your phone's OpenVPN config"
  value       = data.aws_eip.vpn.public_ip
}

output "vpn_private_ip" {
  description = "Private IP of the OpenVPN EC2 instance"
  value       = module.local_vpn_ec2.private_ip
}

output "vpn_instance_id" {
  description = "EC2 instance ID of the OpenVPN server"
  value       = module.local_vpn_ec2.id
}

output "vpn_sg_id" {
  description = "Security group ID attached to the OpenVPN server"
  value       = module.local_vpn_sg.id
}

output "key_pair_name" {
  description = "EC2 key pair name used for SSH access"
  value       = module.local_key_pair.name
}

output "ssh_command" {
  description = "SSH command to reach the OpenVPN server"
  value       = "ssh -i <path-to-private-key> ubuntu@${data.aws_eip.vpn.public_ip}"
}
