# Day 12 — Azure Policy & Governance Engineering Runbook

## 1. Production Requirement

Contoso Holdings needs governance controls that allow developers to move quickly while ensuring Azure resources follow enterprise standards.

The Day 12 requirement was to implement an Azure Policy that identifies governed resources missing mandatory `Owner` and `Environment` tags.

The policy uses the `Audit` effect so that non-compliant resources are detected and reported without blocking deployment.

---

## 2. Engineering Approach

The implementation followed the production-style workflow:

1. Inspect the existing Day 11 Azure governance environment.
2. Build the capability manually in Azure Portal.
3. Create a temporary test resource.
4. Deliberately test a non-compliant configuration.
5. Investigate Azure Policy evaluation.
6. Recreate the same capability using Terraform.
7. Run Terraform validation and plan.
8. Apply the Terraform implementation.
9. Trigger Policy evaluation.
10. Prove the test resource was NonCompliant.
11. Compare Portal and Terraform implementations.
12. Delete the temporary test resource.
13. Run final Terraform validation and plan.
14. Confirm no Terraform drift.
15. Commit the implementation to Git.

---

## 3. Existing Day 11 Baseline

Existing Terraform-managed governance resources included:

- Day 11 allowed-location Policy Definition
- Day 11 Resource Group
- Day 11 Resource Group Policy Assignment
- Day 11 Reader RBAC assignment

Existing Day 11 Resource Group:

`rg-contoso-governance-day11-uks-001`

The Day 12 implementation deliberately extended the existing governance boundary rather than creating duplicate infrastructure.

---

## 4. Azure Policy Model

The Day 12 Policy checks for two mandatory governance tags:

- `Owner`
- `Environment`

The policy condition is:

```json
{
  "if": {
    "anyOf": [
      {
        "field": "[concat('tags[', 'Owner', ']')]",
        "exists": "false"
      },
      {
        "field": "[concat('tags[', 'Environment', ']')]",
        "exists": "false"
      }
    ]
  },
  "then": {
    "effect": "audit"
  }
}
