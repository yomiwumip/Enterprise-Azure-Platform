resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-ukpd-corp-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  allocation_method = "Static"
  sku               = "Standard"

  zones = ["1", "2", "3"]

  tags = local.common_tags
}

resource "azurerm_web_application_firewall_policy" "corp" {
  name                = "wafpol-ukpd-corp-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = local.common_tags
}

resource "azurerm_application_gateway" "corp" {
  name                = "agw-ukpd-corp-prod-uks-001"
  resource_group_name = azurerm_resource_group.corp.name
  location            = var.location

  http2_enabled = false

  zones = ["1", "2", "3"]

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.corp_appgw.id
  }

  frontend_port {
    name = "frontend-port-http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name = "pool-ukpd-corp-web-prod-uks-001"
  }

  backend_http_settings {
    name                  = "bes-ukpd-corp-web-prod-uks-001"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "listener-ukpd-corp-http-prod-uks-001"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "frontend-port-http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-ukpd-corp-web-prod-uks-001"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "listener-ukpd-corp-http-prod-uks-001"
    backend_address_pool_name  = "pool-ukpd-corp-web-prod-uks-001"
    backend_http_settings_name = "bes-ukpd-corp-web-prod-uks-001"
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.corp.id

  tags = local.common_tags
}
