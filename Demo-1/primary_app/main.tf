
locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "apps" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "eastus"
  rg_name = "Primary-App"
  username	= var.username
  password	= var.password
  pool      = "app_america_pool"
  count = 1
}


output "App_web01_Public_IP" {
  value = module.apps[*]
}




