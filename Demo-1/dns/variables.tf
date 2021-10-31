################################
## Azure Provider _ Variables ##
################################

######### Azure authentication variables #########

variable subscription_id  		{}
variable client_id				{}
variable client_secret  		{}
variable tenant_id				{}


#########   Common Variables   ##########

variable tag 		        { default = "Kostas Automation Demo" }
variable location 			{ default = "eastus" }
variable zone_name 			{ default = "f5demo.cloud" }
variable rg_zone         	{ default = "f5demo_dns" }
variable observ_fqdn        { default = "monitor" }
variable gtm_fqdn           { default = "gtm" }
variable gslb_fqdn          { default = "gslb" }
variable app_fqdn 			{ default = "www" }
variable pool_europe 		{ default = "eu" }
variable pool_asia 			{ default = "as" }
variable pool_america		{ default = "us" }

