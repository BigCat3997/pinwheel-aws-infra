locals {
  public_subnet_cidr_by_name = { for s in var.public_subnets : s.name => s.cidr }

  vpn_ami_id_effective = coalesce(var.vpn_ami_id, data.aws_ssm_parameter.ubuntu_2404_ami.value)

  vpn_private_ip_static = coalesce(
    var.vpn_private_ip,
    cidrhost(local.public_subnet_cidr_by_name[var.vpn_subnet_name], 10)
  )

  vpn_user_data = templatefile("${path.module}/resources/user-data/openvpn-setup.sh.tftpl", {
    vpn_server_port  = var.vpn_server_port
    vpn_network      = var.vpn_network
    vpn_network_mask = var.vpn_network_mask
    vpn_remote_host  = module.local_vpn_eip.public_ip
  })

  vpn_ingress_rules = concat(
    [
      {
        from_port   = var.vpn_server_port
        to_port     = var.vpn_server_port
        protocol    = "tcp"
        cidr_blocks = var.vpn_client_ingress_cidrs
        description = "OpenVPN clients"
      }
    ],
    length(var.admin_ssh_ingress_cidrs) > 0 ? [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.admin_ssh_ingress_cidrs
        description = "SSH admin access"
      }
    ] : []
  )
}
