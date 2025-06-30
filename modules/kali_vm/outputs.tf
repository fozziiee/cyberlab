# modules/kali_vm/outputs.tf

output "kali_vm_private_ip" {
  value = azurerm_network_interface.this.ip_configuration[0].private_ip_address
}

output "kali_vm_public_ip" {
  value = azurerm_public_ip.this.ip_address
}

