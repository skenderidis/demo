locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "bigip_primary" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix = "Primary-DC"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= local.gslb_data.f5_user
  password	= local.gslb_data.f5_pass
  pool      = "america_pool"
  sd_fqdn   = "apps-us.f5demo.cloud"
  count = 1
  
}

