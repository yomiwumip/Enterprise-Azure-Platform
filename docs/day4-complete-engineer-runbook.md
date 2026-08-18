# Day 4 — Azure Platform Foundation & Azure Management
## Complete Engineer Runbook

**Contoso Holdings — Enterprise Azure Platform**  
**Cloud Platform Engineer Residency — Week 1 / Sprint 1**

## Purpose

This is the **reproduction runbook**, not a short study summary. Use it whenever you want to practise Day 4 from start to finish.

It contains:

- the exact commands used;
- what every important command means;
- the expected result;
- the actual Day 4 result;
- the exact Azure Portal click path;
- what to type and where;
- the permanent Terraform-managed environment;
- the disposable Portal training exercise;
- Activity Log investigation;
- troubleshooting;
- Git/GitHub delivery;
- the final verification gate.

**Accuracy rule:** Terraform is the source of truth for the permanent Resource Group and management lock. Azure Portal was used for operational inspection and a controlled temporary training exercise. Day 4 did not implement workload networking, IAM, production remote Terraform backend infrastructure or CI/CD automation.

---

# 1. Day 4 Outcome

Permanent Resource Group:

`rg-contoso-platform-prod-uks-001`

Region:

`uksouth` / UK South

Permanent Terraform-managed lock:

`platform-resource-group-cannot-delete`

Lock level:

`CanNotDelete`

Final Terraform verification:

`No changes. Your infrastructure matches the configuration.`

Day 4 Terraform commit:

`80f10fe`

Day 4 documentation commit:

`c149334`

Cumulative promotion PR:

`#6 — Promote Cloud Platform Foundation to main — Days 1-4`

---

# 2. Engineering Loop

![Day 4 engineering loop](day4_engineering_loop_diagram.png)

```text
Inspect
  ↓
Understand standard
  ↓
Change Terraform
  ↓
fmt
  ↓
validate
  ↓
plan
  ↓
read the plan
  ↓
apply
  ↓
verify Azure CLI
  ↓
inspect Azure Portal
  ↓
investigate Activity Log
  ↓
terraform plan again
  ↓
No changes
  ↓
document
  ↓
commit
  ↓
push
  ↓
Pull Request
  ↓
review
  ↓
merge
```

---

# 3. Rules Before Starting

1. Confirm the Azure subscription before changing anything.
2. Inspect the repository before creating or replacing files.
3. Do not recreate a resource that already exists.
4. Do not delete the permanent production-style Resource Group for practice.
5. Use a temporary Resource Group for disposable Portal training.
6. Never run `terraform apply` before reading the plan.
7. Do not use `git add .` when unrelated changes exist.
8. Verify Azure independently after deployment.
9. Run a final Terraform plan to detect drift.
10. If the result is unexpected, STOP and investigate.

---

# 4. Start in Git Bash

Open **Git Bash**.

Navigate to the project:

```bash
cd ~/Desktop/CLOUD\ ENGINEER\ ROLE\ WORK/Enterprise-Azure-Platform
```

### What it means

`cd` changes the current directory.

The `\ ` characters escape the spaces in the Windows folder name for Git Bash.

Check your location:

```bash
pwd
```

### What it means

`pwd` prints the current working directory.

You should be inside:

```text
CLOUD ENGINEER ROLE WORK/Enterprise-Azure-Platform
```

---

# 5. Step 1 — Verify Azure Subscription

Run:

```bash
az account show --output table
```

### What it does

Shows the currently selected Azure subscription and tenant context.

- `az` = Azure CLI.
- `account show` = show the active account/subscription.
- `--output table` = readable table output.

### What you check

During Day 4 the active context showed:

```text
EnvironmentName    AzureCloud
IsDefault          True
Name               Azure subscription 1
State              Enabled
```

### Why

Never make an Azure change without knowing which subscription you are connected to.

---

# 6. Step 2 — Inspect Terraform Variables

Run:

```bash
cat terraform/variables.tf
```

### What it does

`cat` prints the complete file.

### Final Day 4 variables

```hcl
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
```

### Learn this

The variables control:

```text
location        → Azure region
environment     → prod
project_name   → contoso
workload        → platform
region_code     → uks
resource_number → 001
owner           → Cloud Platform Engineering
cost_centre     → IT001
application     → Platform
```

