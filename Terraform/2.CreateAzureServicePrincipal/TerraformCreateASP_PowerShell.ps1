Login-AzAccount

# Optional
Set-AzContext -SubscriptionId "SubscriptionID" # Replace with empty string

# Get the tennant ID
$tennantID = (Get-AzContext).Tenant.Id

# Get the subscription ID
$SubscriptionID = (Get-azcontext).Subscription.Id

# Create a new Service Principal
$sp = New-AzADServicePrincipal -DisplayName "ServicePrincipal" # Replace with dummy value

# Export the secret
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
$UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Output "Sleeping for 20 Seconds till the the role can be assigned"
Start-Sleep -Seconds 20

# Assigning the Azure Service Principal Contributor Rights to the subscription
New-AzRoleAssignment -ApplicationId $sp.ApplicationId -RoleDefinitionName "Contributor"

# Print the Secret that we have created earlier. We will need that for the Terraform configuration
Write-Output ("Client Secret: {0}" -f $UnsecureSecret)
Write-Output ("Client ID: {0}" -f $sp.ApplicationId)
Write-Output ("Tenant ID: {0}" -f $tennantID)
Write-Output ("Subscription ID: {0}" -f $SubscriptionID)


