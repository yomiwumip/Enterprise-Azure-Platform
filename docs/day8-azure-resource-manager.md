# Day 8 — Azure Resource Manager Engineering

## Complete Cloud Platform Engineer Runbook

**Contoso Holdings — Enterprise Azure Platform**  
**Cloud Platform Engineer Residency — Week 2 / Sprint 2**

# How to Use This Runbook

This is the full practice version of Day 8. It combines the engineering
narrative, the actual investigation performed against the existing
Contoso Azure/Terraform environment, the commands used, what each
command means, observed results, false starts/errors, validation, Git
delivery, production interpretation, and interview-ready explanations.

Important: this runbook records what was actually observed. Where an
interpretation goes beyond direct observation, it is labelled as
engineering interpretation rather than presented as an observed fact.

# 1. Purpose

Day 8 introduces Azure Resource Manager (ARM) engineering and
establishes an understanding of how Azure resources are managed through
the Azure management plane. Day 7 established repeatable platform
diagnostics; Day 8 moves one level deeper into the management
architecture underneath those diagnostics.

The operational question for Day 8 is:

How does an engineer understand, manage and troubleshoot the Azure
resources and management operations underneath the platform?

The investigation used the existing Terraform-managed Contoso platform
environment rather than creating a separate lab. This kept the exercise
production-style: inspect first, collect evidence, avoid unnecessary
changes, document the result, and deliver the documentation through Git
and a pull request.

# 2. Day 8 Engineering Objective

The objective was to understand the Azure management plane and the
relationship between Terraform, the AzureRM provider, Azure Resource
Manager, Azure Resource Providers, Azure resources, Terraform state,
resource metadata, deployment history, Activity Log information,
dependencies and management locks.

Day 6 Platform Health \| v Day 7 Platform Operations & Diagnostics \| v
Day 8 Azure Resource Manager Engineering \| v Understand how Azure
resources are managed, identified, governed and troubleshot

# 3. Production Environment Baseline

The existing Azure Resource Group investigated was:

rg-contoso-platform-prod-uks-001

Observed Azure metadata:

-   Type: Microsoft.Resources/resourceGroups

-   Location: uksouth / UK South

-   Provisioning state: Succeeded

-   Application: Platform

-   CostCentre: IT001

-   Environment: prod

-   ManagedBy: Terraform

-   Owner: Cloud Platform Engineering

-   Project: contoso

The subscription overview also showed no active resources producing
usage data at the time of inspection. The Resource Group itself was the
Terraform-managed platform foundation visible in the investigation.

# 4. ARM Management-Plane Mental Model

Cloud Engineer \| +------------------------------+ \| \| \| Terraform
Azure CLI Azure Portal \| \| \| +--------------+---------------+ \| v
Azure Resource Manager \| v Resource Provider \| v Azure Resource

ARM is the management layer through which Azure resources are managed. A
Cloud Engineer should understand that the Portal is an interface to
Azure rather than the whole platform. Terraform, CLI and Portal actions
ultimately operate through Azure's management interfaces and the
appropriate resource provider.

# 5. Terraform-to-Azure Relationship

The configured provider was inspected with:

cat terraform/providers.tf

Observed configuration:

provider "azurerm" { features {} }

The AzureRM Terraform provider is the interface Terraform uses to manage
Azure resources. Terraform configuration describes desired
infrastructure; the provider communicates the required management
operations to Azure.

Terraform configuration \| v AzureRM Terraform provider \| v Azure
management APIs \| v Azure Resource Manager \| v Resource Provider \| v
Azure Resource

# 6. Existing Terraform Configuration

The Resource Group declaration was inspected with:

cat terraform/main.tf

resource "azurerm_resource_group" "platform" { name =
local.resource_group_name location = var.location tags =
local.common_tags }

The Terraform address is:

azurerm_resource_group.platform

The naming and common tags were inspected with:

cat terraform/locals.tf

resource_group_name =
"rg-${var.project_name}-${var.workload}-${var.environment}-${var.region_code}-\${var.resource_number}"

common_tags = { Environment = var.environment Project = var.project_name
Owner = var.owner CostCentre = var.cost_centre Application =
var.application ManagedBy = "Terraform" }

This shows why the Azure Resource Group name and tags are repeatable
rather than arbitrary. The configuration generates resource identity and
governance metadata from defined inputs.

# 7. Resource IDs and Hierarchy

The Resource Group Resource ID followed the Azure hierarchy of
subscription and resource group:

/subscriptions/`<subscription-id>`{=html}/resourceGroups/rg-contoso-platform-prod-uks-001

The management lock state exposed a deeper hierarchy:

/subscriptions/`<subscription-id>`{=html}/resourceGroups/rg-contoso-platform-prod-uks-001/providers/Microsoft.Authorization/locks/platform-resource-group-cannot-delete

Subscription \| v Resource Group \| v Resource Provider \| v Resource
Type \| v Resource Name

Resource IDs matter in production automation because they provide
precise references used for scope, policy, permissions, Terraform state,
API operations and troubleshooting.

# 8. Resource Providers and Registration

