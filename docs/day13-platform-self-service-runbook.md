# Contoso Holdings — Day 13 Platform Self-Service Runbook

## Day 13 — Platform Self-Service Storage Capability

**Project:** Enterprise Azure Platform  
**Objective:** Objective 9 — Platform Self-Service  
**Environment:** Azure UK South  
**Capability:** Azure Storage Account  
**Implementation approach:** Azure Portal discovery → manual testing → Terraform implementation → verification → failure testing → cleanup → drift verification → Git/GitHub

---

# 1. Production Scenario

The platform team needs a repeatable and governed Azure Storage capability for development workloads.

The engineering requirement was to:

- understand how the capability is configured in Azure Portal;
- manually test the configuration;
- understand what Azure actually created;
- reproduce the capability using Terraform;
- compare Portal configuration with Terraform and actual Azure state;
- deliberately test a prohibited authentication method;
- investigate failures rather than ignoring them;
- remove the temporary Portal implementation;
- retain the Terraform implementation;
- verify that Terraform has no drift;
- document the engineering work;
- deliver the implementation through Git and GitHub.

## Engineering workflow

```text
Production requirement
        ↓
Inspect existing platform
        ↓
Temporary Azure Portal implementation
        ↓
Manual Portal testing
        ↓
Understand actual Azure configuration
        ↓
Terraform implementation
        ↓
Terraform formatting
        ↓
Terraform validation
        ↓
Terraform plan
        ↓
Terraform apply
        ↓
Azure verification
        ↓
Deliberate Shared-Key failure test
        ↓
Portal ↔ Terraform ↔ Azure comparison
        ↓
Terraform ownership check
        ↓
Delete temporary Portal resource
        ↓
Verify cleanup
        ↓
Terraform drift check
        ↓
Git staging
        ↓
Git commit
        ↓
GitHub push
        ↓
Remote verification
```

---

# 2. Objective 9 — Platform Self-Service

## Production requirement

The platform team needs a repeatable way to provide a governed Azure Storage capability for development workloads.

The capability needs:

- controlled Storage Account configuration;
- secure authentication;
- HTTPS-only traffic;
- TLS 1.2 configuration;
- controlled anonymous access;
- data-retention protection;
- standard platform tags;
- repeatable Terraform deployment;
- auditable infrastructure ownership.

The Azure Portal implementation was deliberately temporary.

The Terraform implementation is the retained Infrastructure as Code version.

---

# 3. Existing Platform Pre-Flight

Before creating anything, we inspected the existing Terraform configuration.

## Command

```bash
find terraform -maxdepth 1 -type f -name '*.tf' -printf '%f\n' | sort
```

## What the command does

- `find` searches for files.
- `terraform` is the directory being searched.
- `-maxdepth 1` limits the search to the Terraform directory.
- `-type f` means files only.
- `-name '*.tf'` selects Terraform files.
- `-printf '%f\n'` prints only the filename.
- `| sort` sorts the filenames alphabetically.

## Why we ran it

We needed to inspect what already existed before creating Objective 9.

This prevents duplicate Terraform configuration and duplicate infrastructure.

## Result

```text
day11-governance.tf
day11-rbac.tf
day12-policy.tf
locals.tf
main.tf
outputs.tf
providers.tf
variables.tf
versions.tf
```

---

# 4. Confirm Objective 9 Did Not Already Exist

We searched the existing Terraform configuration for the temporary Portal Storage Account and Objective 9 terminology.

## Command

```bash
grep -R -n \
  -E 'stcontosoobj9portal01|obj9portal|Platform Self Service' \
  terraform --include='*.tf' || true
```

## What the command does

`grep` searches files for matching text.

- `-R` searches recursively.
- `-n` displays line numbers.
- `-E` enables extended search expressions.
- `stcontosoobj9portal01` searches for the Portal resource.
- `obj9portal` searches for the Objective 9 identifier.
- `Platform Self Service` searches for the workload name.
- `--include='*.tf'` restricts the search to Terraform files.
- `|| true` prevents a no-match result from stopping the shell sequence.

## Why we ran it

The Portal Storage Account was created manually.

We needed to prove that Terraform did not already contain a definition for it.

## Result

No existing Objective 9 Terraform definition was found.

---

# 5. Terraform File Inventory

The existing Terraform files were inspected before creating the Day 13 implementation.

The inventory was:

```text
day11-governance.tf
day11-rbac.tf
day12-policy.tf
locals.tf
main.tf
outputs.tf
providers.tf
variables.tf
versions.tf
```

The Day 13 file was then created:

```text
terraform/day13-platform-self-service.tf
```

The file initially had a size of zero bytes before the implementation was added.

---

# 6. Azure Portal Practice

The Portal was used as a temporary implementation.

