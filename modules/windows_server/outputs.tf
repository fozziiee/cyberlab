

output "server_private_ip" {
  value = azurerm_network_interface.this.ip_configuration[0].private_ip_address
}

