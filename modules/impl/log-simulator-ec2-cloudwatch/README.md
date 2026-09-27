# Log Simulator EC2 with CloudWatch Logs and S3 Archive

This implementation builds a VPC with a public subnet, a single log-simulator EC2
instance, and one CloudWatch log group. The instance simulates six services that
each write their own log file, but the CloudWatch Agent ships only two of them.
Events in the log group are then streamed through Firehose, reshaped by a Lambda
transformer, and archived to S3.

## Runtime log flow

```mermaid
flowchart TB
  admin((Administrator))

  subgraph public["Public subnet"]
    direction LR
    ec2["Log simulator EC2<br/>systemd timer writes<br/>service1..service6.log"]
    agent["CloudWatch Agent<br/>collect_list: service1, service2"]
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    direction LR
    lg["Log group<br/>/ec2/log-simulator/app"]
    s1["Log stream<br/>&lt;instance-id&gt;-service1"]
    s2["Log stream<br/>&lt;instance-id&gt;-service2"]
  end

  subgraph archive["Archive pipeline"]
    direction LR
    sub_filter["Subscription filter"]
    firehose["Firehose delivery stream<br/>buffers by size and interval"]
    lambda["Transformer Lambda<br/>gunzip, one JSON line per event"]
  end

  subgraph storage["S3 log archive bucket"]
    direction LR
    logs_prefix["logs/YYYY/MM/DD/HH/"]
    errors_prefix["errors/&lt;error-type&gt;/YYYY/MM/DD/"]
  end

  sg{{"Security group<br/>SSH from ssh_ingress_cidrs"}}

  admin -.->|"SSH"| ec2
  sg -.- ec2

  ec2 -->|"service3..service6 stay on disk"| ec2
  ec2 --> agent
  agent --> s1
  agent --> s2
  s1 --> lg
  s2 --> lg

  lg --> sub_filter
  sub_filter --> firehose
  firehose -->|"Batch of records"| lambda
  lambda -->|"Transformed records"| firehose
  firehose -->|"Ok records"| logs_prefix
  firehose -->|"ProcessingFailed records"| errors_prefix

  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef pipeline fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef store fill:#E8F7EE,stroke:#219653,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class ec2,agent publicTier
  class lg,s1,s2 obs
  class sub_filter,firehose,lambda pipeline
  class logs_prefix,errors_prefix store
  class sg sgClass
```

Only the files in `collected_log_paths` (default `service1.log` and
`service2.log`) are listed in the agent's `collect_list`. The other files under
`/var/log/app/` still fill up on disk, but nothing ships them off the instance.
`collected_log_paths` must be a subset of `simulated_log_paths`. The instance
role has only `CloudWatchAgentServerPolicy`, because the collected/uncollected
split is made in the agent configuration, not in IAM.

The subscription filter covers every stream in the log group and forwards events
that match `log_subscription_filter_pattern`. Firehose invokes the Lambda once
per buffered batch (`log_archive_buffer_size_mb` or
`log_archive_buffer_interval_seconds`, whichever is reached first), not once
per event. S3 prefixes use Firehose arrival time, and the bucket expires objects
after `log_archive_expiration_days`.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  existing_secret["Existing SSH public-key secret"]

  inputs --> vpc["VPC"]
  vpc --> subnets["Public subnet"]
  vpc --> igw["Internet Gateway"]
  vpc --> sg["Security group"]
  igw --> routes["Route table and association"]
  subnets --> routes

  existing_secret --> key_pair["EC2 key pair"]
  inputs --> agent_role["CloudWatch Agent role"]
  inputs --> log_group["CloudWatch log group"]
  log_group --> user_data["User data<br/>agent config and simulator"]

  subnets --> ec2["Log simulator EC2"]
  sg --> ec2
  key_pair --> ec2
  agent_role --> ec2
  user_data --> ec2
  routes --> ec2

  inputs --> bucket["Log archive S3 bucket"]
  inputs --> lambda_role["Transformer role"]
  lambda_role --> lambda["Transformer Lambda"]
  bucket --> firehose_role["Firehose role"]
  lambda --> firehose_role
  firehose_role --> firehose["Firehose delivery stream"]
  bucket --> firehose
  lambda --> firehose

  firehose --> sub_role["Subscription role"]
  sub_role --> sub_filter["Subscription filter"]
  log_group --> sub_filter
  firehose --> sub_filter
```

Terraform uses the base modules under `modules/base/` for each component. The
Secrets Manager secret named by `ssh_public_key_secret_name` must already exist
and hold a single OpenSSH public key, which Terraform registers as the key pair
named by `key_pair_name`. Do not store a private key in it.

Standard EC2 user data runs only on first boot. Changing `simulated_log_paths`,
`collected_log_paths`, or the CloudWatch Agent bootstrap later does not
reconfigure an existing instance unless you apply the change on the instance or
accept replacement.

To check delivery after an apply, SSH to the instance (`ssh_command` output) and
confirm `simulate-services.timer` is active and all six files under
`/var/log/app/` are growing. The log group (`log_group_name` output) should
contain exactly two streams, `<instance-id>-service1` and
`<instance-id>-service2`, and objects should appear under `logs/` in the bucket
(`log_archive_bucket_name` output) after the buffer interval.
