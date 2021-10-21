##############################################
######## Create Resoruce Group VNETs ########
##############################################

resource "random_string" "suffix" {
  length  = 3
  special = false
}



# Create a resource group
resource "azurerm_resource_group" "f5_rg" {
  name     = "${var.rg_prefix}-${var.f5_rg_name}-${random_string.suffix.result}"
  location = var.location
  tags = {
    owner = var.tag
  }
}



##############################################
  ######## Create VNETs ########
##############################################

# Create the Secure VNET 
resource "azurerm_virtual_network" "f5_vnet" {
  name                = var.f5_vnet_name
  address_space       = [var.f5_vnet_cidr]
  resource_group_name = azurerm_resource_group.f5_rg.name
  location            = var.location
  tags = {
    owner = var.tag
  }
}


##############################################
		######## Create subnets ########
##############################################

resource "azurerm_subnet" "mgmt_subnet" {
  name                 = var.mgmt_subnet_name
  address_prefixes       = [var.mgmt_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "ext_subnet" {
  name                 = var.ext_subnet_name
  address_prefixes       = [var.ext_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "int_subnet" {
  name                 = var.int_subnet_name
  address_prefixes       = [var.int_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}



##############################################
		######## Create NSG ########
##############################################


# Create Network Security Group to access F5 mgmt
resource "azurerm_network_security_group" "f5_nsg_mgmt" {

  name                = "${var.f5_vnet_name}-f5_mgmt-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-ssh"
    description                = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }
  tags = {
    owner = var.tag
  }
}

# Create Network Security Group to access F5 ext
resource "azurerm_network_security_group" "f5_nsg_ext" {

  name                = "${var.f5_vnet_name}-f5_ext-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "allow-https"
    priority                   = 122
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }
  
  tags = {
    owner = var.tag
  }
}


##############################################
		######## Create F5  ########
##############################################


resource "azurerm_public_ip" "pip_app1" {
  name                = "PublicIPForApp1"
  location            = var.location
  sku				          = "Standard"
  availability_zone   = "No-Zone"
  resource_group_name = azurerm_resource_group.f5_rg.name 
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pip_app2" {
  name                = "PublicIPForApp2"
  location            = var.location
  sku				          = "Standard"
  availability_zone   = "No-Zone"
  resource_group_name = azurerm_resource_group.f5_rg.name 
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "pip_app3" {
  name                = "PublicIPForApp3"
  location            = var.location
  availability_zone   = "No-Zone"
  sku				          = "Standard"
  resource_group_name = azurerm_resource_group.f5_rg.name 
  allocation_method   = "Static"
}


module "azure_f5" {
  source            = "./modules/f5 bigip"
  azure_region      = var.location
  azure_rg_name     = azurerm_resource_group.f5_rg.name
  prefix            = var.prefix_bigip
  tag 		          = var.tag
  mgmt_subnet_id 	  = azurerm_subnet.mgmt_subnet.id
  mgmt_nsg_id	  	  = azurerm_network_security_group.f5_nsg_mgmt.id
  ext_subnet_id 	  = azurerm_subnet.ext_subnet.id
  ext_nsg_id		    = azurerm_network_security_group.f5_nsg_ext.id
  int_subnet_id 	  = azurerm_subnet.int_subnet.id
  self_ip_mgmt 		  = var.self_ip_mgmt_01
  self_ip_ext 		  = var.self_ip_ext_01
  add_ip_ext_1 		  = var.add_ip_ext_01_1
  add_ip_ext_2		  = var.add_ip_ext_01_2
  add_ip_ext_3		  = var.add_ip_ext_01_3
  pip_ext_1_id		  = azurerm_public_ip.pip_app1.id
  pip_ext_2_id		  = azurerm_public_ip.pip_app2.id
  pip_ext_3_id		  = azurerm_public_ip.pip_app3.id
  self_ip_int 		  = var.self_ip_int_01
  f5_instance_type  = var.f5_instance_type
  f5_version        = var.f5_version
  f5_image_name     = var.f5_image_name
  f5_product_name   = var.f5_product_name
  INIT_URL          = var.init_url
  DO_URL            = var.do_url
  AS3_URL           = var.as3_url
  TS_URL            = var.ts_url
  CFE_URL			      = var.cfe_url
  FAST_URL			    = var.fast_url
  f5_password       = var.password
  f5_username       = var.username  
}




resource "null_resource" "add-server" {
  triggers = {
    vm_name   = azurerm_linux_virtual_machine.web-linux-vm.name
    vm_ip     = azurerm_public_ip.pip_app1.ip_address
    username  = var.username
    password  = var.password
    gtm_ip    = var.gtm_ip
  }  
  provisioner "local-exec" {
      command = <<EOT
        curl --location -k --request POST 'https://${var.gtm_ip}/mgmt/tm/gtm/server/' \
        --header 'Content-Type: application/json' \
        --user ${var.username}:${var.password} \
        --data-raw '{"name": "${self.triggers.vm_name}","datacenter": "/Common/azure","monitor": "/Common/tcp","product": "generic-host","virtualServerDiscovery": "disabled","addresses": [{"name": "${self.triggers.vm_ip}","deviceName": "${self.triggers.vm_ip}","translation": "none"}],"virtualServers": [{"name": "${self.triggers.vm_ip}","destination": "${self.triggers.vm_ip}:80","enabled": true}]}'
      EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
        curl --location -k --request DELETE 'https://${self.triggers.gtm_ip}/mgmt/tm/gtm/server/${self.triggers.vm_name}' \
        --header 'Content-Type: application/json' \
        --user ${self.triggers.username}:${self.triggers.password}
      EOT
    on_failure = continue
}

}

resource "null_resource" "add-pool-member-01" {
  triggers = {
    vm_name   = azurerm_linux_virtual_machine.web-linux-vm.name
    vm_ip     = azurerm_public_ip.pip_app1.ip_address
    username  = var.username
    password  = var.password
    gtm_ip    = var.gtm_ip
    pool      = var.pool
  } 


  provisioner "local-exec" {
      command = <<EOT
        curl --location -k --request POST 'https://${var.gtm_ip}/mgmt/tm/gtm/pool/a/~Common~${self.triggers.pool}/' \
        --header 'Content-Type: application/json' \
        --user ${self.triggers.username}:${self.triggers.password} \
        --data-raw '{"name": "${self.triggers.vm_name}:${self.triggers.vm_ip}"}'
      EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
        curl --location -k --request DELETE 'https://${self.triggers.gtm_ip}/mgmt/tm/gtm/pool/a/~Common~${self.triggers.pool}/${self.triggers.vm_name}:${self.triggers.vm_ip}' \
        --header 'Content-Type: application/json' \
        --user ${self.triggers.username}:${self.triggers.password}
      EOT
    on_failure = continue
}  
}