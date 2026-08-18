# Day 4 — Azure Environment Setup & Azure Management Study Guide

## Document Purpose

This document is the complete Day 4 execution record for the Contoso Holdings Enterprise Azure Platform Cloud Engineer Residency.

It is written so that the engineer can return to Day 4 later and reproduce the work independently.

The document records:

- the commands actually used;
- the Terraform configuration actually created or changed;
- the Azure Portal actions actually performed;
- the purpose of each action;
- what each command means;
- the expected result;
- the actual result obtained;
- problems encountered;
- how those problems were resolved;
- what was deployed;
- what was temporary training;
- what was deliberately not deployed.

This document must remain an accurate record of the implementation.

---

# DAY 4 — AZURE ENVIRONMENT SETUP AND MANAGEMENT

## Day 4 Mission

Day 4 moved the Contoso Holdings platform from the Terraform foundation established during Day 3 into an actual Azure environment.

The focus was the first enterprise-style platform Resource Group and the operational controls around it.

The Day 4 work covered:

1. Azure subscription verification
2. Resource Group verification
3. Enterprise naming standard implementation
4. Terraform variable changes
5. Terraform locals
6. Resource Group creation
7. Resource tagging
8. Terraform validation
9. Terraform planning
10. Terraform deployment
11. Terraform state verification
12. Azure-side verification
13. Resource Lock implementation
14. Azure Portal inspection
15. Azure Activity Log investigation
16. Azure resource inventory
17. Temporary Portal training
18. Cleanup
19. PowerShell capability verification

---

# IMPORTANT PRODUCTION ENGINEERING PRINCIPLE

We do not create Azure resources every day simply because it is a training day.

A production resource should exist because there is a legitimate business or technical requirement.

The real platform Resource Group created during Day 4 is therefore retained.

A temporary Resource Group was created only to learn the Azure Portal Resource Lock workflow. That temporary resource was deleted after the exercise.

The real platform Resource Group was not deleted.

The real platform Resource Lock was not deleted.

---

# PART 1 — AZURE ENVIRONMENT VERIFICATION

# Step 1 — Verify the Active Azure Subscription

Before changing Azure infrastructure, we verified the Azure CLI account and subscription context.

## Command

    az account show --output table

## What the command means

`az` is the Azure CLI.

`account` works with Azure account and subscription information.

`show` retrieves information about the current Azure account context.

`--output table` formats the result as a readable table.

## Why we ran it

Before deploying infrastructure, an engineer must know which Azure subscription the CLI is currently connected to.

This reduces the risk of deploying infrastructure into the wrong subscription.

## Actual result

The command showed:

    EnvironmentName    AzureCloud
    IsDefault          True
    Name               Azure subscription 1
    State              Enabled

The tenant information was also displayed.

## Result

Azure CLI was authenticated and an enabled default subscription was available.

---

# Step 2 — Check Whether the Platform Resource Group Already Exists

Before creating the platform Resource Group, we checked Azure directly.

## Command

    az group show --name rg-contoso-platform-prod-uks-001 --output table

## What the command means

`az group show` retrieves information about an Azure Resource Group.

`--name` specifies the Resource Group.

The Resource Group checked was:

    rg-contoso-platform-prod-uks-001

`--output table` makes the output easier to read.

## Actual result

Azure returned:

    (ResourceGroupNotFound) Resource group 'rg-contoso-platform-prod-uks-001' could not be found.

## Meaning

The Resource Group did not already exist.

This confirmed that Terraform could create it as a new resource.

---

# PART 2 — REVIEW THE EXISTING TERRAFORM FOUNDATION

# Step 3 — Inspect terraform/variables.tf

The existing Terraform variables were inspected before making changes.

## Command

    cat terraform/variables.tf

## Why

Day 4 was built on the Terraform foundation created during Day 3.

We did not want to recreate existing work unnecessarily.

We first inspected what already existed.

The original configuration contained variables for:

- location;
- environment;
- project name;
- owner.

The original environment value was:

    sandbox

The original project name was:

    contoso-platform

These values were changed during Day 4 to support the platform naming decision.

---

# Step 4 — Inspect terraform/locals.tf

## Command

    cat terraform/locals.tf

## Original purpose

The existing locals configuration contained a calculated name prefix and common tags.

The existing pattern was:

    locals {
      name_prefix = "${var.project_name}-${var.environment}"

      common_tags = {
        Environment = var.environment
        Project     = var.project_name
        Owner       = var.owner
        ManagedBy   = "Terraform"
      }
    }

## Why it needed to change

The Day 4 naming requirement was:

    rg-contoso-platform-prod-uks-001

The existing naming logic was not sufficiently explicit for the new enterprise naming pattern.

We therefore changed the locals configuration.

---

# Step 5 — Inspect terraform/main.tf

## Command

    cat terraform/main.tf

## Existing configuration

The original Resource Group definition was:

    resource "azurerm_resource_group" "platform" {
      name     = "${local.name_prefix}-rg"
      location = var.location
      tags     = local.common_tags
    }

## Why it needed to change

The Resource Group needed to use the new centralised naming local and expanded tag structure.

---

# PART 3 — ENGINEERING STANDARDS REVIEW

# Step 6 — Review Naming and Tagging References

