# CloudWatch VPC Endpoint Architecture

This implementation builds a VPC with flow logs enabled, a public subnet, and
two private subnets each fronted by a CloudWatch Logs interface VPC endpoint. A
private test EC2 instance pushes log entries to CloudWatch Logs entirely over
the AWS backbone, with no route to the internet.

## Runtime traffic flow

```mermaid
flowchart TB
  internet((Internet))

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph public["Public subnet"]
    direction LR
    pub_rtb["Public route table<br/>0.0.0.0/0 → IGW"]
  end

  subgraph private["Private subnets (private-a, private-b)"]
    direction LR
    ec2["Test EC2<br/>log-pusher service"]
    vpce_a["Logs VPCE ENI<br/>private-a"]
    vpce_b["Logs VPCE ENI<br/>private-b"]
    priv_rtb["Private route table<br/>no NAT, no internet route"]
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    direction LR
    log_group["Log group<br/>/aws/vpce-test/.../push-logs-service"]
  end

  sg{{"Security groups<br/>(app instance: no ingress; VPC endpoints: HTTPS 443 ingress)"}}

  igw --> pub_rtb
  internet -.->|"no path to private subnets"| priv_rtb

  ec2 -->|"HTTPS 443, VPC-internal"| vpce_a
  ec2 -->|"HTTPS 443, VPC-internal"| vpce_b
  vpce_a -->|"AWS backbone, no internet"| log_group
  vpce_b -->|"AWS backbone, no internet"| log_group

  sg -.- ec2
  sg -.- vpce_a
  sg -.- vpce_b

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class igw,pub_rtb ingress
  class ec2,vpce_a,vpce_b,priv_rtb privateTier
  class log_group obs
  class sg sgClass
```

The private route table has no NAT gateway or internet route, so the test
instance can reach CloudWatch Logs only through the interface endpoints. VPC
flow logs are enabled on the VPC itself for network-level visibility.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]

  inputs --> vpc["VPC (flow logs enabled)"]
  vpc --> subnets["Public and private subnets"]
  vpc --> igw["Internet Gateway"]
  vpc --> app_sg["App instance security group"]
  vpc --> vpce_sg["VPC endpoint security group"]

  igw --> routes["Route tables and associations"]
  subnets --> routes

  subnets --> vpce["Logs VPC endpoint<br/>(private-a, private-b)"]
  vpce_sg --> vpce

  inputs --> role["EC2 IAM role and policy"]
  inputs --> log_group["CloudWatch log group"]

  subnets --> ec2["Test EC2 instance"]
  app_sg --> ec2
  role --> ec2
  log_group --> ec2
  vpce --> ec2

  ec2 --> user_data["User-data: log-pusher service"]
```

Terraform uses the base modules under `modules/base/` for each component. The
EC2 instance depends on the log group and IAM role so its user data can push to
CloudWatch Logs as soon as it boots, and on the VPC endpoint's subnets/security
group so the endpoint exists before the instance tries to reach it.
