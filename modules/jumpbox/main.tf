
# Create public IP address
resource "azurerm_public_ip" "this" {
  name                = "Jumpbox-PublicIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Basic"
}

#Create a NIC
resource "azurerm_network_interface" "this" {
  name                = "Jumpbox-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# Create machine - Jumpbox

resource "azurerm_windows_virtual_machine" "this" {
  name                = "Jumpbox"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    name                 = "JumpboxDisk"
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
    environment = "cyberalab"
    owner       = "kayde"
    role        = "windows-jumpbox"
  }
}

resource "azurerm_virtual_machine_extension" "enable-ssh" {
  name                 = "EnableSSH"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris         = ["https://raw.githubusercontent.com/fozziiee/cyberlab/main/enable-ssh.ps1"]
    commandToExecute = "powershell -ExecutionPolicy Bypass -File enable-ssh.ps1"
  })

  protected_settings = jsonencode({
    script = base64encode(file("${path.root}/enable-ssh.ps1"))
  })
}
