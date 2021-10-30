#####################################
## Linux VM with Web Server - Main ##
#####################################


# Generate randon name for virtual machine
resource "random_string" "linux" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  number  = true
}


# Get a Static Public IP
resource "azurerm_public_ip" "web-linux-vm-ip" {

  name                = "vm-pip-${random_string.linux.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  
  tags = {
    owner = var.tag
  }
}

# Create Network Card for web VM
resource "azurerm_network_interface" "web-vm-nic" {
  depends_on=[azurerm_public_ip.web-linux-vm-ip]

  name                = "${var.location}-${var.rg_prefix}-vm-nic-${random_string.linux.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "internal-${random_string.linux.result}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web-linux-vm-ip.id
  }
  tags = {
    owner = var.tag
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_vnic" {

  network_interface_id      = azurerm_network_interface.web-vm-nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
}

# Create Linux VM with web server
resource "azurerm_linux_virtual_machine" "web-linux-vm" {
  depends_on=[azurerm_network_interface.web-vm-nic]

  name                  = "linux-vm-${random_string.linux.result}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.web-vm-nic.id]
  size                  = var.vm-size

  source_image_reference {
    offer     = lookup(var.web-linux-vm-image, "offer", null)
    publisher = lookup(var.web-linux-vm-image, "publisher", null)
    sku       = lookup(var.web-linux-vm-image, "sku", null)
    version   = lookup(var.web-linux-vm-image, "version", null)
  }

  os_disk {
    name                 = "vm-os-disk-${random_string.linux.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "vm-${random_string.linux.result}"
  admin_username = var.username
  admin_password = var.password 
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  disable_password_authentication = false

  admin_ssh_key {
	username       = var.username
 	public_key     = file("./id_rsa.pub")
  }
  
  tags = {
    owner = var.tag
  }
}

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("./docker-init.sh")
}

