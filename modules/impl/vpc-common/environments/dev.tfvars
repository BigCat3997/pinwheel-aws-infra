common_tags = {
  Environment = "dev"
  Project     = "rookie"
  Version     = "1.0.0"
  Created_By  = "terraform"
  Managed_By  = "terraform"
  Deployed_By = "manual"
}

create_vpc     = true
vpc_name       = "bc-vpc-rookie-dev-0"
vpc_cidr_block = "10.70.0.0/21"

private_subnets = [
  {
    name = "bc-subnet-rookie_private-dev-0"
    cidr = "10.70.4.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-rookie_private-dev-1"
    cidr = "10.70.5.0/24"
    az   = "us-east-1b"
  }
]

public_subnets = [
  {
    name = "bc-subnet-rookie_public-dev-0"
    cidr = "10.70.0.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-rookie_public-dev-1"
    cidr = "10.70.1.0/24"
    az   = "us-east-1b"
  }
]

eips = [
  {
    name = "bc-eip-rookie_nat-dev-0"
  },
  {
    name = "bc-eip-rookie_nat-dev-1"
  }
]

nat_gateways = [
  {
    name        = "bc-nat-rookie-dev-0"
    subnet_name = "bc-subnet-rookie_private-dev-0"
    eip_name    = "bc-eip-rookie_nat-dev-0"
  },
  {
    name        = "bc-nat-rookie-dev-1"
    subnet_name = "bc-subnet-rookie_private-dev-1"
    eip_name    = "bc-eip-rookie_nat-dev-1"
  }
]

internet_gateway_name = "bc-igw-rookie-dev-0"

public_route_tables = [
  { name = "bc-rt-rookie_public-dev-0" },
  { name = "bc-rt-rookie_public-dev-1" }
]

private_route_tables = [
  { name = "bc-rt-rookie_private-dev-0", nat_gw_name = "bc-nat-rookie-dev-0" },
  { name = "bc-rt-rookie_private-dev-1", nat_gw_name = "bc-nat-rookie-dev-1" }
]

public_rtb_assoc = [
  {
    key              = "bc-rtba-public-dev-0"
    subnet_name      = "bc-subnet-rookie_public-dev-0"
    route_table_name = "bc-rt-rookie_public-dev-0"
  },
  {
    key              = "bc-rtba-public-dev-1"
    subnet_name      = "bc-subnet-rookie_public-dev-1"
    route_table_name = "bc-rt-rookie_public-dev-1"
  }
]

private_rtb_assoc = [
  {
    key              = "bc-rtba-private-dev-0",
    subnet_name      = "bc-subnet-rookie_private-dev-0",
    route_table_name = "bc-rt-rookie_private-dev-0"
  },
  {
    key              = "bc-rtba-private-dev-1",
    subnet_name      = "bc-subnet-rookie_private-dev-1",
    route_table_name = "bc-rt-rookie_private-dev-1"
  }
]
