# CloudWatch Logs VPC Endpoint Private Test

This implementation provisions a private-network test for CloudWatch Logs.

What this deploys:

- VPC with one public subnet and one private subnet
- Private route table without NAT (no internet egress from private subnet)
- CloudWatch Logs interface VPC endpoint (`com.amazonaws.<region>.logs`)
- Private EC2 in private subnet with IAM role to write CloudWatch logs
- CloudWatch log group for test events
- Systemd service on EC2 that continuously pushes logs through the VPC endpoint

How the test works:

- EC2 user data installs a systemd service (`vpce-log-pusher.service`).
- The service continuously writes log events at `log_push_interval_seconds`.
- The instance has no public IP and no NAT route.
- Continuous log delivery confirms CloudWatch Logs access via VPC endpoint.

## Deploy

```bash
terraform init -upgrade
terraform validate
terraform apply --auto-approve -var-file ./environments/prd.tfvars
```

## Verify

Use output `verify_log_command`, or run:

```bash
aws logs tail /aws/vpce-test/cw-vpce-test-ec2 --since 1h --region us-east-1
```

Expected message contains:

`private-subnet log push through CloudWatch Logs VPC endpoint`
