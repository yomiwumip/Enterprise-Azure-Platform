resource "azurerm_virtual_network_peering" "hub_to_corp" {
  name                      = "peer-ukpd-hub-to-corp-prod-uks-001"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.corp.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "corp_to_hub" {
  name                      = "peer-ukpd-corp-to-hub-prod-uks-001"
  resource_group_name       = azurerm_resource_group.corp.name
  virtual_network_name      = azurerm_virtual_network.corp.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
