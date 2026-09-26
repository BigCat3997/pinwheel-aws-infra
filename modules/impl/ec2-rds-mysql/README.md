# EC2 with RDS MySQL and Dual Backup Architecture

This implementation builds a VPC with a public bastion subnet, a private app
subnet, and two private database subnets. It runs a bastion host, an app EC2
instance, and a Multi-AZ RDS MySQL instance. The database is protected by two
independent backups: RDS automated backups and an AWS Backup plan.

## Runtime traffic flow

```mermaid
flowchart TB
  admin((Administrator))

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph public["Public subnet"]
    bastion["Bastion EC2"]
  end

  subgraph app_tier["Private app subnet"]
    app["App EC2"]
  end

  subgraph db_tier["Private database subnets (two AZs)"]
    direction LR
    rds_primary["RDS MySQL<br/>primary"]
    rds_standby["RDS MySQL<br/>Multi-AZ standby"]
  end

  subgraph backups["Backups"]
    direction LR
    auto_backup["RDS automated backup<br/>daily window 00:00-00:30 UTC"]
    aws_backup["AWS Backup plan<br/>daily 12:00 UTC to backup vault"]
  end

  sg{{"Security groups<br/>(bastion, app, and RDS)"}}

  admin -->|"SSH"| igw
  igw --> bastion
  bastion -.->|"SSH administration"| app
  app -->|"MySQL 3306"| rds_primary
  rds_primary -.->|"Synchronous replication"| rds_standby

  rds_primary --> auto_backup
  rds_primary --> aws_backup

  sg -.- bastion
  sg -.- app
  sg -.- rds_primary

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef backup fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class igw ingress
  class bastion publicTier
  class app,rds_primary,rds_standby privateTier
  class auto_backup,aws_backup backup
  class sg sgClass
```

The bastion is the only instance with a public IP, and its SSH ingress comes
from `bastion_ssh_ingress_cidrs`. The app security group accepts SSH only from
the bastion security group. The RDS security group accepts port 3306 from
`db_ingress_cidrs`, which is the whole VPC in the development configuration.
The RDS subnet group uses only the subnets in `db_subnet_names`, so the app
subnet is kept out of it. There is no NAT gateway, so the app instance has no
outbound internet access.

The first backup is the RDS built-in automated backup, kept for
`automated_backup_retention_days` inside `automated_backup_window`. The second
is an AWS Backup plan that runs on `aws_backup_schedule_expression`, stores
recovery points in its own vault, and keeps them for `aws_backup_retention_days`.
The plan is created only when `create_aws_backup` is `true`.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  existing_secrets["Existing public-key secrets"]

  inputs --> vpc["VPC"]
  vpc --> subnets["Public and private subnets"]
  vpc --> igw["Internet Gateway"]
  vpc --> sg["Security groups"]
  igw --> routes["Public route table"]
  subnets --> assoc["Route table association"]
  routes --> assoc

  existing_secrets --> key_pairs["EC2 key pairs"]
  subnets --> instances["Bastion and app EC2"]
  sg --> instances
  key_pairs --> instances
  assoc --> instances

  subnets --> rds["RDS MySQL<br/>DB subnet group"]
  sg --> rds

  rds --> backup_policies["AWS Backup IAM policies"]
  backup_policies --> backup_role["AWS Backup role"]
  vault["Backup vault"] --> plan["Backup plan"]
  backup_role --> selection["Backup selection"]
  plan --> selection
  rds --> selection

  inputs --> kms["KMS key"]
  kms --> output_secrets["Managed EC2 public-key secrets"]
  key_pairs --> output_secrets
```

Terraform uses the base modules under `modules/base/` for each component. The
public key for each EC2 key pair is read from an existing Secrets Manager secret
(`bastion_ec2_public_key_secret_name` and `app_ec2_public_key_secret_name`),
which must exist before `plan`. The module then writes the keys to new
KMS-encrypted secrets named `ec2/<name>/ec2-user/public-key`. Never store a
private key in those secrets.

The user-data scripts only write a log line to `/var/log/user-data.log`, and
they run only on first boot. The master password is managed by RDS when
`manage_master_user_password` is `true`. Before an apply, replace the
`REPLACE_ME_...` secret names in `environments/dev.tfvars` and narrow
`bastion_ssh_ingress_cidrs` from `0.0.0.0/0`.
