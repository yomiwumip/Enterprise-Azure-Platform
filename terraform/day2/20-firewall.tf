resource "azurerm_public_ip" "firewall" {
  name                = "pip-azfw-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  tags = local.common_tags
}

resource "azurerm_public_ip" "firewall_management" {
  name                = "pip-azfw-mgmt-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  tags = local.common_tags
}

resource "azurerm_firewall_policy" "hub" {
  name                = "fwpol-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name

  sku = "Standard"

  threat_intelligence_mode = "Alert"

  tags = local.common_tags
}

resource "azurerm_firewall" "hub" {
  name                = "azfw-ukpd-hub-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  firewall_policy_id = azurerm_firewall_policy.hub.id

  ip_configuration {
    name                 = "ipconfig-primary"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  management_ip_configuration {
    name                 = "ipconfig-management"
    subnet_id            = azurerm_subnet.firewall_management.id
    public_ip_address_id = azurerm_public_ip.firewall_management.id
  }

  tags = local.common_tags
}

resource "azurerm_firewall_policy_rule_collection_group" "corp_egress" {
  name               = "DefaultNetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.hub.id
  priority           = 200

  network_rule_collection {
    name     = "rc-ukpd-corp-egress-prod-uks-001"
    priority = 500
    action   = "Allow"

    rule {
      name                  = "allow-ukpd-corp-web-egress"
      protocols             = ["TCP"]
      source_addresses      = ["10.10.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }
  }
}
