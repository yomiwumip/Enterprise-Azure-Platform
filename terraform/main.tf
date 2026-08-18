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
