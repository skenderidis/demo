# Create a Public IP for bigip1
resource "azurerm_public_ip" "public_ip_mgmt" {
  name                      = "${var.prefix}-public-ip-mgmt"
  location                  = var.azure_region
  availability_zone         = "No-Zone"
  sku						            = "Standard"
  resource_group_name       = var.azure_rg_name
  allocation_method         = "Static"

  tags = {
    owner = var.tag
  }
}

resource "azurerm_public_ip" "public_ip_ext" {
  name                      = "${var.prefix}-public-ip-ext"
  location                  = var.azure_region
  availability_zone         = "No-Zone"
  sku						            = "Standard"
  resource_group_name       = var.azure_rg_name
  allocation_method         = "Static"

  tags = {
    owner = var.tag
  }
}



# Create the mgmt interface for BIG-IP 01
resource "azurerm_network_interface" "mgmt_nic" {
  name                      = "${var.prefix}-mgmt"
  location                  = var.azure_region
  resource_group_name       = var.azure_rg_name

  ip_configuration {
    name                          = "selfIP"
    subnet_id                     = var.mgmt_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.self_ip_mgmt
    public_ip_address_id          = azurerm_public_ip.public_ip_mgmt.id
  }

  tags = {
    owner = var.tag
  }
}

resource "azurerm_network_interface_security_group_association" "nsg1" {
  network_interface_id      = azurerm_network_interface.mgmt_nic.id
  network_security_group_id = var.mgmt_nsg_id
}


# Create the ext interface for BIG-IP 01
resource "azurerm_network_interface" "ext_nic" {
  name                      = "${var.prefix}-ext"
  location                  = var.azure_region
  resource_group_name       = var.azure_rg_name
  enable_ip_forwarding		= true

  ip_configuration {
    name                          = "selfIP"
    subnet_id                     = var.ext_subnet_id
	primary						              = true
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.self_ip_ext
    public_ip_address_id          = azurerm_public_ip.public_ip_ext.id
  }
  ip_configuration {
    name                          = "Add01"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.add_ip_ext_1
    public_ip_address_id          = var.pip_ext_1_id
 }
  ip_configuration {
    name                          = "Add02"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.add_ip_ext_2
    public_ip_address_id          = var.pip_ext_2_id
  }  
  ip_configuration {
    name                          = "Add03"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.add_ip_ext_3
    public_ip_address_id          = var.pip_ext_3_id
  }  
  tags = {
    owner = var.tag
  }
}
resource "azurerm_network_interface_security_group_association" "nsg2" {
  network_interface_id      = azurerm_network_interface.ext_nic.id
  network_security_group_id = var.ext_nsg_id
}


# Create the ext interface for BIG-IP 01
resource "azurerm_network_interface" "int_nic" {
  name                      = "${var.prefix}-int"
  location                  = var.azure_region
  resource_group_name       = var.azure_rg_name

  ip_configuration {
    name                          = "selfIP"
    subnet_id                     = var.int_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.self_ip_int
	}
  tags = {
    owner = var.tag
  }
}

data "template_file" "f5_bigip_onboard" {
 // count    = var.az_key_vault_authentication ? 0 : 1
  template = file("${path.module}/templates/f5_onboard.tmpl")
  vars = {
    INIT_URL                    = var.INIT_URL
    DO_URL                      = var.DO_URL
    AS3_URL                     = var.AS3_URL
    TS_URL                      = var.TS_URL
    CFE_URL                     = var.CFE_URL
    FAST_URL                    = var.FAST_URL,
    DO_VER                      = split("/", var.DO_URL)[7]
    AS3_VER                     = split("/", var.AS3_URL)[7]
    TS_VER                      = split("/", var.TS_URL)[7]
    CFE_VER                     = split("/", var.CFE_URL)[7]
    FAST_VER                    = split("/", var.FAST_URL)[7]
    bigip_username              = var.f5_username
    bigip_password              = var.f5_password
    vip_address                 = var.add_ip_ext_1
    service_discovery_fqdn      = var.sd_fqdn
    hostname                    = "${var.prefix}-vm-${var.suffix}"
    self-ip-ext                 = var.self_ip_ext
    gateway                     = cidrhost(format("%s/24", var.self_ip_ext), 1)
    self-ip-int                 = var.self_ip_int


  }
}

# Create F5 BIGIP1
resource "azurerm_virtual_machine" "f5-bigip1" {
  name                         = "${var.prefix}-vm-${var.suffix}"
  location                     = var.azure_region
  resource_group_name          = var.azure_rg_name
  primary_network_interface_id = azurerm_network_interface.mgmt_nic.id
  network_interface_ids        = [azurerm_network_interface.mgmt_nic.id, azurerm_network_interface.ext_nic.id, azurerm_network_interface.int_nic.id]
  vm_size                      = var.f5_instance_type
  
  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "f5-networks"
    offer     = var.f5_product_name
    sku       = var.f5_image_name
    version   = var.f5_version
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-os"
    admin_username = var.f5_username
    admin_password = var.f5_password
    custom_data    = data.template_file.f5_bigip_onboard.rendered

  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  plan {
    name          = var.f5_image_name
    publisher     = "f5-networks"
    product       = var.f5_product_name
  }

  tags = {
    owner = var.tag
  }
}



# Run Startup Script
resource "azurerm_virtual_machine_extension" "startup-script" {
  name                 = "${var.prefix}-run-startup-cmd"
  depends_on           = [azurerm_virtual_machine.f5-bigip1]
  virtual_machine_id   = azurerm_virtual_machine.f5-bigip1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  provisioner "local-exec" {
    command = "sleep 220"
  }
  protected_settings = <<PROT
  {
    "script": "${base64encode(data.template_file.f5_bigip_onboard.rendered)}"
  }
  PROT

  tags = {
    owner = var.tag
  }
}

