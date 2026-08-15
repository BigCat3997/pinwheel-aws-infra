aws_region = "us-east-1"

tags = {
  Project     = "cloudwatch-vpce-private-log-test"
  Environment = "dev"
  Created_By  = "Terraform"
  Managed_By  = "Terraform"
}

vpc_name       = "cw-vpce-test-vpc"
vpc_cidr_block = "10.190.0.0/16"

public_subnets = [
  {
    name = "public-a"
    cidr = "10.190.1.0/24"
    az   = "us-east-1a"
  }
]

private_subnets = [
  {
    name = "private-a"
    cidr = "10.190.11.0/24"
    az   = "us-east-1a"
  },
  {
    name = "private-b"
    cidr = "10.190.12.0/24"
    az   = "us-east-1b"
  }
]

internet_gateway_name = "cw-vpce-test-igw"

public_route_tables = [
  {
    name = "public-rt"
  }
]

private_route_tables = [
  {
    name        = "private-rt"
    nat_gw_name = null
  }
]

public_rtb_assoc = [
  {
    key              = "public-a"
    subnet_name      = "public-a"
    route_table_name = "public-rt"
  }
]

private_rtb_assoc = [
  {
    key              = "private-a"
    subnet_name      = "private-a"
    route_table_name = "private-rt"
  }
]

private_test_subnet_name = "private-a"

logs_vpce_sg_name = "bc-sg-vpce_logs-dev-0"

logs_vpce_name                 = "bc-vpce-logs-dev-0"
logs_vpce_service_name         = "com.amazonaws.us-east-1.logs"
logs_vpce_vpc_endpoint_type    = "Interface"
logs_vpce_sg_names             = ["bc-sg-vpce_logs-dev-0"]
logs_vpce_subnet_names         = ["private-a", "private-b"]
logs_vpce_private_dns_enabled  = true
logs_vpce_enable_dns_support   = true
logs_vpce_enable_dns_hostnames = true

app_instance_sg_name          = "bc-sg-app_instance-dev-0"
app_instance_name             = "bc-ec2-app_instance-dev-0"
app_instance_type             = "t3.medium"
app_instance_private_ip       = "10.190.11.10"
app_instance_access_public_ip = false
app_instance_volume_encrypted = true
app_instance_volume_size      = 8
app_instance_volume_type      = "gp3"
volume_delete_on_termination  = true

log_push_interval_seconds = 30

cloudwatch_logs_retention_in_days = 7
