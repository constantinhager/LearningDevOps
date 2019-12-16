az login
az account set --subscription "SubscriptionName"
az ad sp create-for-rbac --name="<ApplicationName>" --role="Contributor" --scopes="/subscriptions/<subscription-id>"