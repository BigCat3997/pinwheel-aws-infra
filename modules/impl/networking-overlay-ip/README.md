# Networking Overlay IP Architecture

This implementation builds a two-VPC overlay-IP test topology: an HA VPC with a
primary and standby node, and a client VPC with a test instance that reaches the
overlay address through a transit gateway. It models the route a tool like
Pacemaker would repoint during a SAP-style HA failover, without any clustering
software — the failover itself is done manually.

## Runtime traffic flow

```mermaid
flowchart TB
  subgraph client_vpc["Client VPC"]
    direction LR
    client_ec2["Client EC2<br/>SSM only, no direct SSH"]
  end

  subgraph tgw_layer["Transit Gateway"]
    direction LR
    tgw["Transit Gateway"]
  end

  subgraph ha_vpc["HA VPC"]
    direction LR
    overlay_route["Overlay route<br/>overlay_cidr → active node's ENI"]
    primary["Primary EC2<br/>owns overlay /32 on loopback"]
    standby["Standby EC2<br/>service running, no overlay IP yet"]
  end

  sg{{"Security groups<br/>(HA nodes: service port from client VPC + all traffic between nodes; client: egress only)"}}

  client_ec2 -->|"curl to overlay IP:service_port"| tgw
  tgw -->|"client VPC CIDR route"| client_vpc
  tgw -->|"overlay CIDR route"| ha_vpc
  overlay_route -->|"currently targets"| primary
  primary -.->|"return traffic to client CIDR"| tgw

  sg -.- primary
  sg -.- standby
  sg -.- client_ec2

  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class client_ec2 publicTier
  class primary,standby,overlay_route privateTier
  class tgw obs
  class sg sgClass
```

All three instances share one IAM role and instance profile so Systems Manager
is the only way in — there's no bastion or open SSH. Failover is manual: moving
traffic to the standby means adding the overlay `/32` to its loopback, replacing
the HA VPC route's ENI target, and removing the address from the primary (see
`manual_failover_commands` in the outputs).

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]

  inputs --> ha_vpc["HA VPC"]
  inputs --> client_vpc["Client VPC"]

  ha_vpc --> ha_subnets["HA public subnets"]
  ha_vpc --> ha_igw["HA Internet Gateway"]
  ha_vpc --> ha_sg["HA nodes security group"]
  ha_igw --> ha_routes["HA route tables + associations"]
  ha_subnets --> ha_routes

  client_vpc --> client_subnets["Client public subnets"]
  client_vpc --> client_igw["Client Internet Gateway"]
  client_vpc --> client_sg["Client security group"]
  client_igw --> client_routes["Client route tables + associations"]
  client_subnets --> client_routes

  inputs --> role["SSM IAM role + instance profile"]

  ha_subnets --> primary_ec2["Primary EC2"]
  ha_subnets --> standby_ec2["Standby EC2"]
  ha_sg --> primary_ec2
  ha_sg --> standby_ec2
  role --> primary_ec2
  role --> standby_ec2

  client_subnets --> client_ec2["Client EC2"]
  client_sg --> client_ec2
  role --> client_ec2

  ha_vpc --> tgw_ha_attach["HA TGW attachment"]
  client_vpc --> tgw_client_attach["Client TGW attachment"]
  tgw["Transit Gateway"] --> tgw_ha_attach
  tgw --> tgw_client_attach

  tgw_ha_attach --> tgw_route["TGW route: overlay CIDR → HA attachment"]
  tgw_client_attach --> client_overlay_route["Client route: overlay CIDR → TGW"]
  tgw_ha_attach --> ha_return_route["HA route: client CIDR → TGW"]
  primary_ec2 --> overlay_route["HA route: overlay CIDR → primary ENI"]
  ha_routes --> overlay_route
```

Terraform uses the base modules under `modules/base/` for VPCs, subnets,
internet gateways, route tables and associations, security groups, EC2
instances, the IAM role, the transit gateway, and its VPC attachments. Three
resources stay in this implementation rather than a base module because their
targets (an ENI, a transit-gateway attachment) are specific to this
composition: the overlay route to the active node, the client-side route to the
overlay CIDR via the transit gateway, and the HA-side return route to the
client VPC CIDR.
