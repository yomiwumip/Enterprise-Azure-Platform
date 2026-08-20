# Azure Resource Manager Engineering

## Purpose

This document records the Week 2 Day 8 investigation into Azure Resource Manager (ARM) using the Contoso Azure platform environment.

The objective is to understand how Azure resources are managed through the Azure management plane and how Infrastructure as Code (Terraform) relates to Azure Resource Manager, Resource Providers, resource metadata, resource IDs, deployment history, activity logging, and resource dependencies.

---

## 1. Azure Resource Manager Architecture

The management flow investigated during this exercise is:

Engineer
↓
Azure Portal / CLI / Terraform
↓
Azure Resource Manager
↓
Azure Resource Provider
↓
Azure Resource

Azure Resource Manager is the management layer through which Azure resource management operations are handled.

This provides a common management model for Azure resources and supports standardisation, automation, governance, auditability, and repeatability.

---

## 2. Resource Providers

Azure resources are associated with Resource Providers.

Examples investigated from the Azure subscription:

- Microsoft.Compute
- Microsoft.Network
- Microsoft.Storage
- Microsoft.KeyVault

The following Resource Providers were verified as Registered in the Contoso subscription:

| Resource Provider | Status |
|---|---|
| Microsoft.Compute | Registered |
| Microsoft.Network | Registered |
| Microsoft.Storage | Registered |
| Microsoft.KeyVault | Registered |

The Contoso Resource Group itself reported the resource type:

`Microsoft.Resources/resourceGroups`

This demonstrates the relationship between a Resource Provider and the resource types it manages.

Important distinction:

Resource Provider registration does not mean that resources of that type currently exist. It means the subscription has the provider registered and available for resource-management operations.

---

## 3. Resource ID

The Contoso platform Resource Group has the following Azure Resource ID structure:

`/subscriptions/<subscription-id>/resourceGroups/rg-contoso-platform-prod-uks-001`

The Resource ID uniquely identifies the resource within the Azure management hierarchy.

Azure Resource IDs are important for:

- Resource identification
- RBAC scope
- Policy scope
- Automation
- Terraform state
- API-driven management
- Troubleshooting

The management lock has a more specific Resource ID:

`/subscriptions/<subscription-id>/resourceGroups/rg-contoso-platform-prod-uks-001/providers/Microsoft.Authorization/locks/platform-resource-group-cannot-delete`

This demonstrates how Azure Resource IDs can represent resources and child resources within the Azure hierarchy.

---

## 4. Resource Metadata

The Resource Group was inspected through Azure Portal JSON View.

Observed metadata included:

- Name: `rg-contoso-platform-prod-uks-001`
- Type: `Microsoft.Resources/resourceGroups`
- Location: `uksouth`
- Provisioning state: `Succeeded`

The Resource Group also contained governance tags:

| Tag | Value |
|---|---|
| Application | Platform |
| CostCentre | IT001 |
| Environment | prod |
| ManagedBy | Terraform |
| Owner | Cloud Platform Engineering |
| Project | contoso |

The metadata demonstrates how Azure resources expose management information that can be used by engineering, governance, automation, operations, and reporting processes.

---

## 5. Deployment History Investigation

The Resource Group Deployment History was inspected.

Result:

`No deployments`

This was recorded rather than creating an artificial deployment simply to populate the deployment history.

Deployment history therefore forms one part of the Azure management investigation, but the absence of deployment records does not mean that the Resource Group does not exist or is unmanaged.

---

## 6. Activity Log Investigation

The Resource Group Activity Log was inspected using:

- Last 6 hours
- Last 30 days

Result:

`No events`

This demonstrated the importance of understanding the scope of an audit query. An Activity Log result is dependent on the selected filters and time period.

No Azure changes were made simply to generate Activity Log events.

---

## 7. Terraform and Azure Resource Manager

The Contoso platform foundation is managed using Terraform.

The Terraform configuration contains:

`azurerm_resource_group.platform`

and:

`azurerm_management_lock.platform_resource_group`

The management flow is:

Terraform
↓
AzureRM Provider
↓
Azure management APIs / Azure Resource Manager
↓
Azure Resource Provider
↓
Azure Resource

