output "public_ip" {
  value = azurerm_container_group.master.ip_address
}

output "fqdn" {
  value = azurerm_container_group.master.fqdn
}

