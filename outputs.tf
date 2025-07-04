
# Server outputs
output "server_private_ip" {
  value = module.windows_server.server_private_ip
}


# Workstation outputs
output "win_workstation_private_ip" {
  value = module.win_workstation.win_workstation_private_ip
}

# Jumpbox
output "win_jumpbox_private_ip" {
  value = module.jumpbox.win_jumpbox_private_ip
}

output "win_jumpbox_public_ip" {
  value = module.jumpbox.win_jumpbox_public_ip
}

output "vpn_server_public_ip" {
  value = module.vpn_server.public_ip
}

output "upload_url_base" {
  value = "https://${azurerm_storage_account.this.name}.blob.core.windows.net/${azurerm_storage_container.vpn.name}"
}