## Why Portal first?

The Portal allowed us to understand:

- the Storage Account creation workflow;
- available configuration options;
- security settings;
- networking settings;
- data protection settings;
- encryption settings;
- tagging;
- Azure's actual resulting configuration.

The Portal resource was not intended to become the final implementation.

---

# 7. Azure Portal — Basics

The temporary Storage Account was configured as follows.

```text
Subscription:
Azure subscription 1

Resource group:
rg-contoso-finops-lab-uks-001

Location:
UK South

Storage account name:
stcontosoobj9portal01

Primary service:
Azure Blob Storage or Azure Data Lake Storage

Performance:
Standard

Replication:
Locally redundant storage (LRS)
```

## Portal steps

1. Open Azure Portal.
2. Search for **Storage accounts**.
3. Select **Storage accounts**.
4. Select **Create**.
5. Select the Azure subscription.
6. Select the Resource Group.
7. Enter the Storage Account name.
8. Select **UK South**.
9. Select **Standard** performance.
10. Select **Locally redundant storage (LRS)**.
11. Continue through the configuration tabs.

## Why

These settings established the basic Storage Account design that would later be reproduced in Terraform.

---

# 8. Azure Portal — Advanced

The Portal configuration showed:

```text
Hierarchical namespace:
Disabled

SFTP:
Disabled

Network file system v3:
Disabled

Allow cross-tenant replication:
Disabled

Access tier:
Hot

Managed Identity for SMB:
Disabled

Require Encryption in Transit for SMB:
Enabled
```

## Why

Only the capabilities required for the development Storage workload were enabled.

Unrequired protocols and capabilities were left disabled.

---

# 9. Azure Portal — Security

The Portal configuration showed:

```text
Secure transfer:
Enabled

Blob anonymous access:
Disabled

Allow storage account key access:
Disabled

Default to Microsoft Entra authorization in the Azure portal:
Enabled

Minimum TLS version:
Version 1.2
```

## Why each setting matters

### Secure transfer

Ensures secure transport is used.

### Blob anonymous access disabled

Prevents unauthenticated public blob access.

### Storage Account key access disabled

Prevents Shared Key authentication.

### Microsoft Entra authorization enabled

Supports identity-based authentication and authorization.

### TLS 1.2

Establishes the intended minimum TLS security baseline.

---

# 10. Azure Portal — Networking

The Portal configuration showed:

```text
Public network access:
Enabled

Public network access scope:
Enabled from all networks

Default routing tier:
Microsoft network routing
```

## Engineering note

This was the configuration used for the temporary development demonstration.

It should not automatically be interpreted as the security posture for every production workload.

A production implementation would assess network exposure against workload requirements.

---

# 11. Azure Portal — Data Protection

The Portal configuration showed:

```text
Point-in-time restore:
Disabled

Blob soft delete:
Enabled

Blob retention:
7 days

Container soft delete:
Enabled

Container retention:
7 days

Classic file share soft delete:
Enabled

Classic file share retention:
7 days

Versioning:
Disabled

Blob change feed:
Disabled

Version-level immutability support:
Disabled
```

## Why

Seven-day soft delete provides a recovery window for accidental deletion.

---

# 12. Azure Portal — Encryption

The Portal configuration showed:

```text
Encryption type:
Microsoft-managed keys (MMK)

Customer-managed key support:
Blobs and files only

Infrastructure encryption:
Disabled
```

## Why

Microsoft-managed keys were sufficient for this development demonstration.

A production workload with stronger regulatory or organisational requirements could require customer-managed keys.

---

# 13. Azure Portal — Tags

The temporary Portal resource used:

```text
Environment        = Development
Owner              = Cloud Platform Team
Application        = Platform Self Service
BusinessUnit       = Technology
CostCentre         = FIN001
Criticality        = Low
DataClassification = Internal
ManagedBy          = Portal-Temporary
```

## Why the tags matter

Tags support:

- ownership;
- cost allocation;
- reporting;
- governance;
- automation;
- operational identification.

The value:

```text
ManagedBy = Portal-Temporary
```

made the temporary nature of the resource explicit.

---

# 14. Portal Screenshot Evidence

The screenshots captured during Day 13 should be retained as evidence of the manual Portal configuration.

## Screenshot evidence

**Screenshot 1 — Storage Account Basics**

Shows:

- subscription;
- Resource Group;
- UK South;
- Storage Account name;
- Standard performance;
- LRS replication.

**Screenshot 2 — Advanced**

Shows:

- hierarchical namespace;
- SFTP;
- NFS;
- cross-tenant replication;
- access tier.

**Screenshot 3 — Security**

Shows:

- secure transfer;
- anonymous access;
- Shared Key disabled;
- Microsoft Entra authorization;
- TLS configuration.

