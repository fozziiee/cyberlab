variable "resource_group_name" {
  description = "RG where Bastion and the public IP will live"
  type        = string
}

variable "location" {
  description = "Azure region (must match the VNet's region)"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing VNet where Bastion will attach"
  type        = string
}

variable "vnet_resource_group_name" {
  description = "RG of the existing VNet (can be same as resource_group_name)"
  type        = string
}

variable "bastion_name" {
  description = "Bastion resource name"
  type        = string
  default     = "cyberlab-bastion"
}

variable "subnet_name" {
  description = "Must be exactly AzureBastionSubnet (Azure requirement)"
  type        = string
  default     = "AzureBastionSubnet"
}

variable "subnet_address_prefixes" {
  description = "CIDR(s) for AzureBastionSubnet (must be /27 or larger)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_ip_name" {
  description = "Name for the Bastion public IP"
  type        = string
  default     = "cyberlab-bastion-pip"
}

variable "tier" {
  description = "Bastion tier: Basic or Standard"
  type        = string
  default     = "Basic"
}

variable "scale_units" {
  description = "Bastion scale units (Standard tier only). Ignored for Basic."
  type        = number
  default     = 2
}

variable "vnet_id" {
  description = "ID of the existing VNet"
  type        = string
}