resource "azurerm_resource_group" "LearningDevOpsrg" {
  name     = "${var.resourcegroupName}"
  location = "${var.location}"
  tags = {
    environment = "${var.environment}"
  }
}
