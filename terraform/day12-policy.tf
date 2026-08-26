resource "azurerm_policy_definition" "day12_required_tags" {
  name         = "contoso-governance-day12-required-tags-tf"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Contoso Day 12 - Required Governance Tags"
  description  = "Requires Owner and Environment tags on governed Azure resources to support ownership, operations and governance reporting."

  metadata = jsonencode({
    category = "Governance"
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "[concat('tags[', 'Owner', ']')]"
          exists = "false"
        },
        {
          field  = "[concat('tags[', 'Environment', ']')]"
          exists = "false"
        }
      ]
    }

    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "day12_required_tags" {
  name                 = "contoso-governance-day12-required-tags-tf"
  resource_group_id    = azurerm_resource_group.day11_governance.id
  policy_definition_id = azurerm_policy_definition.day12_required_tags.id

  display_name = "Contoso Day 12 - Required Governance Tags - Terraform"

  description = "Terraform-managed Day 12 governance assignment requiring Owner and Environment tags."

  enforce = true
}
