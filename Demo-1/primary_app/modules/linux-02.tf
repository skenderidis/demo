#####################################
## Linux VM with Web Server - Main ##
#####################################


# Generate randon name for virtual machine
resource "random_string" "linux-02" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  number  = true
}


# Get a Static Public IP
resource "azurerm_public_ip" "web-linux-vm-ip-02" {

  name                = "vm-pip-${random_string.linux-02.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  
  tags = {
    owner = var.tag
  }
}

# Create Network Card for web VM
resource "azurerm_network_interface" "web-vm-nic-02" {
  depends_on=[azurerm_public_ip.web-linux-vm-ip-02]

  name                = "vm-nic-${random_string.linux-02.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "internal-${random_string.linux-02.result}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web-linux-vm-ip-02.id
  }
  tags = {
    owner = var.tag
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_vnic-02" {

  network_interface_id      = azurerm_network_interface.web-vm-nic-02.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
}

# Create Linux VM with web server
resource "azurerm_linux_virtual_machine" "web-linux-vm-02" {
  depends_on=[azurerm_network_interface.web-vm-nic-02]

  name                  = "linux-vm-${random_string.linux-02.result}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.web-vm-nic-02.id]
  size                  = var.vm-size

  source_image_reference {
    offer     = lookup(var.web-linux-vm-image, "offer", null)
    publisher = lookup(var.web-linux-vm-image, "publisher", null)
    sku       = lookup(var.web-linux-vm-image, "sku", null)
    version   = lookup(var.web-linux-vm-image, "version", null)
  }

  os_disk {
    name                 = "vm-os-disk-${random_string.linux-02.result}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "vm-${random_string.linux-02.result}"
  admin_username = var.username
  admin_password = var.password 
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  disable_password_authentication = false

  admin_ssh_key {
	username       = var.username
 	public_key     = file("./modules/id_rsa.pub")
  }
  
  tags = {
    owner = var.tag
  }
}

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init-02" {
  template = file("./modules/docker-init.sh")
}



resource "null_resource" "add-server-02" {
  triggers = {
    vm_name   = azurerm_linux_virtual_machine.web-linux-vm-02.name
    vm_ip     = azurerm_public_ip.web-linux-vm-ip-02.ip_address
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

resource "null_resource" "add-pool-member-02" {
  triggers = {
    vm_name   = azurerm_linux_virtual_machine.web-linux-vm-02.name
    vm_ip     = azurerm_public_ip.web-linux-vm-ip-02.ip_address
    username  = var.username
    password  = var.password
    gtm_ip    = var.gtm_ip
    pool      = var.pool
  } 


  provisioner "local-exec" {
      command = <<EOT
        curl --location -k --request POST 'https://${var.gtm_ip}/mgmt/tm/gtm/pool/a/~Common~${self.triggers.pool}/members' \
        --header 'Content-Type: application/json' \
        --user ${self.triggers.username}:${self.triggers.password} \
        --data-raw '{"name": "${self.triggers.vm_name}:${self.triggers.vm_ip}"}'
      EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
        curl --location -k --request DELETE 'https://${self.triggers.gtm_ip}/mgmt/tm/gtm/pool/a/~Common~${self.triggers.pool}/members/${self.triggers.vm_name}:${self.triggers.vm_ip}' \
        --header 'Content-Type: application/json' \
        --user ${self.triggers.username}:${self.triggers.password}
      EOT
    on_failure = continue
}  
}