The architecture documentation was searched for existing naming and tagging requirements.

## Command

    grep -niE "naming|resource name|rg-contoso|uks-001|tags|tagging" docs/architecture/landing-zone.md

## What the command means

`grep` searches files for text.

`-n` displays line numbers.

`-i` makes the search case-insensitive.

`-E` enables extended regular expressions.

The search terms covered:

    naming
    resource name
    rg-contoso
    uks-001
    tags
    tagging

## Result

The architecture documentation already contained references to:

- resource organisation;
- tagging;
- naming;
- Infrastructure as Code;
- subscription governance;
- cost management.

This confirmed that Day 4 implementation needed to align with the existing engineering documentation.

---

# Step 7 — Review Cost Management Requirements

## Command

    sed -n '200,220p' docs/engineering-standards.md

## What the command means

`sed` is used to display selected sections of a text file.

`-n` suppresses normal output.

`200,220p` prints lines 200 through 220.

## Important requirement found

The engineering standards state that Azure resources must have:

- a business purpose;
- an owner;
- a cost allocation;

before they are deployed.

This directly influenced the tags introduced during Day 4.

---

# Step 8 — Review Documentation Requirements

## Command

    sed -n '299,330p' docs/engineering-standards.md

## Why

The documentation requirements were checked because the platform implementation must be accurately documented.

The standards require technical documentation to describe:

- purpose;
- dependencies;
- operational requirements;
- known limitations.

Significant architecture decisions must also be recorded through Architecture Decision Records.

---

# PART 4 — NAMING STANDARD

# Step 9 — Establish the Day 4 Naming Pattern

The first production-style platform Resource Group was defined as:

    rg-contoso-platform-prod-uks-001

The standard used for this implementation is:

    <resource>-<company>-<workload>-<environment>-<region>-<number>

## Component meanings

| Component | Meaning |
|---|---|
| resource | Azure resource type |
| company | Contoso Holdings identifier |
| workload | Business or platform purpose |
| environment | Deployment environment |
| region | Azure region identifier |
| number | Sequential resource number |

## Resource Group example

    rg-contoso-platform-prod-uks-001

## Breakdown

`rg`

Resource Group.

`contoso`

Company identifier.

`platform`

Platform workload.

`prod`

Production environment.

`uks`

UK region code.

`001`

Sequential resource number.

---

# Step 10 — Correct docs/naming-standard.md

The existing naming pattern was changed to match the Day 4 implementation.

## Command

    sed -i 's/<resource>-<company>-<environment>-<workload>-<region>-<number>/<resource>-<company>-<workload>-<environment>-<region>-<number>/' docs/naming-standard.md

## Meaning

`sed -i` edits the file directly.

The old pattern:

    <resource>-<company>-<environment>-<workload>-<region>-<number>

was changed to:

    <resource>-<company>-<workload>-<environment>-<region>-<number>

## Why

The documentation and Terraform implementation must use the same naming standard.

---

# Step 11 — Correct the Naming Component Order

The naming table was also changed so that workload appears before environment.

## Command

    sed -i '/| environment | Deployment environment |/{N;s/| environment | Deployment environment |\n| workload | Business or platform purpose |/| workload | Business or platform purpose |\n| environment | Deployment environment |/;}' docs/naming-standard.md

## Result

The order became:

    resource
    company
    workload
    environment
    region
    number

---

# Step 12 — Verify the Naming Standard

## Command

    grep -nA12 "^## Standard Naming Pattern" docs/naming-standard.md

## Expected result

The pattern should show:

    <resource>-<company>-<workload>-<environment>-<region>-<number>

The component table should show:

    workload
    environment

in that order.

---

# PART 5 — TERRAFORM VARIABLES

# Step 13 — Update terraform/variables.tf

The Day 4 Terraform variables were changed to:

    variable "location" {
      description = "Azure region for this deployment."
      type        = string
      default     = "uksouth"
    }

    variable "environment" {
      description = "Environment classification for the platform deployment."
      type        = string
      default     = "prod"

      validation {
        condition     = contains(["sandbox", "dev", "test", "prod"], var.environment)
        error_message = "Environment must be one of: sandbox, dev, test, prod."
      }
    }

    variable "project_name" {
      description = "Short name identifying the platform project."
      type        = string
      default     = "contoso"
    }

    variable "workload" {
      description = "Platform workload or service purpose."
      type        = string
      default     = "platform"
    }

    variable "region_code" {
      description = "Short Azure region code used in resource names."
      type        = string
      default     = "uks"
    }

    variable "resource_number" {
      description = "Sequential identifier for resources in the same naming scope."
      type        = string
      default     = "001"
    }

    variable "owner" {
      description = "Team responsible for the platform resources."
      type        = string
      default     = "Cloud Platform Engineering"
    }

    variable "cost_centre" {
      description = "Cost centre used for platform cost allocation."
      type        = string
      default     = "IT001"
    }

    variable "application" {
      description = "Application or platform service associated with the resource."
      type        = string
      default     = "Platform"
    }

---

# Step 14 — Understand the Terraform Variables

## location

Controls the Azure deployment region.

Value:

    uksouth

## environment

Identifies the deployment environment.

Value:

    prod

