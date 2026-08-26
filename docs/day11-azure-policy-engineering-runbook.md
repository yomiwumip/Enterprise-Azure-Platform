# Day 11 — Azure Policy & RBAC Governance Engineering Runbook

## 1. Production Objective

The production problem addressed on Day 11 was the need to enforce Azure governance standards consistently rather than relying on engineers to remember organisational requirements.

The exercise focused on Azure Policy governance, RBAC least privilege, compliance evaluation, policy exemptions, Terraform management, failure testing and operational cleanup.

The target governance capability was an allowed-location control restricting resources to approved Azure regions.

The exercise deliberately used temporary Azure resources so that the Portal implementation could be understood before reproducing the capability through Terraform.

---

## 2. Engineering Approach

The Day 11 implementation followed this sequence:

1. Understand the production governance requirement.
2. Inspect the existing Azure and Terraform environment.
3. Create temporary governance resources in the Azure Portal.
4. Test Azure Policy manually.
5. Investigate Azure Policy compliance state.
6. Create a deliberately non-compliant resource.
7. Test Audit versus Deny behaviour.
8. Implement and test a least-privileged Reader service principal.
9. Reproduce governance controls through Terraform.
10. Import existing Azure resources into Terraform state.
11. Reconcile Portal-created resources with Terraform.
12. Create and test a narrowly scoped Policy Exemption.
13. Investigate Policy evaluation timing and ARM behaviour.
14. Deliberately investigate failure conditions.
15. Remove temporary test resources.
16. Reconcile Terraform after cleanup.
17. Verify a clean Terraform plan.

---

## 3. Temporary Day 11 Environment

### Main governance Resource Group

`rg-contoso-governance-day11-uks-001`

Region:

`uksouth`

### Temporary Audit Resource Group

`rg-contoso-governance-day11-audit-001`

The Audit Resource Group was created specifically to demonstrate that an Audit policy records a governance violation without blocking deployment.

It was subsequently deleted and independently verified as removed.

---

## 4. Azure Policy — Allowed Locations

A custom Day 11 Azure Policy was created:

`contoso-governance-day11-allowed-locations`

The policy was assigned at the Day 11 governance Resource Group scope.

Allowed location:

`uksouth`

Effect:

`Deny`

The purpose was to prevent resources from being deployed outside the approved Azure region.

---

## 5. Audit Versus Deny

A temporary Audit policy was also created through the Azure Portal:

Display name:

`contoso-day11-audit-allowed-location`

Allowed location:

`uksouth`

Effect:

`Audit`

The Audit policy was intentionally tested against a Storage Account deployed in:

`westus2`

The Storage Account deployed successfully, demonstrating that Audit does not block deployment.

After Azure Policy evaluation was explicitly triggered, the resource appeared as:

`NonCompliant`

with:

`audit`

as the policy effect.

This demonstrated the distinction between:

- Audit — records a governance violation.
- Deny — prevents the deployment.

---

## 6. Policy Evaluation Investigation

An initial Policy State query using `--scope` failed because the installed Azure CLI command did not accept that argument for the `az policy state list` command.

The investigation was corrected by querying the Resource Group using:

`--resource-group`

The resulting Policy State records showed both compliant and non-compliant resources across multiple policy assignments.

The Day 11 policy was then isolated using the policy definition name.

Azure Policy evaluation timing was also investigated.

The Audit test resource existed before the Audit assignment was evaluated against it. An explicit evaluation scan was therefore initiated.

The resulting Policy State showed the intentionally out-of-region Storage Account as:

`NonCompliant`

with effect:

`audit`

This demonstrated that successful deployment and policy compliance are separate operational concepts.

---

## 7. RBAC Least-Privilege Test

A temporary service principal was used:

`contoso-day11-rbac-reader`

The service principal was assigned the:

`Reader`

role

at the Day 11 governance Resource Group scope.

The service principal successfully read the Resource Group.

A deliberate write operation was then attempted against Azure Storage.

Azure returned:

`AuthorizationFailed`

for:

`Microsoft.Storage/storageAccounts/write`

This demonstrated that the Reader identity could inspect resources but could not create or modify resources.

This provided evidence of least-privilege RBAC behaviour.

---

## 8. Terraform RBAC Implementation

The existing Azure RBAC assignment was represented in Terraform using:

`azurerm_role_assignment.day11_rbac_reader`

The existing Azure assignment was imported into Terraform rather than recreated.

Terraform subsequently reported:

`No changes. Your infrastructure matches the configuration.`

This demonstrated successful reconciliation between the existing Azure RBAC assignment and Terraform.

---

## 9. Terraform Azure Policy Implementation

The Day 11 allowed-location policy was represented in Terraform.

Terraform managed:

- The Day 11 governance Resource Group
- The custom Policy Definition
- The Resource Group Policy Assignment
- The RBAC Reader assignment

The existing Azure resources were refreshed and reconciled through Terraform.

The resulting plan reported:

`No changes.`

---

## 10. Portal Policy Exemption

A temporary Policy Exemption was created through the Azure Portal for:

`stgovd11tfgood001`

The exemption used:

Category:

`Waiver`

Expiration:

`2026-09-24T23:00:00Z`

The exemption was deliberately narrow in scope and was intended to demonstrate how an approved exception can bypass a Deny policy for a specific resource while the surrounding Resource Group remains governed.

Policy State subsequently showed the resource as:

`Exempt`

against:

`contoso-governance-day11-allowed-locations`

with effect:

`deny`

This demonstrated that Azure Policy exemptions are visible in Policy evaluation rather than simply relying on deployment success.

