variable "location" {
  default     = "West Europe"
  description = "The azure region"
}

variable "resourcegroupName" {
  description = "the name of the resourcegroup"
  default     = "LearningDevOps"
}

variable "vnetName" {
  description = "the name of the VNet we want to create"
  default     = "LearningDevOpsVNet"
}

variable "vnetaddressspace" {
  description = "the addressspace for the vnet. e.g. 10.1.0.0/16"
  type        = "list"
  default     = ["10.1.0.0/16"]
}

variable "subnetname" {
  description = "the name of the subnet"
  default     = "LearningDevOpsSubnet"
}

variable "subnetaddressprefix" {
  description = "the prefix of the subnet. e.g. 10.1.0.0/24"
  default     = "10.1.0.0/24"
}

variable "vmNicName" {
  description = "the NIC name of the VM. e.g. LearningDevOpsNIC"
  default     = "LearningDevOpsNIC"
}

variable "vmName" {
  description = "the name of the vm that we want to deploy."
  default     = "LearningDevOpsVM"
}

variable "vmSize" {
  description = "the azure vm Size."
  default     = "Standard_DS1_v2"
}

variable "environment" {
  description = "the stage of the environment"
  default     = "LearnDevOps"
}

variable "diagSaName" {
  description = "the name of the storage account for boot diagnostics."
  default     = "learningdevppssaboot"
}
