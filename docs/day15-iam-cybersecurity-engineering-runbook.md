# CONTOSO HOLDINGS — DAY 15
# Enterprise IAM: Entra ID, Azure RBAC and GitHub OIDC

**Project:** Enterprise Azure Platform
**Day:** 15
**Theme:** Enterprise IAM Cybersecurity Engineering
**Role:** Cloud Engineer / IAM Engineer / Platform Engineer / DevOps / SRE
**Environment:** Microsoft Azure / Microsoft Entra ID / GitHub Actions / Terraform
**Repository:** Enterprise-Azure-Platform
**Location:** Azure UK South
**Document Type:** Engineering runbook and implementation record
**Evidence Standard:** Verified implementation and session evidence only

---

## 1. Production Scenario

### 1.1 Business Problem

Contoso Holdings requires an enterprise identity operating model that can support:

- employee onboarding;
- contractor onboarding;
- joiner/mover/leaver processes;
- group-based authorization;
- Azure resource access;
- least-privilege permissions;
- privileged-access controls;
- scalable identity provisioning;
- application and workload authentication;
- Infrastructure-as-Code delivery;
- controlled production deployments;
- security monitoring and incident investigation.

The organisation cannot safely scale identity management by manually assigning Azure permissions to individual users.

An individual-based access model creates operational and security problems:

- permissions become difficult to audit;
- employees can retain access after changing roles;
- leavers can retain inappropriate access if removal is missed;
- access decisions become dependent on individual administrator actions;
- onboarding becomes slow and inconsistent;
- large-scale onboarding becomes difficult to repeat;
- privileged permissions can accumulate;
- infrastructure automation may depend on long-lived credentials;
- production deployments may bypass formal change control.

The Day 15 engineering objective was therefore to build an identity and access model where identity, authentication, authorization, workload identity and controlled delivery are treated as connected security controls.

```text
IDENTITY
   |
   v
MICROSOFT ENTRA ID
   |
   v
AUTHENTICATION
   |
   v
AUTHORIZATION
   |
   +------------------------+
   |                        |
   v                        v
STANDARD ACCESS       PRIVILEGED ACCESS
                            |
                            v
                           PIM
   |
   v
AZURE RESOURCES
   |
   v
MONITORING / RESPONSE
```

Applications and workloads use a separate identity path:

```text
APPLICATIONS / WORKLOADS
          |
          v
    WORKLOAD IDENTITY
 Managed Identity / OIDC
          |
          v
    AZURE RESOURCES
```

---

## 2. Day 15 Context — Week 3 IAM Cybersecurity Engineering

### 2.1 Transition from Week 2 to Week 3

Day 15 begins Week 3 of the Cloud Engineer residency.

Week 2 established the Azure governance and platform operating model:

| Day | Engineering Focus |
|---|---|
| Day 8 | Azure Resource Manager |
| Day 9 | Resource Organisation and Naming |
| Day 10 | Tags, Cost Governance and FinOps |
| Day 11 | RBAC Fundamentals |
| Day 12 | Azure Policy and Governance |
| Day 13 | Platform Self-Service / Operational Safety |
| Day 14 | Governance Review |
| **Day 15** | **Enterprise IAM Cybersecurity Engineering** |

The significance of this transition is that the platform moves from primarily governing Azure resources to governing the identities that access those resources.

Identity therefore becomes a central security boundary.

### 2.2 Week 3 Theme

> **Identity Is The New Security Perimeter**

Modern cloud environments cannot rely solely on traditional network boundaries.

Users, administrators, applications, automation pipelines and services all require authenticated identities.

The security model therefore needs to answer:

- Who is requesting access?
- How was the identity authenticated?
- What is the identity allowed to do?
- At what scope can it operate?
- Is the access temporary or permanent?
- Is the identity human or workload-based?
- Who approved the access?
- How can the access be audited?
- How can access be removed?
- How would suspicious identity activity be investigated?

Day 15 establishes the foundation for answering these questions.

### 2.3 Day 15 Objectives

The Day 15 engineering objectives were to understand and implement:

- enterprise identity architecture;
- Identity and Access Management (IAM);
- Microsoft Entra ID;
- users and groups;
- authentication and authorization concepts;
- Azure RBAC;
- group-based access control;
- least privilege;
- scalable identity provisioning;
- Terraform-based identity management;
- workload identity;
- GitHub Actions authentication;
- OpenID Connect (OIDC);
- federated credentials;
- secure CI/CD authentication;
- Terraform remote state;
- production deployment approval;
- identity-related troubleshooting;
- IAM security considerations;
- operational cleanup and evidence.

The implementation deliberately connects identity engineering with cloud infrastructure engineering.

### 2.4 IAM Engineering Model

```text
                         ENTERPRISE IAM
                              |
          +-------------------+-------------------+
          |                   |                   |
          v                   v                   v
       IDENTITY          AUTHENTICATION       AUTHORIZATION
          |                   |                   |
      Entra ID          Password / MFA       Azure RBAC
      Users             Conditional Access   Groups
      Groups            SSO                  Scope
          |                   |                   |
          +-------------------+-------------------+
                              |
                              v
                         AZURE RESOURCES
                              |
                              v
                     MONITORING / AUDIT
```

The workload identity path used for GitHub Actions is:

```text
                   GITHUB ACTIONS
                         |
                         v
                    OIDC TOKEN
                         |
                         v
                MICROSOFT ENTRA ID
                         |
                         v
              FEDERATED CREDENTIAL
                         |
                         v
                 AZURE ACCESS TOKEN
                         |
                         v
                 AZURE / TERRAFORM
```

This avoids requiring a long-lived Azure client secret for the GitHub Actions deployment workflow.

---

## 3. Enterprise Identity Architecture

### 3.1 Human Identity Architecture

```text
                    EMPLOYEE
                       |
                       v
               MICROSOFT ENTRA ID
                       |
              +--------+--------+
              |                 |
              v                 v
             USER             GROUP
              |                 |
              |                 v
              |            RBAC ROLE
              |                 |
              +--------+--------+
                       |
                       v
                 AZURE SCOPE
                       |
                       v
                   RESOURCE
```

The user represents the identity.

