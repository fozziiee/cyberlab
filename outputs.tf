
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
  value = module.storage.upload_url_base
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "sas_token" {
  value = module.storage.sas_token
}

output "container_name" {
  value = module.storage.sas_token
}
