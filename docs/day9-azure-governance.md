# Day 9 — Azure Governance & Terraform

## Production Engineering Runbook

**Project:** Enterprise Azure Platform
**Day:** 9
**Environment:** Production-style Azure platform
**Region:** UK South

---

## 1. Production Requirement

The platform needs a governance control that ensures Azure resources have an accountable owner.

We will implement and test an Azure Policy requiring an `Owner` tag on resources in the production platform Resource Group.

The initial policy will use audit rather than deny so that we can observe compliance before introducing enforcement.

## 2. Existing Environment

Before starting the Day 9 build, the existing platform was inspected.

The Resource Group already existed:

`rg-contoso-platform-prod-uks-001`

The existing Terraform resources were:

- `azurerm_resource_group.platform`
- `azurerm_management_lock.platform_resource_group`

The Resource Group was protected by a `CanNotDelete` management lock.

The existing Terraform variables already included platform ownership and governance information, including:

- Owner
- CostCentre
- Application
- Environment
- Project

No duplicate Resource Group or management lock was created.

## 3. Portal → Terraform Learning Approach

Because the goal is to understand both Azure and Infrastructure as Code, the Storage Account was first created temporarily through the Azure Portal.

The learning sequence was:

Portal → understand the service → test manually → inspect Azure → recreate with Terraform → compare → test → troubleshoot → delete temporary Portal resource → keep Terraform implementation.

The temporary Portal Storage Account was:

`stcontosogovportal001`

The permanent Terraform Storage Account was:

`stcontosogovtf001`

## 4. Temporary Portal Storage Account

A temporary Storage Account was created through the Azure Portal:

`stcontosogovportal001`

It was created inside:

`rg-contoso-platform-prod-uks-001`

The purpose was not to create production infrastructure manually. The purpose was to understand how Azure exposes and configures the service through the Portal before reproducing the capability with Terraform.

The Portal resource intentionally did not initially contain an `Owner` tag.

This gave us a controlled governance violation to test Azure Policy.

## 5. Azure Policy Governance Control

The governance policy was:

`contoso-platform-require-owner-tag`

Its purpose was to audit resources in the production platform Resource Group for the required `Owner` tag.

The policy was initially deployed in audit mode rather than deny mode.

This allowed us to observe the effect of the governance requirement without immediately blocking resource deployments.

The policy assignment resource name discovered during investigation was:

`39414fa06faf558496fe9b1b`

The policy therefore provided a way to compare:

- the manually created Portal resource
- the Terraform-managed resource
- their resulting compliance states

## 6. Inspecting the Portal Resource

After the Portal deployment completed, Azure CLI was used to verify what Azure actually created.

The Storage Account reported:

- Name: `stcontosogovportal001`
- Location: `uksouth`
- SKU: `Standard_LRS`
- Kind: `StorageV2`
- Public network access: `Enabled`

Security-related settings were also inspected.

The resource reported:

- Access tier: `Hot`
- Blob public access: `False`
- Shared key access: `False`
- Minimum TLS version: `TLS1_2`
- Public network access: `Enabled`

This inspection was important because the Portal configuration was not treated as assumed configuration. Azure's actual resource state was queried and verified.

## 7. Terraform Implementation

The existing Terraform configuration was extended to create the equivalent Storage Account.

The Terraform-managed resource was:

`azurerm_storage_account.platform`

The Azure resource name was:

`stcontosogovtf001`

The configuration included:

- Standard performance
- LRS replication
- StorageV2
- Hot access tier
- HTTPS-only traffic
- TLS 1.2
- Shared-key authentication disabled
- Anonymous blob access disabled
- Public network access enabled
- Seven-day blob deletion retention
- Seven-day container deletion retention
- Common platform tags

The Terraform resource reused the existing Resource Group rather than creating a duplicate Resource Group.

The resulting tags included:

- `Owner = Cloud Platform Engineering`
- `ManagedBy = Terraform`
- `Environment = prod`
- `Application = Platform`
- `CostCentre = IT001`
- `Project = contoso`

## 8. Terraform Validation

The Terraform configuration was formatted and validated before deployment.

The configuration was formatted using:

`terraform -chdir=terraform fmt`

Terraform then validated the configuration using:

`terraform -chdir=terraform validate`

The validation result was:

`Success! The configuration is valid.`

This confirmed that the Terraform configuration was syntactically and structurally valid before deployment.

## 9. Initial Terraform Plan

The initial Terraform plan showed:

`Plan: 1 to add, 0 to change, 0 to destroy.`

The planned addition was:

`azurerm_storage_account.platform`

The plan confirmed the intended Storage Account configuration and platform tags before deployment.

The plan was then approved for deployment.

## 10. Real Terraform Deployment Failure

The first Terraform apply was:

`terraform -chdir=terraform apply`

