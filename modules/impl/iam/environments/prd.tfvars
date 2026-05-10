create_policy        = true
name                 = "pinwheel3-iam"
path                 = "/"
permissions_boundary = null
force_destroy        = true

create_user                           = true
user_name                             = "pinwheel3-user"
create_access_key                     = true
access_key_count                      = 2
create_codecommit_https_credential    = true
create_login_profile                  = true
login_profile_password_length         = 20
login_profile_password_reset_required = true
policy_arn                            = "arn:aws:iam::aws:policy/AdministratorAccess"

tags = {
  Environment = "prd"
  Project     = "rookie"
  Managed_By  = "terraform"
  Created_By  = "terraform"
  Version     = "1.0.0"
  Deployed_By = "codepipeline"
}
