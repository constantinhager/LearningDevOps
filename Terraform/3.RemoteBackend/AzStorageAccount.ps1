# Create the resource Group for the Remote Backend
$BackendResourcegroup = New-AzResourceGroup -Name "LearningDevOpsTFBackend" -Location "West Europe"

# Create the storage account in that resource group
$BackendStorageAccount = New-AzStorageAccount -Name "learningdevopstfsa" -Location "West Europe" -SkuName Standard_LRS -ResourceGroupName $BackendResourcegroup.ResourceGroupName

# Create a Storage blob container in that storage account
New-AzStorageContainer -Name "tfbackends" -Context $BackendStorageAccount.Context