---

# 7. Step 3 — Inspect the Naming Standard

Run:

```bash
grep -nA12 "^## Standard Naming Pattern" docs/naming-standard.md
```

### What it does

Searches for the naming-standard heading and prints the following lines.

### Standard

```text
<resource>-<company>-<workload>-<environment>-<region>-<number>
```

### Day 4 Resource Group

```text
rg-contoso-platform-prod-uks-001
```

Breakdown:

```text
rg       = Resource Group
contoso  = company
platform = workload
prod     = environment
uks      = region code
001      = sequential number
```

### Important Day 4 decision

Workload comes **before** environment.

---

# 8. Step 4 — Inspect Terraform Locals

Run:

```bash
cat terraform/locals.tf
```

### Final configuration

```hcl
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
```

### What it does

The local creates the Resource Group name and centralises common tags.

The resulting name is:

```text
rg-contoso-platform-prod-uks-001
```

---

# 9. Step 5 — Inspect Terraform Main

Run:

```bash
cat terraform/main.tf
```

### Final Day 4 implementation

```hcl
resource "azurerm_resource_group" "platform" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_management_lock" "platform_resource_group" {
  name       = "platform-resource-group-cannot-delete"
  scope      = azurerm_resource_group.platform.id
  lock_level = "CanNotDelete"
  notes      = "Protects the platform Resource Group from accidental deletion."
}
```

### What you should understand

Terraform declares desired state.

The Resource Group is one managed object.

The management lock is another managed object whose scope is the Resource Group.

---

# 10. Step 6 — Format Terraform

Run:

```bash
terraform fmt -recursive terraform
```

### Meaning

Formats Terraform files using Terraform's standard formatter.

`-recursive` checks nested Terraform directories.

### Expected

Terraform may report changed files. If everything is already formatted it may produce no output.

---

# 11. Step 7 — Validate Terraform

Run:

```bash
terraform -chdir=terraform validate
```

### Meaning

Checks Terraform syntax and configuration structure.

### Actual Day 4 result

```text
Success! The configuration is valid.
```

### Important

`validate` does not deploy anything.

---

# 12. Step 8 — Plan Before Deployment

Run:

```bash
terraform -chdir=terraform plan
```

### Meaning

Terraform refreshes managed state and calculates the changes required to make Azure match the configuration.

### Initial Day 4 result

The plan proposed creation of:

```text
azurerm_resource_group.platform
```

with:

```text
name     = "rg-contoso-platform-prod-uks-001"
location = "uksouth"
```

and the expected tags.

### Expected initial summary

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

### Engineering rule

Read the complete plan.

If you see an unexpected deletion or unexpected resource:

**STOP. Do not apply.**

---

# 13. Step 9 — Apply Terraform

Run:

```bash
terraform -chdir=terraform apply
```

Terraform displays the plan again.

You will see:

```text
Do you want to perform these actions?
Only 'yes' will be accepted to approve.
```

Type:

```text
yes
```

Then press **Enter**.

### Meaning

`apply` executes the approved changes against Azure.

### Actual Day 4 Resource Group deployment

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

The Resource Group was created successfully.

---

# 14. Step 10 — Inspect Terraform State

Run:

```bash
terraform -chdir=terraform state list
```

### Meaning

Lists resources tracked by Terraform.

After the Resource Group:

```text
azurerm_resource_group.platform
```

After the lock was applied:

```text
azurerm_management_lock.platform_resource_group
azurerm_resource_group.platform
```

### Lesson

Terraform state is the recorded relationship between Terraform configuration and managed Azure resources.

---

# 15. Step 11 — Inspect Terraform Output

Run:

```bash
terraform -chdir=terraform output
```

### Expected

```text
resource_group_name = "rg-contoso-platform-prod-uks-001"
```

---

# 16. Step 12 — Verify the Resource Group with Azure CLI

Run:

```bash
az group show --name rg-contoso-platform-prod-uks-001 --output table
```

### Meaning

Queries Azure directly rather than relying on Terraform's output.

### Actual result

```text
Location    Name
----------  --------------------------------
uksouth     rg-contoso-platform-prod-uks-001
```

---

