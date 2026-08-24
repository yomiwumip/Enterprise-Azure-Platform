# Day 10 — Azure FinOps Engineering Runbook

## 1. Objective

Implement and investigate production-style Azure FinOps controls covering:

- Cost allocation
- Shared platform costs
- Direct and indirect cost concepts
- Showback and chargeback
- Ownership and tagging
- Cost Management
- Budgets
- Cost exports
- Storage lifecycle optimisation
- Cost-query automation
- Advanced FinOps investigation
- Engineering trade-offs

The implementation was performed against the Azure FinOps lab platform and validated using Azure Portal, Azure CLI, and Terraform repository state.

---

## 2. Platform Resources Investigated

Primary Resource Group:

`rg-contoso-finops-lab-uks-001`

Resources observed:

- `vnet-contoso-finops-uks-001`
- `stcontosofinportal001`
- `pe-contoso-finops-blob-uks-001`
- Private DNS zone `privatelink.blob.core.windows.net`
- Private DNS virtual network link

The Storage Account was configured as:

- Kind: `StorageV2`
- SKU: `Standard_LRS`
- Location: `uksouth`
- Access tier: `Hot`

---

## 3. Cost Allocation

A Cost Management allocation rule was created for shared platform costs allocated to Finance.

The platform uses governance tags including:

- `Owner`
- `BusinessUnit`
- `CostCentre`
- `Application`
- `Environment`
- `Project`

Example Finance ownership:

- BusinessUnit: `Finance`
- CostCentre: `FIN001`
- Application: `FinOpsLab`
- Environment: `finops-lab`
- Project: `contoso`

These dimensions support cost attribution and accountability.

---

## 4. Budget Configuration

A monthly Azure budget was configured:

- Budget name: `contoso-finops-lab-monthly-budget`
- Amount: `£10`
- Time grain: Monthly
- Actual-cost alert: Greater than 80%
- Forecast alert: Greater than 100%

The budget was subsequently verified programmatically with Azure CLI.

Observed current spend during the exercise:

`£0.2627772694286686`

Approximate budget utilisation:

`2.63%`

---

## 5. Cost Management Export

A Cost Management export was created:

`contoso-finops-costallocation-actual-cost`

Configuration:

- Dataset: Cost and usage details (actual)
- Frequency: Daily
- Scope: FinOps platform
- Destination: Azure Blob Storage
- Storage account: `stcontosofinportal001`
- Container: `costexports`
- Directory: `finops`
- Format: CSV
- Compression: Gzip
- File partitioning: Enabled
- Overwrite: Enabled

The export was successfully queued by Azure.

The first dataset was not expected to be immediately available because Azure indicated that the export could take up to a day.

---

## 6. Storage Lifecycle Optimisation

The Storage Account initially had no management policy.

A lifecycle policy was implemented for cost-export data:

- Rule: `finops-cost-export-lifecycle`
- Blob type: `blockBlob`
- Prefix: `costexports/finops/`
- Action: Move blobs to Cool tier after 30 days

The policy was successfully created and verified through Azure.

This demonstrates a cost optimisation mechanism that does not require weakening the platform's private networking architecture.

---

## 7. Cost Analysis Baseline

Azure Cost Analysis was used as the authoritative manual cost baseline.

Observed month-to-date resource cost:

- Private Endpoint: approximately `£0.25`
- Private DNS zone: approximately `£0.02`
- Storage Account: less than `£0.01`
- Total: approximately `£0.26`

The Private Endpoint therefore represented approximately 96% of observed platform spend.

This was investigated rather than automatically treated as an anomaly.

---

## 8. Cost Query Automation Investigation

Several interfaces were tested.

### Azure CLI Consumption

The installed Azure CLI version was:

`2.71.0`

`az consumption usage list` was available, but the usage operation repeatedly failed with:

`KeyError: 'usageStart'`

The failure occurred inside the Azure CLI Consumption response transformation.

