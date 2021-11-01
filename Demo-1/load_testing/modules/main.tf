resource "azurerm_resource_group" "example" {
  name     = "example-resources2"
  location = "West Europe"
}

resource "azurerm_container_group" "master" {
  name                = "worker"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
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
        "monitor.f5demo.cloud"
    ]

    ports {
      port     = 8089
      protocol = "TCP"
    }
  }

}