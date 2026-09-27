# Co-located EC2 and Multi-AZ MySQL Architecture

This implementation builds a VPC with one private subnet per Availability Zone,
a primary and a standby EC2 instance (one per AZ), and an RDS MySQL Multi-AZ
instance. A Lambda function keeps EC2 compute co-located with whichever AZ RDS
currently treats as primary: it starts the instance in that AZ and stops the
other one, triggered whenever RDS emits a DB instance event for this identifier.

EC2 instances cannot change Availability Zone in place, so this module
pre-creates one instance in each AZ and switches which one is running instead of
moving an instance. The RDS DNS endpoint stays stable across a failover, and
applications should always connect through that endpoint rather than to an
instance directly.

## Runtime traffic flow

```mermaid
flowchart TB
  app["Application"]

  subgraph az_a["Availability Zone A"]
    direction LR
    ec2_a["Primary EC2<br/>(running when RDS primary is here)"]
  end

  subgraph az_b["Availability Zone B"]
    direction LR
    ec2_b["Standby EC2<br/>(running when RDS primary is here)"]
  end

  subgraph db["RDS MySQL Multi-AZ"]
    direction LR
    rds["Stable DNS endpoint"]
  end

  events["EventBridge rule<br/>RDS DB Instance Event for this identifier"]

  subgraph reconciler["Failover reconciler"]
    direction LR
    lambda["Lambda: rds_db2_failover_handler"]
  end

  sg{{"Security groups<br/>(EC2 SSH; RDS port only from EC2 SG)"}}

  app -->|"MySQL, always via the endpoint"| rds
  rds -.->|"Reads/writes"| ec2_a
  rds -.->|"Reads/writes"| ec2_b

  rds -->|"DB instance events"| events
  events -->|"Invoke"| lambda
  lambda -->|"DescribeDBInstances: which AZ is primary"| rds
  lambda -->|"StartInstances"| ec2_a
  lambda -->|"StopInstances"| ec2_a
  lambda -->|"StartInstances"| ec2_b
  lambda -->|"StopInstances"| ec2_b

  sg -.- ec2_a
  sg -.- ec2_b
  sg -.- rds

  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class ec2_a,ec2_b privateTier
  class rds publicTier
  class events,lambda obs
  class sg sgClass
```

The Lambda function only starts and stops instances; it never resizes storage
or changes which AZ the pair lives in. On `RDS-EVENT-0049` (failover started) it
polls `DescribeDBInstances` until the reported AZ and status settle before
acting, so it doesn't react to a DB instance that is mid-failover. There is no
scheduled poll — reconciliation only runs when RDS emits a matching event, plus
whatever you trigger manually (see Operations below).

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  key_secret["Existing EC2 public-key secret"]

  inputs --> vpc["VPC"]
  vpc --> subnets["Private subnets (per AZ)"]
  vpc --> ec2_sg["EC2 security group"]
  vpc --> rds_sg["RDS security group"]
  ec2_sg --> rds_sg

  key_secret --> key_pair["EC2 key pair"]

  subnets --> primary_ec2["Primary EC2 (AZ A)"]
  subnets --> standby_ec2["Standby EC2 (AZ B)"]
  ec2_sg --> primary_ec2
  ec2_sg --> standby_ec2
  key_pair --> primary_ec2
  key_pair --> standby_ec2

  inputs --> initial_state["aws_ec2_instance_state<br/>(sets initial_active_node at apply time)"]
  primary_ec2 --> initial_state
  standby_ec2 --> initial_state

  subnets --> rds["RDS MySQL Multi-AZ"]
  rds_sg --> rds

  inputs --> lambda_role["Lambda IAM role and policy"]
  primary_ec2 --> lambda["Failover handler Lambda"]
  standby_ec2 --> lambda
  lambda_role --> lambda

  rds --> event_rule["EventBridge rule<br/>RDS DB Instance Event, this identifier"]
  event_rule --> event_target["EventBridge target + Lambda permission"]
  lambda --> event_target
```

Terraform uses the base modules under `modules/base/` for the VPC, subnets,
security groups, key pair, EC2 instances, Lambda function, and RDS instance. The
`aws_ec2_instance_state` resources only set which instance is running the first
time you apply (`initial_active_node`); after that, the Lambda function is what
keeps the running instance matched to RDS's current primary AZ.

The secret referenced by `sm_ec2_ssh_public_key_name` must already contain an
OpenSSH public key. When `rds_mysql_manage_master_user_password` is `true`, RDS
stores its generated master password in Secrets Manager instead.