The validation allows:

    sandbox
    dev
    test
    prod

## project_name

Identifies the project/company.

Value:

    contoso

## workload

Identifies the purpose of the resource.

Value:

    platform

## region_code

Short Azure region code used in the name.

Value:

    uks

## resource_number

Sequential resource identifier.

Value:

    001

## owner

Responsible engineering team.

Value:

    Cloud Platform Engineering

## cost_centre

Cost allocation identifier.

Value:

    IT001

## application

Application/platform service associated with the resource.

Value:

    Platform

---

# Step 15 — Verify terraform/variables.tf

## Command

    cat terraform/variables.tf

## Result

The complete Day 4 variables configuration was verified.

---

# PART 6 — TERRAFORM LOCALS AND TAGGING

# Step 16 — Update terraform/locals.tf

The final locals configuration was:

    locals {
      resource_group_name = "rg-${var.project_name}-${var.workload}-${var.environment}-${var.region_code}-${var.resource_number}"

      common_tags = {
        Environment = var.environment
        Project     = var.project_name
        Owner       = var.owner
        CostCentre  = var.cost_centre
        Application = var.application
        ManagedBy   = "Terraform"
      }
    }

## Why resource_group_name is a local

Instead of manually typing the Resource Group name inside the resource definition, Terraform constructs it from variables.

The resulting name is:

    rg-contoso-platform-prod-uks-001

This makes the naming pattern reusable.

---

# Step 17 — Understand the Common Tags

The common tags are:

    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CostCentre  = var.cost_centre
    Application = var.application
    ManagedBy   = "Terraform"

With the current values this produces:

    Environment = prod
    Project     = contoso
    Owner       = Cloud Platform Engineering
    CostCentre  = IT001
    Application = Platform
    ManagedBy   = Terraform

---

# Step 18 — Verify terraform/locals.tf

## Command

    cat terraform/locals.tf

## Result

The final locals configuration was verified.

---

# PART 7 — TERRAFORM RESOURCE GROUP

# Step 19 — Update terraform/main.tf

The Resource Group configuration was written as:

    resource "azurerm_resource_group" "platform" {
      name     = local.resource_group_name
      location = var.location
      tags     = local.common_tags
    }

## Command used

    cat > terraform/main.tf <<'EOF'
    resource "azurerm_resource_group" "platform" {
      name     = local.resource_group_name
      location = var.location
      tags     = local.common_tags
    }
    EOF

## What the command means

`cat > terraform/main.tf`

writes the supplied content into the file.

The `EOF` markers indicate the beginning and end of the content.

## Why

The Resource Group obtains:

- its name from `local.resource_group_name`;
- its location from `var.location`;
- its tags from `local.common_tags`.

This keeps the configuration centralised and reproducible.

---

# Step 20 — Verify terraform/main.tf

## Command

    cat terraform/main.tf

## Expected result

    resource "azurerm_resource_group" "platform" {
      name     = local.resource_group_name
      location = var.location
      tags     = local.common_tags
    }

---

# PART 8 — TERRAFORM VALIDATION AND DEPLOYMENT

# Step 21 — Format Terraform

## Command

    terraform fmt -recursive terraform

## Meaning

`terraform fmt`

formats Terraform configuration according to Terraform's standard formatting.

`-recursive`

formats Terraform files within subdirectories.

## Result

The command completed successfully.

---

# Step 22 — Validate Terraform

## Command

    terraform -chdir=terraform validate

## Meaning

`-chdir=terraform`

tells Terraform to use the `terraform` directory as its working directory.

`validate`

checks the Terraform configuration for correctness.

## Actual result

    Success! The configuration is valid.

---

# Step 23 — Review the Terraform Diff

## Command

    git diff -- terraform/variables.tf terraform/locals.tf terraform/main.tf docs/naming-standard.md

## Why

Before deployment, we reviewed the changes.

The changes included:

- production environment;
- Contoso project name;
- workload variable;
- region code;
- resource number;
- owner;
- cost centre;
- application;
- calculated Resource Group name;
- additional tags;
- updated Resource Group definition;
- corrected naming documentation.

---

# Step 24 — Terraform Plan

## Command

    terraform -chdir=terraform plan

## Meaning

Terraform compares the configuration with the current state and Azure environment.

It calculates the changes that would be made.

It does not apply them.

## Actual result

Terraform proposed:

    + azurerm_resource_group.platform

The Resource Group name was:

    rg-contoso-platform-prod-uks-001

Location:

    uksouth

Tags:

    Application = Platform
    CostCentre  = IT001
    Environment = prod
    ManagedBy   = Terraform
    Owner       = Cloud Platform Engineering
    Project     = contoso

Terraform reported:

    Plan: 1 to add, 0 to change, 0 to destroy.

---

# Step 25 — Terraform Apply

## Command

    terraform -chdir=terraform apply

Terraform displayed the plan and asked for confirmation.

## Confirmation entered

    yes

## Actual result

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Terraform created:

    rg-contoso-platform-prod-uks-001

in:

    uksouth

---

# Step 26 — Verify Terraform State

## Command

    terraform -chdir=terraform state list

## Actual result at this point

    azurerm_resource_group.platform

## Meaning

