
##############################################
######## Create Resource Group  ########
##############################################
resource "random_string" "random-rg-name" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  number  = true
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}-${random_string.random-rg-name.result}"
  location = var.location
  tags = {
    owner = var.tag
  }
}


##############################################
  ######## Create VNETs ########
##############################################

# Create App VNET
resource "azurerm_virtual_network" "vnet" {
  name                  = var.vnet_name
  address_space         = [var.vnet_cidr]
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  tags = {
    owner = var.tag
  }
}


##############################################
		######## Create subnets ########
##############################################

resource "azurerm_subnet" "subnet" {
  name                    = var.subnet_name
  address_prefixes        = [var.subnet_cidr]
  virtual_network_name    = azurerm_virtual_network.vnet.name
  resource_group_name     = azurerm_resource_group.rg.name 
}


##############################################
		######## Create NSG ########
##############################################


# Create Network Security Group to access web
resource "azurerm_network_security_group" "nsg" {

  name                = "apps-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name 

  security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  }
  tags = {
    owner = var.tag
  }
}



resource "null_resource" "add-member" {
  provisioner "local-exec" {
      command = <<EOT
curl --location -k --request POST 'https://13.90.59.154/mgmt/tm/gtm/server/' \
--header 'Content-Type: application/json' \
--user azureuser:Kostas123 \
--data-raw '{"name": "test2","datacenter": "/Common/AWS","monitor": "/Common/tcp","product": "generic-host","virtualServerDiscovery": "disabled","addresses": [{"name": "5.5.5.7","deviceName": "test2","translation": "none"}],"virtualServers": [{"name": "website2","destination": "5.5.5.9:80","enabled": true}]}'
EOT
  }

}