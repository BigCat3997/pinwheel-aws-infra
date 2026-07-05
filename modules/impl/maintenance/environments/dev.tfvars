tags = {
  Environment = "dev"
  Project     = "rookie"
  Scenario    = "alb-ec2-lambda-maintenance"
  Created_By  = "terraform"
  Managed_By  = "terraform"
  Version     = "v1.0.0"
  Deployed_By = "manual"
}

aws_region             = "us-east-1"
name_prefix            = "bc-rookie-maint"
maintenance_mode       = true
instance_type          = "t3.micro"
key_pair_name          = null
allowed_ssh_cidr       = "0.0.0.0/0"
s3_bucket_name         = "bc-s3-maintenancewebsite-dev-1"
maintenance_object_key = "index.html"

vpc_cidr = "10.50.0.0/16"

public_subnets = [
  {
    name = "bc-subnet-maint-public-a"
    cidr = "10.50.1.0/24"
    az   = "us-east-1a"
  },
  {
    name = "bc-subnet-maint-public-b"
    cidr = "10.50.2.0/24"
    az   = "us-east-1b"
  }
]