**Screenshot 4 — Networking**

Shows:

- public network access;
- network scope;
- routing.

**Screenshot 5 — Data Protection**

Shows:

- blob soft delete;
- container soft delete;
- retention periods;
- versioning settings.

**Screenshot 6 — Encryption**

Shows:

- Microsoft-managed keys;
- customer-managed key option;
- infrastructure encryption.

**Screenshot 7 — Tags**

Shows:

- Environment;
- Owner;
- Application;
- BusinessUnit;
- CostCentre;
- Criticality;
- DataClassification;
- ManagedBy.

---

# 15. Portal Shared-Key Failure Test

The Portal configuration stated:

```text
Allow storage account key access = Disabled
```

We deliberately tested whether Azure enforced this configuration.

## Why

A configuration screen alone does not prove runtime enforcement.

We wanted evidence that Azure would actually reject Shared Key authentication.

## Test result

Azure returned:

```text
Key based authentication is not permitted on this storage account.
```

with:

```text
ErrorCode:KeyBasedAuthenticationNotPermitted
```

## Meaning

The test succeeded.

The request was rejected because Shared Key authentication was disabled.

This provided runtime evidence that the security control worked.

---

# 16. Portal Azure Configuration Verification

We queried the actual Azure configuration of the Portal resource.

## Result

```json
{
  "DefaultToOAuth": true,
  "HTTPS": true,
  "MinTLS": null,
  "Name": "stcontosoobj9portal01",
  "SharedKey": false
}
```

## Important values

```text
DefaultToOAuth = true
HTTPS          = true
SharedKey      = false
```

## Meaning

Azure confirmed:

- OAuth/default authorization was enabled;
- HTTPS was enabled;
- Shared Key access was disabled.

The query returned:

```text
MinTLS = null
```

for this particular query.

We did not incorrectly treat that one CLI field as proof that TLS 1.2 was disabled.

The Portal configuration showed TLS 1.2 and the Terraform configuration explicitly set TLS 1.2.

---

# 17. Terraform Implementation

After understanding and testing the Portal configuration, we created the retained Terraform implementation.

File:

```text
terraform/day13-platform-self-service.tf
```

## Terraform configuration

```hcl
resource "azurerm_storage_account" "objective9_self_service" {
  name                     = "stcontosobj9tf001"
  resource_group_name      = "rg-contoso-finops-lab-uks-001"
  location                 = "UK South"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

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

  tags = {
    Environment        = "Development"
    Owner              = "Cloud Platform Team"
    Application        = "Platform Self Service"
    BusinessUnit       = "Technology"
    CostCentre         = "FIN001"
    Criticality        = "Low"
    DataClassification = "Internal"
    ManagedBy          = "Terraform"
  }
}
```

---

# 18. Terraform Configuration — Security

## HTTPS

```hcl
https_traffic_only_enabled = true
```

Ensures HTTPS-only traffic.

## Anonymous access

```hcl
allow_nested_items_to_be_public = false
```

Prevents public anonymous access to nested storage items.

## Shared Key

```hcl
shared_access_key_enabled = false
```

Disables Shared Key authentication.

## OAuth

```hcl
default_to_oauth_authentication = true
```

Explicitly reproduces the OAuth configuration discovered in Azure.

## TLS

```hcl
min_tls_version = "TLS1_2"
```

Explicitly defines TLS 1.2 as the minimum TLS version.

---

# 19. Terraform Configuration — Data Protection

The Terraform implementation included:

```hcl
blob_properties {
  delete_retention_policy {
    days = 7
  }

  container_delete_retention_policy {
    days = 7
  }
}
```

This represents:

```text
Blob retention:
7 days

Container retention:
7 days
```

---

# 20. Terraform Configuration — Tags

Terraform used:

```text
Environment        = Development
Owner              = Cloud Platform Team
Application        = Platform Self Service
BusinessUnit       = Technology
CostCentre         = FIN001
Criticality        = Low
DataClassification = Internal
ManagedBy          = Terraform
```

The key management distinction was:

```text
Portal:
ManagedBy = Portal-Temporary

Terraform:
ManagedBy = Terraform
```

---

# 21. Terraform Formatting

## Command

```bash
terraform -chdir=terraform fmt day13-platform-self-service.tf
```

## What it does

Formats the Terraform file using Terraform's standard formatting rules.

## Why

Consistent formatting makes the configuration easier to read and review.

## Result

```text
day13-platform-self-service.tf
```

---

# 22. Terraform Validation

## Command

```bash
terraform -chdir=terraform validate
```

## What it does

Checks whether the Terraform configuration is syntactically and structurally valid.

## Why

We should validate configuration before deployment.

## Result

```text
Success! The configuration is valid.
```

---

