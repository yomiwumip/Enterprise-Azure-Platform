# Day 6 — Platform Health Automation
## Complete Cloud Platform Engineer Runbook

**Contoso Holdings — Enterprise Azure Platform**

**Cloud Platform Engineer Residency — Week 1 / Sprint 1**

---

# 1. Purpose

Day 6 extends the Day 5 automation foundation into reusable platform health automation.

The objective is to move from:

Manual Azure checks
→ individual operational scripts
→ Terraform-driven configuration
→ reusable platform health automation.

The automation retrieves the Resource Group name from the existing Terraform output rather than hard-coding the production Resource Group name.

It validates:

- Terraform can provide the Resource Group name.
- The Azure Resource Group exists and can be queried.
- The required `CanNotDelete` management lock exists.
- The platform foundation can therefore be reported as `HEALTHY`.

---

# 2. Day 6 Engineering Outcome

Day 6 introduces:

- Terraform-to-Bash configuration consumption.
- Portable Bash automation.
- Resource Group validation.
- Management lock validation.
- Explicit success and failure states.
- Working-directory independence.
- Reusable operational health checking.

The final operational flow is:

```text
Terraform State
      |
      v
Terraform Output
      |
      v
Bash Platform Health Script
      |
      +----------------------+
      |                      |
      v                      v
Resource Group          Management Lock
Validation              Validation
      |                      |
      +----------+-----------+
                 |
                 v
       PLATFORM HEALTH
        HEALTHY / FAILED

# 4. Existing Terraform Configuration

Before creating new automation, the existing Terraform configuration was inspected.

The purpose was to identify the existing source of truth for:

- Resource Group naming.
- Azure location.
- Environment classification.
- Platform ownership.
- Resource numbering.
- Terraform outputs.

## Terraform Variables

The existing `terraform/variables.tf` defines:

```text
location
environment
project_name
workload
region_code
resource_number
owner
cost_centre
application

# 5. Terraform Output Verification

The existing Terraform output was verified before being consumed by automation.

## Command

```bash
terraform -chdir=terraform output -raw resource_group_name


# 7. Day 6 Platform Health Automation

The new Day 6 automation was created at:

```text
scripts/platform-context.sh


# 12. Portability Test and Real Defect Discovered

A deliberate portability test was performed by running the script from the `scripts` directory rather than from the repository root.

## Test

The script was executed from:

```text
Enterprise-Azure-Platform/scripts
