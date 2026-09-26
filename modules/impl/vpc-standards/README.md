# VPC Standards Architecture

This implementation builds a VPC with public and private subnets, an Internet
Gateway, Elastic IPs and NAT gateways, and route tables with their subnet
associations. VPC Flow Logs are enabled and delivered to CloudWatch Logs. It
creates no compute, so it serves as the network foundation for other
implementations.

## Runtime traffic flow

```mermaid
flowchart TB
  internet((Internet))

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph vpc["VPC"]
    direction TB

    subgraph public["Public subnets"]
      direction LR
      pub_a["Public subnet A"]
      pub_b["Public subnet B"]
    end

    subgraph nat["NAT gateways"]
      direction LR
      nat_a["NAT Gateway A<br/>Elastic IP A"]
      nat_b["NAT Gateway B<br/>Elastic IP B"]
    end

    subgraph private["Private subnets"]
      direction LR
      priv_a["Private subnet A"]
      priv_b["Private subnet B"]
    end
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    flow_logs["VPC Flow Logs<br/>log group and IAM role"]
  end

  internet --> igw
  igw -->|"Public route table<br/>0.0.0.0/0 to IGW"| pub_a
  igw -->|"Public route table<br/>0.0.0.0/0 to IGW"| pub_b

  priv_a -->|"Private route table A<br/>0.0.0.0/0 to NAT A"| nat_a
  priv_b -->|"Private route table B<br/>0.0.0.0/0 to NAT B"| nat_b
  nat_a --> igw
  nat_b --> igw

  vpc -->|"Accepted and rejected traffic records"| flow_logs

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  class igw ingress
  class pub_a,pub_b,nat_a,nat_b publicTier
  class priv_a,priv_b privateTier
  class flow_logs obs
```

Which subnet hosts each NAT gateway is set by `subnet_name` in `nat_gateways`,
and Terraform looks that name up in the `private_subnets` map. A NAT gateway
needs a subnet routed to the Internet Gateway to reach the internet, so check
that the configured names and the route table associations agree. The diagram
shows the intended layout of NAT gateways in public subnets. The route tables and
associations come from `public_route_tables`, `private_route_tables`,
`public_rtb_assoc`, and `private_rtb_assoc`.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]

  inputs --> vpc["VPC<br/>Flow Logs to CloudWatch Logs"]
  vpc --> subnets["Public and private subnets"]
  vpc --> igw["Internet Gateway"]
  inputs --> eips["Elastic IPs"]

  subnets --> nat["NAT Gateways"]
  eips --> nat

  igw --> routes["Route tables"]
  nat --> routes

  subnets --> assoc["Route table associations"]
  routes --> assoc
```

Terraform uses the base modules under `modules/base/` for each component. The
NAT gateway route targets are built from the created gateways by name, so a
private route table refers to a NAT gateway through the `nat_gateways` entry
names. The module exposes `vpc_id`, `vpc_cidr_block`, `public_subnet_names`, and
`private_subnet_names` as outputs for other implementations to consume.
