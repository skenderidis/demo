locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "bigip-east-us" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix = "F5-eastus"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool"
  sd_fqdn   = "apps-us.f5demo.cloud"
  count     = var.count_eastus
 
}

module "bigip-west-us" {
  source    = "./modules"
  location  = "westus"
  rg_prefix = "F5-westus"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool" 
  sd_fqdn   = "apps-us.f5demo.cloud"
  count     = var.count_westus
}

module "bigip-west-eu" {
  source    = "./modules"
  location  = "uksouth"
  rg_prefix = "F5-eu"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "europe_pool" 
  sd_fqdn   = "apps-eu.f5demo.cloud"
  count     = var.count_uksouth
}

module "bigip-asia" {
  source    = "./modules"
  location  = "eastasia"
  rg_prefix = "F5-asia"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "asia_pool"
  sd_fqdn   = "apps-as.f5demo.cloud"
  count     = var.count_eastasia
}
