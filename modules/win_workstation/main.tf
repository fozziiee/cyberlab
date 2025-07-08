# WINDOWS WORKSTATION


# NIC for WinWS
resource "azurerm_network_interface" "this" {
  name                = "WinWS-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "Internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                = "WinWorkstation"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    name                 = "WinWSOSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "win10-21h2-pro"
    version   = "latest"
  }

  tags = {
    environment = "cyberlab"
    owner       = "kayde"
    role        = "windows-workstation"
  }
}

data "template_file" "workstation_bootstrap" {
  template = file("${path.root}/bootstrap_workstation.ps1")

  vars = {
    creds_url = var.lab_creds_url
    domain = var.domain_name
  }
} 