Terraform is tracking the Resource Group in its state.

---

# Step 27 — Verify Terraform Output

## Command

    terraform -chdir=terraform output

## Actual result

    resource_group_name = "rg-contoso-platform-prod-uks-001"

This confirms the Terraform output matches the Resource Group that was created.

---

# PART 9 — VERIFY AZURE DIRECTLY

# Step 28 — Verify the Resource Group in Azure

## Command

    az group show --name rg-contoso-platform-prod-uks-001 --output json

## Why

Terraform state is not enough.

We also verify the actual Azure environment.

## Actual result

Azure reported:

    name:
    rg-contoso-platform-prod-uks-001

    location:
    uksouth

    provisioningState:
    Succeeded

The tags were:

    Application = Platform
    CostCentre  = IT001
    Environment = prod
    ManagedBy   = Terraform
    Owner       = Cloud Platform Engineering
    Project     = contoso

## Result

The Resource Group existed successfully in Azure with the expected configuration.

---

# PART 10 — TERRAFORM OUTPUT FILE CHECK

# Step 29 — Check the Terraform Output File

We checked whether the file was called `output.tf`.

## Command

    cat terraform/output.tf

## Actual result

    cat: terraform/output.tf: No such file or directory

This was not a Terraform error.

Terraform does not require a file specifically named `output.tf`.

We then checked the actual file:

## Command

    cat terraform/outputs.tf

## Actual result

    output "resource_group_name" {
      description = "Name of the platform Resource Group."
      value       = azurerm_resource_group.platform.name
    }

## Lesson

Terraform loads `.tf` files in the directory.

The project uses:

    terraform/outputs.tf

rather than:

    terraform/output.tf

---

# Step 30 — Revalidate Terraform

## Command

    terraform -chdir=terraform validate

## Actual result

    Success! The configuration is valid.

---

# PART 11 — RESOURCE LOCK

# Step 31 — Add a Resource Lock

The platform Resource Group was protected from accidental deletion.

The Terraform management lock configuration used was:

    resource "azurerm_management_lock" "platform_resource_group" {
      name       = "platform-resource-group-cannot-delete"
      scope      = azurerm_resource_group.platform.id
      lock_level = "CanNotDelete"
      notes      = "Protects the platform Resource Group from accidental deletion."
    }

## Meaning

The lock name is:

    platform-resource-group-cannot-delete

The scope is the Resource Group created by Terraform.

The lock level is:

    CanNotDelete

This prevents deletion of the protected scope through normal deletion operations.

The note documents the purpose of the lock.

---

# Step 32 — Validate the Lock Configuration

## Command

    terraform -chdir=terraform validate

## Actual result

    Success! The configuration is valid.

---

# Step 33 — Plan the Lock

## Command

    terraform -chdir=terraform plan

## Actual result

Terraform proposed:

    + azurerm_management_lock.platform_resource_group

with:

    lock_level = "CanNotDelete"

and:

    name = "platform-resource-group-cannot-delete"

The plan reported:

    Plan: 1 to add, 0 to change, 0 to destroy.

---

# Step 34 — Apply the Lock

## Command

    terraform -chdir=terraform apply

Terraform displayed the plan.

The confirmation entered was:

    yes

## Actual result

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

The management lock was successfully created.

---

# Step 35 — Verify Terraform State After the Lock

## Command

    terraform -chdir=terraform state list

## Actual result

    azurerm_management_lock.platform_resource_group
    azurerm_resource_group.platform

Terraform was therefore managing both:

1. the Resource Group;
2. the Resource Lock.

---

# Step 36 — Verify Terraform Has No Drift

## Command

    terraform -chdir=terraform plan

## Actual result

    No changes. Your infrastructure matches the configuration.

Terraform had compared the configuration with the real infrastructure and found no differences.

This is an important Infrastructure as Code verification.

---

# PART 12 — AZURE PORTAL RESOURCE LOCK INSPECTION

# Step 37 — Open the Platform Resource Group in Azure Portal

Azure Portal navigation:

    Azure Portal
    → Resource groups
    → rg-contoso-platform-prod-uks-001

The Resource Group page contained options including:

    Overview
    Activity log
    Access control (IAM)
    Tags
    Resource visualizer
    Events
    Deployments
    Security
    Policies
    Properties
    Locks
    Cost Management
    Monitoring
    Automation

---

# Step 38 — Open Locks

From the Resource Group:

    rg-contoso-platform-prod-uks-001

select:

    Locks

The Terraform-managed lock was visible.

## Lock

    platform-resource-group-cannot-delete

## Lock type

    Delete

This corresponds to the Terraform configuration:

    lock_level = "CanNotDelete"

## Important distinction

The permanent platform lock is managed through Terraform.

The Azure Portal was used to inspect and verify it.

---

# PART 13 — TEMPORARY PORTAL TRAINING

# Step 39 — Why We Created a Temporary Resource Group

We wanted to learn how to create a Resource Lock manually through the Azure Portal.

We did not want to manually modify the real Terraform-managed platform Resource Group.

Therefore, a temporary training Resource Group was created.

## Temporary Resource Group

    rg-contoso-lock-test-001

## Region

    UK South

This was a training resource only.

---

# Step 40 — Create the Temporary Portal Lock

