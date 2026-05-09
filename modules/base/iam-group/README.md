# IAM Group base module

Creates an IAM group and optionally:

- attaches managed policy ARNs
- adds inline policies
- assigns IAM users to the group

## Example

```hcl
module "developers_group" {
  source = "../../base/iam-group"

  name = "developers"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  users = [
    "alice",
    "bob"
  ]
}
```