# 23. Terraform Plan

## Command

```bash
terraform -chdir=terraform plan -no-color
```

## What it does

Terraform:

1. refreshes its knowledge of Azure;
2. compares Azure with the Terraform configuration;
3. calculates the proposed changes.

## Why

We review the planned blast radius before applying infrastructure.

## Result

Terraform planned:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

The resource was:

```text
stcontosobj9tf001
```

The plan also showed:

```text
default_to_oauth_authentication = true
shared_access_key_enabled       = false
```

## Meaning

Terraform intended to create exactly one new resource and make no other changes.

---

# 24. OAuth Configuration Investigation

During Portal-to-Terraform comparison, Azure reported:

```text
DefaultToOAuth = true
```

Terraform therefore needed to explicitly represent this configuration.

## Configuration added

```hcl
default_to_oauth_authentication = true
```

## Why

We did not want to rely on an implicit provider default.

We wanted Terraform to explicitly describe the desired Azure configuration.

---

# 25. Terraform Reformat and Validation After OAuth Fix

After adding the OAuth configuration:

## Format

```bash
terraform -chdir=terraform fmt day13-platform-self-service.tf
```

## Validate

```bash
terraform -chdir=terraform validate
```

## Result

```text
Success! The configuration is valid.
```

---

# 26. Terraform Plan After OAuth Fix

## Command

```bash
terraform -chdir=terraform plan -no-color
```

## Result

The plan showed:

```text
default_to_oauth_authentication = true
```

and:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

## Meaning

The OAuth configuration was now explicitly represented in the Terraform deployment plan.

---

# 27. Terraform Apply

## Command

```bash
terraform -chdir=terraform apply
```

## What it does

Unlike `plan`, which only calculates proposed changes, `apply` actually creates or changes Azure infrastructure.

## Result

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Terraform created:

```text
stcontosobj9tf001
```

---

# 28. Azure Verification of Terraform Resource

After Terraform completed, the resulting Azure resource was queried.

## Result

```json
{
  "DefaultToOAuth": true,
  "HTTPS": true,
  "Location": "uksouth",
  "MinTLS": null,
  "Name": "stcontosobj9tf001",
  "PublicNetwork": "Enabled",
  "Replication": "Standard_LRS",
  "SharedKey": false
}
```

## Meaning

Azure confirmed:

```text
DefaultToOAuth = true
HTTPS          = true
SharedKey      = false
Location       = UK South
Replication    = Standard_LRS
PublicNetwork  = Enabled
```

The Terraform deployment therefore resulted in the intended Azure configuration.

---

# 29. Terraform Shared-Key Failure Test

We deliberately attempted a data-plane operation using Shared Key authentication.

## Step 1 — Retrieve the Storage Account key

```bash
TF_STORAGE_KEY=$(az storage account keys list \
  --account-name "stcontosobj9tf001" \
  --resource-group "rg-contoso-finops-lab-uks-001" \
  --subscription "eb1f07b2-12b1-417e-80d0-fe08c2376f5a" \
  --query "[0].value" \
  --output tsv)
```

## What the command does

`az storage account keys list` retrieves the Storage Account keys.

`--account-name` identifies the Storage Account.

`--resource-group` identifies its Resource Group.

`--subscription` identifies the Azure subscription.

`--query "[0].value"` selects the first key value.

`--output tsv` returns the value as plain text.

`$(...)` captures the result.

The value is stored in:

```text
TF_STORAGE_KEY
```

## Why

We needed a credential to perform the controlled negative test.

The key was stored in a shell variable and was not printed.

---

# 30. Shared-Key Data-Plane Test

## Command

```bash
az storage container list \
  --account-name "stcontosobj9tf001" \
  --account-key "$TF_STORAGE_KEY" \
  --output table
```

## What it does

Attempts to list Storage containers using Shared Key authentication.

## Why

We wanted to prove that the Terraform security configuration was enforced by Azure at runtime.

## Expected

Azure should reject the request.

## Actual result

```text
Key based authentication is not permitted on this storage account.
```

with:

```text
ErrorCode:KeyBasedAuthenticationNotPermitted
```

## Conclusion

The security control worked.

The Terraform-created Storage Account rejected Shared Key authentication as intended.

---

# 31. Portal ↔ Terraform ↔ Azure Comparison

