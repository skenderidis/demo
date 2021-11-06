
locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "apps-us" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "westus"
  rg_prefix = "App-eastus"
  username	= var.username
  password	= var.password
  pool      = "app_america_pool"
  count = count_westus
}

# Create a resource group for Demo
module "apps-europe" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "uksouth"
  rg_prefix = "App-europe"
  username	= var.username
  password	= var.password
  pool      = "app_europe_pool"
  count = count_uksouth
}


# Create a resource group for Demo
module "apps-asia" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "eastasia"
  rg_prefix = "App-asia"
  username	= var.username
  password	= var.password
  pool      = "app_asia_pool"
  count = count_eastasia
}

output "america_public_ips" {
  value = module.apps-us[*]
}

output "europe_public_ips" {
  value = module.apps-europe[*]
}

output "asia_public_ips" {
  value = module.apps-asia[*]
}



