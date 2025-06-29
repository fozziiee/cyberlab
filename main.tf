provider "azurerm" {
  features {}

  subscription_id = "b5d7ea6a-df7a-4f55-93b2-6245517cd5b3"
  
}

resource "azurerm_resource_group" "cyberlab-rg" {
  name = "cyberlab-rg"
  location = "Australia East"
}

resource "azurerm_virtual_network" "cyberlab-vnet" {
  name = "cyberlab-vnet"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
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
}

# Associate NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "cyberlab_assoc" {
  subnet_id                     = azurerm_subnet.cyberlab_subnet.id
  network_security_group_id     = azurerm_network_security_group.cyberlab_nsg.id
}

# Create a public IP address
resource "azurerm_public_ip" "cyberlab_pip" {
  name = "Cyberlab-PublicIP"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name
  allocation_method = "Dynamic"
}

# Create a network interface
resource "azurerm_network_interface" "cyberlab-nic" {
  name = "Cyberlab-NIC"
  location = azurerm_resource_group.cyberlab-rg.location
  resource_group_name = azurerm_resource_group.cyberlab-rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.cyberlab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.cyberlab_pip.id
  }
}

# Deploy the Windows Server VM
resource "azurerm_windows_virtual_machine" "cyberlab_vm" {
  name = "Cyberlab-VM"
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
}

