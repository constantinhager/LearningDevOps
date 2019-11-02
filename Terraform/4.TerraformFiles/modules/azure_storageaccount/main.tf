resource "azurerm_storage_account" "LearningDevOpsSA" {
  name                     = "${var.diagSaName}"
  location                 = "${var.location}"
  resource_group_name      = "${var.resourcegroupName}"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}
