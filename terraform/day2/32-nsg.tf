resource "azurerm_network_security_group" "corp_app" {
  name                = "nsg-ukpd-corp-app-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  tags = local.common_tags
}

resource "azurerm_network_security_group" "corp_data" {
  name                = "nsg-ukpd-corp-data-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  tags = local.common_tags
}

resource "azurerm_network_security_group" "corp_integration" {
  name                = "nsg-ukpd-corp-integration-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  tags = local.common_tags
}

resource "azurerm_network_security_group" "corp_private_endpoints" {
  name                = "nsg-ukpd-corp-private-endpoints-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  tags = local.common_tags
}

resource "azurerm_network_security_group" "corp_management" {
  name                = "nsg-ukpd-corp-management-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "corp_app" {
  subnet_id                 = azurerm_subnet.corp_app.id
  network_security_group_id = azurerm_network_security_group.corp_app.id
}

resource "azurerm_subnet_network_security_group_association" "corp_data" {
  subnet_id                 = azurerm_subnet.corp_data.id
  network_security_group_id = azurerm_network_security_group.corp_data.id
}

resource "azurerm_subnet_network_security_group_association" "corp_integration" {
  subnet_id                 = azurerm_subnet.corp_integration.id
  network_security_group_id = azurerm_network_security_group.corp_integration.id
}

resource "azurerm_subnet_network_security_group_association" "corp_private_endpoints" {
  subnet_id                 = azurerm_subnet.corp_private_endpoints.id
  network_security_group_id = azurerm_network_security_group.corp_private_endpoints.id
}

resource "azurerm_subnet_network_security_group_association" "corp_management" {
  subnet_id                 = azurerm_subnet.corp_management.id
  network_security_group_id = azurerm_network_security_group.corp_management.id
}
