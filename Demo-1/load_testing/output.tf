output "public_ip" {
  value = azurerm_container_group.master.ip_address
}

output "fqdn" {
  value = azurerm_container_group.master.fqdn
}

output "eastus" {
  value = var.count_eastus
}
output "westus" {
  value = var.count_westus
}
output "uk" {
  value = var.count_uk
}
output "eu" {
  value = var.count_eu
}
output "asia" {
  value = var.count_asia
}
output "australia" {
  value = var.count_au
}