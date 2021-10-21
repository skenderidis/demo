

# Create a resource group for Demo
module "bigip-east-us" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix    = "Demo-eastus"
  count = 0
}


module "bigip-west-us" {
  source    = "./modules"
  location  = "westus"
  rg_prefix    = "Demo-eastus"
  count = 0
}


module "bigip-north-eu" {
  source    = "./modules"
  location  = "northeurope"
  rg_prefix    = "Demo-north-eu"
  count = 0
}

module "bigip-west-eu" {
  source    = "./modules"
  location  = "westeurope"
  rg_prefix    = "Demo-west-eu"
  count = 0
}

module "bigip-asia" {
  source    = "./modules"
  location  = "eastasia"
  rg_prefix    = "Demo-asia"
  count = 0
}