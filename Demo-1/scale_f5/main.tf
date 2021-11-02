locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "bigip-east-us" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix    = "Primary-DC"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool"
  sd_fqdn   = "us.f5demo.cloud"
  count = 0
 
}


module "bigip-west-us" {
  source    = "./modules"
  location  = "westus"
  rg_prefix    = "Demo-eastus"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool" 
  sd_fqdn   = "us.f5demo.cloud"
  count = 0
}


module "bigip-uk-south" {
  source    = "./modules"
  location  = "uksouth"
  rg_prefix = "Demo-uk-south"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "europe_pool" 
  sd_fqdn   = "eu.f5demo.cloud"
  count = 1
}

module "bigip-west-eu" {
  source    = "./modules"
  location  = "westeurope"
  rg_prefix = "Demo-west-eu"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "europe_pool" 
  sd_fqdn   = "eu.f5demo.cloud"
  count = 0
}

module "bigip-asia" {
  source    = "./modules"
  location  = "eastasia"
  rg_prefix = "Demo-asia"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "asia_pool"
  sd_fqdn   = "as.f5demo.cloud"
  count = 1
}
