provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = "b5d7ea6a-df7a-4f55-93b2-6245517cd5b3"
  
}

resource "azurerm_resource_group" "cyberlab-rg" {
  name = "cyberlab-rg"
  location = "Australia East"

  tags = {
    environment = "cyberlab"
    owner       = "kayde"
    purpose     = "lab"
  }
}

resource "azurerm_virtual_network" "cyberlab-vnet" {
  name = "cyberlab-vnet"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name

  tags = {
    environment = "cyberlab"
    owner       = "kayde"
    purpose     = "lab"
  }
}

resource "azurerm_subnet" "cyberlab_subnet" {
  name = "ServerSubnet"
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  virtual_network_name = azurerm_virtual_network.cyberlab-vnet.name
  address_prefixes = ["10.0.1.0/24"]

  
}

# Create Network Security Group (NSG) 
resource "azurerm_network_security_group" "cyberlab_nsg" {
  name = "Cyberlab-NSG"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name

  security_rule {
    name                        = "Allow-RDP"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3389"
    source_address_prefix       = "Internet"
    destination_address_prefix  = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "Allow-WinRM-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "cyberlab"
    owner       = "kayde"
    purpose     = "lab"
  }
}

# Associate NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "cyberlab_assoc" {
  subnet_id                     = azurerm_subnet.cyberlab_subnet.id
  network_security_group_id     = azurerm_network_security_group.cyberlab_nsg.id
}

# Create a public IP address
resource "azurerm_public_ip" "cyberlabserver_pip" {
  name = "CyberlabServer-PublicIP"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  allocation_method = "Static"
  sku = "Basic"
}

# Create a network interface
resource "azurerm_network_interface" "cyberlab-nic" {
  name = "CyberlabServer-NIC"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.cyberlab_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.100"
    public_ip_address_id = azurerm_public_ip.cyberlabserver_pip.id
  }
}

# Deploy the Windows Server VM
resource "azurerm_windows_virtual_machine" "cyberlab_server_vm" {
  name = "Server-VM"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  size = "Standard_B1ms"
  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.cyberlab-nic.id
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }

  tags = {
    environment = "cyberlabServer"
    owner       = "kayde"
    role        = "windows-server"
  }
}

##### EXTENSIONS ######

# WinRM Extension
resource "azurerm_virtual_machine_extension" "enable_winrm" {
  name = "EnableWinRM"
  virtual_machine_id = azurerm_windows_virtual_machine.cyberlab_server_vm.id
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File enable-winrm.ps1"
  })

  protected_settings = jsonencode({
    script = base64encode(file("enable-winrm.ps1"))
  })
}

# Create a public IP for the Kali VM
resource "azurerm_public_ip" "kali_pip" {
  name = "Kali-PublicIP"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

# Create NIC for Kali
resource "azurerm_network_interface" "kali-nic" {
  name = "Kali-NIC"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.cyberlab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.kali_pip.id
  }
}

# Kali Linux VM
resource "azurerm_linux_virtual_machine" "kali_vm" {
  name = "Kali-VM"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  size = "Standard_B1s"
  admin_username = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.kali-nic.id]



  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "KaliOSDisk"
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


# WINDOWS WORKSTATION

# Public IP for workstation
resource "azurerm_public_ip" "winws_pip" {
  name = "WinWS-PublicIP"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

# NIC for WinWS
resource "azurerm_network_interface" "winws_nic" {
  name = "WinWS-NIC"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name

  ip_configuration {
    name = "Internal"
    subnet_id = azurerm_subnet.cyberlab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.winws_pip.id
  }
}

resource "azurerm_windows_virtual_machine" "winws_vm" {
  name                = "WinWorkstation"
  location            = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  
  network_interface_ids = [azurerm_network_interface.winws_nic.id]

  os_disk {
    name                 = "WinWSOSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer = "windows-11"
    sku = "win11-24h2-pro"
    version = "latest"
  }

  tags = { 
    environment = "cyberlab"
    owner = "kayde"
    role = "windows-workstation"
   }
} 