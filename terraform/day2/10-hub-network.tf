resource "azurerm_resource_group" "hub" {
  name     = "rg-ukpd-connectivity-hub-prod-uks"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.64/26"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.128/26"]
}

resource "azurerm_subnet" "dns_inbound" {
  name                 = "snet-dns-inbound"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.192/28"]

  delegation {
    name = "dns-resolver-inbound"

    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "dns_outbound" {
  name                 = "snet-dns-outbound"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.208/28"]

  delegation {
    name = "dns-resolver-outbound"

    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_subnet" "firewall_management" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}
