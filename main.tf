provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = "b5d7ea6a-df7a-4f55-93b2-6245517cd5b3"

}

resource "azurerm_resource_group" "cyberlab-rg" {
  name     = "cyberlab-rg"
  location = "Australia East"

  tags = {
    environment = "cyberlab"
    owner       = "kayde"
    purpose     = "lab"
  }
}

module "network" {
  source              = "./modules/network"
  resource_group_name = local.resource_group_name
  location            = local.location
}


module "windows_server" {
  source              = "./modules/windows_server"
  resource_group_name = local.resource_group_name
  location            = local.location
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  lab_creds_upload_url = local.lab_creds_blob_url
}


module "win_workstation" {
  source              = "./modules/win_workstation"
  resource_group_name = local.resource_group_name
  location            = local.location
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  lab_creds_url = local.lab_creds_blob_url
  domain_name = "xyz.local"
}

module "jumpbox" {
  source              = "./modules/jumpbox"
  resource_group_name = local.resource_group_name
  location            = local.location
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}

module "vpn_server" {
  source              = "./modules/vpn_server"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = module.network.subnet_id
  ssh_public_key_path = "/home/kayde/id_rsa.pub"
  admin_username      = var.admin_username

  ovpn_upload_url = "${module.storage.upload_url_base}/kayde.ovpn${module.storage.sas_token}"
}

module "storage" {
  source              = "./modules/storage"
  location            = local.location
  resource_group_name = local.resource_group_name
}
