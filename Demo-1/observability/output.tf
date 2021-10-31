
output "public_ip" {
  value = azurerm_public_ip.web-linux-vm-ip.ip_address
}

output "Vnet" {
  value = azurerm_resource_group.rg.name
}

output "private_ip" {
  value = azurerm_network_interface.web-vm-nic.private_ip_address
}

resource "null_resource" "observe-file" {
  provisioner "local-exec" {
    command = "echo '{\"mgmt_ip\":\"${azurerm_public_ip.web-linux-vm-ip.ip_address}\", \"admin_user\":\"admin\", \"admin_pass\":\"admin\"}' > /tmp/observability_info.json"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm /tmp/observability_info.json"
    on_failure = continue
  }
}