The group represents membership and access grouping.

The Azure RBAC assignment determines what the group can do.

The scope determines where that permission applies.

This creates a separation between identity and authorization.

### 3.2 Group-Based Authorization

The design uses groups rather than assigning Azure RBAC directly to individual employees wherever possible.

```text
User
 |
 +---- Member of ----> Entra Security Group
                            |
                            +---- Reader ----> Azure Scope
```

For example:

```text
IAM Engineer
     |
     v
CONTOSO-IAM-DEV-TEST
     |
     v
Azure Reader
     |
     v
Defined Azure Scope
```

This is easier to change and audit than assigning the same permission directly to individual users.

When an employee changes role, the organisation can change group membership rather than rebuilding multiple individual Azure RBAC assignments.

When an employee leaves, access can be removed through the identity lifecycle process.

It also gives the access review process a clear group-to-role relationship.

### 3.3 Least Privilege

Least privilege means an identity should receive:

1. only the permissions required;
2. only at the required scope;
3. only for the required duration where possible;
4. through the appropriate identity mechanism.

```text
Incorrect:

User
 |
 +---- Owner
       |
       +---- Entire Subscription


Preferred:

User
 |
 +---- Group
       |
       +---- Reader
             |
             +---- Required Resource Group
```

The second model reduces the blast radius if an identity is compromised.

---

## 4. Activity Tile — Build and Automate Enterprise IAM

**Activity Tile:** Enterprise IAM Cybersecurity Engineering

**Role:** Cloud Engineer / IAM Engineer / Platform Engineer / DevOps / SRE

**Purpose:**
Design and implement an enterprise identity and access model using Microsoft Entra ID, Azure RBAC, Terraform and GitHub Actions workload identity.

**Change:**
Implement Entra users and groups, group-based Azure RBAC, controlled bulk identity onboarding, Terraform-managed IAM, GitHub Actions OIDC authentication, remote Terraform state and protected production deployment.

**Why it matters:**
Identity controls access to cloud resources and therefore directly affects security, compliance, operational resilience and business risk.

**Environment:**
Microsoft Azure, Microsoft Entra ID, GitHub Actions, Terraform and the Contoso Enterprise Azure Platform repository.

**Time:**
Day 15 hands-on implementation and troubleshooting session.

**Risk / Cost:**
Identity changes can affect access to Azure resources. Temporary identities and controlled test permissions were used during implementation. Production deployment access was protected through GitHub Environment approval and OIDC-based authentication rather than a long-lived Azure client secret.

**Success Evidence:**

- Enterprise IAM architecture documented;
- Entra groups implemented;
- group-based Azure RBAC implemented;
- Finance IAM/RBAC implemented;
- controlled IAM test employee implemented;
- 20-user Terraform onboarding implemented and tested;
- Terraform repeatability demonstrated;
- GitHub Actions CI implemented;
- OIDC authentication implemented;
- federated credentials configured;
- production Environment approval implemented;
- Terraform remote state implemented;
- successful production Terraform Apply completed;
- IAM and CI/CD failures investigated and resolved;
- two accidental orphan test groups identified and removed;
- operational evidence captured.

**Stage:**
Day 15 Enterprise IAM implementation, CI/CD engineering and operational closeout.

---

## 5. Enterprise IAM Design Principles

### 5.1 Identity Is Separate From Authorization

A core Day 15 principle is that creating an identity does not automatically determine what that identity can access.

```text
IDENTITY
   |
   v
Who are you?
   |
   v
AUTHENTICATION
   |
   v
Have you proved who you are?
   |
   v
AUTHORIZATION
   |
   v
What are you allowed to do?
   |
   v
SCOPE
   |
   v
Where are you allowed to do it?
```

This distinction is important for security design, troubleshooting and auditing.

A successful login does not mean that the identity should have access to a particular Azure resource.

Authentication and authorization failures therefore need to be investigated separately.

### 5.2 Human Identity Versus Workload Identity

Human identities and workloads have different lifecycle and authentication requirements.

Human identities represent:

- employees;
- contractors;
- administrators;
- engineers;
- business users.

Workload identities represent:

- GitHub Actions;
- applications;
- automation;
- services;
- infrastructure deployment processes.

Day 15 demonstrates workload identity through GitHub Actions OIDC.

The deployment workflow does not require a stored Azure client secret.

### 5.3 Group-Based Access

The preferred authorization pattern is:

```text
User
  |
  v
Entra Group
  |
  v
RBAC Role
  |
  v
Defined Scope
```

This allows the authorization policy to remain stable while membership changes according to the identity lifecycle.

### 5.4 Scope Is Part of the Security Boundary

An RBAC role cannot be evaluated safely without considering its scope.

The engineering model is:

```text
Principal + Role Definition + Scope = Permission
```

For example:

```text
CONTOSO-IAM-DEV-TEST
        +
      Reader
        +
Resource Group Scope
        =
Read Access at that Resource Group
```

Granting the same role at subscription scope produces a substantially larger permission boundary.

Therefore role and scope must always be reviewed together.

---

## 6. Microsoft Entra ID Implementation

### 6.1 Portal Practice

The Day 15 Portal exercise used Microsoft Entra ID as the central identity boundary.

Portal navigation:

```text
Azure Portal
   |
   v
Microsoft Entra ID
   |
   +---- Users
   |
   +---- Groups
   |
   +---- App registrations
   |
   +---- Enterprise applications
```

Before making an identity change, the engineer must confirm the correct tenant.

This is particularly important where multiple tenants or guest identities are present.

### 6.2 Development IAM Security Group

The Terraform-managed development IAM group was:

**Display name:** `CONTOSO-IAM-DEV-TEST`

**Object ID:** `17cb8bbe-3aff-4936-99af-abd353e3979d`

The group was used to demonstrate group-based IAM and Azure RBAC.

A duplicate similarly named group was encountered during the real session.

Its object ID was:

`5fc485de-2b82-411f-bcff-c03ceeec503d`

The operational lesson is:

> Never select an identity object solely because its display name looks correct when multiple objects have similar names.

Use immutable identifiers and inspect the object properties before applying access.

### 6.3 Finance Security Group

The Finance security group was:

**Display name:** `CONTOSO-IAM-FINANCE`

**Object ID:** `dfcfbcea-0ab8-49aa-a5c7-7ea75a21ec19`

The group demonstrates a business-aligned authorization boundary.

Rather than attaching Finance access to individual users, the group provides the authorization abstraction.

---

## 7. IAM Test Employee

### 7.1 Purpose

A controlled IAM test employee was created to validate the identity lifecycle pattern without using a real employee account.

**Display name:** `IAM IaC Test Employee`

**Object ID:** `5dde1c4c-f907-43ba-ac7c-71966d6f6a11`

The account was configured as a temporary test identity.

### 7.2 Bootstrap Password Model

Terraform used:

```hcl
password              = var.day15_test_user_password
force_password_change = true
```

The actual password value was deliberately kept out of source control.

The password is a bootstrap credential rather than a permanent identity secret.

`force_password_change = true` requires the user to change the initial password during first login.

This models an onboarding workflow more safely than treating the Terraform input password as the user's permanent credential.

### 7.3 Password Lifecycle Handling

The Terraform configuration also used:

```hcl
lifecycle {
  ignore_changes = [
    password
  ]
}
```

This was used in the controlled exercise because password representation and lifecycle are not suitable for continuous Terraform reconciliation.

This does not mean that password lifecycle can be ignored in production.

A production identity platform should define an approved process for:

- bootstrap credentials;
- password reset;
- MFA registration;
- credential expiry;
- account disablement;
- leaver processing.

Actual passwords must never be committed to Git.

---

## 8. Azure RBAC Implementation

### 8.1 RBAC Model

Day 15 implemented group-based Azure RBAC.

The fundamental model is:

```text
Entra Principal
      |
      v
Security Group
      |
      v
Azure RBAC Role
      |
      v
Azure Scope
```

The group receives the role rather than each user receiving an independent assignment.

### 8.2 Reader Role

The Reader role was used for controlled read-only access.

Reader is appropriate where an identity needs to inspect Azure resources without changing them.

This aligns with least privilege more closely than Contributor or Owner.

### 8.3 Portal Role Assignment Process

The controlled Portal workflow was:

1. Open Azure Portal.
2. Open the relevant Resource Group.
3. Select **Access control (IAM)**.
4. Select **Add → Add role assignment**.
5. On the Role tab select **Reader**.
6. Continue to Members.
7. Select **User, group, or service principal**.
8. Select the intended Entra security group.
9. Review role and scope.
10. Select **Review + assign**.
11. Reopen Role assignments.
12. Confirm the group has Reader at the intended scope.

The critical review is:

```text
WHO?
  |
  +-- Group

WHAT?
  |
  +-- Reader

WHERE?
  |
  +-- Intended Resource Group
```

A role assignment should not be approved without answering all three questions.

---

## 9. Finance IAM and RBAC

The Finance group was implemented as a separate business-aligned access boundary.

The engineering principle is:

```text
Finance Users
      |
      v
CONTOSO-IAM-FINANCE
      |
      v
Reader RBAC
      |
      v
Defined Azure Scope
```

This allows Finance access to be managed through membership rather than repeatedly creating individual Azure RBAC assignments.

The approach supports future lifecycle operations:

```text
JOINER
  |
  v
Add to approved group
  |
  v
Access inherited

MOVER
  |
  v
Change group membership
  |
  v
Access changes

LEAVER
  |
  v
Remove / disable identity
  |
  v
Access removed
```

The exact lifecycle process would normally integrate with an enterprise HR/JML process and identity governance platform.

---

## 10. Terraform IAM Implementation

### 10.1 Why Terraform

Terraform converts the IAM design into repeatable infrastructure code.

The benefits are:

- version control;
- review;
- repeatability;
- predictable changes;
- audit history;
- peer review;
- automated validation;
- controlled deployment;
- drift detection.

Instead of manually creating every identity, Terraform describes the intended state.

### 10.2 Terraform Provider

The project uses the AzureAD Terraform provider for Entra identity objects and AzureRM for Azure resources.

The AzureAD provider manages identity objects such as:

```text
azuread_user
azuread_group
azuread_group_member
```

AzureRM manages Azure infrastructure and RBAC resources.

This separates identity management from Azure resource management while allowing them to work together in one platform configuration.

### 10.3 Terraform IAM Pattern

The controlled IAM configuration included resources such as:

```hcl
resource "azuread_group" "day15_iam_dev_test" {
  display_name     = "CONTOSO-IAM-DEV-TEST"
  description      = "Temporary Terraform-managed security group for testing enterprise group-based IAM and Azure RBAC."
  security_enabled = true
  mail_enabled     = false
  mail_nickname    = "contoso-iam-dev-test"
}
```

The group then became the principal used by the Azure RBAC assignment.

The dependency chain is:

```text
Terraform
   |
   +---- Entra Group
             |
             v
        Object ID
             |
             v
       Azure RBAC
             |
             v
          Scope
```

---

## 11. Scalable Bulk User Onboarding

### 11.1 Why Bulk Onboarding

Enterprise organisations may need to onboard tens, hundreds or thousands of identities.

Creating each user manually does not scale.

Day 15 therefore used Terraform `for_each`.

Conceptually:

```hcl
resource "azuread_user" "day15_bulk_employee" {
  for_each = local.day15_employee_data

  user_principal_name = each.value.upn
  display_name        = each.value.display_name
  mail_nickname       = each.value.employee_id
  password            = var.day15_bulk_test_user_password
  force_password_change = true

  lifecycle {
    ignore_changes = [
      password
    ]
  }

  account_enabled = true
}
```

The important engineering point is that the resource definition is written once.

The input data determines how many instances Terraform manages.

### 11.2 20-User Canary

The design supported a larger rollout, but Day 15 deliberately used a 20-user canary.

The reason was risk control.

```text
1000 USERS
    |
    | Too large for first validation
    v
20-USER CANARY
    |
    +-- Validate creation
    +-- Validate attributes
    +-- Validate provider behaviour
    +-- Validate passwords
    +-- Validate state
    +-- Validate repeatability
    |
    v
Evidence
    |
    v
Scale decision
```

The 1000-user design was **not** deployed at 1000 users.

