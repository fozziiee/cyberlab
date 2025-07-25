

resource "azurerm_public_ip" "this" {
  name                = "vpn-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "this" {
  name                = "vpn-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.101"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}


resource "azurerm_linux_virtual_machine" "this" {
  name                  = "vpn-server"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = "Standard_B1ms"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.root}/openvpn-install.tpl", {
    ovpn_upload_url = var.ovpn_upload_url,
    admin_user      = var.admin_username
  }))

  tags = {
    environment = "cyberlab"
    role        = "vpn-server"
  }
}
