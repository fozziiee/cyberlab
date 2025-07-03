

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
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_network_security_group" "vpn_nsg" {
  name                = "vpn-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-OpenVPN"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.vpn_nsg.id
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

  custom_data = filebase64("${path.root}/openvpn-install.txt")

  tags = {
    environment = "cyberlab"
    role        = "vpn-server"
  }
}
