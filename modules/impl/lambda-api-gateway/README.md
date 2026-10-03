# Lambda HTTP API Architecture

This implementation builds an API Gateway HTTP API in front of a single Lambda
function, using an envelope pattern for request and response bodies. The
function is invoked through an AWS_PROXY integration for every route and stage,
and its execution role is scoped to CloudWatch Logs only.

## Runtime traffic flow

```mermaid
flowchart TB
  client["Client"]

  subgraph api["API Gateway HTTP API"]
    direction LR
    cors["CORS configuration"]
    default_route["ANY /{proxy+}"]
    root_route["$default"]
    stages["Stages<br/>(dev, staging, prod, ...)"]
  end

  subgraph compute["Lambda"]
    direction LR
    integration["AWS_PROXY integration"]
    fn["Lambda function<br/>index.py: lambda_handler"]
  end

  subgraph observability["Observability (CloudWatch Logs)"]
    direction LR
    logs["Function log group"]
  end

  perm{{"Lambda permission<br/>allows API Gateway to invoke the function"}}

  client -->|"HTTPS request<br/>{action, data}"| stages
  stages --> default_route
  stages --> root_route
  default_route --> integration
  root_route --> integration
  integration -->|"AWS_PROXY invoke"| fn
  fn -->|"{success, data|error, timestamp}"| client

  fn -->|"Execution logs"| logs
  cors -.- stages
  perm -.- integration

  classDef publicTier fill:#DBEAFE,stroke:#2563EB,stroke-width:1px;
  classDef privateTier fill:#EDE9FE,stroke:#7C3AED,stroke-width:1px;
  classDef obs fill:#FCE7F3,stroke:#DB2777,stroke-width:1px;
  classDef sgClass fill:#FEF3C7,stroke:#D97706,stroke-width:1px;
  class cors,default_route,root_route,stages publicTier
  class integration,fn privateTier
  class logs obs
  class perm sgClass
```

Every route resolves to the same Lambda integration, so routing logic lives in
the function's `action` dispatch rather than in API Gateway. The `aws_lambda_permission`
resource is what actually authorizes API Gateway to invoke the function; without
it, requests fail with an authorization error even though the integration and
routes exist.

## Terraform dependency flow

```mermaid
flowchart LR
  inputs["Environment tfvars"]
  src["Lambda source<br/>files/lambda/src/"]

  inputs --> role["Lambda IAM role"]
  src --> zip["Lambda deployment package"]

  role --> fn["Lambda function"]
  zip --> fn

  inputs --> api["HTTP API<br/>+ CORS configuration"]
  fn --> integration["Lambda integration<br/>AWS_PROXY"]
  api --> integration

  integration --> routes["Routes<br/>ANY /{proxy+}, $default"]
  inputs --> stages["Stages"]
  api --> stages

  fn --> permission["Lambda permission<br/>for API Gateway"]
  api --> permission
```

Terraform uses the base modules under `modules/base/` for the IAM role and the
Lambda function itself; the API Gateway resources are defined directly in this
implementation since no reusable HTTP API base module exists yet. Changing
`files/lambda/src/index.py` and reapplying rebuilds and redeploys the function's
package.
