
# Server outputs
output "server_private_ip" {
  value = module.windows_server.server_private_ip
}

output "server_public_ip" {
  value = module.windows_server.server_public_ip
}

# Workstation outputs
output "win_workstation_private_ip" {
  value = module.win_workstation.win_workstation_private_ip
}

output "win_workstation_public_ip" {
  value = module.win_workstation.win_workstation_public_ip
}

# Kali VM
output "kali_vm_private_ip" {
  value = module.kali_vm.kali_vm_private_ip
}

output "kali_vm_public_ip" {
  value = module.kali_vm.kali_vm_public_ip
}

# Jumpbox
output "win_jumpbox_private_ip" {
  value = module.jumpbox.win_jumpbox_private_ip
}

output "win_jumpbox_public_ip" {
  value = module.jumpbox.win_jumpbox_public_ip
}
