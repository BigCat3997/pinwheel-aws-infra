tags = {
  Project     = "Rookie"
  Created_By  = "Terraform"
  Managed_By  = "Terraform"
  Environment = "Shared"
}

repositories = [
  {
    repository_name = "bc-infrastructure-provisioning"
    description     = "Repository for infrastructure provisioning code"
    default_branch  = "main"
  },
  {
    repository_name = "bc-orchestration"
    description     = "Repository for orchestration code"
    default_branch  = "main"
  },
  {
    repository_name = "bc-api"
    description     = "Repository for Java API code"
    default_branch  = "main"
  },
  {
    repository_name = "bc-frontend"
    description     = "Repository for frontend code"
    default_branch  = "main"
  }
]