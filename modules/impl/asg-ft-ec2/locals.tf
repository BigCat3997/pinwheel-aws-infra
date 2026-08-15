locals {
  subnet_mappings = [
    {
      subnet_id            = module.subnet.private_subnets["bc-subnet-rookie_app_private-dev-0"]
      private_ipv4_address = "10.0.0.100"
    },
    {
      subnet_id            = module.subnet.private_subnets["bc-subnet-rookie_app_private-dev-1"]
      private_ipv4_address = "10.0.0.132"
    }
  ]
}
