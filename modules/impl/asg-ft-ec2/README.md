# ASG Fault-Tolerant EC2 Architecture

This implementation builds a VPC with public and private subnets, a bastion
host, a standalone application instance, and an Auto Scaling group (ASG) built
from a launch template. The ASG registers its instances with the target groups
of both an Application Load Balancer and a Network Load Balancer.

## Runtime traffic flow

```mermaid
flowchart TB
  internet((Internet))
  private_clients["VPC or connected-network clients"]

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph public["Public subnets"]
    direction LR
    bastion["Bastion EC2"]
    nat["NAT Gateways"]
  end

  subgraph private["Private application subnets"]
    direction LR
    alb["ALB<br/>listeners from alb_listeners"]
    nlb["NLB<br/>listeners from nlb_listeners"]
    asg["Auto Scaling group<br/>launch-template instances"]
    app["Standalone app EC2"]
  end

  sg{{"Security groups<br/>(attached to bastion, app EC2, ALB, and ASG instances)"}}

  internet --> igw
  igw --> bastion
  private_clients --> alb
  private_clients --> nlb

  alb -->|"Application traffic"| asg
  nlb -->|"Layer 4 traffic"| asg
  bastion -.->|"SSH administration"| asg
  bastion -.->|"SSH administration"| app

  asg -->|"Outbound internet"| nat
  app -->|"Outbound internet"| nat
  nat --> igw

  sg -.- bastion
  sg -.- app
  sg -.- alb
  sg -.- asg

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class igw ingress
  class bastion,nat publicTier
  class alb,nlb,asg,app privateTier
  class sg sgClass
```

Both load balancers are placed in private subnets. The NLB is internal unless
`nlb_enable_public` is `true`, and the ALB is public unless `alb_enable_public`
is `false`, so review those two settings together with the subnet choice. The
standalone app instance is not behind a load balancer. It is reached through
the bastion.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  existing_secrets["Existing public-key secrets"]

  inputs --> vpc["VPC"]
  vpc --> subnets["Public and private subnets"]
  vpc --> igw["Internet Gateway"]
  vpc --> sg["Security groups"]
  inputs --> eips["Elastic IPs"]

  subnets --> nat["NAT Gateways"]
  eips --> nat
  igw --> routes["Route tables and associations"]
  nat --> routes
  subnets --> routes

  existing_secrets --> key_pairs["EC2 key pairs"]
  subnets --> instances["Bastion and app EC2"]
  sg --> instances
  key_pairs --> instances

  key_pairs --> lt["Launch template"]
  sg --> lt

  subnets --> load_balancers["ALB and NLB"]
  sg --> load_balancers
  load_balancers --> target_groups["Target groups"]

  lt --> asg["Auto Scaling group"]
  subnets --> asg
  target_groups --> asg

  inputs --> kms["KMS key"]
  kms --> output_secrets["Managed EC2 public-key secrets"]
  key_pairs --> output_secrets
```

Terraform uses the base modules under `modules/base/` for each component. The
public key for each key pair is read from an existing Secrets Manager secret
(`bastion_ec2_public_key_secret_name`, `app_ec2_public_key_secret_name`, and
`lt_ec2_public_key_secret_name`), which must exist before `plan`. The module
then writes the keys to new KMS-encrypted secrets named
`ec2/<name>/ec2-user/public-key`.

`locals.tf` hard-codes the two NLB subnet mappings (subnet names
`bc-subnet-rookie_app_private-dev-0` and `-1`, private IPs `10.0.0.100` and
`10.0.0.132`), so those subnets must exist in `private_subnets`. User data runs
only on first boot, and a new launch template version affects only instances
the ASG launches afterward.
