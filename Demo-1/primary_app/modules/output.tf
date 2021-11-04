
output "App_Server_01" {
  value = azurerm_public_ip.web-linux-vm-ip.ip_address
}
output "App_Server_02" {
  value = azurerm_public_ip.web-linux-vm-ip-02.ip_address
}
output "Vnet" {
  value = azurerm_resource_group.rg.name
}