The Azure subscription's Resource Providers blade was inspected. The
following providers were verified as Registered:

-   Microsoft.Compute

-   Microsoft.Network

-   Microsoft.Storage

-   Microsoft.KeyVault

The investigation did not register or unregister providers. The exercise
was observational. A key distinction is that provider registration does
not prove that resources of that provider currently exist.

# 9. Resource Group Investigation

The Resource Group was inspected through Azure Portal and JSON View. The
observed values were:

-   Name: rg-contoso-platform-prod-uks-001

-   Type: Microsoft.Resources/resourceGroups

-   Location: uksouth

-   Provisioning state: Succeeded

-   Governance tags matched the Terraform configuration.

The investigation therefore established alignment between the Azure
resource representation and the Terraform configuration for the
attributes inspected.

# 10. Deployment History Investigation

The Resource Group's Deployments view was inspected.

Observed result: No deployments

This means no deployment records were displayed in the investigated
view. It should not be overstated as proof that the Resource Group has
never been created or managed. A production engineer interprets the
result within the scope and filters used.

# 11. Activity Log Investigation

The Resource Group Activity Log was initially checked for the last six
hours with all event severities selected. The result was no events to
display.

Scope: Resource group = rg-contoso-platform-prod-uks-001 Timespan = Last
6 hours Event severity = All

Observed: No events to display

The investigation was then widened to the last 30 days and still
returned no events in the selected scope.

Timespan = Last 30 days Observed = No events

The correct engineering interpretation is not 'nothing has ever
happened'. It is 'no matching Activity Log events were visible within
the investigated resource scope and time period.'

# 12. Terraform State Investigation

The Terraform state resources were listed with:

terraform -chdir=terraform state list

Observed:

azurerm_management_lock.platform_resource_group
azurerm_resource_group.platform

This established that Terraform's current state tracks the Resource
Group and the management lock.

# 13. Resource Group State Inspection

terraform -chdir=terraform state show azurerm_resource_group.platform

The state showed the Resource Group ID, name, location and governance
tags. These values were compared against the Azure Resource Group
metadata and found to be aligned for the inspected fields.

# 14. Management Lock and Dependency

The Terraform configuration included:

resource "azurerm_management_lock" "platform_resource_group" { name =
"platform-resource-group-cannot-delete" scope =
azurerm_resource_group.platform.id lock_level = "CanNotDelete" notes =
"Protects the platform Resource Group from accidental deletion." }

The lock state was inspected with:

terraform -chdir=terraform state show
azurerm_management_lock.platform_resource_group

Observed:

-   Lock name: platform-resource-group-cannot-delete

-   Lock level: CanNotDelete

-   Scope: the Contoso platform Resource Group

The expression scope = azurerm_resource_group.platform.id explicitly
connects the lock to the Resource Group. This is a Terraform dependency
and an example of operational protection represented as code.

# 15. Desired State, Recorded State and Actual State

Desired state Terraform configuration \| v Recorded managed state
Terraform state \| v Actual cloud state Azure

A production engineer must be able to compare these layers. Differences
may indicate drift, out-of-band changes, incorrect configuration, state
problems or incomplete changes. Day 8 did not identify a discrepancy in
the inspected Resource Group attributes.

# 16. Production Troubleshooting Workflow

1.  Identify the subscription and Resource Group.

2.  Obtain the Resource ID.

3.  Identify the resource type and Resource Provider.

4.  Inspect provisioning state and metadata.

5.  Inspect deployment history where relevant.

6.  Inspect Activity Log with a deliberate scope and time window.

7.  Inspect Terraform configuration.

8.  Inspect Terraform state.

9.  Compare desired, recorded and actual state.

10. Check resource dependencies and protection.

11. Only then determine the safest remediation.

The key principle is inspect before changing. Evidence collection
reduces the risk of making an unnecessary production change.

# 17. Actual Errors, False Starts and What They Taught Us

## 17.1 Incorrect placeholder cd command

