locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "bigip_primary" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix = "Primary-DC"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool"
  sd_fqdn   = "us.f5demo.cloud"
  count = 1
  
}