# 17. Step 13 — Verify Detailed Azure State

Run:

```bash
az group show --name rg-contoso-platform-prod-uks-001 --output json
```

### Check

```text
location = uksouth
name = rg-contoso-platform-prod-uks-001
provisioningState = Succeeded
```

Check the tags:

```text
Application = Platform
CostCentre = IT001
Environment = prod
ManagedBy = Terraform
Owner = Cloud Platform Engineering
Project = contoso
```

### Why

This independently proves the actual Azure object matches the intended governance configuration.

---

# 18. Step 14 — Inventory Resources Inside the RG

Run:

```bash
az resource list --resource-group rg-contoso-platform-prod-uks-001 --output table
```

You can also inspect JSON:

```bash
az resource list --resource-group rg-contoso-platform-prod-uks-001 --output json
```

### Actual Day 4 result

```json
[]
```

### Is that an error?

No.

It means no workload resources had been deployed inside the Resource Group.

The Resource Group itself is verified using:

```bash
az group show --name rg-contoso-platform-prod-uks-001 --output table
```

The management lock is verified using:

```bash
az lock list --resource-group rg-contoso-platform-prod-uks-001 --output table
```

---

# 19. Step 15 — Verify the Management Lock with Azure CLI

Run:

```bash
az lock list --resource-group rg-contoso-platform-prod-uks-001 --output table
```

### Expected

```text
Level         Name
------------  -------------------------------------
CanNotDelete  platform-resource-group-cannot-delete
```

### Actual Day 4 result

The lock existed and had:

```text
Level = CanNotDelete
```

### Why

Always verify important governance controls directly in Azure.

---

# 20. Azure Portal Practice — Navigation Diagram

![Azure Portal practice](day4_azure_portal_practice_diagram.png)

The permanent Resource Group click path is:

```text
Azure Portal
→ Resource groups
→ rg-contoso-platform-prod-uks-001
→ Overview
→ Tags
→ Properties
→ Activity log
→ Settings
→ Locks
```

---

# 21. Portal Step 1 — Open Azure Portal

1. Open your browser.
2. Open Azure Portal.
3. Sign in.
4. Wait for the Azure Portal home page.

### Goal

Practise operational Portal navigation.

---

# 22. Portal Step 2 — Open Resource Groups

1. Find the **Search** box at the top of Azure Portal.
2. Click it.
3. Type:

```text
Resource groups
```

4. Click **Resource groups** from the results.

---

# 23. Portal Step 3 — Open the Day 4 Resource Group

1. Find the Resource Group search/filter area.
2. Type:

```text
rg-contoso-platform-prod-uks-001
```

3. Press **Enter** if necessary.
4. Locate the matching Resource Group.
5. Click:

```text
rg-contoso-platform-prod-uks-001
```

---

# 24. Portal Step 4 — Inspect Overview

You should now be inside the Resource Group.

1. Click **Overview** if it is not already selected.
2. Confirm the Resource Group name.
3. Confirm the region is **UK South**.
4. Review the resource information.
5. Click **Resource visualizer**.
6. Look at the visual representation.

### Lesson

Portal is useful for operational inspection.

Terraform remains the source of truth for the permanent managed environment.

---

# 25. Portal Step 5 — Inspect Tags

1. On the left menu, click **Tags**.
2. Review the existing tags.

Confirm:

```text
Environment = prod
Project = contoso
Owner = Cloud Platform Engineering
CostCentre = IT001
Application = Platform
ManagedBy = Terraform
```

### Important

Do not manually change these permanent tags in Portal.

If the configuration needs to change, change Terraform and run the controlled workflow.

---

# 26. Portal Step 6 — Inspect Properties

1. On the left menu, click **Properties**.
2. Review the Resource Group ID.
3. Review the subscription.
4. Review the location.

### Why

These values are useful when troubleshooting, escalating incidents or communicating with another engineer.

---

# 27. Portal Step 7 — Open Activity Log

1. On the left menu, click **Activity log**.
2. Find **Add filter** or **Filter**.
3. Click it.
4. Select **Operation name**.
5. Search for:

```text
Add management locks
```

6. Select **Add management locks**.
7. Click **Apply**.
8. Find the resulting event.
9. Click/open the event.

### Review

Look at:

```text
Resource
Operation name
Status
Time stamp
Subscription
Event initiated by
```

### Why

The Activity Log is a control-plane audit trail.

---

# 28. Portal Step 8 — Activity Log Filter Issue We Actually Encountered

During Day 4, the **Event initiated by** filter stayed at:

```text
All
```

and would not retain the email value.

Do not waste time repeatedly trying to save the filter.

Use:

```text
Activity log
→ Add filter
→ Operation name
→ Add management locks
→ Apply
→ Open event
→ Inspect Event initiated by
```

### Lesson

A Portal UI quirk should not stop an operational investigation when the event itself contains the required information.

---

# 29. Portal Step 9 — Inspect the Lock

1. On the Resource Group left menu, find **Settings**.
2. Click **Locks**.
3. Find:

```text
platform-resource-group-cannot-delete
```

4. Confirm the level:

```text
CanNotDelete
```

5. Read the note:

```text
Protects the platform Resource Group from accidental deletion.
```

### IMPORTANT

Do not delete the permanent Terraform-managed lock.

This step is inspection only.

---

# 30. Temporary Portal Training — Never Use the Production RG

For manual Portal practice, use:

```text
rg-contoso-lock-test-001
```

Do **not** practise deletion or manual lock creation against:

```text
rg-contoso-platform-prod-uks-001
```

---

# 31. Temporary Portal Step 1 — Create Training RG

1. Search for **Resource groups**.
2. Click **Resource groups**.
3. Click **Create**.
4. Select subscription:

```text
Azure subscription 1
```

5. In **Resource group**, type:

```text
rg-contoso-lock-test-001
```

6. Select region:

```text
UK South
```

7. Click **Review + create**.
8. Wait for validation.
9. Click **Create**.
10. Wait for deployment to complete.

### Why

This is disposable training, not permanent infrastructure.

---

# 32. Temporary Portal Step 2 — Open Training RG

1. Return to **Resource groups**.
2. Search:

```text
rg-contoso-lock-test-001
```

3. Click it.

---

# 33. Temporary Portal Step 3 — Add Training Lock

1. Click **Locks** under Settings.
2. Click **Add**.
3. Choose the delete-protection lock option shown by the Portal.
4. Enter a clear training lock name.
5. Add a note identifying it as training.
6. Save.

Then confirm the lock appears in the Locks blade.

---

# 34. Temporary Portal Step 4 — Delete Training RG

When finished:

1. Open the training Resource Group **Overview**.
2. Click **Delete resource group**.
3. Read the warning.
4. If Azure asks you to type the name, type:

```text
rg-contoso-lock-test-001
```

5. Confirm deletion.
6. Wait for deletion to finish.

Then verify from Git Bash:

```bash
az group show --name rg-contoso-lock-test-001 --output table
```

### Expected

```text
(ResourceGroupNotFound)
```

That is expected after cleanup.

---

# 35. Production Resource Lifecycle Lesson

A production environment is not normally deleted and recreated every day.

Permanent resources stay deployed.

Cost management is normally achieved through controlled decisions such as:

- correct SKU;
- correct capacity;
- scaling;
- scheduling where appropriate;
- storage tiers;
- retention;
- right-sizing;
- architectural optimisation.

Disposable training resources can be created and deleted.

Permanent production resources require change control.

---

# 36. Step 16 — Final Terraform Drift Check

Run:

```bash
terraform -chdir=terraform plan
```

### Actual Day 4 result

```text
No changes. Your infrastructure matches the configuration.
```

### Meaning

Terraform found no difference between its declared configuration and the managed Azure state.

This is a critical Day 4 checkpoint.

---

# 37. Step 17 — Final State Check

Run:

```bash
terraform -chdir=terraform state list
```

Expected:

```text
azurerm_management_lock.platform_resource_group
azurerm_resource_group.platform
```

---

# 38. Step 18 — Final Output Check

Run:

```bash
terraform -chdir=terraform output
```

Expected:

```text
resource_group_name = "rg-contoso-platform-prod-uks-001"
```

---

# 39. Step 19 — Git Status

Run:

```bash
git status --short
```

### Meaning

Shows modified, staged and untracked files.

Do not assume everything shown belongs to Day 4.

