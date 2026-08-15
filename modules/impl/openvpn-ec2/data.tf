data "aws_ssm_parameter" "ubuntu_2404_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

data "aws_eip" "vpn" {
  id = module.local_vpn_eip.id

  depends_on = [module.local_vpn_eip]
}
