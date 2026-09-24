# EKS Standards

This implementation builds a VPC with public and private subnets, NAT gateways,
and a standards-compliant EKS cluster with managed node groups. The cluster
control plane runs with configurable private/public API endpoint access, worker
nodes run in the private subnets, and control-plane logs are delivered to
CloudWatch Logs.

## Runtime traffic flow

```mermaid
flowchart TB
  internet((Internet))
  operator["Operator / kubectl client"]

  subgraph ingress["Ingress"]
    igw["Internet Gateway"]
  end

  subgraph public["Public subnets"]
    direction LR
    nat_a["NAT Gateway A"]
    nat_b["NAT Gateway B"]
  end

  subgraph private["Private subnets"]
    direction LR
    nodes["EKS managed node group(s)<br/>worker EC2 instances"]
  end

  subgraph controlplane["EKS control plane (AWS-managed)"]
    api["Cluster API server endpoint"]
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    cluster_logs["Cluster log group<br/>enabled_cluster_log_types"]
  end

  sg{{"Cluster security group<br/>(attached to control plane ENIs and nodes)"}}

  internet --> igw
  operator -->|"kubectl / EKS API<br/>(public endpoint, if enabled)"| api
  api -->|"private endpoint"| nodes

  nodes -->|"Outbound internet<br/>(pull images, etc.)"| nat_a
  nodes -->|"Outbound internet<br/>(pull images, etc.)"| nat_b
  nat_a --> igw
  nat_b --> igw

  api -->|"control plane logs"| cluster_logs

  sg -.- api
  sg -.- nodes

  classDef ingress fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef controlplaneTier fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  class igw ingress
  class nat_a,nat_b publicTier
  class nodes privateTier
  class api controlplaneTier
  class cluster_logs obs
```

The cluster's API endpoint access is controlled by `endpoint_private_access`,
`endpoint_public_access`, and `public_access_cidrs`. When the public endpoint is
disabled, `kubectl` must reach the API server from inside the VPC or a connected
network.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]

  inputs --> vpc["VPC"]
  vpc --> subnets["Public and private subnets"]
  vpc --> igw["Internet Gateway"]
  inputs --> eips["Elastic IPs"]

  subnets --> nat["NAT Gateways"]
  eips --> nat
  igw --> routes["Route tables and associations"]
  nat --> routes
  subnets --> routes

  vpc --> cluster_sg["Cluster security group"]

  cluster_role["EKS cluster IAM role"]
  node_role["EKS node IAM role"]

  subnets --> eks["EKS cluster and managed node groups"]
  cluster_sg --> eks
  cluster_role --> eks
  node_role --> eks
  routes --> eks

  eks --> node_groups_ready["Node groups ready"]
  node_groups_ready --> addons["EKS addons<br/>(vpc-cni, coredns, kube-proxy)"]

  eks --> outputs["Cluster outputs<br/>(id, ARN, endpoint, CA data, OIDC issuer)"]
  addons --> outputs2["Addon outputs<br/>(addon_arns)"]

  outputs --> oidc["OIDC provider<br/>(aws_iam_openid_connect_provider)"]
  oidc --> ebs_role["EBS CSI driver IRSA role"]
  ebs_role --> ebs_addon["aws-ebs-csi-driver addon<br/>(standalone aws_eks_addon)"]
```

Terraform uses the base modules under `modules/base/` for each component. The
EKS control plane, node groups, and most addons are provisioned together by
`modules/base/eks`, which depends on the private subnets and route table
associations being in place before nodes can reach the NAT gateways for
outbound access. Addons are applied after the managed node groups so that
they have nodes to schedule onto; configure them via the `eks_addons`
variable. The `dev` environment enables the VPC CNI's `enableNetworkPolicy`
setting via `configuration_values`, so Kubernetes `NetworkPolicy` resources
are enforced by the CNI itself.

The `aws-ebs-csi-driver` addon is **not** part of `eks_addons` — it needs an
IRSA (IAM Roles for Service Accounts) role scoped to its Kubernetes service
account, and that role's trust policy needs the cluster's OIDC issuer URL,
which only exists after the cluster itself is created. Passing that role's
ARN through `module.local_eks`'s own `addons` input would create a dependency
cycle (the module would depend on a resource that depends on the module's own
output). Instead, `main.tf` creates the OIDC provider
(`aws_iam_openid_connect_provider.eks`), the IRSA role
(`module.local_ebs_csi_driver_role`), and a standalone `aws_eks_addon.ebs_csi_driver`
resource after the cluster and node groups exist.

## Operator quick reference

```bash
aws sts get-caller-identity
aws configure get region

aws eks update-kubeconfig --region us-east-1 --name <EKS_NAME>

kubectl config current-context
kubectl cluster-info
kubectl get nodes
kubectl get ns
```
