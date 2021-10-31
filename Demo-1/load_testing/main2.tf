

resource "azurerm_container_group" "example" {
  name                = "master"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_address_type     = "public"
  os_type             = "Linux"

  container {
    name   = "locust"
    image  = "skenderidis/test3"
    cpu    = "2"
    memory = "4"
    commands = ["--master"]

    ports {
      port     = 8089
      protocol = "TCP"
    }
  }

}