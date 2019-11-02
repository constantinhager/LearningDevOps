resource "azurerm_network_interface" "LearningDevOpsNIC" {
  name                = "${var.vmNicName}"
  location            = "${var.location}"
  resource_group_name = "${var.resourcegroupName}"

  ip_configuration {
    name                          = "LearningDevOpsIP"
    subnet_id                     = "${var.subnetid}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.LearningDevOpsPIP.id}"
  }
}

resource "azurerm_public_ip" "LearningDevOpsPIP" {
  name                = "LearningDevOpsPIP"
  location            = "${var.location}"
  resource_group_name = "${var.resourcegroupName}"
  allocation_method   = "Dynamic"
  domain_name_label   = "learningdevopspiplabel"
}

resource "azurerm_virtual_machine" "LearningDevOpsVM" {
  name                  = "${var.vmName}"
  location              = "${var.location}"
  resource_group_name   = "${var.resourcegroupName}"
  vm_size               = "${var.vmSize}"
  network_interface_ids = ["${azurerm_network_interface.LearningDevOpsNIC.id}"]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "LearningDevOpsVM-OSDisc"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "UbuntuVM"
    admin_username = "azureuser"
    admin_password = "Passw0rd!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${var.storageuri}"
  }
}
