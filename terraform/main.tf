resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_management_lock" "platform_resource_group" {
  name       = "platform-resource-group-cannot-delete"
  scope      = azurerm_resource_group.platform.id
  lock_level = "CanNotDelete"
  notes      = "Protects the platform Resource Group from accidental deletion."
}

resource "azurerm_storage_account" "platform" {
  name                     = "stcontosogovtf001"
  resource_group_name      = azurerm_resource_group.platform.name
  location                 = azurerm_resource_group.platform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled = true

  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  min_tls_version = "TLS1_2"

  public_network_access_enabled = true

  access_tier = "Hot"

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