This distinction is important for truthful engineering evidence.

### 11.3 Canary Results

The controlled 20-user deployment was completed.

The users were verified.

The test demonstrated that the `for_each` model could manage multiple identities from one Terraform resource definition.

The engineering lesson is:

> Validate the pattern at bounded scale before increasing the blast radius.

---

## 12. Terraform Repeatability

A major requirement was to demonstrate that the implementation was repeatable.

After the initial deployment, Terraform was run again.

The desired result was:

```text
No changes.
Your infrastructure matches the configuration.
```

A no-change plan provides evidence that the declared configuration and Terraform's managed state agree at that point.

This is stronger evidence than simply observing that resources exist in the Portal.

It also establishes the foundation for drift detection.

---

## 13. Terraform State Architecture

### 13.1 Initial State Model

The project initially used local Terraform state.

This was acceptable for the early learning stages but is not the preferred production operating model for collaborative CI/CD.

The CI/CD workflow needs shared Terraform state with:

- controlled access;
- locking;
- durable storage;
- CI/CD access;
- auditability;
- protection from concurrent state modification.

### 13.2 Azure Storage Backend

A dedicated Azure Blob Storage container was introduced for Terraform state.

Storage account:

`stcontosogovtf001`

Resource Group:

`rg-contoso-platform-prod-uks-001`

Container:

`tfstate`

State key:

`contoso-platform.tfstate`

Backend configuration:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-contoso-platform-prod-uks-001"
    storage_account_name = "stcontosogovtf001"
    container_name       = "tfstate"
    key                  = "contoso-platform.tfstate"
    use_azuread_auth     = true
  }
}
```

### 13.3 Backend Authentication

The backend uses Microsoft Entra authentication rather than storage account access keys.

The signed-in identity required data-plane access to the Blob container.

The required role was:

**Storage Blob Data Contributor**

This is distinct from ordinary Azure management-plane access.

The practical takeaway is:

> Management-plane permissions do not automatically provide Blob data-plane permissions.

### 13.4 State Migration

The first backend migration attempt returned:

```text
403 AuthorizationPermissionMismatch
```

The state migration was not allowed to proceed without the required Blob data-plane permission.

After the appropriate `Storage Blob Data Contributor` permission was assigned, Terraform initialization was rerun and the state migration completed successfully.

Terraform then reported:

```text
Successfully configured the backend "azurerm"!
Terraform has been successfully initialized!
```

The state contained the expected existing resources, demonstrating that the migrated remote state was being used.

---

## 14. GitHub Actions Workload Identity

### 14.1 Why Workload Identity

CI/CD pipelines need Azure authentication.

A weak pattern is:

```text
GitHub Actions
      |
      v
Long-lived Azure client secret
      |
      v
Azure
```

The secret must be stored, rotated, protected and potentially revoked.

Day 15 implemented:

```text
GitHub Actions
      |
      v
OIDC token
      |
      v
Microsoft Entra ID
      |
      v
Federated credential
      |
      v
Azure access token
      |
      v
Azure / Terraform
```

This removes the requirement for a long-lived Azure client secret in GitHub.

### 14.2 GitHub Actions Application

The Entra App Registration was:

`Enterprise-Azure-Platform-GitHub-Actions`

Client ID:

`fe2cf9f5-4c17-4ef5-83c2-b558fcef34c4`

Service principal object ID:

`8b07c276-3150-4ca0-92ab-cbaa264c4dc7`

The application was used as the workload identity for GitHub Actions.

---

## 15. Microsoft Graph Permissions

Terraform's AzureAD provider needed Microsoft Graph permissions to manage Entra users and groups.

The application was initially configured with no required Graph permissions.

This caused Graph-related failures during CI.

The required Application permissions added were:

- `Group.ReadWrite.All`
- `User.ReadWrite.All`

Tenant-wide admin consent was then granted.

The permissions were selected to support the actual Terraform operations rather than granting the broader `Directory.ReadWrite.All` permission.

This was an important least-privilege decision.

The failure demonstrated a common production IAM dependency:

```text
Terraform
   |
   v
AzureAD Provider
   |
   v
Microsoft Graph
   |
   +---- Group permissions
   |
   +---- User permissions
```

If the deployment identity cannot perform the underlying Graph operation, Terraform cannot successfully manage the Entra objects.

---

## 16. GitHub Actions Workflow

The workflow was implemented in:

`.github/workflows/terraform-ci.yml`

Terraform was pinned to:

`1.15.9`

The workflow uses:

```yaml
permissions:
  id-token: write
  contents: read
```

The important security setting is:

```yaml
id-token: write
```

Without it, GitHub Actions cannot request the OIDC token required for Azure authentication.

### 16.1 Production Trigger

The production deployment path was restricted to:

```yaml
on:
  push:
    branches:
      - develop
```

The reason was security.

A production deployment identity should not automatically trust arbitrary feature-branch execution contexts.

The workflow therefore separates:

```text
Pull Request / Feature Work
          |
          v
      Validation / Plan

Develop
          |
          v
Production Apply
          |
          v
Human Approval
```

This reduces the workload identity trust boundary.

---

## 17. OIDC Federated Credentials

### 17.1 OIDC Trust Model

The Entra federated credential establishes trust between GitHub Actions and the Entra application.

The security boundary consists of:

- issuer;
- subject;
- audience.

The implementation used exact subjects rather than broad wildcard trust.

### 17.2 Develop Credentials

The application contained:

- `github-develop`
- `github-develop-immutable`

The immutable develop subject was:

```text
repo:yomiwip@184878261/Enterprise-Azure-Platform@1320275340:ref:refs/heads/develop
```

### 17.3 Production Environment Credential

When the GitHub production Environment was introduced, the OIDC subject changed.

The exact production subject observed during troubleshooting was:

```text
repo:yomiwip@184878261/Enterprise-Azure-Platform@1320275340:environment:production
```

The required production federated credential was therefore:

**Name:**

`github-production-immutable`

**Issuer:**

`https://token.actions.githubusercontent.com`

**Subject:**

```text
repo:yomiwip@184878261/Enterprise-Azure-Platform@1320275340:environment:production
```

**Audience:**

