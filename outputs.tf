output "vnet_name" {
  description = "The name of the virtual network"
  value = azurerm_virtual_network.cyberlab-vnet.name
}

output "nsg_name" {
  value = azurerm_network_security_group.cyberlab_nsg.name
}

output "subnet_nsg_assoc_id" {
  value = azurerm_subnet_network_security_group_association.cyberlab_assoc.id
}