Azure successfully created the Storage Account, but Terraform subsequently failed while waiting for the Storage Account data plane to become available.

The important error was:

`403 Key based authentication is not permitted on this storage account.`

Azure returned:

`KeyBasedAuthenticationNotPermitted`

This was a genuine deployment failure rather than an intentionally created error.

## 11. Failure Investigation

The first investigation checked Terraform state:

`terraform -chdir=terraform state list`

The Storage Account appeared in Terraform state alongside the existing Resource Group and management lock.

Azure was then queried directly.

The Storage Account reported:

- Provisioning state: `Succeeded`
- Shared key authentication: `False`
- Public network access: `Enabled`
- Minimum TLS: `TLS1_2`

This established an important distinction:

The Azure management-plane operation had successfully created the Storage Account, but a subsequent data-plane operation used by the Terraform provider failed because key-based authentication was disabled.

## 12. Management Plane vs Data Plane

The failure demonstrated the difference between Azure's management plane and data plane.

The management-plane sequence was:

Terraform → Azure Resource Manager → Microsoft.Storage → Storage Account created.

The later data-plane operation attempted to interact with the Blob service and was rejected because key-based authentication was not permitted.

The important troubleshooting lesson was:

A resource can successfully exist in Azure even though a subsequent provider operation against its data plane fails.

## 13. Provider Authentication Fix

The AzureRM provider configuration was inspected.

The provider initially contained:

`provider "azurerm" { features {} }`

The Storage Account security configuration disabled shared-key authentication.

To allow Terraform to use identity-based authentication for supported Storage data-plane operations, the provider was configured with:

`storage_use_azuread = true`

This preserved the security requirement:

`shared_access_key_enabled = false`

The solution therefore fixed the automation authentication path without re-enabling Storage Account keys.

## 14. Tainted Terraform Resource

After the failed deployment, Terraform identified the Storage Account as tainted and initially proposed:

`-/+ destroy and then create replacement`

Before allowing Terraform to replace the resource, the actual Azure resource was checked.

Azure reported:

`ProvisioningState = Succeeded`

The resource therefore existed successfully in Azure.

The resource was untainted with:

`terraform -chdir=terraform untaint azurerm_storage_account.platform`

A new Terraform plan then showed:

`Plan: 0 to add, 1 to change, 0 to destroy.`

This avoided unnecessary destruction and replacement of an existing healthy Azure resource.

## 15. Successful Terraform Recovery

Terraform was applied again after the authentication configuration was corrected.

The result was:

`Apply complete! Resources: 0 added, 1 changed, 0 destroyed.`

The Storage Account was now successfully managed by Terraform.

The permanent Terraform-managed resource was:

`stcontosogovtf001`

## 16. Azure Policy Compliance Test

The Azure Policy state was queried after the Terraform deployment.

The relevant policy assignment was:

`39414fa06faf558496fe9b1b`

The Terraform-managed Storage Account was reported as:

`stcontosogovtf001 → Compliant`

The temporary Portal Storage Account was initially reported as:

`stcontosogovportal001 → NonCompliant`

This demonstrated that the governance policy could detect the difference between a resource with the required `Owner` tag and a resource without it.

## 17. Governance Remediation

The missing `Owner` tag was added to the temporary Portal Storage Account.

The tag was:

`Owner = Cloud Platform Engineering`

The actual Azure resource was then queried to verify the remediation.

Azure returned:

`Owner: Cloud Platform Engineering`

This proved that the resource itself had been successfully corrected.

The Policy result remained temporarily `NonCompliant`, demonstrating that Azure Policy compliance results are evaluation data and may not immediately reflect a resource configuration change.

The important distinction was:

Resource configuration:

`Owner = Cloud Platform Engineering`

Policy evaluation:

`NonCompliant`

The resource had been remediated; the stored policy evaluation had not yet caught up.

## 18. Temporary Portal Resource Cleanup

The temporary Portal Storage Account was:

`stcontosogovportal001`

An initial deletion attempt was blocked by the Resource Group management lock.

Azure returned:

`ScopeLocked`

The existing lock was inspected and confirmed as:

`platform-resource-group-cannot-delete`

with:

`CanNotDelete`

This demonstrated that the Resource Group protection was functioning correctly.

Because the Storage Account was explicitly a temporary training resource, the lock was temporarily removed under controlled conditions.

The temporary Portal Storage Account was then deleted successfully.

The permanent Terraform-managed Storage Account was not deleted.

## 19. Restoring Platform Protection

The management lock remained defined in Terraform.

After the temporary Portal resource was removed, Terraform was run again.

Terraform detected that the management lock was missing and planned:

`azurerm_management_lock.platform_resource_group`

The plan showed:

`Plan: 1 to add, 0 to change, 0 to destroy.`

Terraform recreated:

`platform-resource-group-cannot-delete`

with:

`CanNotDelete`