During the actual Day 4 work, unrelated items included:

```text
.gitignore
.vscode/
docs/naming-standard.md
```

They were intentionally kept separate.

---

# 40. Step 20 — Review Terraform Changes

Run:

```bash
git diff -- terraform/variables.tf terraform/locals.tf terraform/main.tf
```

### Meaning

Shows the exact unstaged changes in the Terraform implementation.

---

# 41. Step 21 — Formatting Gate

Run:

```bash
terraform fmt -check -recursive terraform
```

### Expected

No output.

No output means the formatting check passed.

---

# 42. Step 22 — Stage Only Terraform

Run:

```bash
git add terraform/variables.tf terraform/locals.tf terraform/main.tf
```

Do not use:

```bash
git add .
```

### Why

Explicit staging prevents unrelated files from entering the commit.

---

# 43. Step 23 — Review Staged Terraform

Run:

```bash
git diff --cached --stat
```

Expected:

```text
terraform/locals.tf
terraform/main.tf
terraform/variables.tf
```

Then:

```bash
git diff --cached --check
```

Expected:

```text
no output
```

---

# 44. Step 24 — Commit Terraform

Run:

```bash
git commit -m "feat: implement Day 4 Azure platform foundation"
```

Actual Day 4 commit:

```text
80f10fe
```

---

# 45. Step 25 — Verify Day 4 Study Guide

The study guide is:

```text
docs/day4-azure-management-study-guide.md
```

Check it:

```bash
wc -l docs/day4-azure-management-study-guide.md
```

Check the beginning:

```bash
head -20 docs/day4-azure-management-study-guide.md
```

Check the end:

```bash
tail -30 docs/day4-azure-management-study-guide.md
```

Check headings:

```bash
grep -nE "^#|^##|^###" docs/day4-azure-management-study-guide.md
```

Check whitespace:

```bash
git diff --check -- docs/day4-azure-management-study-guide.md
```

### Actual Day 4 study guide

The study guide was approximately 2,445 lines and was committed as:

```text
c149334
```

---

# 46. Step 26 — Stage the Study Guide

Run:

```bash
git add docs/day4-azure-management-study-guide.md
```

Then:

```bash
git diff --cached --stat
```

Review that the intended documentation is staged.

---

# 47. Step 27 — Commit the Study Guide

Run:

```bash
git commit -m "docs: add Day 4 Azure management study guide"
```

Actual commit:

```text
c149334
```

---

# 48. Step 28 — Verify GitHub Remote

Run:

```bash
git remote -v
```

Expected:

```text
origin  https://github.com/yomiwumip/Enterprise-Azure-Platform
```

---

# 49. Step 29 — Push Develop

Run:

```bash
git push origin develop
```

### Meaning

Pushes the local `develop` branch to GitHub.

The Day 4 commits were successfully pushed.

---

# 50. Step 30 — Pull Request Workflow

The actual cumulative PR was:

```text
#6
```

Title:

```text
Promote Cloud Platform Foundation to main — Days 1-4
```

Base:

```text
main
```

Compare:

```text
develop
```

### Important

The PR contained the accumulated Days 1–4 work, not Day 4 alone.

Before merging:

1. Open **Commits**.
2. Review the commits.
3. Open **Files changed**.
4. Review the actual files.
5. Confirm there are no conflicts.
6. Confirm the PR description accurately describes the scope.
7. Merge only after understanding the change set.

Actual result:

```text
PR #6 — Merged
develop → main
```

---

# 51. Troubleshooting

## ResourceGroupNotFound

If:

```bash
az group show --name rg-contoso-platform-prod-uks-001 --output table
```

returns `ResourceGroupNotFound`:

1. Check subscription:

```bash
az account show --output table
```

2. Check the Resource Group name character-for-character.
3. Check Terraform state:

```bash
terraform -chdir=terraform state list
```

4. Do not create another Resource Group until the cause is understood.

---

## `az resource list` returns `[]`

This can be valid.

It means there are no child workload resources in the Resource Group.

Use:

```bash
az group show --name rg-contoso-platform-prod-uks-001 --output table
```

to verify the Resource Group itself.

Use:

```bash
az lock list --resource-group rg-contoso-platform-prod-uks-001 --output table
```