The raw-output attempt also produced an empty file.

### Cost Management CLI Extension

The Cost Management extension was installed and verified:

- Extension: `costmanagement`
- Version: `1.0.0`

The extension exposed Cost Management export commands:

- `create`
- `delete`
- `list`
- `show`
- `update`

The extension did not expose a direct cost query command in the installed version.

### Cost Management REST API

A direct Cost Management REST query was attempted.

Azure returned:

`429 Too Many Requests`

The request was not repeatedly hammered after the throttling response.

### Export verification

The Cost Management export was successfully configured through the Portal, but the installed CLI extension did not successfully discover the Portal-created export at the queried Resource Group scope.

No duplicate export was created.

### Engineering conclusion

Cost Analysis is the validated interactive cost-analysis interface. Cost Management Export is the validated configured reporting mechanism; the first scheduled dataset had not yet become available during the exercise.

The CLI limitations and API throttling were documented rather than bypassed by weakening security or repeatedly retrying a throttled API.

---

## 9. Storage Network Security Investigation

The Storage Account network rule set was inspected.

Observed configuration:

- `bypass`: `AzureServices`
- `defaultAction`: `Deny`
- No IP rules
- No virtual network rules

A local blob-list operation was blocked by the Storage Account network rules.

This was expected because the laptop is outside the Azure VNet.

DNS investigation showed the laptop resolving the Blob endpoint to a public IP:

`20.209.240.129`

The architecture instead provides a Private Endpoint and Private DNS path for clients operating inside the Azure network.

This demonstrated the distinction between:

- Azure management-plane access
- Storage data-plane access
- Private Endpoint connectivity
- Private DNS resolution
- Storage network controls

The Storage Account was not opened to public access merely to make the laptop test succeed.

---

# 10. Advanced FinOps Investigation

## 10.1 Cost anomaly investigation

The largest cost driver was identified as the Standard Private Endpoint.

The resource cost was approximately:

`£0.25`

against approximately:

`£0.26`

total observed spend.

The Private Endpoint was investigated in Cost Analysis and confirmed to be a Standard Private Endpoint meter.

The cost was determined to be an expected architectural cost rather than unexplained spend.

The endpoint exists to provide private connectivity to Blob Storage.

---

## 10.2 Forecast variance

Azure Cost Analysis displayed no forecast for the lab.

This was not artificially manufactured by generating unnecessary usage.

The environment therefore did not provide enough forecast data to calculate an actual forecast variance during the exercise.

The production lesson is that forecast variance becomes more useful as sufficient historical consumption accumulates. In production, actual spend would be compared with the projected month-end spend and the resulting variance investigated.

---

## 10.3 Cost allocation models

A Cost Management allocation rule was created for shared platform costs allocated to Finance.

Governance tags were also used to provide ownership and attribution dimensions including:

- Business Unit
- Cost Centre
- Application
- Environment
- Project
- Owner

The allocation rule and tagging model provide the basis for shared-cost attribution and accountability.

---

## 10.4 Unit cost

The platform contains one Private Endpoint protecting one Blob Storage endpoint.

Observed cost:

`£0.26`

Observed infrastructure unit:

`1 protected Blob Storage endpoint`

Observed lab infrastructure unit cost:

`£0.26 per protected Blob Storage endpoint`

This is explicitly treated as a lab infrastructure metric rather than a production business KPI.

Production platforms should use business-relevant denominators such as:

- cost per transaction
- cost per workload
- cost per GB processed
- cost per customer
- cost per active user

depending on the service.

---

## 10.5 Engineering trade-offs

Cost decisions were evaluated against architectural requirements rather than optimising cost in isolation.

The Private Endpoint introduces recurring cost but provides private connectivity to Blob Storage.

The decision was therefore to retain the private connectivity architecture rather than remove a security control simply to save a small amount of money.

---

## 10.6 Reliability vs cost

The platform deliberately retains private connectivity and controlled networking rather than selecting the cheapest possible public-access architecture.

