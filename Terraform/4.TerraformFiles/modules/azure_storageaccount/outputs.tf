output "blobendpoint" {
  value = "${azurerm_storage_account.LearningDevOpsSA.primary_blob_endpoint}"
}
