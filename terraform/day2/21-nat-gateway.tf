resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name

  allocation_method = "Static"
  sku               = "Standard"


  tags = local.common_tags
}

resource "azurerm_nat_gateway" "hub" {
  name                = "nat-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name

  sku_name = "StandardV2"


  tags = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "hub" {
  nat_gateway_id       = azurerm_nat_gateway.hub.id
  public_ip_address_id = azurerm_public_ip.nat.id
}
