resource "azurerm_private_dns_resolver" "hub" {
  name                = "dnspr-ukpd-hub-prod-uks-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  virtual_network_id  = azurerm_virtual_network.hub.id

  tags = local.common_tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "hub" {
  name                    = "dnsin-ukpd-hub-prod-uks-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub.id
  location                = var.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_inbound.id
  }

  tags = local.common_tags
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "hub" {
  name                    = "dnsout-ukpd-hub-prod-uks-001"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub.id
  location                = var.location
  subnet_id               = azurerm_subnet.dns_outbound.id

  tags = local.common_tags
}
