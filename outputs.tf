output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.cyberlab-vnet.name
}

output "nsg_name" {
  value = azurerm_network_security_group.cyberlab_nsg.name
}

output "subnet_nsg_assoc_id" {
  value = azurerm_subnet_network_security_group_association.cyberlab_assoc.id
}

output "windows_server_ip" {
  value       = azurerm_public_ip.cyberlabserver_pip.ip_address
  description = "Public IP of the Windows VM"
}

output "kali_vm_ip" {
  value       = azurerm_public_ip.kali_pip.ip_address
  description = "Public IP of the Kali Linux VM"
}

output "win_ws_ip" {
  value       = azurerm_public_ip.winws_pip.ip_address
  description = "Public IP of the Windows Workstation"
}

