resource "azurerm_storage_account" "private_blob" {
  name                     = "stukpdprivproduks001"
  resource_group_name      = azurerm_resource_group.corp.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  shared_access_key_enabled = true

  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.common_tags
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-ukpd-blob-prod-uks-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.corp.name
  subnet_id           = azurerm_subnet.corp_private_endpoints.id

  private_service_connection {
    name                           = "psc-ukpd-blob-prod-uks-001"
    private_connection_resource_id = azurerm_storage_account.private_blob.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = local.common_tags
}


resource "azurerm_private_dns_a_record" "blob" {
  name                = "stukpdprivproduks001"
  zone_name           = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.hub.name
  ttl                 = 300

  records = [
    azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address
  ]
}
