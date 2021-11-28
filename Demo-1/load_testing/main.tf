resource "random_string" "suffix" {
  length  = 2
  special = false
}


# Create a resource group
resource "azurerm_resource_group" "load_rg_master" {
  name     = "Load-master-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_container_group" "master" {
  name                = "worker"
  location            = azurerm_resource_group.load_rg_master.location
  resource_group_name = azurerm_resource_group.load_rg_master.name
  ip_address_type     = "public"
  dns_name_label      = "f5demo-${random_string.suffix.result}"
  os_type             = "Linux"

  container {
    name   = "locust-master"
    image  = "skenderidis/locust-hackazon"
    cpu    = "2"
    memory = "4"
    commands = [
        "locust",
        "--locustfile",
        "/mnt/locust/locustfile.py",
        "--master"
    ]
    ports {
      port     = 8089
      protocol = "TCP"
    }
    ports {
      port     = "5557"
      protocol = "TCP" 
    }
  }
}

/*
resource "azurerm_resource_group" "load_rg_east_us" {
  count     = var.count_eastus >= 1 ? 1 : 0
  name      = "Load-East-us"
  location  = "eastus"
}
resource "azurerm_resource_group" "load_rg_west_us" {
  count     = var.count_westus >= 1 ? 1 : 0
  name      = "Load-West-us"
  location  = "westus"
}
resource "azurerm_resource_group" "load_rg_uk_south" {
  count     = var.count_uksouth >= 1 ? 1 : 0
  name      = "Load-West-eu"
  location  = "uknorth"
}
resource "azurerm_resource_group" "load_rg_easteasia" {
  count     = var.count_eastasia >= 1 ? 1 : 0
  name      = "Load-east-asia"
  location  = "eastasia"
}
*/

resource "azurerm_resource_group" "load_worker" {
  name      = "Load-worker-${random_string.suffix.result}"
  location  = "eastus"
}

module "load-east-us" {
  source    = "./modules"
  location  = "eastus"
  rg_name   = azurerm_resource_group.load_worker.name
  master    = azurerm_container_group.master.fqdn
  count     = var.count_eastus
}
module "load-west-us" {
  source    = "./modules"
  location  = "westus"
  rg_name   = azurerm_resource_group.load_worker.name
  master    = azurerm_container_group.master.fqdn
  count     = var.count_westus
}

module "load-eu" {
  source    = "./modules"
  location  = "westeurope"
  rg_name   = azurerm_resource_group.load_worker.name
  master    = azurerm_container_group.master.fqdn
  count     = var.count_eu
}

module "load-uk" {
  source    = "./modules"
  location  = "uksouth"
  rg_name   = azurerm_resource_group.load_worker.name
  master    = azurerm_container_group.master.fqdn
  count     = var.count_uk
}

module "load-eastasia" {
  source    = "./modules"
  location  = "eastasia"
  rg_name   = azurerm_resource_group.load_worker.name
  master    = azurerm_container_group.master.fqdn
  count = var.count_asia
}

module "load-australia" {
  source    = "./modules"
  location  = "australiasoutheast"
  rg_name   = azurerm_resource_group.load_worker.name
  master    = azurerm_container_group.master.fqdn
  count = var.count_au
}