`api://AzureADTokenExchange`

The production credential was added as an exact trust entry.

No wildcard feature-branch trust was introduced.

---

## 18. OIDC Troubleshooting History

Day 15 deliberately preserved real authentication failures as engineering evidence.

### Failure 1 — Missing OIDC Permission

Error:

```text
Unable to get ACTIONS_ID_TOKEN_REQUEST_URL
```

Root cause:

The workflow did not request the GitHub OIDC token permission.

Fix:

```yaml
permissions:
  id-token: write
  contents: read
```

Result:

Azure OIDC authentication subsequently became available.

### Failure 2 — Feature Branch Subject Mismatch

The feature branch generated a subject containing:

```text
ref:refs/heads/feature/day15-cd-apply
```

The immutable develop credential trusted the develop branch, not the feature branch.

Rather than creating broad feature-branch trust, the deployment workflow was restricted to `develop`.

This was the smallest appropriate trust-boundary change.

### Failure 3 — Production Environment Subject Mismatch

After the production Environment was introduced, the token subject changed to:

```text
environment:production
```

Azure returned:

```text
AADSTS700213
```

Root cause:

No federated credential matched the exact production Environment subject.

Fix:

Create the exact production federated credential.

The engineering lesson was:

> Read the actual OIDC subject claim before changing Entra trust.

Do not respond to a subject mismatch by creating a wildcard credential.

### Failure 4 — Missing Azure RBAC Permission

The GitHub Actions service principal initially lacked permission to create Azure role assignments.

The relevant operation requires permission to write role assignments.

A Role Based Access Control Administrator assignment was subsequently configured at the required Resource Group scope.

The assignment was constrained with:

- Assignable role: `Reader`
- Assignable principal type: `Group`

This allowed the deployment identity to perform the specific Day 15 RBAC assignment pattern without giving unrestricted subscription-wide RBAC administration.

---

## 19. Production Deployment Control

### 19.1 Plan and Apply Separation

The GitHub Actions workflow separated Terraform Plan and Apply.

The model was:

```text
Git Push
   |
   v
Terraform Init
   |
   v
Terraform Validate
   |
   v
Terraform Plan
   |
   v
Plan Artifact
   |
   v
Production Environment
   |
   v
Human Approval
   |
   v
Terraform Apply
```

This is stronger than allowing every successful pipeline run to immediately modify production.

### 19.2 Why Approval Matters

Terraform Plan answers:

> What does Terraform intend to change?

Production approval answers:

> Is the organisation authorising this change to cross the production control boundary?

These are different decisions.

The production Environment therefore provides a formal change-control point.

### 19.3 Successful Apply

After the exact production OIDC trust was configured and the workflow was corrected, the production deployment path successfully completed.

The successful Apply result was:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

The corresponding Plan reported:

```text
No changes. Your infrastructure matches the configuration.
```

This is important evidence that the corrected CI/CD pipeline could authenticate, initialise the remote backend, acquire the Terraform state lock, refresh the managed resources and execute the approved Apply without unintended infrastructure changes.

---

## 20. Remote State in CI/CD

The successful GitHub Actions Plan demonstrated that CI/CD was using the remote Terraform state.

The workflow acquired the Terraform state lock and refreshed the existing managed resources.

This eliminated the earlier failure mode where CI had an empty/local state and therefore attempted to recreate resources that already existed.

That distinction was critical.

### Before remote state alignment

```text
GitHub Actions
      |
      v
Empty / incorrect state
      |
      v
Terraform believes resources are absent
      |
      v
Duplicate creation attempts
```

### After remote state alignment

```text
GitHub Actions
      |
      v
Azure Blob Terraform State
      |
      v
Existing resource ownership known
      |
      v
Terraform refresh
      |
      v
Correct Plan
      |
      v
Controlled Apply
```

This was one of the most important Day 15 production lessons.

---

## 21. Failure and Root-Cause Catalogue

### 21.1 Duplicate Entra Users

During an earlier CI run, the 20 users returned errors indicating that another object with the same UPN already existed.

Root cause:

CI was operating without the correct shared Terraform state and therefore attempted to create identities that already existed.

Lesson:

Terraform state ownership must be established before CI/CD manages an existing environment.

### 21.2 Duplicate Groups

Earlier failed execution created duplicate groups because the runner was not using the same authoritative state.

The duplicate groups were later inspected and confirmed to have:

- zero members;
- zero Azure RBAC assignments.

They were then explicitly deleted.

This cleanup was limited to the confirmed orphan groups.

### 21.3 Missing Graph Permissions

Root cause:

The GitHub Actions Entra application initially had no required Microsoft Graph Application permissions.

Fix:

Add:

- `Group.ReadWrite.All`
- `User.ReadWrite.All`

and grant tenant-wide admin consent.

### 21.4 Missing Role Assignment Permission

Root cause:

The GitHub Actions service principal could authenticate to Azure but could not create the required RBAC assignment.

Fix:

Assign the required Role Based Access Control Administrator permission at the appropriate Resource Group scope with constrained assignment conditions.

### 21.5 Remote Backend Permission Failure

Initial Terraform backend migration returned:

```text
403 AuthorizationPermissionMismatch
```

Root cause:

The signed-in identity did not have the required Blob data-plane permission.

Fix:

Assign:

`Storage Blob Data Contributor`

at the storage account scope.

Terraform backend migration then succeeded.

---

## 22. Security Review

Day 15 security controls include:

### Identity Boundary

Microsoft Entra ID is used as the enterprise identity boundary.

### Group-Based Authorization

Groups are preferred over direct individual RBAC assignments where practical.

### Least Privilege

Roles and scopes are reviewed together.

### Workload Identity

GitHub Actions uses OIDC instead of a long-lived Azure client secret.

### Exact OIDC Trust

Federated credentials use exact subjects.

Wildcard trust was deliberately avoided.

### Production Approval

Apply is protected by the GitHub production Environment.

### Secret Protection

Temporary test passwords are supplied through GitHub secrets and are not documented in source control.

### Temporary Privileges

Temporary elevated deployment access must be removed after the exercise.

### Auditability

Git, GitHub Actions, Terraform state and Azure logs provide evidence of changes and deployment activity.

