# Day 3 — Terraform & Infrastructure as Code Study Guide

## Day 3 Objective

Understand how Terraform is used as Infrastructure as Code (IaC) to define, validate, version, review, and manage Azure infrastructure through an engineering-controlled workflow.

---

## 1. Infrastructure as Code (IaC)

### What is IaC?

Infrastructure as Code is the practice of defining and managing infrastructure through machine-readable configuration files rather than relying on unmanaged manual changes through the Azure portal.

### Why it matters

IaC makes infrastructure:

- Reproducible
- Traceable
- Reviewable
- Version controlled
- Consistent
- Automatable

### Contoso Holdings approach

Terraform is the primary Infrastructure as Code technology for the Azure platform.

The repository Engineering Standards require infrastructure definitions to be stored in source control and infrastructure changes to follow the branching, Pull Request, review, and approval process.

Reference:

docs/engineering-standards.md

---

## 2. Terraform

### Definition

Terraform is a declarative Infrastructure as Code tool used to define and manage infrastructure.

Terraform allows engineers to describe the desired infrastructure configuration while Terraform determines the actions required to reach that configuration.

### Production value

Terraform allows infrastructure changes to be:

- Version controlled
- Reviewed
- Validated
- Planned
- Reproduced
- Automated

---

## 3. Declarative Configuration

### Definition

Declarative configuration describes the desired outcome rather than requiring the engineer to manually specify every operation required to achieve it.

Example:

    resource "azurerm_resource_group" "platform" {
      name     = "${local.name_prefix}-rg"
      location = var.location
      tags     = local.common_tags
    }

This defines the desired Resource Group configuration.

---

## 4. Terraform Provider

### Definition

A Terraform provider is the component Terraform uses to interact with an external platform or service.

This project uses the AzureRM provider.

Example:

    provider "azurerm" {
      features {}
    }

The relationship is:

    Terraform
        |
        v
    AzureRM Provider
        |
        v
    Azure

### Provider version

The project requires:

    hashicorp/azurerm
    ~> 4.0

Terraform initialized the AzureRM provider at version:

    4.81.0

---

## 5. Terraform Resource

### Definition

A Terraform resource represents infrastructure that Terraform manages.

The initial platform resource is:

    resource "azurerm_resource_group" "platform"

This represents an Azure Resource Group managed by Terraform.

---

## 6. Terraform Variables

Variables allow configuration values to be supplied without hard-coding them throughout the Terraform configuration.

The project currently defines:

- location
- environment
- project_name
- owner

Example:

    variable "location" {
      type    = string
      default = "uksouth"
    }

### Why variables matter

Variables allow the same Terraform configuration to support different environments or approved deployment locations.

---

## 7. Variable Validation

The environment variable includes validation.

Example:

    validation {
      condition     = contains(["sandbox", "dev", "test", "prod"], var.environment)
      error_message = "Environment must be one of: sandbox, dev, test, prod."
    }

This prevents unsupported environment values from being accepted.

### Engineering principle

Validate configuration as early as possible so invalid input is detected before infrastructure deployment.

---

## 8. Terraform Locals

The project uses local values to create reusable configuration.

Example:

    locals {
      name_prefix = "${var.project_name}-${var.environment}"

      common_tags = {
        Environment = var.environment
        Project     = var.project_name
        Owner       = var.owner
        ManagedBy   = "Terraform"
      }
    }

### Name prefix

With the current defaults:

    project_name = contoso-platform
    environment  = sandbox

The resulting prefix is:

    contoso-platform-sandbox

This is used to construct the Resource Group name.

---

## 9. Resource Naming

The current Terraform foundation establishes a reusable naming pattern:

    <project>-<environment>-<resource>

Current example:

    contoso-platform-sandbox-rg

### Why naming matters

Consistent naming improves:

- Resource identification
- Operations
- Troubleshooting
- Governance
- Automation
- Resource inventory

---

## 10. Resource Tagging

Common tags are defined centrally.

Example:

    common_tags = {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }

### Why tags matter

Tags provide resource metadata that can support:

- Ownership
- Environment identification
- Governance
- Cost management
- Operations
- Automation

---

## 11. Terraform Outputs

The project defines an output for the Resource Group name.

Example:

    output "resource_group_name" {
      description = "Name of the platform Resource Group."
      value       = azurerm_resource_group.platform.name
    }

### Definition

A Terraform output exposes useful information from the Terraform configuration.

---

## 12. Terraform Provider Lock File

Terraform created:

    terraform/.terraform.lock.hcl

The lock file records the selected provider version and provider checksums.

The project currently records AzureRM provider version:

    4.81.0

with the provider constraint:

    ~> 4.0

