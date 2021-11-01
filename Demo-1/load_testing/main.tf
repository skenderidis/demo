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
resource "azurerm_resource_group" "load_rg_north_eu" {
  count     = var.count_northeu >= 1 ? 1 : 0
  name      = "Load-North-eu"
  location  = "northeurope"
}
resource "azurerm_resource_group" "load_rg_west_eu" {
  count     = var.count_westeu >= 1 ? 1 : 0
  name      = "Load-West-eu"
  location  = "westeurope"
}
resource "azurerm_resource_group" "load_rg_easteasia" {
  count     = var.count_eastasia >= 1 ? 1 : 0
  name      = "Load-east-asia"
  location  = "eastasia"
}


module "load-east-us" {
  source    = "./modules"
  location  = azurerm_resource_group.load_rg_east_us[0].location
  rg_name   = azurerm_resource_group.load_rg_east_us[0].name
  master    = azurerm_container_group.master.fqdn
  count     = var.count_eastus
}
module "load-west-us" {
  source    = "./modules"
  location  = azurerm_resource_group.load_rg_west_us[0].location
  rg_name   = azurerm_resource_group.load_rg_west_us[0].name
  master    = azurerm_container_group.master.fqdn
  count     = var.count_westus
}

module "load-north-eu" {
  source    = "./modules"
  location  = azurerm_resource_group.load_rg_north_eu[0].location
  rg_name   = azurerm_resource_group.load_rg_north_eu[0].name
  master    = azurerm_container_group.master.fqdn
  count = var.count_northeu
}

module "load-west-eu" {
  source    = "./modules"
  location  = azurerm_resource_group.load_rg_west_eu[0].location
  rg_name   = azurerm_resource_group.load_rg_west_eu[0].name
  master    = azurerm_container_group.master.fqdn
  count = var.count_westeu
}

module "load-asia" {
  source    = "./modules"
  location  = azurerm_resource_group.load_rg_easteasia[0].location
  rg_name   = azurerm_resource_group.load_rg_easteasia[0].name
  master    = azurerm_container_group.master.fqdn
  count = var.count_eastasia
}