The temporary Resource Group was opened in Azure Portal.

Navigation:

    Resource Group
    → Locks
    → Add

A temporary lock was created.

## Lock name

    portal-training-cannot-delete

## Lock type

    Delete

This demonstrated the Azure Portal Resource Lock workflow.

---

# Step 41 — Delete the Temporary Portal Lock

The temporary Portal-created lock was selected and deleted.

The lock deleted was:

    portal-training-cannot-delete

The permanent Terraform lock was not touched.

---

# Step 42 — Delete the Temporary Training Resource Group

The temporary training Resource Group was then removed because it was no longer required.

Resource deleted:

    rg-contoso-lock-test-001

## Production principle

Temporary training resources should not be left in a real subscription indefinitely.

Once the exercise is complete, the temporary resource should be removed.

---

# Step 43 — Verify the Temporary Resource Group Was Deleted

## Command

    az group show --name rg-contoso-lock-test-001 --output table

## Actual result

    (ResourceGroupNotFound) Resource group 'rg-contoso-lock-test-001' could not be found.

## Meaning

The cleanup was successful.

There was no temporary Resource Group remaining.

---

# PART 14 — AZURE ACTIVITY LOG

# Step 44 — Open Activity Log

Azure Portal navigation:

    Azure Portal
    → Resource groups
    → rg-contoso-platform-prod-uks-001
    → Activity log

The Activity Log displayed management events.

The events we saw included:

    Add management locks
    Succeeded

and:

    Update resource group
    Succeeded

---

# Step 45 — Investigate the Add Management Locks Event

The following event was opened:

    Add management locks

The event showed:

## Resource

    /subscriptions/.../resourceGroups/rg-contoso-platform-prod-uks-001/providers/Microsoft.Authorization/locks/platform-resource-group-cannot-delete

## Operation name

    Add management locks

## Time stamp

    Tue Aug 18 2026 11:15:06 GMT+0100 (British Summer Time)

## Event initiated by

    ukpropertydealdesk@gmail.com

## Why this matters

Activity Log provides operational evidence.

An engineer can investigate:

    What happened?
    When did it happen?
    Where did it happen?
    Who initiated it?
    Did the operation succeed?

---

# Step 46 — Filter Activity Log by Operation

On the Activity Log page:

    Add filter
    → Operation name
    → Add management locks
    → Apply

The actual operation selected was:

    Add management locks

The filtered result showed the relevant event.

## Why

In a production environment there may be many Activity Log events.

Filtering by operation makes it easier to find the management action being investigated.

---

# Step 47 — Activity Log Filter Limitation Encountered

We attempted to use a Status filter for:

    Succeeded

However, the Azure Portal interface displayed during this exercise did not provide `Succeeded` as a selectable filter value.

Therefore, we did not continue trying to force that filter.

The successful status was already visible directly in the event:

    Add management locks
    Succeeded

## Engineering lesson

Azure Portal interfaces can vary.

An engineer should work with the controls actually available in the environment instead of assuming that a particular filter option exists.

---

# Step 48 — Event Initiated By Filter Limitation

We also investigated the:

    Event initiated by

filter.

The Portal displayed the identity search field, but the email address could not be saved as a selected filter value.

The filter therefore remained:

    Event initiated by | All

We stopped using that filter.

The identity was instead verified directly from the actual event details:

    ukpropertydealdesk@gmail.com

## Engineering lesson

If a Portal filter does not behave as expected, do not waste operational time fighting the interface.

Use the information available in the event itself.

---

# PART 15 — AZURE RESOURCE INVENTORY

# Step 49 — List Resources in the Platform Resource Group

We used Azure CLI to inventory resources inside the platform Resource Group.

## Command

    az resource list --resource-group rg-contoso-platform-prod-uks-001 --output table

## Actual result

No resources were listed.

There was no error.

---

# Step 50 — Understand Why the Resource Inventory Was Empty

The empty result is correct.

The Resource Group itself is the management container.

At this point, we had created the Resource Group but had not created child workload resources such as:

- virtual network;
- subnet;
- virtual machine;
- storage account;
- database.

Therefore the current structure is:

    Azure Subscription
    └── rg-contoso-platform-prod-uks-001
        └── No child workload resources yet

The management lock was queried separately.

---

# Step 51 — Inventory the Resource Lock

## Command

    az lock list --resource-group rg-contoso-platform-prod-uks-001 --output table

## Actual result

    Level         Name
    ------------  -------------------------------------
    CanNotDelete  platform-resource-group-cannot-delete

The notes showed:

    Protects the platform Resource Group from accidental deletion.

## Meaning

The Resource Lock exists in Azure and is set to:

    CanNotDelete

---

# Step 52 — Inventory Resources as JSON

## Command

    az resource list --resource-group rg-contoso-platform-prod-uks-001 --output json

## Actual result

    []

## Meaning

The Resource Group currently has no child resources.

This is not an error.

It is the correct inventory result for the current platform state.

---

# Step 53 — Verify the Resource Group Itself

Because `az resource list` checks child resources, we used `az group show` to inspect the Resource Group itself.

## Command

    az group show --name rg-contoso-platform-prod-uks-001 --output table

## Purpose

