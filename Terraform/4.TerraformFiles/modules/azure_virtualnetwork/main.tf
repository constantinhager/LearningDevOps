resource "azurerm_virtual_network" "LearningDevOpsVNet" {
  name                = var.vnetName
  location            = var.location
  address_space       = var.vnetaddressspace
  resource_group_name = var.resourcegroupName
}

resource "azurerm_subnet" "LearningDevOpsSubnet" {
  name                 = var.subnetname
  virtual_network_name = azurerm_virtual_network.LearningDevOpsVNet.name
  resource_group_name  = var.resourcegroupName
  address_prefix       = var.subnetaddressprefix
}

