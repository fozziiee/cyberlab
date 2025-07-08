locals {
  resource_group_name   = azurerm_resource_group.cyberlab-rg.name
  location              = azurerm_resource_group.cyberlab-rg.location
}

locals {
  lab_creds_blob_url = "https://${module.storage.storage_account_name}.blob.core.windows.net/${module.storage.lab_secrets_container_name}/lab-creds.json${module.storage.sas_token}"
}