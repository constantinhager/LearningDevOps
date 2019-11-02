$env:ARM_SUBSCRIPTION_ID = ""
$env:ARM_CLIENT_ID = ""
$env:ARM_CLIENT_SECRET = ""
$env:ARM_TENANT_ID = ""
$env:ARM_ACCESS_KEY = ""

terraform init -backend-config="backend.tfvars"

terraform fmt

terraform validate

terraform plan

terraform apply