---

## 23. Reliability and Operations Review

### 23.1 Canary Strategy

A bounded 20-user canary was used before considering larger onboarding.

### 23.2 Repeatability

Terraform was rerun to establish no-change behaviour.

### 23.3 Saved Plan

The Apply stage uses the reviewed Terraform plan artifact.

### 23.4 Approval Gate

Production Apply requires explicit approval.

### 23.5 Remote State

Azure Blob Storage provides shared Terraform state.

### 23.6 Failure Preservation

Real failures were retained as evidence rather than bypassed.

### 23.7 Monitoring

A production IAM operating model should monitor:

- Entra sign-in logs;
- Entra audit logs;
- group membership changes;
- privileged role activation;
- service-principal activity;
- failed authentication patterns;
- risky sign-ins where available;
- GitHub Actions deployment activity.

Alerts should map to ownership and incident-response procedures.

---

## 24. Compliance and Governance

Day 15 supports governance through:

- documented access roles;
- defined scopes;
- group-based authorization;
- Git-based change history;
- Pull Request review;
- production approval;
- Terraform state;
- identity audit logs;
- controlled workload identity;
- explicit cleanup.

The important governance principle is that access should be:

**Requested → Approved → Provisioned → Used → Audited → Reviewed → Removed**

where the organisation's identity governance process requires each stage.

---

## 25. Cost Review

Identity resources do not create Azure compute consumption by themselves.

However:

- Entra licensing may have commercial implications depending on tenant licensing;
- Azure resources modified or created through Terraform may incur normal Azure charges;
- temporary resources must not be left running;
- unnecessary privileged access should be removed;
- cost savings should never be claimed without measured evidence.

Day 15 did not introduce a permanent compute workload.

---

## 26. Testing Matrix

| Test | Purpose | Evidence / Result |
|---|---|---|
| Positive | Create intended IAM objects | 20-user controlled deployment completed; Finance group provisioned |
| Negative | Test unsupported authentication/trust path | OIDC subject mismatches deliberately exposed |
| Permission | Verify intended RBAC | Group-based Reader model implemented |
| Configuration | Validate Terraform | Terraform validation succeeded |
| Repeatability | Detect unnecessary changes | No-change Terraform plan achieved |
| Safe failure | Allow security boundary to reject invalid trust | `AADSTS700213` exposed exact subject mismatch |
| Cleanup | Remove temporary identities/privileges | Orphan groups removed; temporary identity cleanup remains controlled follow-up |
| Drift | Detect state/configuration mismatch | Remote-state Plan used as drift evidence |

---

## 27. Terraform Operational Model

All Terraform operations must be executed from the repository root using the project-standard form:

```bash
terraform -chdir=terraform <command>
```

Examples:

```bash
terraform -chdir=terraform fmt
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan
terraform -chdir=terraform apply
terraform -chdir=terraform output
terraform -chdir=terraform destroy
```

### Operational Rules

`fmt`:

Ensures Terraform code follows standard formatting.

`init`:

Initialises providers and the configured backend.

`validate`:

Checks Terraform configuration for structural and syntax errors.

`plan`:

Shows the proposed changes without applying them.

`apply`:

Executes an approved change.

`output`:

Displays configured Terraform outputs.

`destroy`:

Destructive and must never be used against the whole Day 15 environment without explicit review.

Day 15 cleanup must remain scoped to temporary resources.

---

## 28. Git and Change-Control Model

Day 15 used Git-based change control.

The expected production workflow is:

```text
Feature Branch
     |
     v
Implementation
     |
     v
Terraform Validation
     |
     v
Plan
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
Merge to develop
     |
     v
CI
     |
     v
Production Approval
     |
     v
Apply
```

This provides traceability between:

- engineer;
- code change;
- validation;
- review;
- approval;
- deployment;
- resulting infrastructure state.

---

## 29. Portfolio Evidence — What I Actually Did

### Situation

Contoso needed scalable identity onboarding and controlled infrastructure deployment without relying on long-lived Azure credentials.

### Task

I implemented enterprise IAM, group-based Azure RBAC, scalable Terraform onboarding and a controlled GitHub Actions deployment path.

### Action

I designed Entra security groups and role assignments, provisioned a controlled 20-user canary using Terraform `for_each`, implemented temporary first-login password change, introduced GitHub Actions OIDC using exact immutable GitHub subjects, restricted deployment to `develop`, created a protected production Environment and required human approval.

I investigated real OIDC failures caused first by a missing OIDC permission, then by a feature-branch subject mismatch and finally by the production Environment subject. I used the actual identity claims and Azure errors to identify the trust mismatch instead of weakening the trust model with a wildcard.

I also migrated Terraform state to an Azure Blob backend using Entra authentication, resolved Blob data-plane permissions, corrected Microsoft Graph application permissions and established the required scoped RBAC capability for the deployment identity.

### Result

The implementation demonstrated:

- enterprise IAM architecture;
- group-based authorization;
- least-privilege RBAC;
- scalable Terraform identity provisioning;
- workload identity;
- OIDC;
- remote Terraform state;
- GitHub Actions CI/CD;
- production approval;
- evidence-based troubleshooting;
- controlled cleanup.

The final successful Apply completed with:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

---

## 30. Interview Questions and Answers

### 1. Why did you use Entra groups instead of assigning RBAC directly to users?

I used groups because the business requirement is lifecycle-oriented access rather than person-specific permission. A user's joiner, mover or leaver event changes group membership while the RBAC policy remains stable. This reduces administrative duplication, improves auditability and makes access reviews more manageable.

### 2. Why is Reader safer than Contributor for planning?

A planning identity should normally be able to inspect the environment and dependencies without modifying infrastructure. Reader therefore aligns more closely with least privilege. Apply permissions should be separated and scoped to the minimum required capability.

### 3. Why did you use a 20-user canary instead of 1000 users?

I wanted to validate the onboarding pattern before increasing the blast radius. The Terraform `for_each` design can scale, but the controlled canary provided evidence about identity creation, attributes, password handling and provider behaviour before a larger rollout. I explicitly document that 1000 users were designed for, not deployed.

### 4. What does `force_password_change = true` achieve?

