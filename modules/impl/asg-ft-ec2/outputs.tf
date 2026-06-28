output "bastion_public_ip" {
  value = module.bastion_ec2.public_ip
}

output "ssh_bastion_ec2" {
  value = module.bastion_ec2.ssh_public
}

output "app_ec2_private_ip" {
  value = module.app_ec2.private_ip
}

output "ssh_app_ec2" {
  value = module.app_ec2.ssh_private
}

output "ssh_ltm_ec2" {
  value = module.app_ec2.ssh_private
}
