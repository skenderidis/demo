

# Create a resource group for Demo
module "gslb-us" {
  source    = "./modules"
  location  = "eastus"
  rg_prefix    = "GSLB-east"
  username	= var.username
  password	= var.password
}

resource "null_resource" "GSLB-info" {
  provisioner "local-exec" {
    command = "echo '{\"gslb-us-dns-ip\":\"${module.gslb-us.F5_Ext_Public_IP}\", \"gslb-us-mgmt-ip\":\"${module.gslb-us.F5_Mgmt_Public_IP}\", \"f5_user\":\"${module.gslb-us.f5_username}\", \"f5_pass\":\"${module.gslb-us.f5_password}\"}' > /tmp/gslb_info.json"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm /tmp/gslb_info.json"
    on_failure = continue
  }
}

