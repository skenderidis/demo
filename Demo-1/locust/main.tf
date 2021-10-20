
# Create a resource group for Demo
module "apps" {
  source    = "./modules"
  location  = "westeurope"
  rg_name    = "locust-master"
  count = 1
}


output "App_web01_Public_IP" {
  value = module.apps[*]
}


