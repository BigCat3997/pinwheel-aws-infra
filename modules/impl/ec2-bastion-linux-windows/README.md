# Bastion + Private EC2 with CloudWatch Architecture

This implementation builds a VPC with public and private subnets, a Linux bastion,
a Windows bastion, and one or two private application instances reachable only
through the bastions or Systems Manager. Private EC2 instances run a CloudWatch
Agent that ships system logs to CloudWatch Logs, and reach SSM and CloudWatch
Logs over VPC interface endpoints instead of the internet.

## Runtime traffic flow

```mermaid
flowchart TB
  internet((Internet))
  admin["Administrator"]

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph public["Public subnets"]
    direction LR
    bastion["Linux Bastion EC2<br/>Amazon Linux 2023"]
    win_bastion["Windows Bastion EC2<br/>Windows Server 2022"]
    nat["NAT Gateway"]
  end

  subgraph private["Private application subnets"]
    direction LR
    private_ec2["Private EC2<br/>CloudWatch Agent"]
    private_ec2_secondary["Private EC2 (secondary)<br/>CloudWatch Agent"]
  end

  subgraph endpoints["VPC interface endpoints"]
    direction LR
    ssm_vpce["SSM endpoint"]
    logs_vpce["Logs endpoint"]
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    direction LR
    log_group["Log group<br/>/aws/ec2/&lt;private-ec2-name&gt;/system"]
  end

  sg{{"Security groups<br/>(attached to bastions, private EC2, VPC endpoints)"}}

  internet --> igw
  igw --> bastion
  igw --> win_bastion
  admin -->|"SSH 22"| bastion
  admin -->|"RDP 3389"| win_bastion

  bastion -.->|"SSH administration"| private_ec2
  bastion -.->|"SSH administration"| private_ec2_secondary

  private_ec2 -->|"Outbound internet"| nat
  private_ec2_secondary -->|"Outbound internet"| nat
  nat --> igw

  private_ec2 -->|"HTTPS"| ssm_vpce
  private_ec2 -->|"HTTPS"| logs_vpce
  private_ec2_secondary -->|"HTTPS"| ssm_vpce
  private_ec2_secondary -->|"HTTPS"| logs_vpce

  private_ec2 -->|"System logs"| log_group
  private_ec2_secondary -->|"System logs"| log_group

  sg -.- bastion
  sg -.- win_bastion
  sg -.- private_ec2
  sg -.- private_ec2_secondary
  sg -.- ssm_vpce
  sg -.- logs_vpce

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef endpointTier fill:#FEF9C3,stroke:#CA8A04,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class igw ingress
  class bastion,win_bastion,nat publicTier
  class private_ec2,private_ec2_secondary privateTier
  class ssm_vpce,logs_vpce endpointTier
  class log_group obs
  class sg sgClass
```

Private EC2 instances have no public IP; the bastions are the only supported
SSH/RDP path in from the internet. Windows AMIs reject ED25519 key pairs, so the
Windows bastion's key pair is sourced from its own RSA public-key secret while
the Linux bastion and private instances can share one ED25519 secret.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  bastion_secret["ec2-user public-key secret"]
  windows_secret["Windows public-key secret"]
  private_secret["Private EC2 public-key secret"]
  private_secondary_secret["Private EC2 secondary public-key secret"]

  inputs --> vpc["VPC"]
  vpc --> subnets["Public and private subnets"]
  vpc --> igw["Internet Gateway"]
  vpc --> sg["Security groups"]
  inputs --> eip["Elastic IP"]

  subnets --> nat["NAT Gateway"]
  eip --> nat
  igw --> routes["Route tables and associations"]
  nat --> routes
  subnets --> routes

  bastion_secret --> bastion_key["Linux bastion key pair"]
  windows_secret --> windows_key["Windows bastion key pair"]
  private_secret --> private_key["Private EC2 key pair"]
  private_secondary_secret --> private_secondary_key["Private EC2 secondary key pair"]

  subnets --> bastion["Linux bastion EC2"]
  sg --> bastion
  bastion_key --> bastion

  subnets --> win_bastion["Windows bastion EC2"]
  sg --> win_bastion
  windows_key --> win_bastion

  inputs --> role["CloudWatch agent IAM role"]
  inputs --> log_group["CloudWatch log group"]
  inputs --> ssm_param["CloudWatch Agent config SSM parameter"]
  log_group --> ssm_param

  subnets --> vpce["SSM and Logs VPC endpoints"]
  sg --> vpce

  subnets --> private_ec2["Private EC2 instances"]
  sg --> private_ec2
  private_key --> private_ec2
  private_secondary_key --> private_ec2
  role --> private_ec2
  ssm_param --> private_ec2
  vpce --> private_ec2
  routes --> private_ec2

  bastion_key --> kms_secrets["Published bastion public-key secrets"]
  windows_key --> kms_secrets
  kms["KMS key"] --> kms_secrets
```

Terraform uses the base modules under `modules/base/` for each component. Key
pairs are created from existing Secrets Manager public-key secrets rather than
local files, and the resulting bastion public keys are republished to Secrets
Manager, encrypted with a dedicated KMS key, for downstream consumers.