It makes the initial password a bootstrap credential. The user must change it at first login, reducing the lifetime of the initial credential.

### 5. Why use `ignore_changes` on passwords?

In this controlled exercise it prevents Terraform from repeatedly reconciling a password value whose lifecycle is intentionally handled as a bootstrap secret. It should not be used to hide an actual production security requirement.

### 6. Explain the OIDC design.

GitHub Actions obtains an OIDC token and presents it to Microsoft Entra ID. Entra validates the issuer, audience and exact federated subject before issuing an Azure access token. This removes the need for a long-lived Azure client secret in GitHub.

### 7. What was the most important OIDC troubleshooting lesson?

The subject claim is part of the security boundary. The feature branch, `develop` branch and production Environment produced different subjects. Reading the actual claim from the log allowed me to identify the exact missing trust relationship.

### 8. Why not create a wildcard federated credential?

A wildcard would widen the trust boundary and potentially allow unintended branches or execution contexts to obtain Azure tokens. Exact subjects provide stronger workload identity isolation.

### 9. Why do you need production approval if Terraform Plan succeeded?

Plan answers what Terraform intends to change. Approval answers whether the organisation authorises that change to cross the production boundary. Separating those decisions creates a change-control point and audit evidence.

### 10. What did the failed Apply tell you?

The production approval gate had worked. The remaining failure was Azure authentication trust. `AADSTS700213` and the exact `environment:production` subject narrowed the problem to Entra federated credential configuration.

### 11. How would you improve the deployment identity?

I would separate the read-only planning identity from the deployment identity, scope deployment permissions to the resources actually managed and avoid unrestricted subscription-level Contributor. Privileged human access should use mechanisms such as PIM where appropriate.

### 12. How would you handle a 1000-user onboarding failure halfway through?

I would stop expansion, identify the affected subset using Terraform state and logs, separate transient API failures from permission or data-quality problems, and reconcile only the affected identities. I would not manually recreate users.

### 13. How would you prove there is no Terraform drift?

I would run a Terraform Plan against the authoritative remote state. A no-change result provides evidence that the declared configuration matches the managed state at that point.

### 14. What would you monitor in production IAM?

I would monitor Entra sign-ins, audit events, group membership changes, privileged role activation, service-principal activity, failed authentication patterns, risky sign-ins where available and CI/CD deployment events.

### 15. What is the business value of this work?

It turns identity from a collection of manual permissions into an auditable operating model. Access is grouped, onboarding is repeatable, workload authentication avoids long-lived secrets and infrastructure changes pass through review and approval.

### 16. How would you explain this to a non-technical director?

We built a controlled identity system where people receive the right access through groups, automation can authenticate without stored Azure passwords and infrastructure changes cannot reach protected deployment stages without technical validation and explicit approval.

### 17. What would you do if a developer requested Owner on production?

I would clarify the business requirement, determine the minimum required permission and scope, and avoid granting Owner by default. If elevated access were genuinely necessary, I would use an appropriate privileged-access process such as PIM with approval and time limits.

### 18. What would you do if Terraform suddenly proposed a large destroy?

I would stop the deployment. I would inspect the exact plan, state ownership, configuration history, replacement reasons and imports before approving anything. I would not apply an unexplained destructive plan.

### 19. Why is GitHub PR evidence important?

Production engineering requires traceability. The organisation needs to know what changed, who reviewed it, what tests passed, what failed and how the change reached the deployment boundary.

### 20. What is your strongest Day 15 engineering lesson?

My strongest lesson is to troubleshoot from actual control-plane evidence. The OIDC failures looked similar initially, but the subject claim changed between feature branch, develop and production Environment. Reading the claim precisely prevented weakening the trust model and led to the smallest correct fix.

---

## 31. Operational Cleanup Status

### Completed

- Two accidental orphan Entra groups were confirmed to have zero members and zero Azure RBAC assignments.
- The two orphan groups were explicitly deleted.
- Terraform remote state is now authoritative for the managed platform.
- Production Apply completed successfully.

### Outstanding / Controlled Follow-Up

The remaining temporary Terraform-managed identities are:

- `day15_bulk_employee["emp001"]` through `["emp020"]`;
- `day15_iam_dev_test_employee`;
- associated temporary IAM membership and group/RBAC configuration.

These should not be removed through ad-hoc Azure deletion.

If they are no longer required, their removal should be handled through the normal Terraform reviewed change process.

The project must not use:

```bash
terraform -chdir=terraform destroy
```

against the whole environment for this cleanup.

The Terraform configuration contains permanent platform and governance resources.

Cleanup must be scoped and reviewed.

### Legacy OIDC Credential

The legacy `github-develop` federated credential should be reviewed after the immutable develop and production credentials have been proven.

It should only be removed once confirmed obsolete.

### Temporary Elevated Access

Any temporary elevated Azure permission introduced solely for controlled Day 15 deployment testing should be removed after the evidence has been captured.

---

## 32. Verified Current State

These values were checked during the Day 15 engineering session and subsequent closeout work:

| Item | Verified Value |
|---|---|
| Subscription | Azure subscription 1 |
| Subscription ID | `eb1f07b2-12b1-417e-80d0-fe08c2376f5a` |
| Tenant ID | `59d35c79-722f-48ec-b8c5-03218a073cc4` |
| Repository | `yomiwip/Enterprise-Azure-Platform` |
| Platform RG | `rg-contoso-platform-prod-uks-001` |
| FinOps RG | `rg-contoso-finops-lab-uks-001` |
| Governance RG | `rg-contoso-governance-day11-uks-001` |
| IAM group | `CONTOSO-IAM-DEV-TEST` |
| IAM group object ID | `17cb8bbe-3aff-4936-99af-abd353e3979d` |
| Finance group | `CONTOSO-IAM-FINANCE` |
| Finance group object ID | `dfcfbcea-0ab8-49aa-a5c7-7ea75a21ec19` |
| IAM test employee object ID | `5dde1c4c-f907-43ba-ac7c-71966d6f6a11` |
| GitHub Actions App | `Enterprise-Azure-Platform-GitHub-Actions` |
| GitHub Actions Client ID | `fe2cf9f5-4c17-4ef5-83c2-b558fcef34c4` |
| Service Principal Object ID | `8b07c276-3150-4ca0-92ab-cbaa264c4dc7` |
| Terraform version | `1.15.9` |
| Terraform backend storage | `stcontosogovtf001` |
| Terraform backend container | `tfstate` |
| Terraform backend key | `contoso-platform.tfstate` |
| Production Environment | `production` |
| Production Apply | Successful |
| Apply result | `0 added, 0 changed, 0 destroyed` |

