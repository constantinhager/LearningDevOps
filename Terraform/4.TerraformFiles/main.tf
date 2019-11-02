provider "azurerm" {
  version = "=1.36.1"
}

terraform {
  required_version = ">= 0.12"
  backend "azurerm" {}
}

module "AzureResourceGroup" {
  source = "./modules/azure_resourcegroup"

  location          = "${var.location}"
  resourcegroupName = "${var.resourcegroupName}"
  environment       = "${var.environment}"
}

module "AzureStorageAccount" {
  source = "./modules/azure_storageaccount"

  diagSaName        = "${var.diagSaName}"
  resourcegroupName = "${module.AzureResourceGroup.resourcegroupname}"
  location          = "${var.location}"
}

module "AzureVirtualMachine" {
  source = "./modules/azure_virtualmachine"

  vmNicName         = "${var.vmNicName}"
  vmName            = "${var.vmName}"
  vmSize            = "${var.vmSize}"
  resourcegroupName = "${module.AzureResourceGroup.resourcegroupname}"
  location          = "${var.location}"
  subnetid          = "${module.AzureVirtualNetwork.subnetid}"
  storageuri        = "${module.AzureStorageAccount.blobendpoint}"
}

module "AzureVirtualNetwork" {
  source = "./modules/azure_virtualnetwork"

  vnetName            = "${var.vnetName}"
  vnetaddressspace    = "${var.vnetaddressspace}"
  subnetname          = "${var.subnetname}"
  subnetaddressprefix = "${var.subnetaddressprefix}"
  resourcegroupName   = "${module.AzureResourceGroup.resourcegroupname}"
  location            = "${var.location}"
}
