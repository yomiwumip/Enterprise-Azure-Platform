resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.hub.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_blob" {
  name                  = "vnetlink-ukpd-hub-prod-uks-001"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.hub.id

  registration_enabled = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "corp_blob" {
  name                  = "vnetlink-ukpd-corp-prod-uks-001"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.corp.id

  registration_enabled = false
}
