aws_region = "us-east-1"

tags = {
  Project = "cloudwatch-vpce-private-log-test"
  Env     = "prd"
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

private_test_subnet_name  = "private-a"
test_instance_name        = "cw-vpce-test-ec2"
test_instance_type        = "t3.micro"
log_push_interval_seconds = 30

cloudwatch_logs_retention_in_days = 7
