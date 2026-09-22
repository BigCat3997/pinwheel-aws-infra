# EC2 HA Load-Balanced Architecture

This implementation builds a VPC with public and private subnets, two application
instances, a bastion host, and both Application and Network Load Balancers. The
load balancers distribute traffic to the primary and standby EC2 instances, and
their vended logs are delivered to CloudWatch Logs.

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
    alb["Public ALB<br/>HTTP / HTTPS listeners"]
    bastion["Bastion EC2"]
    nat_a["NAT Gateway A"]
    nat_b["NAT Gateway B"]
  end

  subgraph private["Private application subnets"]
    direction LR
    nlb["Internal NLB<br/>TCP / TLS listeners"]
    primary["Primary EC2"]
    standby["Standby EC2"]
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    direction LR
    alb_logs["Log group<br/>/aws/alb/&lt;alb-name&gt;"]
    nlb_logs["Log group<br/>/aws/nlb/&lt;nlb-name&gt;"]
  end

  sg{{"Security groups<br/>(attached to ALB, NLB, bastion, primary, standby)"}}

  internet --> igw
  igw --> alb
  igw --> bastion
  private_clients --> nlb

  alb -->|"HTTP application traffic"| primary
  alb -->|"HTTP application traffic"| standby
  nlb -->|"Layer 4 traffic"| primary
  nlb -->|"Layer 4 traffic"| standby
  bastion -.->|"SSH administration"| primary
  bastion -.->|"SSH administration"| standby

  primary -->|"Outbound internet"| nat_a
  standby -->|"Outbound internet"| nat_b
  nat_a --> igw
  nat_b --> igw

  alb -->|"Access, connection, and health-check logs"| alb_logs
  nlb -->|"NLB_ACCESS_LOGS"| nlb_logs

  sg -.- alb
  sg -.- nlb
  sg -.- bastion
  sg -.- primary
  sg -.- standby

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class igw ingress
  class alb,bastion,nat_a,nat_b publicTier
  class nlb,primary,standby privateTier
  class alb_logs,nlb_logs obs
  class sg sgClass
```

The NLB is internal in the development configuration, so clients must reach it
from the VPC or a connected network. AWS emits NLB access-log records only for
TLS listeners; TCP listeners do not produce `NLB_ACCESS_LOGS` entries.

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
  subnets --> instances["Bastion, primary, and standby EC2"]
  sg --> instances
  key_pairs --> instances
  nat --> instances

  instances --> lookup["EC2 lookup by Name tag"]
  lookup --> attachments["Target-group attachments"]
  subnets --> load_balancers["ALB and NLB"]
  sg --> load_balancers
  attachments --> load_balancers

  load_balancers --> delivery["CloudWatch Logs delivery"]
  log_groups["ALB and NLB log groups"] --> delivery

  inputs --> kms["KMS key"]
  kms --> output_secrets["Managed EC2 public-key secrets"]
  key_pairs --> output_secrets
```

Terraform uses the base modules under `modules/base/` for each component. The
explicit EC2 lookup converts the configured instance names to instance IDs before
building the ALB and NLB target-group attachments.
