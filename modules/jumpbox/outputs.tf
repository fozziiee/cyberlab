output "win_jumpbox_private_ip" {
  value = azurerm_network_interface.this.ip_configuration[0].private_ip_address
}

output "win_jumpbox_public_ip" {
  value = azurerm_public_ip.this.ip_address
}

