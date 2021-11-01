
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
  name     = "${var.rg_prefix}-${var.rg_name}-${random_string.random-rg-name.result}"
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
    name                       = "allow-ssh"
    description                = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "allow-kibana"
    description                = "allow-kibana"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5601"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  } 
  security_rule {
    name                       = "allow-grafana"
    description                = "allow-grafana"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  } 
    security_rule {
    name                       = "allow-locust"
    description                = "allow-locust"
    priority                   = 112
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8090"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  } 
    security_rule {
    name                       = "allow-locust-5557"
    description                = "allow-locust-5557"
    priority                   = 118
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5557"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  } 
    security_rule {
    name                       = "allow-prometheus"
    description                = "allow-prometheus"
    priority                   = 113
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  } 
     security_rule {
    name                       = "allow-elastic"
    description                = "allow-elastic"
    priority                   = 114
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9200"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  }  
  tags = {
    owner = var.tag
  }
}



