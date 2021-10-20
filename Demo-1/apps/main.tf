/*

# Create a resource group for Demo
module "apps" {
  source    = "./modules"
  count = 0
}


output "App_web01_Public_IP" {
  value = module.apps[*]
}



*/



#resource "null_resource" "dns_add" {
#  provisioner "local-exec" {
#    command = "echo '[{\"name\":\"${azurerm_dns_a_record.app_dns1.name}\",\"ip\":\"${module.web01.public_ip}\",\"link\":\"https://${azurerm_dns_a_record.app_dns1.name}.${var.zone_name}\"}, {\"name\":\"${azurerm_dns_a_record.app_dns2.name}\",\"ip\":\"${module.web02.public_ip}\",\"link\":\"https://${azurerm_dns_a_record.app_dns2.name}.${var.zone_name}\"}]' > dns.json"
#}
#}
#resource "null_resource" "dns_delete" {
#  provisioner "local-exec" {
#    when    = destroy
#    command = "rm dns.json"
#  }
#}




locals{
gslb_data = jsondecode(file("../gslb_info.json"))
}

output name123 { 
  value = local.json_data.gslb-us-dns-ip

}