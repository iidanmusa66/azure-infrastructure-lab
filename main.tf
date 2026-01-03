terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_rg" {
  name     = "rg-security-lab-01"
  location = "West Europe"
}

resource "azurerm_virtual_network" "my_vnet" {
  name                = "vnet-secure-01"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "snet-internal"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "my_nsg" {
  name                = "nsg-secure-01"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.my_subnet.id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}