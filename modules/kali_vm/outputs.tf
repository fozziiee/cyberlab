# modules/kali_vm/outputs.tf

output "kali_vm_private_ip" {
  value = azurerm_network_interface.this.ip_configuration[0].private_ip_address
}

