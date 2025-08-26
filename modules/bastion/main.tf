data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  
}

# Create Bastion subnet
resource "azurerm_subnet" "bastion" {
  name = var.subnet_name
  resource_group_name = var.vnet_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes = var.subnet_address_prefixes
}

resource "azurerm_public_ip" "pip" {
  name = var.public_ip_name
  location = var.location
  resource_group_name = var.resource_group_name

    allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "this" {
  name = var.bastion_name
  location = var.location
  resource_group_name = var.resource_group_name

  sku = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.pip.id
    }

  }