Do not place passwords, client secrets, tokens or other credentials in this document.

---

## 33. Day 15 Completion Gate

### Engineering

- [x] IAM architecture
- [x] Entra security groups
- [x] Finance group/RBAC
- [x] IAM test employee
- [x] Temporary first-login password-change configuration
- [x] Terraform IAM provisioning
- [x] `for_each` bulk onboarding
- [x] 20-user controlled canary
- [x] 20 users created and verified
- [x] Terraform repeatability
- [x] GitHub Actions CI
- [x] Terraform version pin
- [x] GitHub Actions Entra application
- [x] Service principal
- [x] OIDC federation
- [x] Immutable OIDC subject handling
- [x] `id-token: write`
- [x] Azure OIDC authentication
- [x] GitHub Actions Reader access
- [x] Remote Terraform backend
- [x] Terraform Plan
- [x] Production Environment approval
- [x] Production CD Apply
- [x] Two confirmed orphan groups removed

### Documentation / Closeout

- [ ] Final temporary Terraform-managed identity cleanup
- [ ] Legacy OIDC credential review/removal
- [ ] Final documentation Git delivery
- [ ] Final portfolio evidence commit

These remaining items are deliberately kept separate from the already-proven Day 15 implementation so that incomplete cleanup is not falsely reported as complete.

---

## 34. What I Learned

The main Day 15 takeaway was that IAM is not just creating users. The useful control is the chain from identity to authentication, authorization, scope and the resource being protected.

The platform must connect:

```text
Identity
   |
Authentication
   |
Authorization
   |
Scope
   |
Infrastructure
   |
CI/CD
   |
Monitoring
   |
Incident Response
```

The other important takeaway was workload identity. GitHub Actions needed its own trust boundary, just as a human identity does.

GitHub Actions OIDC demonstrated that:

- trust must be explicit;
- claims matter;
- branch context matters;
- environment context matters;
- broad wildcard trust is dangerous;
- authentication failure can be a security control working correctly.

The third major lesson was that Terraform state is part of the production control plane.

A correct Terraform configuration with incorrect or missing state can still produce dangerous duplicate-resource behaviour.

---

## 35. Independent Practice — Day 15 Without the Answer

A future independent reproduction should follow this sequence:

1. State the production IAM problem in your own words.
2. Open the Enterprise-Azure-Platform repository and confirm `develop`.
3. Inspect existing Terraform before changing anything.
4. Reproduce the identity architecture diagram.
5. Open Azure Portal and navigate to Microsoft Entra ID.
6. Inspect the development security group.
7. Inspect the Finance group.
8. Inspect the IAM test employee.
9. Inspect group-based Reader RBAC.
10. Open the GitHub Actions App Registration.
11. Inspect federated credentials.
12. Run Terraform initialization.
13. Run Terraform formatting validation.
14. Run Terraform validation.
15. Generate and inspect an IAM plan.
16. Deploy the controlled IAM test configuration after reviewing the plan.
17. Verify Terraform state and live Entra objects.
18. Run the 20-user canary.
19. Verify first-login password-change configuration.
20. Run a no-change Terraform plan.
21. Review GitHub Actions workflow permissions.
22. Review the Terraform version.
23. Review the CI Plan job.
24. Review the production Environment protection rule.
25. Review the CD Apply job.
26. Read the OIDC subject from the Actions log.
27. If the subject does not match Entra, stop and correct the trust.
28. Do not create wildcard federation.
29. Capture successful Apply evidence.
30. Perform controlled cleanup.
31. Run final Terraform validation and Plan.
32. Confirm temporary resources are not left behind.
33. Document failures and root causes.
34. Commit and push through Git.
35. Open and review the Pull Request.
36. Merge through the approved branch workflow.

---

## 36. Day 15 Portfolio Statement

> During my enterprise cloud engineering residency, I implemented a production-oriented IAM and CI/CD control model using Microsoft Entra ID, Azure RBAC, Terraform and GitHub Actions.
>
> I designed group-based authorization, implemented a controlled 20-user onboarding canary using Terraform `for_each`, introduced workload identity through GitHub OIDC and protected production deployment with a GitHub Environment approval gate.
>
> I encountered and resolved real authentication, Microsoft Graph, RBAC and Terraform state failures. Rather than weakening security controls, I investigated the actual Azure and GitHub control-plane evidence and implemented the smallest appropriate fixes.
>
> I also migrated Terraform from local state to an Azure Blob remote backend using Entra authentication, established controlled CI/CD state access and successfully executed the production Apply path with zero infrastructure changes.
>
> The result was a repeatable, auditable identity and infrastructure delivery model with stronger separation of identity, authorization, workload authentication and production change control.

---

## 37. Final Day 15 Engineering Summary

Day 15 transformed the Azure platform from a governance-focused environment into an identity-aware engineering platform.

The final operating model is:

```text
                  CONTOSO AZURE PLATFORM
                           |
          +----------------+----------------+
          |                                 |
          v                                 v
     HUMAN IDENTITY                    WORKLOAD IDENTITY
          |                                 |
     Entra ID                           GitHub OIDC
          |                                 |
     Groups / Users                    Federated Trust
          |                                 |
       Azure RBAC                         Azure
          |                                 |
          +---------------+-----------------+
                          |
                          v
                  GOVERNED RESOURCES
                          |
                          v
                  Terraform State
                          |
                          v
                 GitHub CI/CD
                          |
                          v
                Production Approval
                          |
                          v
                      APPLY
                          |
                          v
                Audit / Monitoring
```

The Day 15 engineering objective was therefore achieved at the implementation level: identity, authorization, workload identity, Infrastructure as Code, remote state, CI/CD and production change control were connected into one operating model.