to verify the lock.

---

## Portal Activity Log filter will not save the email

Use the reliable filter:

```text
Activity log
→ Add filter
→ Operation name
→ Add management locks
→ Apply
→ Open event
→ Event initiated by
```

Do not let a Portal filter UI issue block the investigation.

---

## `Get-AzContext` is not recognised

If PowerShell says:

```text
Get-AzContext : The term 'Get-AzContext' is not recognized
```

and:

```powershell
Get-Module -ListAvailable Az
```

returns nothing, Azure PowerShell's `Az` module is not available in that PowerShell environment.

Day 4 used Azure CLI for the verified CLI checks.

---

## Terraform plan shows unexpected changes

STOP.

Do not apply.

Inspect:

```bash
terraform -chdir=terraform plan
```

Then inspect:

```bash
cat terraform/variables.tf
cat terraform/locals.tf
cat terraform/main.tf
```

Understand the difference before changing anything.

---

## Git shows unrelated files

Run:

```bash
git status --short
```

Stage only the intended file paths.

Never blindly use:

```bash
git add .
```

when unrelated changes exist.

---

# 52. Command Cheat Sheet

```bash
az account show --output table

cat terraform/variables.tf

grep -nA12 "^## Standard Naming Pattern" docs/naming-standard.md

cat terraform/locals.tf

cat terraform/main.tf

terraform fmt -recursive terraform

terraform -chdir=terraform validate

terraform -chdir=terraform plan

terraform -chdir=terraform apply

terraform -chdir=terraform state list

terraform -chdir=terraform output

az group show --name rg-contoso-platform-prod-uks-001 --output table

az group show --name rg-contoso-platform-prod-uks-001 --output json

az resource list --resource-group rg-contoso-platform-prod-uks-001 --output table

az lock list --resource-group rg-contoso-platform-prod-uks-001 --output table

terraform -chdir=terraform plan

terraform fmt -check -recursive terraform

git status --short

git diff -- terraform/variables.tf terraform/locals.tf terraform/main.tf

git diff --cached --stat

git diff --cached --check

git commit -m "feat: implement Day 4 Azure platform foundation"

git add docs/day4-azure-management-study-guide.md

git diff --cached --stat

git diff --check -- docs/day4-azure-management-study-guide.md

git commit -m "docs: add Day 4 Azure management study guide"

git remote -v

git push origin develop
```

---

# 53. Portal Click Reference

| Task | Click path |
|---|---|
| Find Resource Groups | Search → Resource groups |
| Open permanent RG | Resource groups → rg-contoso-platform-prod-uks-001 |
| Region | RG → Overview |
| Visualiser | RG → Resource visualizer |
| Tags | RG → Tags |
| Properties | RG → Properties |
| Activity Log | RG → Activity log |
| Lock event | Activity log → Add filter → Operation name → Add management locks → Apply |
| Locks | RG → Settings → Locks |
| Training RG | Resource groups → Create |
| Training lock | Training RG → Settings → Locks → Add |
| Training cleanup | Training RG → Overview → Delete resource group |

---

# 54. Practice Checklist

- [ ] I can verify my Azure subscription.
- [ ] I can explain the naming pattern.
- [ ] I can explain every Day 4 Terraform variable.
- [ ] I can explain how locals create the name and tags.
- [ ] I can run and explain `terraform fmt`.
- [ ] I can run and explain `terraform validate`.
- [ ] I can run and read `terraform plan`.
- [ ] I can safely approve `terraform apply`.
- [ ] I can inspect Terraform state.
- [ ] I can inspect Terraform outputs.
- [ ] I can verify the Resource Group through Azure CLI.
- [ ] I can verify the lock through Azure CLI.
- [ ] I can find the Resource Group in Azure Portal.
- [ ] I can inspect Tags.
- [ ] I can inspect Properties.
- [ ] I can inspect the Activity Log.
- [ ] I can investigate an `Add management locks` event.
- [ ] I can find the management lock in Portal.
- [ ] I can create a disposable training Resource Group.
- [ ] I can create a disposable training lock.
- [ ] I can delete the training Resource Group.
- [ ] I understand why production resources are not recreated every day.
- [ ] I can run the final Terraform plan.
- [ ] I can interpret `No changes`.
- [ ] I can stage only intended Git files.
- [ ] I can review a Pull Request.
- [ ] I can explain why PR #6 was `develop → main`.

