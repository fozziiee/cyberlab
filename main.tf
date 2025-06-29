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

