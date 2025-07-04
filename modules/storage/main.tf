

resource "azurerm_storage_account" "this" {
  name                          = "fozstore"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true

  tags = {
    environment = "cyberlab"
    purpose     = "vpn-config"
    owner       = "kayde"
  }
}

resource "azurerm_storage_container" "vpn" {
  name                  = "vpn-configs"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "time_static" "now" {}

data "azurerm_storage_account_sas" "vpn_sas" {
  connection_string = azurerm_storage_account.this.primary_connection_string

  https_only = true
  start      = time_static.now.rfc3339
  expiry     = timeadd(time_static.now.rfc3339, "72h")

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = true
    list    = true
    create  = true
    add     = false
    update  = false
    process = false
    delete  = false
    filter  = false
    tag     = false
  }
}
