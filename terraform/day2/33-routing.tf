resource "azurerm_route_table" "corp_egress" {
  name                = "rt-ukpd-corp-egress-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  bgp_route_propagation_enabled = false

  tags = local.common_tags
}

resource "azurerm_route" "corp_default_to_firewall" {
  name                   = "route-default-to-azure-firewall"
  resource_group_name    = azurerm_resource_group.corp.name
  route_table_name       = azurerm_route_table.corp_egress.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "corp_app" {
  subnet_id      = azurerm_subnet.corp_app.id
  route_table_id = azurerm_route_table.corp_egress.id
}

resource "azurerm_subnet_route_table_association" "corp_data" {
  subnet_id      = azurerm_subnet.corp_data.id
  route_table_id = azurerm_route_table.corp_egress.id
}

resource "azurerm_subnet_route_table_association" "corp_integration" {
  subnet_id      = azurerm_subnet.corp_integration.id
  route_table_id = azurerm_route_table.corp_egress.id
}

resource "azurerm_subnet_route_table_association" "corp_management" {
  subnet_id      = azurerm_subnet.corp_management.id
  route_table_id = azurerm_route_table.corp_egress.id
}
