# modules/windows_server/main.tf


# Create a network interface
resource "azurerm_network_interface" "this" {
  name                = "CyberlabServer-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.100"
  }
}

# Windows Server VM
resource "azurerm_windows_virtual_machine" "this" {
  name                = "Server-VM"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = "cyberlabServer"
    owner       = "kayde"
    role        = "windows-server"
  }
}

##### EXTENSIONS ######

# WinRM Extension
# resource "azurerm_virtual_machine_extension" "enable_winrm" {
#   name                 = "EnableWinRM"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"

#   settings = jsonencode({
#     fileUris         = ["https://raw.githubusercontent.com/fozziiee/cyberlab/refs/heads/master/enable-winrm.ps1"]
#     commandToExecute = "powershell -ExecutionPolicy Unrestricted -File enable-winrm.ps1"
#   })

#   protected_settings = jsonencode({
#     script = base64encode(file("${path.root}/enable-winrm.ps1"))
#   })
# }

resource "azurerm_virtual_machine_extension" "ad_domain_setup" {
  name                 = "ADDomainSetup"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris         = ["https://raw.githubusercontent.com/fozziiee/cyberlab/master/bootstrap-server.ps1"]
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File C:\\bootstrap-server.ps1"
  })

}

