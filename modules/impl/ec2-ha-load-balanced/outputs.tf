output "bastion_public_ip" {
  value = module.bastion_ec2.public_ip
}

output "ssh_bastion_ec2" {
  value = module.bastion_ec2.ssh_public
}

output "primary_ec2_private_ip" {
  value = module.primary_ec2.private_ip
}

output "ssh_primary_app_ec2" {
  value = module.primary_ec2.ssh_private
}

output "standby_ec2_private_ip" {
  value = module.standby_ec2.private_ip
}

output "ssh_standby_ec2" {
  value = module.standby_ec2.ssh_private
}

output "nlb_dns_name" {
  value = module.nlb.dns_name
}

output "nlb_target_group_names" {
  value = module.nlb.target_group_names
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

# output "alb_target_group_names" {
#   value = module.alb.target_group_names
# }