The apply completed successfully:

`Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`

This restored the intended platform protection through Infrastructure as Code rather than manually recreating the control.

## 20. Final Terraform Verification

A final Terraform plan was executed:

`terraform -chdir=terraform plan`

Terraform returned:

`No changes. Your infrastructure matches the configuration.`

This proved that the final Azure environment matched the Terraform configuration with no remaining Terraform drift.

The final state was:

Terraform configuration = Terraform state = Azure infrastructure.

## 21. Production Engineering Lessons

### Governance is an operational control

Azure Policy is not simply documentation. It actively evaluates the configuration of Azure resources and provides compliance information that engineers can act upon.

### Security controls must work with automation

Disabling shared-key authentication improved the Storage Account security posture, but automation also needed to use an appropriate identity-based authentication method.

The provider therefore had to be configured consistently with the security design.

### Management-plane success does not guarantee data-plane success

The Storage Account could successfully exist in Azure while a later provider operation against the Blob data plane failed.

This distinction is important when troubleshooting Azure automation.

### Investigate before replacing infrastructure

Terraform marked the Storage Account as tainted after the failed operation.

The Azure resource was inspected before allowing Terraform to replace it.

Because the resource was confirmed as successfully provisioned, unnecessary destruction was avoided.

### Governance controls can affect operational procedures

The `CanNotDelete` Resource Group lock prevented deletion of the temporary Storage Account.

This demonstrated that security and governance controls can directly affect normal operational tasks.

Engineers therefore need to understand both the purpose of a control and its operational consequences.

### Terraform should remain the source of truth

The management lock was temporarily removed for controlled cleanup.

Terraform subsequently recreated it.

The final Terraform plan showed no changes, proving that the intended platform state had been restored.

## 22. Final Day 9 Outcome

The Day 9 exercise delivered a complete production-style governance workflow:

1. A production governance requirement was identified.
2. The existing platform was inspected before changes were made.
3. A temporary Storage Account was created through the Azure Portal.
4. The Portal resource was inspected and tested.
5. The capability was recreated using Terraform.
6. Azure Policy was used to evaluate resource compliance.
7. A real Terraform deployment failure was investigated.
8. The management-plane and data-plane distinction was identified.
9. Azure AD authentication was configured for Storage data-plane operations.
10. A tainted Terraform resource was investigated and recovered without unnecessary replacement.
11. The governance violation was remediated.
12. The temporary Portal resource was removed.
13. The Resource Group protection was restored through Terraform.
14. A final Terraform plan confirmed there was no infrastructure drift.

The final Terraform verification returned:

`No changes. Your infrastructure matches the configuration.`

This represents the completed engineering state for Day 9.

## 23. Day 9 Evidence

The following evidence was produced during the exercise:

- Temporary Portal Storage Account: `stcontosogovportal001`
- Terraform Storage Account: `stcontosogovtf001`
- Azure Policy assignment: `39414fa06faf558496fe9b1b`
- Resource Group: `rg-contoso-platform-prod-uks-001`
- Resource Group management lock: `platform-resource-group-cannot-delete`
- Terraform validation: `Success! The configuration is valid.`
- Terraform recovery: `Apply complete!`
- Final Terraform verification: `No changes. Your infrastructure matches the configuration.`

The exercise also produced evidence of two real operational behaviours:

1. Storage data-plane authentication failure caused by disabled key-based authentication.
2. Resource deletion blocked by an Azure `CanNotDelete` management lock.

These failures were investigated and resolved rather than bypassed without understanding their cause.

## 24. Portfolio Statement

A concise portfolio description of Day 9 is:

> Built and operated a production-style Azure governance capability using Terraform and Azure Policy. Created a temporary Portal implementation to understand Azure service configuration, reproduced the capability through Infrastructure as Code, implemented mandatory ownership tagging, investigated a real Storage data-plane authentication failure, configured Azure AD authentication for Terraform, recovered a tainted resource without unnecessary replacement, tested governance compliance and remediation, investigated management-lock behaviour, and restored the final platform to a drift-free Terraform-managed state.

## 25. Day 9 Completion Checklist

- [x] Production requirement understood
- [x] Existing infrastructure inspected
- [x] Temporary Portal resource created
- [x] Portal configuration inspected
- [x] Azure Policy tested
- [x] Terraform implementation created
- [x] Terraform configuration validated
- [x] Terraform plan reviewed
- [x] Real deployment failure investigated
- [x] Authentication issue resolved
- [x] Tainted resource investigated
- [x] Resource recovered without unnecessary replacement
- [x] Policy remediation demonstrated
- [x] Temporary Portal resource deleted
- [x] Management lock restored through Terraform
- [x] Final Terraform plan verified
- [x] Documentation created
- [ ] Git commit
- [ ] Git push
- [ ] Pull Request
- [ ] Final runbook export/download