### Why the lock file matters

It helps different engineers and environments use a consistent provider selection.

The lock file should be committed to source control.

---

# Terraform Workflow

## 13. terraform init

Command used:

    terraform init

### What it does

Initializes a Terraform working directory.

It can:

- Initialize Terraform
- Install required providers
- Create or update the provider lock file
- Initialize a configured backend

### Day 3 result

Terraform successfully installed:

    hashicorp/azurerm v4.81.0

and created the provider lock file.

---

## 14. terraform fmt

Command used:

    terraform fmt -recursive terraform

### What it does

Formats Terraform configuration files according to Terraform's standard formatting rules.

### Why we used it

Consistent formatting improves readability and makes code review easier.

---

## 15. terraform validate

Command used:

    terraform -chdir=terraform validate

### What it does

Checks whether the Terraform configuration is syntactically and structurally valid.

### Day 3 result

The configuration returned:

    Success! The configuration is valid.

### Important distinction

terraform validate does not prove that an Azure deployment will succeed.

It validates the Terraform configuration itself.

---

# Terraform State

## 16. Terraform State

### Definition

Terraform state is the record Terraform uses to track infrastructure managed by a Terraform configuration.

Terraform uses state when determining what infrastructure changes may be required.

### Day 3 verification

We ran:

    terraform -chdir=terraform state list

Terraform returned:

    No state file was found!

### Why?

The Terraform Resource Group configuration has not been deployed.

Therefore:

    Terraform configuration = exists
    Terraform state         = not created
    Azure deployment        = not performed

We must not claim that the Resource Group was deployed.

---

## 17. Terraform Backend

### Definition

A Terraform backend determines where Terraform stores and accesses its state.

For an enterprise platform, shared infrastructure should use an appropriately designed remote state solution rather than relying on an individual engineer's local state.

### Day 3 status

A remote backend was studied as a production concept but was not implemented.

The Azure environment was not available for safe backend infrastructure deployment.

---

## 18. Remote State

### Definition

Remote state means Terraform state is stored in a shared remote location rather than only on an engineer's local machine.

Conceptually:

    Engineer A \
    Engineer B  ---> Shared Terraform State
    CI/CD      /

### Production relevance

Remote state supports team-based infrastructure management and enables CI/CD systems to work with the same Terraform state.

---

## 19. State Locking

### Definition

State locking prevents multiple Terraform operations from modifying the same state simultaneously.

### Production relevance

State management requires deliberate consideration of:

- Security
- Storage
- Access control
- Backup
- Recovery
- Locking

The repository's Infrastructure as Code strategy explicitly identifies these considerations.

---

# Terraform Change Workflow

## 20. Terraform and Git

The Day 3 implementation followed a Git-based engineering workflow:

    Feature Branch
          |
          v
    Terraform Changes
          |
          v
    Formatting
          |
          v
    Validation
          |
          v
    Commit
          |
          v
    Push
          |
          v
    Pull Request
          |
          v
    Review
          |
          v
    Merge
          |
          v
    develop

### Actual Day 3 implementation

Feature branch:

    feature/day3-terraform-foundation

Terraform foundation commit:

    60c13c2

Pull Request:

    #5

Merge commit:

    dbf6823

The Terraform foundation was successfully merged into develop.

---

## 21. terraform plan

### Definition

terraform plan previews the changes Terraform proposes to make to infrastructure.

Possible plan actions include:

    + Create
    ~ Update
    - Destroy

### Production workflow

A production Terraform change should normally be reviewed before it is applied.

---

## 22. terraform apply

### Definition

terraform apply executes Terraform changes against the target environment.

A production-oriented workflow should use controlled review and approval rather than uncontrolled manual changes.

A controlled workflow is:

    Change
      |
      v
    Git
      |
      v
    Review
      |
      v
    Validation
      |
      v
    Plan
      |
      v
    Approval
      |
      v
    Apply
      |
      v
    Verification

### Day 3 status

No Azure resources were deployed as part of this Day 3 implementation.

---

# Production vs Current Environment

## 23. What We Actually Implemented

The following were implemented and verified:

- Terraform project structure
- Terraform version constraint
- AzureRM provider configuration
- Provider version constraint
- Provider lock file
- Location variable
- Environment variable
- Environment validation
- Project variable
- Owner variable
- Reusable naming convention
- Common resource tags
- Azure Resource Group Terraform definition
- Resource Group output
- Terraform initialization
- Terraform formatting
- Terraform validation
- Git feature branch workflow
- Pull Request
- Review
- Merge into develop

---

## 24. What Was Not Deployed

The following were not deployed during Day 3:

- Azure Resource Group
- Remote Terraform backend
- Production Terraform state storage
- Production state locking infrastructure
- Production CI/CD deployment pipeline

