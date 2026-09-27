# Co-located EC2 and Multi-AZ MySQL

Creates four `t3.medium` EC2 instances (two in each of two AZs), one RDS MySQL
Multi-AZ instance, and a Lambda reconciler. The reconciler starts both EC2
instances in the current RDS primary AZ and stops both instances in the other AZ.
It runs for every RDS instance event and once per minute as a safety net.

EC2 instances cannot change Availability Zone in place. This module therefore
pre-creates capacity in both AZs and changes which pair is running. The RDS DNS
endpoint remains stable through an RDS failover and applications should always
connect using that endpoint.

```hcl
module "co_located_app" {
  source = "./modules/impl/co-located-ec2-rds"

  aws_region     = "ap-southeast-1"
  vpc_name       = "application"
  vpc_cidr_block = "10.20.0.0/16"
  private_subnets = [
    { name = "private-a", cidr = "10.20.1.0/24", az = "ap-southeast-1a" },
    { name = "private-b", cidr = "10.20.2.0/24", az = "ap-southeast-1b" },
  ]

  ec2_az_a_subnet_name          = "private-a"
  ec2_az_b_subnet_name          = "private-b"
  ec2_ami_id                    = "ami-0123456789abcdef0"
  ec2_name_prefix               = "application"
  key_pair_ec2_name             = "application"
  sm_ec2_ssh_public_key_name    = "application/ssh-public-key"
  sg_ec2_name                   = "application-ec2"
  rds_mysql_identifier          = "application-mysql"
  rds_mysql_name                = "application"
  rds_mysql_master_username     = "dbadmin"
}
```

The secret referenced by `sm_ec2_ssh_public_key_name` must already contain an
OpenSSH public key. RDS stores its generated master password in Secrets Manager.
