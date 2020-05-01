variable "vnetName" {
  description = "the name of the VNet we want to create"
}

variable "vnetaddressspace" {
  description = "the addressspace for the vnet. e.g. 10.1.0.0/16"
  type        = list(string)
}

variable "subnetname" {
  description = "the name of the subnet"
}

variable "subnetaddressprefix" {
  description = "the prefix of the subnet. e.g. 10.1.0.0/24"
}

variable "resourcegroupName" {
  description = "the name of the resourcegroup"
}

variable "location" {
  description = "The azure region"
}
