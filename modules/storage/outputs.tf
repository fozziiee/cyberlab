

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "sas_token" {
  value     = "?${data.azurerm_storage_account_sas.vpn_sas.sas}"
  sensitive = true
}

output "container_name" {
  value     = azurerm_storage_container.vpn.name
  sensitive = true
}

output "upload_url_base" {
  value     = "https://${azurerm_storage_account.this.name}.blob.core.windows.net/${azurerm_storage_container.vpn.name}"
  sensitive = true
}