---

# 55. Production vs Training

| Area | Implemented / verified | Not claimed |
|---|---|---|
| Resource Group | Terraform-managed and deployed | Additional workload resources |
| Naming | Structured Resource Group naming | Full naming catalogue |
| Tags | Governance and cost-allocation tags | Full policy enforcement |
| Lock | Terraform-managed CanNotDelete | Organisation-wide automation |
| Portal | Inspection + temporary training | Portal as source of truth |
| CLI | RG + lock verification | Full operational automation |
| State | Terraform state for managed resources | Production remote backend |
| CI/CD | Git/GitHub PR workflow | Automated deployment pipeline |
| Networking | Not implemented | Day 4 network deployment |
| IAM | Not implemented | Day 4 IAM implementation |

---

# 56. Portfolio Evidence

```text
Resource Group:
rg-contoso-platform-prod-uks-001

Region:
uksouth

Lock:
platform-resource-group-cannot-delete

Lock level:
CanNotDelete

Terraform commit:
80f10fe

Study guide commit:
c149334

Pull Request:
#6

Promotion:
develop → main

Final plan:
No changes. Your infrastructure matches the configuration.
```

### Truthful portfolio statement

> I implemented and verified an enterprise-style Azure Resource Group foundation using Terraform, including structured naming, governance and cost-allocation tagging, and a Terraform-managed CanNotDelete management lock. I independently verified the deployed environment through Azure CLI, investigated management operations through Azure Portal Activity Log, completed a controlled Portal training exercise, and used Terraform plan to confirm that the managed environment matched the declared configuration. I delivered the cumulative Days 1–4 platform foundation through GitHub Pull Request #6 into main.

---

# 57. Day 4 Completion Gate

- PASS — Azure subscription context verified.
- PASS — Naming model implemented.
- PASS — Production-style Resource Group deployed.
- PASS — UK South verified.
- PASS — Governance tags verified.
- PASS — CanNotDelete lock implemented.
- PASS — Terraform state inspected.
- PASS — Terraform output inspected.
- PASS — Azure CLI Resource Group verification completed.
- PASS — Azure CLI lock verification completed.
- PASS — Azure resource inventory checked.
- PASS — Azure Portal inspection completed.
- PASS — Activity Log investigation completed.
- PASS — Permanent lock inspected without deleting it.
- PASS — Temporary Portal training completed.
- PASS — Temporary training Resource Group deleted.
- PASS — Final Terraform plan returned no changes.
- PASS — Day 4 study guide created.
- PASS — Terraform implementation committed as `80f10fe`.
- PASS — Documentation committed as `c149334`.
- PASS — Changes pushed to GitHub.
- PASS — PR #6 reviewed.
- PASS — PR #6 merged into `main`.

---

# 58. Engineering Mindset

Use this sequence whenever you manage Azure:

```text
STOP
↓
Inspect
↓
Understand why
↓
Check what already exists
↓
Make the smallest controlled change
↓
Format
↓
Validate
↓
Plan
↓
Read the plan
↓
Apply
↓
Verify Azure independently
↓
Inspect Portal
↓
Investigate Activity Log
↓
Plan again
↓
No changes
↓
Document
↓
Git
↓
PR
↓
Review
↓
Merge
```

The goal is not to memorise commands.

The goal is to know:

- why you are running the command;
- what it reads or changes;
- what result you expect;
- what evidence it provides;
- what to do if the result is unexpected.

---

# 59. Final Day 4 Statement

**DAY 4 — WEEK 1 — Sprint 1: Azure Platform Foundation & Azure Management is COMPLETE.**

The production-style platform Resource Group was deployed through Terraform, governed with a management lock, inspected through Azure Portal, verified through Azure CLI and reconciled through Terraform plan.

The Day 4 study guide and this complete engineer runbook document the work so it can be reproduced independently.

The cumulative Days 1–4 work was promoted from `develop` into `main` through Pull Request #6.

No additional workload resources, production remote Terraform backend infrastructure, CI/CD deployment automation, networking or IAM implementation are claimed as Day 4 work.
