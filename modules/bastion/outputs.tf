output "bastion_id" {
  description = "Resource ID of the Bastion host"
  value       = azurerm_bastion_host.this.id
}

output "bastion_pip" {
  description = "Public IP address of Bastion"
  value       = azurerm_public_ip.pip.ip_address
}

output "bastion_subnet_id" {
  description = "Subnet ID of AzureBastionSubnet"
  value       = azurerm_subnet.bastion.id
}
