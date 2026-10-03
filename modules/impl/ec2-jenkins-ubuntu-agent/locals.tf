locals {
  vpc_name                = "${var.name_prefix}-vpc"
  public_subnet_name      = "${var.name_prefix}-public"
  internet_gateway_name   = "${var.name_prefix}-igw"
  public_route_table_name = "${var.name_prefix}-public-rt"
  availability_zone       = coalesce(var.availability_zone, data.aws_availability_zones.available.names[0])

  ami_id = coalesce(var.ami_id, try(data.aws_ssm_parameter.ubuntu_2404_ami[0].value, null))

  ssh_ingress_rules = length(var.jenkins_controller_cidrs) == 0 ? [] : [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.jenkins_controller_cidrs
      description = "Jenkins controller and administrator SSH access"
    }
  ]

  allow_all_egress_rule = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow agent-initiated outbound traffic"
  }

  instance_managed_policy_arns = distinct(concat(
    var.enable_ssm ? ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"] : [],
    var.instance_managed_policy_arns,
  ))

  user_data = templatefile("${path.module}/templates/jenkins-agent-user-data.sh.tftpl", {
    agent_user        = var.ssh_user
    terraform_version = var.terraform_version
  })
}
