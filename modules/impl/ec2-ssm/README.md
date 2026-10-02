# EC2 + Systems Manager (Session Manager)

A VPC with one EC2 instance in a public subnet with a public IP, managed through
AWS Systems Manager Session Manager. There is no bastion, no key pair and no
inbound security group rule, so the public IP is only for outbound internet.

## What it creates

- VPC, public subnet + internet gateway + public route table, private subnet(s)
- Interface VPC endpoints: `ssm`, `ssmmessages`, `ec2messages` (private DNS on)
- Security groups: instance (all egress, no ingress) and endpoints (443 from instance SG)
- IAM role with `AmazonSSMManagedInstanceCore` and an instance profile
- Amazon Linux 2023 EC2 instance (SSM agent preinstalled), IMDSv2 required

## Usage

```bash
terraform init
terraform apply -var-file=environments/dev.tfvars
aws ssm start-session --target <ec2_instance_id>   # also printed as output ssm_start_session
```

Requires the AWS CLI Session Manager plugin on your machine. The instance
registers with SSM a few minutes after launch.

## Notes

- To also reach the internet from the instance, add a NAT gateway and set
  `nat_gw_name` on the private route table (not wired in this module).
- To put endpoints in more AZs, add subnets and list them in
  `endpoint_extra_subnet_names`.