| Configuration | Portal | Terraform | Azure Result |
|---|---|---|---|
| Performance | Standard | Standard | Standard |
| Replication | LRS | LRS | Standard_LRS |
| Location | UK South | UK South | uksouth |
| HTTPS | Enabled | true | true |
| Shared Key | Disabled | false | false |
| OAuth/default authorization | Enabled | true | true |
| Anonymous access | Disabled | false | Disabled |
| Minimum TLS | 1.2 | TLS1_2 | Portal confirmed 1.2 |
| Public network | Enabled | true | Enabled |
| Access tier | Hot | Hot | Hot |
| Blob retention | 7 days | 7 days | 7 days |
| Container retention | 7 days | 7 days | 7 days |
| Environment | Development | Development | Development |
| Owner | Cloud Platform Team | Cloud Platform Team | Cloud Platform Team |
| Application | Platform Self Service | Platform Self Service | Platform Self Service |
| BusinessUnit | Technology | Technology | Technology |
| CostCentre | FIN001 | FIN001 | FIN001 |
| Criticality | Low | Low | Low |
| DataClassification | Internal | Internal | Internal |
| ManagedBy | Portal-Temporary | Terraform | Terraform |

## Comparison conclusion

The Terraform implementation reproduced the important Portal configuration while changing the management model from temporary Portal management to Terraform ownership.

---

# 32. Terraform Ownership Check

Before deleting the temporary Portal resource, Terraform state was checked.

## Command

```bash
terraform -chdir=terraform state list | grep 'objective9'
```

## What it does

`terraform state list` lists resources Terraform currently manages.

`grep 'objective9'` filters the output to Objective 9.

## Why

Before manually deleting an Azure resource, we must understand whether Terraform believes it owns that resource.

## Result

```text
azurerm_storage_account.objective9_self_service
```

## Meaning

Terraform manages:

```text
stcontosobj9tf001
```

The Portal-created resource was not present in Terraform state.

Therefore:

```text
Portal resource:
stcontosoobj9portal01
Temporary / not Terraform-managed

Terraform resource:
stcontosobj9tf001
Terraform-managed / retained
```

---

# 33. Temporary Portal Resource Cleanup

The temporary Portal Storage Account had completed its purpose.

Resource:

```text
stcontosoobj9portal01
```

Resource Group:

```text
rg-contoso-finops-lab-uks-001
```

It was deleted.

The Terraform-managed resource:

```text
stcontosobj9tf001
```

was not deleted.

## Why

The Portal resource was the temporary discovery implementation.

The Terraform resource was the retained Infrastructure as Code implementation.

---

# 34. Portal Cleanup Verification

A successful delete action is not enough.

We verified Azure's resulting state.

## Command

```bash
az storage account show \
  --name "stcontosoobj9portal01" \
  --resource-group "rg-contoso-finops-lab-uks-001" \
  --subscription "eb1f07b2-12b1-417e-80d0-fe08c2376f5a" \
  --output json
```

## What it does

Attempts to retrieve the temporary Portal Storage Account.

## Why

We need independent evidence that the resource no longer exists.

## Expected

Azure should return `ResourceNotFound`.

## Actual result

```text
(ResourceNotFound) The Resource 'Microsoft.Storage/storageAccounts/stcontosoobj9portal01' under resource group 'rg-contoso-finops-lab-uks-001' was not found.

Code: ResourceNotFound
```

## Meaning

The temporary Portal Storage Account had been successfully removed.

---

# 35. Final Terraform Drift Check

After cleanup, Terraform was run again.

## Command

```bash
terraform -chdir=terraform plan -no-color
```

## What it does

Terraform refreshes Azure state and compares it with the Terraform configuration.

## Why

We had changed Azure outside Terraform by deleting the temporary Portal resource.

We needed to prove that the deletion did not affect Terraform-managed infrastructure.

