##############################################
######## Create worker Resource Group VNETs ########
##############################################

resource "random_string" "suffix" {
  length  = 3
  special = false
}


resource "azurerm_container_group" "worker" {
  name                = "locust-worker-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.rg_name
  ip_address_type     = "public"
  os_type             = "Linux"

  container {
    name   = "locust-worker"
    image  = "skenderidis/locust-hackazon"
    cpu    = "2"
    memory = "4"
    commands = [
        "locust",
        "--locustfile",
        "/mnt/locust/locustfile.py",
        "--worker",
        "--master-host",
        var.master
    ]
    ports {
      port     = 8089
      protocol = "TCP"
    }
  }
}