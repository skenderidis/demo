
locals{
  gslb_data = jsondecode(file("/tmp/gslb_info.json"))
  observ_data = jsondecode(file("/tmp/observability_info.json"))
}

resource "azurerm_dns_a_record" "observ_dns" {
  name                = var.observ_fqdn
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300
  records             = ["${local.observ_data.mgmt_ip}"]
}

resource "azurerm_dns_a_record" "gtm_dns" {
  name                = var.gtm_fqdn
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300
  records             = ["${local.gslb_data.mgmt_ip}"]
}

resource "azurerm_dns_a_record" "gslb_dns" {
  name                = var.gslb_fqdn
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 300
  records             = ["${local.gslb_data.dns_ip}"]
}

resource "azurerm_dns_ns_record" "delegation-www" {
  name                = "www"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-apps-eu" {
  name                = "apps-eu"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-apps-as" {
  name                = "apps-as"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-apps-us" {
  name                = "apps-us"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-bigip" {
  name                = "bigip"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-bigip-eu" {
  name                = "bigip-eu"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-bigip-as" {
  name                = "bigip-as"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}

resource "azurerm_dns_ns_record" "delegation-bigip-us" {
  name                = "bigip-us"
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 10

  records = ["${azurerm_dns_a_record.gslb_dns.name}.${var.zone_name}"]
}