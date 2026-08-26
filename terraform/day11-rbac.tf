resource "azurerm_role_assignment" "day11_rbac_reader" {
  scope                = azurerm_resource_group.day11_governance.id
  role_definition_name = "Reader"
  principal_id         = "e120dea3-1ca7-4b2c-b984-62ecb326182d"
}