### Why

The current Azure environment was not available for safe deployment.

We therefore studied the production architecture without falsely claiming that it had been deployed.

### Engineering principle

Do not claim production implementation when only design or laboratory work has been completed.

---

# Key Terraform Vocabulary

| Term | Meaning |
|---|---|
| Infrastructure as Code | Managing infrastructure through code/configuration |
| Terraform | Declarative Infrastructure as Code tool |
| Declarative | Describes desired outcome |
| Provider | Connects Terraform to an external platform |
| Resource | Infrastructure managed by Terraform |
| Variable | Configurable input |
| Validation | Rules that reject invalid configuration |
| Local | Reusable value calculated inside Terraform |
| Output | Exposes useful Terraform information |
| State | Terraform's record of managed infrastructure |
| Backend | Determines where Terraform state is stored/accessed |
| Remote State | Terraform state stored remotely |
| State Locking | Prevents conflicting state operations |
| Plan | Preview of proposed infrastructure changes |
| Apply | Executes proposed infrastructure changes |
| Provider Lock File | Records provider selection and checksums |
| Drift | Difference between intended and actual infrastructure |
| Reproducibility | Ability to recreate consistent infrastructure |
| Declarative IaC | Infrastructure described by desired state |

---

# Interview Questions

## What is Terraform?

Terraform is a declarative Infrastructure as Code tool used to define and manage infrastructure through version-controlled configuration.

## What is the difference between a provider and a resource?

A provider allows Terraform to interact with an external platform such as Azure.

A resource represents a specific piece of infrastructure managed through that provider.

## Why is Terraform state important?

Terraform state allows Terraform to track infrastructure it manages and use that information when determining required changes.

## Why use remote state in an enterprise environment?

Remote state provides a shared location for Terraform state so engineers and automation can work from a common state rather than relying on individual local state.

## Why should Terraform changes go through Git and Pull Requests?

Git provides version history and traceability, while Pull Requests provide a controlled mechanism for reviewing infrastructure changes before they are merged and eventually deployed.

## What is the difference between terraform validate and terraform plan?

terraform validate checks whether the Terraform configuration is structurally valid.

terraform plan previews the changes Terraform proposes to make.

## Did you deploy the Azure Resource Group during Day 3?

No.

The Terraform configuration for the Resource Group was implemented and validated, but the Azure environment was not available for safe deployment.

---

# Portfolio Evidence

Day 3 provides evidence of practical Terraform engineering rather than only theoretical learning.

### Terraform implementation

    terraform/
    ├── .terraform.lock.hcl
    ├── locals.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    └── versions.tf

### Git evidence

    Feature branch:
    feature/day3-terraform-foundation

    Terraform foundation commit:
    60c13c2

    Pull Request:
    #5

    Merge commit:
    dbf6823

### Validation evidence

    terraform -chdir=terraform validate

    Result:
    Success! The configuration is valid.

---

# Day 3 Completion Checklist

## Engineering Implementation

- [x] Terraform foundation created
- [x] Terraform version constrained
- [x] AzureRM provider configured
- [x] Provider version constrained
- [x] Provider lock file created
- [x] Variables created
- [x] Environment validation created
- [x] Locals created
- [x] Naming convention created
- [x] Common tags created
- [x] Resource Group defined
- [x] Output created
- [x] Terraform initialized
- [x] Terraform formatted
- [x] Terraform validated
- [x] Git feature branch used
- [x] Pull Request created
- [x] Pull Request reviewed
- [x] Pull Request merged

## Production Knowledge

- [x] Infrastructure as Code
- [x] Declarative configuration
- [x] Terraform providers
- [x] Terraform resources
- [x] Variables
- [x] Locals
- [x] Outputs
- [x] Terraform state
- [x] Terraform backend
- [x] Remote state
- [x] State locking
- [x] Plan vs Apply
- [x] Git-based infrastructure workflow

## Documentation

- [x] Day 3 study guide created
- [ ] Study guide committed
- [ ] Study guide reviewed through Git workflow
- [ ] Day 3 formally closed

---

# Day 3 Summary

Day 3 established the initial Terraform Infrastructure as Code foundation for the Contoso Holdings Azure platform.

The implementation established reusable Terraform configuration, AzureRM provider management, variables, validation, naming, tagging, an initial Resource Group definition, outputs, and provider dependency locking.

The implementation was validated and moved through a Git feature branch and Pull Request workflow before being merged into develop.

Production state and backend architecture were studied but not deployed because the Azure environment was not available for safe implementation.

The result is a documented, version-controlled Terraform foundation that can be extended during subsequent platform implementation work.