---

## 11. Terraform Policy Exemption

The Terraform provider schema was inspected before implementation.

The provider exposed:

`azurerm_resource_policy_exemption`

The required attributes included:

- `exemption_category`
- `name`
- `policy_assignment_id`
- `resource_id`

The Portal-created exemption was imported into Terraform.

An initial Terraform plan attempted to replace the exemption because the Policy Assignment ID differed in resource path casing.

The configuration was corrected to match the existing Azure resource representation.

Terraform then reported:

`No changes.`

This demonstrated the importance of matching Azure resource identifiers accurately when importing existing resources into Terraform.

---

## 12. ARM API Investigation

The Azure CLI Policy Exemption command was identified as being in preview.

The ARM representation of the Policy Exemption was therefore queried directly using `az rest`.

An initial API version failed because Azure did not support that API version for the Policy Exemption resource type.

Azure returned the supported API versions.

The query was then repeated using:

`api-version=2026-01-01-preview`

The ARM object confirmed:

- Resource type: `Microsoft.Authorization/policyExemptions`
- Category: `Waiver`
- Policy Assignment: `contoso-governance-day11-allowed-location-tf`
- Expiration: `2026-09-24T23:00:00Z`
- Exemption resource name: `8ea708b5954f5177a5cbb809`

This demonstrated direct ARM investigation when higher-level tooling did not expose the required information cleanly.

---

## 13. Failure Investigation — Policy Exemption Lifecycle

During cleanup, the Storage Account targeted by the resource-scoped Policy Exemption was deleted.

Terraform subsequently detected that the exemption configuration no longer corresponded to an existing Azure resource and initially proposed:

`1 to add, 0 to change, 0 to destroy`

The investigation confirmed that the Storage Account target no longer existed.

The obsolete Policy Exemption was removed from Terraform state using:

`terraform state rm azurerm_resource_policy_exemption.day11_approved_location`

The exemption configuration was also confirmed to be absent from the Terraform working directory.

This demonstrated the lifecycle dependency between a resource-scoped Policy Exemption and its target resource.

---

## 14. Temporary Resource Cleanup

The temporary Audit Resource Group was deleted:

`rg-contoso-governance-day11-audit-001`

Deletion was independently verified using Azure CLI.

Azure returned:

`ResourceGroupNotFound`

confirming the Resource Group had been removed.

The two temporary Storage Accounts in the main Day 11 Resource Group were also deleted:

- `stcontosogovday11good001`
- `stgovd11tfgood001`

A subsequent Storage Account inventory returned no rows, confirming that the temporary Storage Accounts had been removed.

---

## 15. Final Terraform Verification

Terraform formatting and validation succeeded.

The final Terraform plan reported:

`No changes. Your infrastructure matches the configuration.`

This confirmed that cleanup of the temporary test resources did not leave unexpected Terraform drift.

Terraform continues to manage the intended Day 11 governance resources.

---

## 16. Key Engineering Lessons

### Azure Policy versus RBAC

Azure Policy controls whether resource configurations comply with organisational governance requirements.

RBAC controls what an identity is authorised to do.

They solve different problems and should be designed independently.

### Audit versus Deny

Audit is useful for visibility and governance rollout.

Deny is an enforcement mechanism and should be introduced carefully because it can block workloads.

A production rollout should normally establish visibility before introducing restrictive enforcement.

### Policy Evaluation Is Not Always Immediate

A resource can exist before its Policy State reflects the latest governance decision.

Explicit evaluation scans and Policy State investigation may therefore be required during troubleshooting.

### Terraform Import Requires Reconciliation

Importing an existing Azure resource does not automatically guarantee that Terraform configuration matches Azure exactly.

Resource IDs, path casing and optional attributes can affect Terraform plans.

### Policy Exemptions Require Tight Scope

Exemptions should be narrowly scoped, justified, time-bound where appropriate and reviewed.

A broad exemption can undermine the governance control it is intended to work around.

### Resource Lifecycle Matters

Resource-scoped governance objects can depend on the lifecycle of their target resources.

Deleting the target resource without considering dependent governance objects can create Terraform reconciliation issues.

---

## 17. Production Operational Considerations

Before introducing a Deny policy into a production subscription:

1. Start with Audit where appropriate.
2. Measure existing compliance.
3. Identify workloads that would be affected.
4. Establish an exemption process.
5. Define ownership and expiry for exemptions.
6. Test in a controlled scope.
7. Communicate the change to stakeholders.
8. Introduce enforcement gradually.
9. Monitor policy failures after rollout.

The goal is governance without unnecessarily blocking legitimate engineering delivery.

---

## 18. Day 11 Evidence

Evidence captured during the exercise includes:

- Azure Portal Policy configuration
- Azure Portal Audit policy
- Azure Portal Policy Exemption
- RBAC Reader service principal login
- Successful Reader access
- Deliberate RBAC write failure
- Policy State compliance results
- Policy evaluation scan
- ARM Policy Exemption investigation
- Terraform validation
- Terraform import
- Terraform reconciliation
- Terraform clean plans
- Temporary resource cleanup
- Post-cleanup verification

---

## 19. Final Outcome

Day 11 delivered a production-style Azure governance capability demonstrating:

- Azure Policy
- RBAC least privilege
- Audit versus Deny
- Policy compliance evaluation
- Policy exemptions
- Terraform management
- Existing-resource import
- ARM investigation
- Failure engineering
- Temporary environment cleanup
- Terraform reconciliation

The final Terraform plan confirmed:

`No changes.`