Terraform therefore provides the Infrastructure as Code layer while Azure Resource Manager provides the Azure management-plane interface.

---

## 8. Terraform Configuration

The Resource Group is defined using:

- A generated enterprise naming convention
- A configured Azure location
- Common governance tags

The naming pattern is generated from Terraform variables:

`rg-${project_name}-${workload}-${environment}-${region_code}-${resource_number}`

This produced:

`rg-contoso-platform-prod-uks-001`

The Terraform configuration also defines the management lock:

`azurerm_management_lock.platform_resource_group`

with:

`lock_level = "CanNotDelete"`

---

## 9. Terraform State Verification

Terraform state was inspected using:

`terraform -chdir=terraform state list`

The state contains:

- `azurerm_resource_group.platform`
- `azurerm_management_lock.platform_resource_group`

The Resource Group state was then inspected.

The Terraform state showed the same:

- Resource ID
- Resource name
- Location
- Governance tags

as the Azure Portal JSON representation.

This provided evidence that the Terraform state and Azure Resource Group representation were aligned at the time of investigation.

---

## 10. Resource Dependencies

The management lock depends on the Resource Group because its scope references the Resource Group ID:

`scope = azurerm_resource_group.platform.id`

This creates the logical relationship:

Resource Group
↓
Resource ID
↓
Management Lock
↓
CanNotDelete protection

The lock therefore protects the Resource Group represented by the Resource Group resource ID.

---

## 11. Operational Safety

The Contoso platform Resource Group has a `CanNotDelete` management lock.

The lock is named:

`platform-resource-group-cannot-delete`

Its purpose is:

`Protects the platform Resource Group from accidental deletion.`

This demonstrates how Azure resource management controls can provide an additional operational safety mechanism for important platform resources.

Resource locks will be examined in greater depth during the Week 2 Operational Safety objective.

---

## 12. Enterprise Engineering Perspective

Azure Resource Manager provides a consistent management model that supports:

- Standardisation
- Automation
- Governance
- Auditability
- Repeatability

In an enterprise environment, Cloud Engineers need to understand the management plane rather than treating the Azure Portal as the whole platform.

The same Azure environment can be managed through different interfaces, including:

- Azure Portal
- Azure CLI
- PowerShell
- Terraform
- Azure APIs

These management interfaces ultimately interact with Azure's management plane and resource providers.

---

## 13. Production Troubleshooting Model

When investigating an Azure infrastructure problem, an engineer should be able to reason across multiple layers:

Desired configuration
↓
Terraform state
↓
Azure Resource Manager
↓
Resource Provider
↓
Azure resource

If these layers disagree, further investigation may be required for configuration drift, state problems, failed operations, or changes made outside the normal Infrastructure as Code workflow.

The Contoso investigation found alignment between the Terraform state and the Azure Resource Group metadata.

---

## 14. Contoso Environment Findings

During this investigation:

- The Resource Group exists in UK South.
- The Resource Group contains no child resources at the time of inspection.
- ARM JSON metadata was successfully inspected.
- The Resource Group provisioning state is `Succeeded`.
- No deployment records were displayed.
- No Activity Log events were displayed for the selected six-hour and 30-day periods.
- Microsoft.Compute is Registered.
- Microsoft.Network is Registered.
- Microsoft.Storage is Registered.
- Microsoft.KeyVault is Registered.
- Terraform manages the Resource Group.
- Terraform manages the Resource Group's `CanNotDelete` management lock.
- Terraform state and Azure Resource Group metadata were aligned during the investigation.

---

## 15. Engineering Takeaway

The key lesson from Day 8 is that Azure Resource Manager should be understood as the management layer underneath the tools engineers use to operate Azure.

A Cloud Engineer should be able to trace:

Engineer
↓
Terraform / Portal / CLI
↓
Azure Resource Manager
↓
Resource Provider
↓
Azure Resource

and use Resource IDs, metadata, state, deployment information, Activity Logs, and resource relationships to understand and troubleshoot the environment.

This investigation provides the foundation for the remaining Week 2 governance objectives:

- Resource organisation
- Enterprise naming
- Tagging
- RBAC
- Azure Policy
- Resource protection
- FinOps
- Platform engineering
- Governance automation
