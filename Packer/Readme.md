# Optimizing Infrastructure Deployment with Packer

- [Optimizing Infrastructure Deployment with Packer](#optimizing-infrastructure-deployment-with-packer)
  - [Overview of Packer](#overview-of-packer)
    - [Installing Packer](#installing-packer)
  - [Creating Packer templates for Azure VMs with scripts](#creating-packer-templates-for-azure-vms-with-scripts)
    - [The structure of the Packer template](#the-structure-of-the-packer-template)
      - [the builders section](#the-builders-section)
      - [The provisioners section](#the-provisioners-section)
      - [The variables section](#the-variables-section)
    - [Building an Azure image with the Packer template](#building-an-azure-image-with-the-packer-template)
  - [Using Ansible in a Packer template](#using-ansible-in-a-packer-template)
  - [Executing Packer](#executing-packer)
    - [Configuring Packer to authenticate to Azure](#configuring-packer-to-authenticate-to-azure)
    - [Checking the validity of the Packer template](#checking-the-validity-of-the-packer-template)
    - [Running Packer to generate our VM image](#running-packer-to-generate-our-vm-image)
  - [Using a Packer image with Terraform](#using-a-packer-image-with-terraform)

Packer is a simple tool that simplifies the creation of VMs in a DvOps process and integrates very well with Terraform.

We phase the following issues with virtual machine workloads:

- The configuration of a VM can be very time consuming.
- The different environment (DEV, QA, PROD) are not identical, because the deployment scripts are not identical.
- Configuration and security compliance is not often applied or updated.

A solution for this is a custom VM image. Every cloud provider supports that. These images contain the following:

- The latest security updates
- The latest configuration of that image
- and so on.

We get the following benefits out of that:

- The provisioning of a VM from an image is very fast.
- Each VM is uniform in configuration and, above all, is safety compliant.

The tool for that is Packer from HashiCorp. This tool allows us to create VM images from a file (template).

## Overview of Packer

Packer is part of the HashiCorp open Source tools. The official web page is [Packer](https://www.packer.io/).
It is an open source command line tool that creates VM images for any operating system from a JSON file. These images are
also called templates.

Packers image process is based on a OS provided by the different cloud providers. It then configures a temporary VM by executing
the script described in the JSON template. From this temporary VM Packer creates an image that can then be used to create a new
VM. Packer can also create Docker or Vagrant images.

### Installing Packer

Packer is a cross platform tool that is almost identical to the Terraform installation. It can be done in two ways:

- Manually: [Packer download](https://www.packer.io/downloads.html)

- Script install:
  - [Install Windows](1.InstallPacker/PackerInstallWindows.ps1)
  - [Install Linux](1.InstallPacker/PackerInstallLinux.sh)

## Creating Packer templates for Azure VMs with scripts

The packer configuration of a VM is based on a file (template) that is defined in JSON.

### The structure of the Packer template

The Packer JSON template consists of the following sections

- builders
- provisioners and
- variables

The structure is as follows:

```json
{
    "variables": {

    },
    "builders": [
        {

        }
    ],
    "provisioners": [
        {

        }
    ]
}
```

#### the builders section

the builders section is mandatory. It contains all of the properties that define the image and its location, such
as its name, the type of image, the cloud provider on which the image will be generated, connection information to the cloud,
the base image to use, an other properties that are specific to the image type.

A sample section:

```json
{
    "builders": [
        {
            "type": "azure-rm",
            "client_id: "xxxxx",
            "client_secret": "xxxx",
            "subscription_id": "xxxx",
            "tenant_id": "xxx",
            "os_type": "Linux",
            "image_publisher: "",
            "image_offer": "",
            "location": ""
        }
    ]
}
```

the full documentation can be found here: [builder section](https://www.packer.io/docs/templates/builders.html)

If you want to define multiple providers for the same image you can do this with the following code sample:

```json
{
    "builders": [
        {
            "type": "azure-rm",
            "location": "",
        },
        {
            "type: "docker",
            "image": "alpine:latest"
        }
    ]
}
```

#### The provisioners section

The provisioners section is optional. It contains a list of scripts that will be executed by Packer on a temporary
VM base image in order to build our custom VM image according to our needs.

If the provisioners section is not defined no configuration will be applied on the base image.

The provisioning section is available for Windows as well as Linux images. You can run the following types inside
the provisioning section:

- executing a local or remote script
- executing a command
- copying a file

the full documentation can be found here: [provisioner section](https://www.packer.io/docs/provisioners/index.html)

An example section for the provisioners section can be seen here:

```json
{
...

    "provisioners": [
        {
            "type": "shell",
            "script": "hardening-config.sh"
        },
        {
            "type": "file",
            "source": "script/installers",
            "destination": "/tmp/scripts"
        }
    ]
...
}
```

In this section, we list all of the configuration action for the image to be created.

When we create a VM image we need to generalize It. This means we need to delete all of the personal
user information that was used to create this image.

For example if we create an image of a Windows VM we have to execute Sysprep. So we define a provisioner step.

```json
{
...
    "provisioners": [
        {
            "type": "powershell",
            "inline": ["& C:\\windows\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /shutdown /quiet"]
        }
    ]
}
```

For generalizing a Linux image you can use the following provisioner code:

```json
{
...
    "provisioners": [
        {
            "type": "shell",
            "execute_command": "sudo sh -c '{{ .Vars }} {{ .Path }}'",
            "inline": [
                "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
            ]
        }
    ]
...
}
```

#### The variables section

This section is optional. We need this block if we want to define values that are not static.
This variables can be used in the builders or provisioners section.

Example of the variables section:

```json
{
    "variables": {
        "access_key": "{{env `ACCESS_KEY`}}",
        "image_folder": "/tmp/image",
        "vm_size": "Standard_A1"
    },
....
}
```

To use this variables we have to define the {{user 'variablename'}} notation. Example:

```json
{
    "builders": [
        {
            "type": "azure-arm",
            "access_key": "{{ user `access_key`}}",
            "vm_size": "{{ user `vm_size`}}"
            ...
        }
    ]
}
```

To use the variables in the provisioners section:

```json
{
    "provisioners": [
        {
            "type": "shell",
            "inline": [
                "mkdir {{user `image_folder`}}",
                "chmod 777 {{user `image_folder`}}",
                ...
            ],
            "execute_command": "sudo sh -c '{{ .Vars }} {{ .Path }}'
        },
    ...
    ]
}
```

### Building an Azure image with the Packer template

For creating a Azure VM image we first need to define an Azure Service Principal.

## Using Ansible in a Packer template

We can use Ansible as a provisioner of our Linux VM. The good news are, that we can reuse
our existing Ansible playbooks.

## Executing Packer

For creating a Packer image in Azure we need to perform the following steps:

- Configure Packer to authenticate to Azure
- Check our Packer template.
- Run Packer to generate our image.

### Configuring Packer to authenticate to Azure

We have to declare the following 4 environment variables:

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID

To create these environment variables you have to execute the following scripts:

- Windows:

```powershell
$env:ARM_CLIENT_ID = <client ID>
$env:ARM_CLIENT_SECRET = <client Secret>
$env:ARM_SUBSCRIPTION_ID = <subscription_id>
$env:ARM_TENANT_ID = <tenant ID>
```

- Linux:

```bash
export ARM_SUBSCRIPTION_ID=<subscription_id>
export ARM_CLIENT_ID=<client ID>
export ARM_SECRET_SECRET=<client Secret>
export ARM_TENANT_ID=<tenant ID>
```

### Checking the validity of the Packer template

You can validate a Packer template by executing the following command:

```cmd
packer validate <template file>
```

### Running Packer to generate our VM image

to create an image in Azure use the following command:

```cmd
packer build <template file>
```

Packer will create an extra resource group where the VM will be deployed to.
The resource group where the images are stored in has to exist.

We can override the variables that are defined in the variable template section
over the command line. An example:

```cmd
packer build -var '<variable name>' <template file>
```

## Using a Packer image with Terraform

Now that we have a Azure VM image we can deploy a VM from that. To provision a VM we use Terraform.

We need to add the following block in our Terraform configuration:

```terraform
data "azurerm_image" "customnginx" {
    name = "linuxWeb-0.0.1"
    resource_group_name = "rg_images"
}
```

In the azurerm_virtual_machine resource code the storage_image_reference part need to be modified
like this:

```terraform
resource "azurerm_virtual_machine" "vm" {
    ....

    storage_image_reference {
        id ="${data.azurerm_image.customnginx.id}"
    }
    ....
}
```
