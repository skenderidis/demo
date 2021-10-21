locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "bigip-east-us" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix    = "F5-eastus"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool"
  count = 1
  
}


module "bigip-west-us" {
  source    = "./modules"
  location  = "westus"
  rg_prefix    = "Demo-eastus"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "america_pool" 
  count = 0
}


module "bigip-north-eu" {
  source    = "./modules"
  location  = "northeurope"
  rg_prefix    = "Demo-north-eu"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "europe_pool" 
  count = 0
}

module "bigip-west-eu" {
  source    = "./modules"
  location  = "westeurope"
  rg_prefix    = "Demo-west-eu"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "europe_pool" 
  count = 0
}

module "bigip-asia" {
  source    = "./modules"
  location  = "eastasia"
  rg_prefix    = "Demo-asia"
  gtm_ip    = local.gslb_data.mgmt_ip
  username	= var.username
  password	= var.password
  pool      = "asia_pool"   
  count = 0
}