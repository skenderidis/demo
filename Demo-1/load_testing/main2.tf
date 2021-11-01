locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
}


# Create a resource group for Demo
module "load-east-us" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix = "East-us"
  master    = "monitor.f5demo.cloud"
  count = 0
}


module "load-west-us" {
  source    = "./modules"
  location  = "westus"
  rg_prefix = "West-us"
  master    = "monitor.f5demo.cloud"
  count = 0
}

module "load-north-eu" {
  source    = "./modules"
  location  = "northeurope"
  rg_prefix = "North-eu"
  master    = "monitor.f5demo.cloud"
  count = 0
}

module "load-west-eu" {
  source    = "./modules"
  location  = "westeurope"
  rg_prefix = "West-eu"
  master    = "monitor.f5demo.cloud"
  count = 0
}

module "load-asia" {
  source    = "./modules"
  location  = "eastasia"
  rg_prefix = "East-asia"
  master    = "monitor.f5demo.cloud"
  count = 0
}