## Result

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```

## Meaning

The retained Terraform-managed infrastructure has no drift.

---

# 36. Troubleshooting — JMESPath Query

During the wider governance work, a CLI query produced:

```text
Invalid jmespath query supplied for --query:
Unknown function: tostring()
```

## What happened

The Azure CLI query engine did not support the function used in the query.

## Engineering response

The query was simplified rather than repeatedly adding complexity.

The raw Azure response was inspected to understand the actual values.

## Lesson

When a CLI query fails:

1. simplify the query;
2. retrieve the raw response;
3. inspect the data;
4. add filtering only when necessary.

---

# 37. Troubleshooting — OAuth Configuration Difference

Azure returned:

```text
DefaultToOAuth = true
```

The Terraform implementation initially did not explicitly configure the same value.

## Investigation

The actual Azure configuration was queried.

The Portal configuration was compared with Terraform.

## Fix

We added:

```hcl
default_to_oauth_authentication = true
```

## Verification

We ran:

```bash
terraform -chdir=terraform fmt day13-platform-self-service.tf
```

then:

```bash
terraform -chdir=terraform validate
```

then:

```bash
terraform -chdir=terraform plan -no-color
```

The plan showed:

```text
default_to_oauth_authentication = true
```

## Lesson

Provider defaults should not be assumed to represent the actual desired Azure configuration.

Important configuration should be explicit.

---

# 38. Troubleshooting — Shared-Key Failure

The Shared-Key test returned:

```text
KeyBasedAuthenticationNotPermitted
```

## Was this an error?

Yes technically, but it was an **intentional and successful negative test**.

## Why

We deliberately attempted an authentication method that the Storage Account was configured to reject.

## Expected behaviour

Azure rejects the request.

## Actual behaviour

Azure rejected the request.

## Conclusion

The security control was functioning correctly.

---

# 39. Troubleshooting — Cleanup Verification

After deleting the temporary Portal resource, Azure returned:

```text
ResourceNotFound
```

## Was this an error?

It is an Azure lookup error, but it was the **expected result of the verification test**.

The resource was supposed to be gone.

Therefore:

```text
ResourceNotFound = cleanup successfully verified
```

---

# 40. Production Engineering Lessons

## Configuration is not proof

A Portal setting shows configuration.

Runtime testing provides evidence that the configuration is actually enforced.

## Management plane and data plane are different

Terraform and Azure management commands interact with Azure resource configuration.

The Storage container operation exercised the Storage data plane.

## Terraform state establishes ownership

Before cleanup, Terraform state was checked.

This avoided accidentally deleting Terraform-managed infrastructure.

## Portal and Terraform should be compared

The Portal provided discovery.

Terraform provided repeatability and version control.

Azure verification provided evidence of the resulting state.

## Temporary resources need lifecycle discipline

The Portal resource had a temporary purpose and was removed after the comparison.

## Failure testing is valuable

The Shared-Key rejection demonstrated that a security boundary worked.

## Drift detection is important

The final Terraform plan returned:

```text
No changes.
```

This proved the retained Terraform infrastructure remained aligned with the configuration.

---

# 41. Interview Questions — 10/10 Answers

## Q1. Why did you build the resource in Azure Portal first?

### Model answer

I used the Azure Portal deliberately as a temporary discovery and validation mechanism rather than as the final deployment mechanism.

I wanted to understand the Azure Storage configuration, available security controls and runtime behaviour before reproducing the capability in Terraform.

I then compared the Portal configuration, Terraform configuration and actual Azure state. This allowed me to identify differences, explicitly represent important settings in Terraform and prove that the resulting resource behaved as intended.

---

## Q2. Why did you deliberately cause a failure?

### Model answer

I wanted to prove that the security control was enforced at runtime rather than simply trusting a configuration screen.

Shared Key authentication was disabled, so I deliberately attempted a Storage data-plane operation using a Storage Account key.

Azure returned `KeyBasedAuthenticationNotPermitted`.

That was the expected result and provided runtime evidence that the authentication restriction was actually enforced.

---

## Q3. What did you do when Portal and Terraform did not initially match?

### Model answer

I treated the discrepancy as an engineering investigation rather than ignoring it.

Azure reported OAuth/default authorization as enabled, while Terraform did not initially represent that configuration explicitly.

I queried the actual Azure state, identified the difference and explicitly configured `default_to_oauth_authentication = true`.

I then formatted, validated and replanned the Terraform configuration before deployment.

That ensured the IaC configuration deliberately represented the desired Azure state.

---

## Q4. How did you avoid duplicate infrastructure?

### Model answer

Before implementing Objective 9, I inspected the existing Terraform files and searched for the Portal resource name and Objective 9 identifiers.

This established that the Portal resource was not already represented in Terraform.

I also checked Terraform state before cleanup to establish which resource Terraform actually owned.

---

## Q5. How did you know which resource could safely be deleted?

### Model answer

I checked Terraform state using `terraform state list` and filtered for Objective 9.

The Terraform-created resource appeared as `azurerm_storage_account.objective9_self_service`.

The temporary Portal resource did not appear in Terraform state.

Therefore I knew the Portal resource was the temporary unmanaged implementation and the Terraform resource was the retained implementation.

---

## Q6. Why was ResourceNotFound a successful result?

### Model answer

Because the resource had intentionally been deleted.

The follow-up Azure query was specifically designed to verify that deletion.

Azure returning `ResourceNotFound` proved the temporary Portal resource no longer existed.

I then ran Terraform plan to confirm that the retained Terraform-managed infrastructure was unaffected.

---

## Q7. How did you prove there was no Terraform drift?

### Model answer

After cleanup, I ran Terraform plan again.

Terraform returned:

`No changes. Your infrastructure matches the configuration.`

That demonstrated that the remaining Terraform-managed infrastructure matched the desired configuration and that the deleted Portal resource was not part of Terraform state.

---

## Q8. Why is the Shared-Key error useful evidence?

### Model answer

The error demonstrated enforcement rather than configuration alone.

The Storage Account was configured with Shared Key access disabled.

I then attempted a real data-plane request using Shared Key authentication.

Azure rejected it with `KeyBasedAuthenticationNotPermitted`.

Therefore I had both configuration evidence and runtime enforcement evidence.

---

## Q9. What would you improve in the implementation?

### Model answer

I would improve reuse by replacing hard-coded values such as the Resource Group and location with existing Terraform variables or resource references where appropriate.

I would introduce that improvement through the same controlled engineering lifecycle: change the code, format it, validate it, review the plan, test the result and commit it through Git.

I would not make a refactor to a verified platform implementation without testing the effect of the change.

---

## Q10. What did this exercise demonstrate about platform engineering?

### Model answer

It demonstrated that platform engineering is more than creating an Azure resource.

The complete lifecycle included discovery, design, Infrastructure as Code, security configuration, runtime testing, troubleshooting, ownership verification, cleanup and drift detection.

The important outcome was not simply that a Storage Account existed.

The outcome was that I could explain why it existed, how it was configured, how its security controls behaved, which implementation Terraform owned, how temporary infrastructure was removed and how I proved that the retained infrastructure remained correct.

---

# 42. Objective 9 Evidence Summary

```text
Production requirement                  COMPLETE
Existing platform inspection            COMPLETE
Duplicate-resource check                 COMPLETE
Portal implementation                    COMPLETE
Portal configuration inspection          COMPLETE
Portal manual testing                    COMPLETE
Portal security failure test             COMPLETE
Azure configuration discovery            COMPLETE
Terraform implementation                 COMPLETE
Terraform formatting                     COMPLETE
Terraform validation                     COMPLETE
Terraform plan                           COMPLETE
Terraform apply                          COMPLETE
Azure Terraform verification             COMPLETE
Terraform Shared-Key failure test        COMPLETE
Portal/Terraform/Azure comparison         COMPLETE
OAuth discrepancy investigation          COMPLETE
Terraform ownership check                COMPLETE
Temporary Portal cleanup                 COMPLETE
Cleanup verification                     COMPLETE
Final Terraform drift check              COMPLETE
```

---

# 43. Day 13 Final Architecture

```text
                 Azure Portal
                      │
                      │ Temporary discovery
                      ▼
        ┌─────────────────────────────┐
        │ Temporary Storage Account   │
        │ stcontosoobj9portal01       │
        └─────────────────────────────┘
                      │
                      │ Inspect / test
                      │
                      ▼
             Portal configuration
                      │
                      │ Reproduce as IaC
                      ▼
        ┌─────────────────────────────┐
        │ Terraform configuration     │
        │ day13-platform-self-service │
        └─────────────────────────────┘
                      │
                      │ terraform apply
                      ▼
        ┌─────────────────────────────┐
        │ Retained Azure Storage      │
        │ stcontosobj9tf001           │
        └─────────────────────────────┘
                      │
                      ├── OAuth enabled
                      ├── Shared Key disabled
                      ├── HTTPS enabled
                      ├── TLS 1.2 configured
                      ├── Anonymous access disabled
                      └── 7-day retention
