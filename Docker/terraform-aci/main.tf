resource "azurerm_resource_group" "aciresourcegroup" {
  name = "ACI"
  location = "westeurope"
}

resource "azurerm_container_group" "aci-containergroup" {
  name = "aci-agent"
  location = "westeurope"
  resource_group_name = "${azurerm_resource_group.aciresourcegroup.name}"
  os_type = "linux"
  container {
      name = "myappdemo"
      image = "docker.io/chagernoe/${var.dockerhub-username}:${var.imageversion}"
      cpu = "0.5"
      memory = "1.5"
      ports {
          port = 80
          protocol = "TCP"
      }
  }
}
