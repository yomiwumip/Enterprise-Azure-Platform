resource "azurerm_role_assignment" "day15_iam_group_reader" {
  scope                = "/subscriptions/eb1f07b2-12b1-417e-80d0-fe08c2376f5a/resourceGroups/rg-contoso-finops-lab-uks-001"
  role_definition_name = "Reader"
  principal_id         = azuread_group.day15_iam_dev_test.object_id
  description          = "Provides read-only access to the Contoso FinOps lab resource group for the Day 15 IAM development test group. Used to demonstrate group-based least-privilege Azure RBAC."
}