This answers:

    Does the Resource Group exist?

and allows us to inspect its basic Azure properties.

---

# PART 16 — POWERSHELL CHECK

# Step 54 — Open PowerShell

From Git Bash, PowerShell was opened using:

    powershell

The prompt changed to a PowerShell prompt.

---

# Step 55 — Check Azure PowerShell Context

## Command

    Get-AzContext

## Actual result

PowerShell returned:

    Get-AzContext : The term 'Get-AzContext' is not recognized as the name of a cmdlet...

## Meaning

The `Get-AzContext` cmdlet was not available.

This indicated that the Azure PowerShell Az module was not installed or available.

---

# Step 56 — Check Whether Az PowerShell Was Installed

## Command

    Get-Module -ListAvailable Az

## Actual result

The command returned no output.

## Meaning

No Az PowerShell module was available in the current PowerShell installation.

---

# Step 57 — Decision Not to Install Az PowerShell During Day 4

We deliberately did not install the Az PowerShell module during Day 4.

The Azure CLI inventory requirements had already been completed successfully.

Installing another tool merely to repeat the same inventory exercise would have expanded the Day 4 scope unnecessarily.

PowerShell remains an important Cloud Engineer skill and will be used as part of later automation work.

---

# PART 17 — CLEANUP VERIFICATION

# Step 58 — Exit PowerShell

## Command

    exit

## Meaning

`exit` closes the current PowerShell session and returns to the previous shell.

---

# Step 59 — Check Git Working Tree

## Command

    git status --short

## Actual result at the Day 4 checkpoint

The repository showed:

    M .gitignore
    M terraform/locals.tf
    M terraform/main.tf
    M terraform/variables.tf
    ?? .vscode/
    ?? docs/naming-standard.md

The Day 4 Terraform and naming files were therefore modified.

The `.gitignore` and `.vscode/` changes were not part of the Day 4 Terraform implementation and were not to be accidentally committed with the Day 4 work.

---

# Step 60 — Confirm Temporary Azure Resource Cleanup

## Command

    az group show --name rg-contoso-lock-test-001 --output table

## Actual result

    (ResourceGroupNotFound) Resource group 'rg-contoso-lock-test-001' could not be found.

## Meaning

The temporary training Resource Group had been successfully deleted.

---

# PART 18 — FINAL DAY 4 AZURE STATE

The real platform Resource Group is:

    rg-contoso-platform-prod-uks-001

Location:

    uksouth

Environment:

    prod

Workload:

    platform

---

# Resource Group Tags

The Resource Group has:

    Application = Platform
    CostCentre  = IT001
    Environment = prod
    ManagedBy   = Terraform
    Owner       = Cloud Platform Engineering
    Project     = contoso

---

# Resource Lock

The real platform Resource Lock is:

    platform-resource-group-cannot-delete

Lock level:

    CanNotDelete

Purpose:

    Protects the platform Resource Group from accidental deletion.

---

# Terraform State

The final Terraform state contains:

    azurerm_management_lock.platform_resource_group
    azurerm_resource_group.platform

---

# Terraform Drift Verification

The final Terraform plan returned:

    No changes. Your infrastructure matches the configuration.

This means Terraform's configuration and the deployed Azure infrastructure were aligned at the time of verification.

---

# Azure Resource Inventory

The current child resource inventory returned:

    []

This is expected because no workload resources have been deployed into the platform Resource Group yet.

---

# Azure Lock Inventory

The lock inventory returned:

    CanNotDelete  platform-resource-group-cannot-delete

---

# Activity Log Evidence

The Resource Lock creation generated the Activity Log event:

    Add management locks

Status:

    Succeeded

Timestamp:

    Tue Aug 18 2026 11:15:06 GMT+0100

Initiated by:

    ukpropertydealdesk@gmail.com

---

# PART 19 — PRODUCTION VS TRAINING

## Real Production-Style Platform Resource

Keep:

    rg-contoso-platform-prod-uks-001

Keep:

    platform-resource-group-cannot-delete

These are part of the actual platform implementation.

---

## Temporary Training Resource

Created temporarily:

    rg-contoso-lock-test-001

Temporary lock:

    portal-training-cannot-delete

Both were removed after the training exercise.

---

# Why We Do Not Create And Delete Resources Every Day

Production engineers do not create and delete infrastructure simply because the training schedule changed to another day.

A production resource exists because it provides a business or technical capability.

Resources should be:

- purposeful;
- owned;
- cost-aware;
- secured;
- monitored;
- maintained;
- eventually decommissioned when genuinely no longer required.

Temporary training resources should be removed after the training exercise.

---

# PART 20 — COMMAND REFERENCE

## Azure Subscription

    az account show --output table

Shows the current Azure account/subscription context.

---

## Resource Group Lookup

    az group show --name <resource-group> --output table

Checks a specific Resource Group.

---

## Resource Inventory

    az resource list --resource-group <resource-group> --output table

Lists child Azure resources in the Resource Group.

---

## JSON Resource Inventory

    az resource list --resource-group <resource-group> --output json

Returns the same inventory as machine-readable JSON.

---

## Resource Lock Inventory

    az lock list --resource-group <resource-group> --output table

Lists management locks associated with the Resource Group.

---