\$ cd `<your-Enterprise-Azure-Platform-path>`{=html} bash: syntax error
near unexpected token \`newline'

Cause: angle brackets were used as literal shell input instead of being
replaced with the real path. In shell instructions, \<...\> normally
denotes a placeholder. The repository was already open in the correct
directory, so the command was unnecessary.

Lesson: never paste placeholder syntax literally. Replace placeholders
with real values, or skip the command when the current working directory
is already correct.

## 17.2 Unrelated working-tree changes

git status

Changes not staged for commit: modified: .gitignore

Untracked files: .vscode/ docs/naming-standard.md

These files were deliberately left out of the Day 8 documentation
commit. This demonstrated selective staging and change isolation.

## 17.3 No deployment records

Deployments -\> No deployments

This was not treated as an error requiring an artificial deployment. We
preserved the environment and documented the observed evidence.

## 17.4 No Activity Log events

Activity Log -\> No events

This was investigated with different time windows rather than
immediately assuming there was no historical activity. The lesson is to
validate scope, time and filters before drawing conclusions.

## 17.5 Repository documentation first-pass was too compressed

The first Day 8 document was successfully committed and merged, but it
did not yet meet the same full-runbook standard as Day 7. The
engineering response is to improve the existing document rather than
create a duplicate document. This is a documentation quality
improvement, not an infrastructure rollback.

# 18. Commands --- What Each One Means

ls -la terraform

Meaning: Lists the Terraform directory, including hidden files. Used to
understand the existing project before changing anything.

find terraform -maxdepth 2 -type f

Meaning: Finds files within the Terraform directory to establish the
existing configuration/state structure.

cat terraform/main.tf

Meaning: Prints the Terraform resource declarations so the engineer can
understand what is managed.

cat terraform/providers.tf

Meaning: Prints the Terraform provider configuration.

cat terraform/locals.tf

Meaning: Prints naming and common-tag logic.

terraform -chdir=terraform state list

Meaning: Lists resources currently tracked in Terraform state without
changing infrastructure.

terraform -chdir=terraform state show azurerm_resource_group.platform

Meaning: Displays Terraform's recorded attributes for the Resource
Group.

terraform -chdir=terraform state show
azurerm_management_lock.platform_resource_group

Meaning: Displays Terraform's recorded attributes for the management
lock.

git status

Meaning: Shows the branch, upstream relationship, staged changes,
unstaged changes and untracked files.

git diff --no-index /dev/null docs/azure-resource-manager.md

Meaning: Reviews an untracked file as a new-file diff.

git add docs/azure-resource-manager.md

Meaning: Stages only the intended Day 8 documentation file.

git commit -m "docs: document Azure Resource Manager engineering"

Meaning: Creates a Git checkpoint containing the staged documentation.

git push origin develop

Meaning: Publishes the development branch commit to GitHub.

git fetch origin

Meaning: Refreshes remote branch information without changing working
files.

git log --oneline -5 origin/main

Meaning: Shows recent commits on the remote main branch.

git ls-tree -r --name-only origin/main \| grep
'\^docs/azure-resource-manager.md\$'

Meaning: Verifies that the documentation file exists in the remote main
branch.

# 19. Git Delivery and Pull Request Evidence

Commit: a53e526 docs: document Azure Resource Manager engineering

Pull Request: #11

Flow: develop -\> main

Merge commit observed on origin/main: df25003 Merge pull request #11
from yomiwumip/develop

The final verification confirmed that origin/main contained
docs/azure-resource-manager.md. The PR was reviewed for title,
description, changed files and mergeability before merging.

# 20. Production Engineering Interpretation

The deeper lesson is that Azure platform engineering is not just Portal
navigation. The engineer must reason across configuration, state, Azure
management APIs, Resource Providers, resources, audit evidence and
safety controls.

Engineer \| v Terraform / Portal / CLI \| v Azure Resource Manager \| v
Resource Provider \| v Azure Resource

And:

Terraform Configuration \| v Terraform State \| v Actual Azure State

# 21. Portfolio Outcome

This Day 8 work demonstrates practical ability to investigate an
existing Azure management environment, understand Terraform's
relationship with Azure, inspect state and metadata, investigate
audit/deployment views, reason about resource dependencies and
protection, document evidence, and deliver the result through a Git
pull-request workflow.

# 22. Interview-Ready Summary

During Week 2, I investigated Azure Resource Manager against an existing
Terraform-managed platform rather than creating a separate lab. I traced
the relationship between Terraform configuration, the AzureRM provider,
Azure Resource Manager, Resource Providers and the actual Resource
Group. I verified the Resource Group's identity, location, provisioning
state and governance tags, checked provider registration, investigated
deployment history and Activity Log scope, inspected Terraform state,
and confirmed that the Terraform-managed CanNotDelete lock depended on
the Resource Group ID. I then documented the evidence, raised Pull
Request #11, reviewed it and merged it into main. The key lesson was to
inspect and establish evidence across desired state, Terraform state and
actual Azure state before making changes.

# 23. Day 8 Completion Criteria

-   [ ] Azure Resource Manager architecture understood

-   [ ] Management plane investigated

-   [ ] Resource Group inspected

-   [ ] Resource ID inspected

-   [ ] Resource metadata inspected

-   [ ] Resource Providers investigated

-   [ ] Microsoft.Compute registration verified

-   [ ] Microsoft.Network registration verified

-   [ ] Microsoft.Storage registration verified

-   [ ] Microsoft.KeyVault registration verified

-   [ ] Deployment history investigated

-   [ ] Activity Log investigated using defined scopes/time windows

-   [ ] Terraform provider inspected

-   [ ] Terraform Resource Group configuration inspected

-   [ ] Terraform naming and tag logic inspected

-   [ ] Terraform state inspected

-   [ ] Terraform management lock inspected

-   [ ] Resource dependency understood

-   [ ] Terraform state compared with Azure

-   [ ] Documentation delivered through Git and PR

-   [ ] Remote main branch verified to contain the documentation

# 24. Final Engineering Principle

Inspect before changing.

A production Cloud Engineer should be able to explain what resource is
involved, how it is identified, which provider manages it, what Azure
reports, what Terraform believes it manages, what audit evidence exists,
what dependencies and protections apply, and what the safest next action
is before modifying the environment.
