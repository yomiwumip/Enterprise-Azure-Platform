resource "azurerm_role_assignment" "day15_finance_group_reader" {
  scope                = "/subscriptions/eb1f07b2-12b1-417e-80d0-fe08c2376f5a/resourceGroups/rg-contoso-finops-lab-uks-001"
  role_definition_name = "Reader"
  principal_id         = azuread_group.day15_finance.object_id

  description = "Provides read-only access to the FinOps lab resource group for the Finance IAM business-role group."
}
