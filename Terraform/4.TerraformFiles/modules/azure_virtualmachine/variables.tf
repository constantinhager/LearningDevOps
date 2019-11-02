variable "vmNicName" {
  description = "the NIC name of the VM. e.g. LearningDevOpsNIC"
}

variable "vmName" {
  description = "the name of the vm that we want to deploy."
}

variable "vmSize" {
  description = "the azure vm Size."
}

variable "resourcegroupName" {
  description = "the name of the resourcegroup"
}

variable "location" {
  description = "The azure region"
}

variable "subnetid" {
  description = "The azure id of the subnet"
}

variable "storageuri" {
  description = "the primary blobendpoint for storing diagnosticsdata."
}
