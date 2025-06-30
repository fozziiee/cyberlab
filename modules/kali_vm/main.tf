# modules/kali_vm/main.tf

# Create a public IP for the Kali VM (will comment out when not needed)
resource "azurerm_public_ip" "this" {
  name                = "Kali-PublicIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Create NIC for Kali
resource "azurerm_network_interface" "this" {
  name                = "Kali-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# Kali Linux VM
resource "azurerm_linux_virtual_machine" "this" {
  name                            = "Kali-VM"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.this.id]



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "KaliOSDisk"
  }

  source_image_reference {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = "kali-2024-4"
    version   = "latest"
  }

  plan {
    name      = "kali-2024-4"
    product   = "kali"
    publisher = "kali-linux"
  }



  tags = {
    environment = "cyberlab"
    owner       = "kayde"
    role        = "kali-vm"
  }
}