## Terraform Formatting

    terraform fmt -recursive terraform

Formats Terraform files.

---

## Terraform Validation

    terraform -chdir=terraform validate

Checks whether Terraform configuration is valid.

---

## Terraform Plan

    terraform -chdir=terraform plan

Shows proposed infrastructure changes without applying them.

---

## Terraform Apply

    terraform -chdir=terraform apply

Applies the Terraform configuration.

---

## Terraform State

    terraform -chdir=terraform state list

Lists resources tracked in Terraform state.

---

## Terraform Outputs

    terraform -chdir=terraform output

Displays Terraform outputs.

---

## Git Status

    git status --short

Shows modified and untracked files.

---

# PART 21 — TROUBLESHOOTING

# Problem 1 — Resource Group Not Found

Command:

    az group show --name rg-contoso-platform-prod-uks-001 --output table

Result:

    ResourceGroupNotFound

Meaning:

The Resource Group did not exist yet.

Resolution:

Terraform was used to create it.

---

# Problem 2 — PowerShell Get-AzContext Not Recognized

Command:

    Get-AzContext

Result:

    The term 'Get-AzContext' is not recognized...

Meaning:

Azure PowerShell cmdlets were unavailable.

Resolution:

Check:

    Get-Module -ListAvailable Az

No Az module was returned.

Decision:

Do not install it during Day 4 because Azure CLI already provided the required inventory functionality.

---

# Problem 3 — Resource Inventory Returned Empty

Command:

    az resource list --resource-group rg-contoso-platform-prod-uks-001 --output json

Result:

    []

Meaning:

There are currently no child Azure resources in the Resource Group.

This is not an error.

---

# Problem 4 — terraform/output.tf Did Not Exist

Command:

    cat terraform/output.tf

Result:

    cat: terraform/output.tf: No such file or directory

Resolution:

The actual Terraform output file was:

    terraform/outputs.tf

Terraform does not require a specific filename such as `output.tf`.

Terraform loads `.tf` files from the Terraform working directory.

---

# Problem 5 — Activity Log Status Filter

The Portal did not show `Succeeded` as a selectable Status filter in the interface being used.

Resolution:

The filter was not forced.

The successful status was verified directly from the Activity Log event.

---

# Problem 6 — Event Initiated By Filter

The Portal displayed the Event initiated by search field but did not allow the email to be saved as the selected filter value.

Resolution:

The filter was not forced.

The identity was verified directly from the event details.

---

# PART 22 — WHAT WAS ACTUALLY DEPLOYED

The actual Azure infrastructure deployed during Day 4 was intentionally small.

## Deployed

Resource Group:

    rg-contoso-platform-prod-uks-001

Management Lock:

    platform-resource-group-cannot-delete

---

# PART 23 — WHAT WAS NOT DEPLOYED

The following were not deployed during this Day 4 work:

- Virtual Network
- Subnet
- Network Security Group
- Virtual Machine
- Storage Account
- Key Vault
- Database
- Log Analytics Workspace
- Application workload
- Management Group hierarchy
- New Azure subscription
- Azure Policy implementation
- Production application infrastructure
- Az PowerShell module

These were not required for the specific Day 4 implementation performed.

We did not create unnecessary infrastructure merely to make the environment look more complete.

---

# PART 24 — ENGINEERING LESSONS

## Lesson 1 — Check Before Creating

Before deploying a Resource Group, we checked whether it already existed.

This is basic production discipline.

---

## Lesson 2 — Infrastructure Should Be Reproducible

The Resource Group was created through Terraform.

The configuration defines:

- name;
- location;
- tags.

---

## Lesson 3 — Naming Is an Engineering Standard

The Resource Group name communicates:

    resource
    company
    workload
    environment
    region
    number

Example:

    rg-contoso-platform-prod-uks-001

---

## Lesson 4 — Tags Provide Operational Metadata

The Resource Group has:

    Environment
    Project
    Owner
    CostCentre
    Application
    ManagedBy

These values provide information useful for governance, ownership and cost management.

---

## Lesson 5 — Protect Important Infrastructure

The platform Resource Group has a `CanNotDelete` management lock.

This reduces the risk of accidental deletion.

---

## Lesson 6 — Terraform Is the Source of Truth

The permanent platform Resource Group and management lock are managed by Terraform.

The Azure Portal was used for inspection and controlled training.

---

## Lesson 7 — Verify Terraform Against Azure

We did not stop at:

    terraform apply

We also checked:

    terraform state list

    terraform output

    az group show

    terraform plan

This gave us evidence that the infrastructure was deployed and aligned.

---

## Lesson 8 — Activity Log Is Operational Evidence

The Activity Log allowed us to identify:

    What happened?
    When?
    Where?
    Who initiated it?
    Did it succeed?

---

## Lesson 9 — Inventory Is an Operational Skill

Azure CLI can quickly answer:

> What resources currently exist in this Resource Group?

---

## Lesson 10 — Empty Inventory Can Be Correct

An empty resource list does not automatically mean failure.

It can simply mean the Resource Group has no child resources yet.

---

## Lesson 11 — Do Not Waste Production Time Fighting the Portal

If a Portal filter does not behave as expected, use the information that is actually available.

