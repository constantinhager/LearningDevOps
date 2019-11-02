output "publicip" {
  value = "${azurerm_public_ip.LearningDevOpsPIP.ip_address}"
}