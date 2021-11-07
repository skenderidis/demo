
locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


module "apps-west-us" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "westus"
  rg_prefix = "App-west-us"
  username	= local.gslb_data.f5_user
  password	= local.gslb_data.f5_pass
  pool      = "app_america_pool"
  count     = var.count_westus
}

module "apps-east-us" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "eastus"
  rg_prefix = "App-east-us"
  username	= local.gslb_data.f5_user
  password	= local.gslb_data.f5_pass
  pool      = "app_america_pool"
  count     = var.count_eastus
}


module "apps-europe" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "uksouth"
  rg_prefix = "App-europe"
  username	= local.gslb_data.f5_user
  password	= local.gslb_data.f5_pass
  pool      = "app_europe_pool"
  count = var.count_uksouth
}


module "apps-asia" {
  source    = "./modules"
  gtm_ip    = local.gslb_data.mgmt_ip
  location  = "eastasia"
  rg_prefix = "App-asia"
  username	= local.gslb_data.f5_user
  password	= local.gslb_data.f5_pass
  pool      = "app_asia_pool"
  count     = var.count_eastasia
}

output "east_us_public_ips" {
  value = module.apps-east-us[*]
}
output "west_us_public_ips" {
  value = module.apps-west-us[*]
}
output "europe_public_ips" {
  value = module.apps-europe[*]
}
output "asia_public_ips" {
  value = module.apps-asia[*]
}



