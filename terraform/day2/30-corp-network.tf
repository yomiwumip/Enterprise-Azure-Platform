resource "azurerm_resource_group" "corp" {
  name     = "rg-ukpd-corp-network-prod-uks"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "corp" {
  name                = "vnet-ukpd-corp-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name
  address_space       = var.corp_address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "corp_app" {
  name                 = "snet-app-prod-uks-001"
  resource_group_name  = azurerm_resource_group.corp.name
  virtual_network_name = azurerm_virtual_network.corp.name
  address_prefixes     = ["10.10.0.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "corp_data" {
  name                 = "snet-data-prod-uks-001"
  resource_group_name  = azurerm_resource_group.corp.name
  virtual_network_name = azurerm_virtual_network.corp.name
  address_prefixes     = ["10.10.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "corp_integration" {
  name                 = "snet-integration-prod-uks-001"
  resource_group_name  = azurerm_resource_group.corp.name
  virtual_network_name = azurerm_virtual_network.corp.name
  address_prefixes     = ["10.10.2.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "corp_appgw" {
  name                 = "snet-appgw-prod-uks-001"
  resource_group_name  = azurerm_resource_group.corp.name
  virtual_network_name = azurerm_virtual_network.corp.name
  address_prefixes     = ["10.10.3.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "corp_private_endpoints" {
  name                 = "snet-private-endpoints-prod-uks-001"
  resource_group_name  = azurerm_resource_group.corp.name
  virtual_network_name = azurerm_virtual_network.corp.name
  address_prefixes     = ["10.10.10.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "corp_management" {
  name                 = "snet-management-prod-uks-001"
  resource_group_name  = azurerm_resource_group.corp.name
  virtual_network_name = azurerm_virtual_network.corp.name
  address_prefixes     = ["10.10.20.0/24"]

  private_endpoint_network_policies = "Disabled"
}
