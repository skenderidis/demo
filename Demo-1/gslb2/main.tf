

# Create a resource group for Demo
module "gslb" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix    = "Demo-GSLB"
  count = 1
}


