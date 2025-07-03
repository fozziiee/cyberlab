# modules/win_workstation/outputs.tf

output "win_workstation_private_ip" {
  value = azurerm_network_interface.this.ip_configuration[0].private_ip_address
}


