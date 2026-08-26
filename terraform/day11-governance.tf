resource "azurerm_resource_group" "day11_governance" {
  name     = "rg-contoso-governance-day11-uks-001"
  location = "uksouth"

  tags = {
    Owner        = "Cloud Platform Engineering"
    CostCentre   = "IT001"
    Application  = "Platform Governance"
    Environment  = "governance-lab"
    Project      = "contoso"
    BusinessUnit = "Technology"
    ManagedBy    = "Terraform"
  }
}

resource "azurerm_policy_definition" "day11_allowed_locations" {
  name         = "contoso-governance-day11-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Contoso Day 11 - Allowed Locations"
  description  = "Restricts indexed Azure resources to approved UK South location."

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = "[parameters('listOfAllowedLocations')]"
        },
        {
          field     = "location"
          notEquals = "global"
        },
        {
          field     = "type"
          notEquals = "Microsoft.AzureActiveDirectory/b2cDirectories"
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })

  parameters = jsonencode({
    listOfAllowedLocations = {
      type = "Array"

      metadata = {
        displayName = "Allowed locations"
        description = "The Azure regions allowed for resources."
      }
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "day11_allowed_locations" {
  name                 = "contoso-governance-day11-allowed-location-tf"
  resource_group_id    = azurerm_resource_group.day11_governance.id
  policy_definition_id = azurerm_policy_definition.day11_allowed_locations.id

  display_name = "Contoso Day 11 - Allowed Locations - Terraform"

  description = "Terraform-managed Day 11 governance assignment restricting resources to approved UK South location."

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "uksouth"
      ]
    }
  })
}
