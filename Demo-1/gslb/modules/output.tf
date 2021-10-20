output "F5_Mgmt_Public_IP" {
  value = module.azure_f5.mgmt_public_ip
}

output "F5_Ext_Public_IP" {
  value = module.azure_f5.ext_public_ip
}

output "F5_Ext_Private_IP" {
  value = var.self_ip_ext_01
}

output "f5_username" {
  value = var.username
}

output "f5_password" {
  value = var.password
}