```

The Portal resource was then removed.

The Terraform resource remained.

---

# 44. Git and GitHub Evidence

## Intended Day 13 files

The Day 13 implementation consists of:

```text
terraform/day13-platform-self-service.tf
docs/day13-platform-self-service-runbook.md
```

The existing unrelated file:

```text
docs/naming-standard.md
```

must remain outside the Day 13 commit.

## Git pre-flight before Day 13 commit

The repository showed:

```text
## develop...origin/develop
?? docs/naming-standard.md
?? terraform/day13-platform-self-service.tf
```

The latest completed engineering commit was:

```text
75f322d feat: implement day 12 azure policy governance
```

## Day 13 staging rule

Only these two files belong in the Day 13 commit:

```text
docs/day13-platform-self-service-runbook.md
terraform/day13-platform-self-service.tf
```

The naming-standard file is unrelated existing work and must remain untracked.

## Git completion

The final Git procedure is:

```text
Verify working tree
        ↓
Review Day 13 files
        ↓
Stage only Day 13 files
        ↓
Review staged diff
        ↓
Commit Day 13
        ↓
Push develop
        ↓
Verify origin/develop
        ↓
Verify remote commit
        ↓
Verify remote files
```

The actual Day 13 commit hash must be recorded here only after the commit has actually been created.

The actual GitHub remote result must likewise be recorded only after the push and remote verification have actually been performed.

---

# 45. Day 13 Final Outcome

Day 13 demonstrated a production-style Platform Self-Service Storage capability.

The engineering process was:

```text
Understand the requirement
        ↓
Inspect what already exists
        ↓
Build temporary Portal version
        ↓
Test manually
        ↓
Inspect actual Azure configuration
        ↓
Build Terraform version
        ↓
