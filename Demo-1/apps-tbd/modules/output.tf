
output "App-Server-01" {
  value = azurerm_public_ip.web-linux-vm-ip.ip_address
}
output "App-Server-02" {
  value = azurerm_public_ip.web-linux-vm-ip-02.ip_address
}
output "Vnet" {
  value = azurerm_resource_group.rg.name
}

