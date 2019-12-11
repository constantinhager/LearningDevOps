# Terraform Doc

- [Terraform Doc](#terraform-doc)
  - [Install Terraform](#install-terraform)
    - [Install Terraform on Linux](#install-terraform-on-linux)
    - [Install Terraform on Windows](#install-terraform-on-windows)
    - [Terraform and Azure Cloud Shell](#terraform-and-azure-cloud-shell)
  - [Configuring Terraform for Azure](#configuring-terraform-for-azure)
    - [Configure the terraform provider](#configure-the-terraform-provider)
    - [Deploying the infrastructure with Terraform](#deploying-the-infrastructure-with-terraform)
  - [Terraform useful commands](#terraform-useful-commands)
  - [Terraform in CI / CD Pipelines](#terraform-in-ci--cd-pipelines)
  - [The tfstate File](#the-tfstate-file)
    - [Provision Azure Storage Account](#provision-azure-storage-account)
    - [Configure Terraform to use the remote backend](#configure-terraform-to-use-the-remote-backend)

## Install Terraform

To install terraform manually goto [Terraform Download](https://www.terraform.io/downloads.html)

----------

### Install Terraform on Linux

[Terraform on Linux](1.InstallTerraform/TerraformInstallLinux.sh)

----------

### Install Terraform on Windows

The installation process is a chocolatey package. If you ran that
on an Azure Pipelines Hosted agent chocolatey is already pre installed.
[What hosted agents are available / Installed Software](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops)

If you do not run it on a hosted agent you have to install chocolatey first
by using this lines of code:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

----------

After that you can install terraform with this script:
[Terraform on Windows](1.InstallTerraform/TerraformInstallWindows.ps1)

### Terraform and Azure Cloud Shell

It is already preinstalled and configured. You need to upload the terraform scripts to the storage account of the Azure Cloud Shell and run It from there.

----------

## Configuring Terraform for Azure

To work with Terraform on Azure we first need a Azure Service Principal.

There are Two ways of deploying an Azure Service Principal.

Az CLI:

Note: If you do not have Az Cli you can use this script to download an install It (Windows Install):

```powershell
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

After you installed Az CLI run the following script to create an Azure Service Principal:

[Create Azure Service Principal Az CLI](2.CreateAzureServicePrincipal/TerraformCreateASP_AzCli.ps1)

Azure PowerShell:

[Create Azure Service Principal Azure PowerShell](2.CreateAzureServicePrincipal/TerraformCreateASP_PowerShell.ps1)

The PowerShell script returns the parameters needed for the Terraform configuration part.

If you used the Az CLI part you can read the values out of the return value from the command.

Mapping

- appId = Client ID
- password = Client Secret
- tenant = Tenant ID

### Configure the terraform provider

We will assign the appropriate information at runtime through Terraform environment variables

These are:

- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID

### Deploying the infrastructure with Terraform

run

```powershell
terraform init
```

in the folder where the Terraform files are stored.

run

```powershell
terraform plan
```

to see the changes.

If the changes are correct you run the

```powershell
terraform apply
```

command to initiate the deployment. Type in yes.

## Terraform useful commands

to remove the previous provisioned Terraform environment run

```powershell
terraform destroy
```

format Terraform code

```powershell
terraform fmt
```

validate all Terraform files

```powershell
terraform validate
```

## Terraform in CI / CD Pipelines

The workflow in a CI / CD Pipeline would be

- Getting the IaC from a source controlled repository
- formatting the code with `terraform fmt`
- Initialize the terraform environment with `terraform init`
- Validate the Terraform files with `terraform validate`
- Display the preview of the infrastructure and store it into a file `terraform plan -out=out.tfplan`
- Make the changes to the environment `terraform apply --auto-approve out.tfplan`

## The tfstate File

This file preserves the whole state of the environment by the time it got rolled out.
It will be created locally when `terraform apply` is executed.
If a `terraform plan` is executed Terraform compares the Terraform template with the tfstate file and outputs the actions that need to be made (e.g. apply, remove).

Disadvantages of a tfstate file in an enterprise environment:

- Knowing that this file contains the status of the infrastructure, it should not-be deleted. If deleted, Terraform may not behave as expected when it is-executed.
- It must be accessible at the same time by all members of the team handling-resources on the same infrastructure.
- This file can contain sensitive data, so it must be secure.
- When provisioning multiple environments, it is necessary to be able to use-multiple tfstate files.

Therefor Terraform invented the remote backend to store the tfstate file. We will be using the azurerm remote backend. But there are more
read here: [Terraform remote backend](https://www.terraform.io/docs/backends/types/remote.html).

We need to perform the following steps:

- Provision an Azure Storage Account
- Configure Terraform to use the remote backend
- Execute Terraform with the remote backend

### Provision Azure Storage Account

[Provision Azure Storage Account](3.RemoteBackend/AzStorageAccount.ps1)

### Configure Terraform to use the remote backend

We need to define another environment variable (ARM_ACCESS_KEY).
This is where the storage account key is going.

In my backend.tfvars file is the following content:

storage_account_name = Name of the storage account that you just created
container_name       = The container inside of the storage account the you just created
key                  = the filename of the tfstate file (example: myapp.tfstate)

To init Terraform with the Azure remote backend execute the following command:

```powershell
terraform init -backend-config="backend.tfvars"
```