Validate
        ↓
Plan
        ↓
Apply
        ↓
Verify Azure
        ↓
Deliberately test failure
        ↓
Investigate discrepancy
        ↓
Check Terraform ownership
        ↓
Delete temporary Portal resource
        ↓
Verify deletion
        ↓
Run final Terraform drift check
        ↓
Git / GitHub
```

## Retained resource

```text
stcontosobj9tf001
```

## Terraform implementation

```text
terraform/day13-platform-self-service.tf
```

## Temporary Portal resource

```text
stcontosoobj9portal01
```

## Temporary resource status

```text
Deleted
```

## Cleanup verification

```text
ResourceNotFound
```

## Final Terraform status

```text
No changes. Your infrastructure matches the configuration.
```

---

# 46. Portfolio Evidence Statement

Day 13 can be presented as evidence that the engineer can:

- translate a platform requirement into an Azure capability;
- inspect existing infrastructure before making changes;
- use Azure Portal for discovery;
- reproduce an Azure capability through Terraform;
- explicitly configure security controls;
- validate and review Terraform changes;
- verify actual Azure state;
- conduct deliberate negative testing;
- investigate configuration discrepancies;
- understand Terraform state and resource ownership;
- safely remove temporary infrastructure;
- verify cleanup;
- detect and confirm absence of Terraform drift;
- document the implementation;
- deliver the resulting engineering work through Git and GitHub.

The strongest evidence from this exercise is the combination of:

```text
Portal configuration
        +
Terraform configuration
        +
Azure verification
        +
Runtime failure testing
        +
Ownership verification
        +
Cleanup verification
        +
Terraform drift verification
```

This demonstrates an engineering lifecycle rather than simply showing that an Azure resource was created.

---

# 47. Commands Used During Day 13

For quick practice, the principal commands used were:

```bash
find terraform -maxdepth 1 -type f -name '*.tf' -printf '%f\n' | sort
```

```bash
grep -R -n \
  -E 'stcontosoobj9portal01|obj9portal|Platform Self Service' \
  terraform --include='*.tf' || true
```

```bash
terraform -chdir=terraform fmt day13-platform-self-service.tf
```

```bash
terraform -chdir=terraform validate
```

```bash
terraform -chdir=terraform plan -no-color
```

```bash
terraform -chdir=terraform apply
```

```bash
terraform -chdir=terraform state list | grep 'objective9'
```

```bash
az storage container list \
  --account-name "stcontosobj9tf001" \
  --account-key "$TF_STORAGE_KEY" \
  --output table
```

```bash
az storage account show \
  --name "stcontosoobj9portal01" \
  --resource-group "rg-contoso-finops-lab-uks-001" \
  --subscription "eb1f07b2-12b1-417e-80d0-fe08c2376f5a" \
  --output json
```

```bash
terraform -chdir=terraform plan -no-color
```

---

# 48. Quick Practice Checklist

When repeating this exercise independently:

```text
[ ] Read production requirement
[ ] Inspect existing Terraform
[ ] Check for duplicate implementation
[ ] Create temporary Portal resource
[ ] Configure Portal
[ ] Test Portal configuration
[ ] Verify actual Azure state
[ ] Create Terraform implementation
[ ] Format Terraform
[ ] Validate Terraform
[ ] Review Terraform plan
[ ] Apply Terraform
[ ] Verify Azure
[ ] Perform deliberate negative test
[ ] Investigate failures
[ ] Compare Portal ↔ Terraform ↔ Azure
[ ] Check Terraform state ownership
[ ] Delete temporary Portal resource
[ ] Verify deletion
[ ] Run Terraform plan
[ ] Confirm no drift
[ ] Review Git changes
[ ] Stage only Day 13 files
[ ] Commit
[ ] Push
[ ] Verify GitHub
[ ] Record final evidence
```

---

# 49. Day 13 Status

## Engineering implementation

**COMPLETE**

## Azure Portal discovery

**COMPLETE**

## Terraform implementation

**COMPLETE**

## Security testing

**COMPLETE**

## Troubleshooting

**COMPLETE**

## Temporary resource cleanup

**COMPLETE**

## Terraform drift verification

**COMPLETE**

## Documentation

**THIS DOCUMENT**

## Git/GitHub

**FINAL COMMIT/PUSH/REMOTE VERIFICATION TO BE RECORDED AFTER EXECUTION**

---

# 50. Day 13 Close-Out

The technical objective of Day 13 has been completed.

The remaining repository activity is deliberately separated from the engineering implementation:

```text
Day 13 engineering
        ↓
Documentation
        ↓
Git review
        ↓
Commit
        ↓
GitHub push
        ↓
Remote verification
        ↓
Portfolio evidence complete
        ↓
Week 14
```