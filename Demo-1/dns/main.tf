
locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
  observ_data = jsondecode(file("/tmp/observability_info.json"))
}

resource "azurerm_dns_a_record" "f5_dns" {
  name                = "bigip"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300
  records             = ["${local.observ_data.observability_ip}"]
}

resource "azurerm_dns_a_record" "gslb_dns" {
  name                = var.gslb_fqdn
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300
  records             = ["${local.gslb_data.mgmt_ip}"]
}

resource "azurerm_dns_ns_record" "delegation-www" {
  name                = "www"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-eu" {
  name                = "eu"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-as" {
  name                = "as"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-us" {
  name                = "us"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

