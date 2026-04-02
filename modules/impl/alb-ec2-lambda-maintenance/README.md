# ALB -> EC2 / Lambda maintenance switch

This standalone impl module uses **plain Terraform AWS resources** and does **not** depend on the existing base modules.

## Traffic flow

- **Normal mode** (`maintenance_mode = false`)
  - `ALB -> target group -> 2 EC2 instances running nginx`
- **Maintenance mode** (`maintenance_mode = true`)
  - `ALB -> Lambda -> S3 static maintenance page`

## Files

- `main.tf`: VPC, subnets, ALB, EC2, S3, Lambda, IAM
- `terraform.tfvars`: sample values you can apply directly
- `templates/nginx_user_data.sh.tftpl`: bootstraps nginx on both EC2 instances
- `lambda/maintenance_handler.py`: Lambda reads the HTML page from S3 and returns it to the ALB
- `maintenance-site/index.html`: custom maintenance landing page

## How to use

```bash
terraform init
terraform plan
terraform apply
```

## Switch traffic during maintenance

1. Open `terraform.tfvars`
2. Change:

```hcl
maintenance_mode = true
```

1. Re-run:

```bash
terraform apply
```

That will switch the ALB default action from the nginx EC2 target group to the Lambda maintenance page.