This represents a reliability/security architecture decision with an associated infrastructure cost.

---

## 10.7 Security vs cost

The Storage Account uses:

- Private Endpoint
- Private DNS
- Default network action: Deny
- Azure services bypass

The recurring Private Endpoint cost was accepted as part of the security architecture.

---

## 10.8 Performance vs cost

The Storage Account uses:

- `StorageV2`
- `Standard_LRS`
- `Hot` access tier

The FinOps workload does not currently demonstrate a requirement for premium storage performance.

The selected configuration therefore avoids paying for higher performance or replication without demonstrated business benefit.

This demonstrates the principle:

> Use sufficient performance for the workload rather than maximum available performance.

---

# 11. Key Engineering Lessons

1. Cost driver does not automatically mean cost anomaly.
2. Budget threshold and anomaly detection answer different questions.
3. Cost allocation requires meaningful ownership dimensions.
4. Unit-cost metrics require a defensible denominator.
5. Security controls have financial consequences.
6. Private networking introduces recurring infrastructure cost.
7. Cost optimisation should not automatically weaken security.
8. Azure Portal, Azure CLI, Terraform and APIs serve different engineering purposes.
9. Management-plane access and data-plane access are different.
10. CLI/API failures should be investigated rather than hidden.
11. A throttled API should not be hammered with repeated requests.
12. Production automation should use reliable supported interfaces.
13. A lab should not manufacture usage merely to produce a forecast.
14. Infrastructure decisions should balance cost, security, reliability and performance.

---

# 12. Day 10 Outcome

The FinOps platform now demonstrates:

- Cost allocation
- Budget control
- Cost export
- Storage lifecycle optimisation
- Governance tagging
- Cost investigation
- Cost-query troubleshooting
- Advanced FinOps analysis
- Security/cost trade-offs
- Performance/cost trade-offs
- Operational troubleshooting

The implementation intentionally records both successful outcomes and tooling limitations encountered during the exercise.

---

# 11. Portal vs Terraform vs Azure Comparison

The temporary FinOps implementation created through the Azure Portal was compared with the existing Terraform-managed platform before making any Terraform changes.

## Portal-created FinOps resource

- Storage Account: `stcontosofinportal001`
- Resource Group: `rg-contoso-finops-lab-uks-001`
- SKU: `Standard_LRS`
- Kind: `StorageV2`
- Access tier: `Hot`
- Public network access: `Disabled`
- Private Endpoint: Present
- Private DNS zone: Present
- Lifecycle policy: Present
- Cost Management budget/export configuration: Present

## Existing Terraform-managed platform resource

- Storage Account: `stcontosogovtf001`
- Resource Group: `rg-contoso-platform-prod-uks-001`
- SKU: `Standard_LRS`
- Kind: `StorageV2`
- Access tier: `Hot`
- Public network access: `Enabled`
- Private Endpoint: Not represented in the existing Terraform storage resource
- Lifecycle management policy: Not represented in the existing Terraform configuration
- Cost Management budget/export configuration: Not represented in the existing Terraform configuration

## Terraform validation

The existing Terraform state contained:

- `azurerm_resource_group.platform`
- `azurerm_management_lock.platform_resource_group`
- `azurerm_storage_account.platform`

Terraform was refreshed and a plan was executed.

Result:

`No changes. Your infrastructure matches the configuration.`

This confirmed that the existing Terraform-managed platform was healthy and that the temporary Portal FinOps resources were not Terraform drift.

## Engineering conclusion

The Portal FinOps implementation and the existing Terraform platform are separate resources with different purposes.

Terraform parity for the temporary FinOps implementation was therefore **not claimed as complete**.

The comparison identified the next potential engineering step: recreate the required FinOps capabilities in Terraform, validate them, and then remove the temporary Portal implementation.

This deliberate separation avoided importing or modifying an existing Terraform-managed resource without first establishing the correct ownership model.
