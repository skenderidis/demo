output "F5_Mgmt_Public_IP" {
  value = module.azure_f5.mgmt_public_ip
}

output "App1_Public_IP" {
  value = azurerm_public_ip.pip_app1.ip_address
}
output "App2_Public_IP" {
  value = azurerm_public_ip.pip_app2.ip_address
}
output "App3_Public_IP" {
  value = azurerm_public_ip.pip_app3.ip_address
}
