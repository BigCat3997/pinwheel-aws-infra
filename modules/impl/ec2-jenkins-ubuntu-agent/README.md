# Jenkins EC2 Agent Architecture

This implementation builds a dedicated VPC with one public subnet and a single
Jenkins build agent on EC2. The Jenkins controller connects to the agent over SSH
using a key pair created from a public key stored in AWS Secrets Manager. The
agent is bootstrapped with Docker, Git, Java, AWS CLI, and Terraform, and can be
administered through AWS Systems Manager.

## Runtime traffic flow

```mermaid
flowchart TB
  internet((Internet))
  controller["Jenkins controller<br/>(jenkins_controller_cidrs)"]
  admin["Administrator<br/>(Session Manager)"]

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph public["Public subnet"]
    direction LR
    agent["Jenkins agent EC2<br/>Docker, Git, Java 21, AWS CLI, Terraform"]
  end

  subgraph iam["Identity"]
    direction LR
    role["IAM role and instance profile"]
    ssm["AmazonSSMManagedInstanceCore"]
  end

  sg{{"Security group<br/>(SSH 22 from controller CIDRs only)"}}

  controller -->|"SSH 22"| igw
  igw --> agent
  admin -.->|"SSM"| agent
  agent -->|"Outbound: packages, Terraform, AWS APIs"| igw
  igw --> internet

  role --> agent
  ssm -.- role
  sg -.- agent

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef identity fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class igw ingress
  class agent publicTier
  class role,ssm identity
  class sg sgClass
```

Inbound SSH is allowed only from `jenkins_controller_cidrs`; when the list is
empty no inbound rule is created and the agent is reachable only through Session
Manager. Outbound traffic is unrestricted so the agent can install packages and
call AWS APIs.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  secret["Existing public-key secret"]

  inputs --> vpc["VPC"]
  vpc --> subnet["Public subnet"]
  vpc --> igw["Internet Gateway"]
  vpc --> sg["Security group"]

  igw --> routes["Route table and association"]
  subnet --> routes

  secret --> key_pair["EC2 key pair"]
  inputs --> role["IAM role and instance profile"]
  inputs --> user_data["User-data template"]

  subnet --> agent["Jenkins agent EC2"]
  sg --> agent
  key_pair --> agent
  role --> agent
  user_data --> agent
  routes --> agent
```

Terraform uses the base modules under `modules/base/` for each component. The
agent waits for the route table association so the bootstrap script has internet
access on first boot. User data runs only on first boot; changing it does not
replace the instance unless `user_data_replace_on_change` is `true`.
