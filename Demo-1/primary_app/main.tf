
locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "apps" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "eastus"
  rg_prefix = "Primary-App"
  username	= local.gslb_data.f5_user
  password	= local.gslb_data.f5_pass
  pool      = "app_america_pool"
  count = 1
}


output "App_web01_Public_IP" {
  value = module.apps[*]
}