The objective is operational understanding, not clicking every available option.

---

## Lesson 12 — Temporary Resources Need Lifecycle Management

Temporary training infrastructure was removed after the exercise.

This avoids leaving unnecessary resources in the subscription.

---

# PART 25 — PORTFOLIO EVIDENCE

Day 4 provides evidence that can be demonstrated in a Cloud Engineer portfolio.

## Infrastructure as Code

Terraform configuration:

    terraform/variables.tf
    terraform/locals.tf
    terraform/main.tf
    terraform/outputs.tf

---

## Azure Resource Group

    rg-contoso-platform-prod-uks-001

---

## Azure Region

    uksouth

---

## Resource Governance

Tags:

    Application = Platform
    CostCentre  = IT001
    Environment = prod
    ManagedBy   = Terraform
    Owner       = Cloud Platform Engineering
    Project     = contoso

---

## Resource Protection

    platform-resource-group-cannot-delete

Lock:

    CanNotDelete

---

## Terraform State Evidence

    azurerm_management_lock.platform_resource_group
    azurerm_resource_group.platform

---

## Drift Evidence

    No changes. Your infrastructure matches the configuration.

---

## Activity Log Evidence

    Add management locks
    Succeeded

---

## Resource Inventory Evidence

    az resource list

and:

    az lock list

---

# PART 26 — DAY 4 COMPLETION CHECKLIST

## Azure Environment

- [x] Azure subscription verified
- [x] Target Resource Group checked
- [x] Platform Resource Group created
- [x] Resource Group verified directly in Azure
- [x] Location verified
- [x] Tags verified

## Naming

- [x] Naming pattern reviewed
- [x] Naming pattern corrected
- [x] Resource Group naming implemented
- [x] Naming documentation updated

## Terraform

- [x] Variables updated
- [x] Locals updated
- [x] Resource Group definition updated
- [x] Terraform formatted
- [x] Terraform validated
- [x] Terraform plan reviewed
- [x] Terraform apply completed
- [x] Terraform state verified
- [x] Terraform output verified
- [x] Final Terraform plan showed no changes

## Resource Protection

- [x] Terraform management lock implemented
- [x] Lock applied
- [x] Lock present in Terraform state
- [x] Lock inspected in Azure Portal
- [x] Temporary Portal lock created
- [x] Temporary Portal lock deleted
- [x] Temporary Resource Group deleted
- [x] Temporary Resource Group deletion verified

## Azure Operations

- [x] Activity Log opened
- [x] Resource Lock event investigated
- [x] Operation filter used
- [x] Resource inventory performed
- [x] Lock inventory performed
- [x] JSON inventory performed
- [x] PowerShell availability checked

## Deliberately Not Completed

- [ ] Az PowerShell installation
- [ ] Application workload deployment
- [ ] Network deployment
- [ ] Database deployment
- [ ] Storage deployment
- [ ] Key Vault deployment
- [ ] Monitoring platform deployment

These were outside the actual Day 4 work performed.

---

# PART 27 — FINAL DAY 4 STATE

The platform now contains:

    Azure Subscription
    │
    └── rg-contoso-platform-prod-uks-001
            │
            └── CanNotDelete management lock

The Resource Group is managed by Terraform.

The Resource Group has the required tags.

The Resource Group is protected against accidental deletion.

Terraform state contains the Resource Group and management lock.

Terraform reports no configuration drift.

Azure Activity Log contains evidence of the management lock operation.

The temporary Portal training Resource Group has been removed.

No unnecessary workload resources were created.

---

# DAY 4 SUMMARY

Day 4 established the first actual Azure platform foundation for the Contoso Holdings environment.

The Resource Group:

    rg-contoso-platform-prod-uks-001

was created through Terraform in:

    uksouth

The Resource Group uses the enterprise naming standard:

    <resource>-<company>-<workload>-<environment>-<region>-<number>

The Resource Group is tagged with:

    Application
    CostCentre
    Environment
    ManagedBy
    Owner
    Project

A `CanNotDelete` management lock was created through Terraform:

    platform-resource-group-cannot-delete

Terraform state was verified.

Terraform output was verified.

Azure was queried directly to confirm the Resource Group existed.

Terraform was run again to confirm:

    No changes. Your infrastructure matches the configuration.

The Azure Portal was used to inspect the Resource Group and Resource Lock.

A temporary Portal training Resource Group was created to learn manual lock management.

The temporary lock and temporary Resource Group were deleted after the exercise.

Azure Activity Log was used to investigate the lock creation event.

Azure CLI was used to inventory resources and locks.

PowerShell was checked for Azure PowerShell availability, but Az PowerShell was not installed during Day 4 because it was not required to complete the Day 4 objective.

The result is a small but genuine Terraform-managed Azure platform foundation that can be extended in later residency days.

---

# FINAL ENGINEERING PRINCIPLE

A Cloud Platform Engineer should not ask:

> What Azure resource do I need to create today?

The better question is:

> What engineering requirement are we solving, and what is the smallest safe implementation that satisfies it?

The Day 4 implementation follows that principle.

Infrastructure is:

- purposeful;
- reproducible;
- reviewable;
- traceable;
- cost-aware;
- protected;
- documented.

# END OF DAY 4
