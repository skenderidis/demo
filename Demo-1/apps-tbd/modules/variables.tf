
#########   Common Variables   ##########

variable tag 					{default = "Kostas Automation Demo"}
variable location				{default = "eastus"}
variable zone_name				{default = "f5demo.cloud"}
variable rg_zone 				{default = "f5demo_dns"}
variable allowedIPs				{default = ["0.0.0.0/0"]}
variable password		  		{default = "Kostas580"}
variable username		  		{default = "azureuser"}

variable gtm_ip  			{default = ""}
variable pool  			  {default = ""}


###########   App  Variables   ############

variable rg_name  			{default = "test-rg"}
variable vnet_name  		{default = "apps_vnet"}
variable vnet_cidr  		{default = "10.10.30.0/24"}
variable subnet_name  		{default = "default"}
variable subnet_cidr  		{default = "10.10.30.0/24"}


variable ip_web01  			{default = "10.10.30.15"}
variable ip_web02  			{default = "10.10.30.16"}
variable prefix_web01		{default = "web01"}
variable prefix_web02		{default = "web02"}
variable vm-size			{default = "Standard_DS1_v2"}

variable "web-linux-license-type" {
  type        = string
  description = "Specifies the BYOL type for the virtual machine."
  default     = null
}

# Azure virtual machine storage settings #

variable "web-linux-delete-os-disk-on-termination" {
  type        = string
  description = "Should the OS Disk (either the Managed Disk / VHD Blob) be deleted when the Virtual Machine is destroyed?"
  default     = "true"  # Update for your environment
}

variable "web-linux-delete-data-disks-on-termination" {
  description = "Should the Data Disks (either the Managed Disks / VHD Blobs) be deleted when the Virtual Machine is destroyed?"
  type        = string
  default     = "true"
}

variable "web-linux-vm-image" {
  type        = map(string)
  description = "Virtual machine source image information"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "18.04.202004290"
  }
}
