# Contoso Holdings — Day 14 Governance Review Meeting

## 1. Production Scenario

Day 14 represents a Contoso Holdings leadership governance review.

The Cloud Platform Engineer is required to present the Azure platform from four leadership perspectives:

1. Architecture — How Azure is organised
2. Security — How access is controlled
3. Finance — How costs are tracked
4. Operations — How changes are monitored

The purpose is not to introduce another Azure resource.

The purpose is to demonstrate that the engineer understands the governance platform built during Week 2 and can explain its business value, controls, risks and operational model to technical and business leadership.

---

## 2. Week 2 Context

Week 2 established the Enterprise Azure Governance & Platform Operating Model.

The engineering progression was:

Day 8 — Azure Resource Manager

Day 9 — Resource Organisation & Naming

Day 10 — Tags, Cost Governance and FinOps

Day 11 — RBAC Fundamentals

Day 12 — Azure Policy and Governance

Day 13 — Platform Self-Service / Operational Safety

Day 14 — Governance Review Meeting

Day 14 therefore brings the previous engineering work together into a leadership-level explanation.

---

## 3. Governance Review Model

```text
                    CONTOSO AZURE PLATFORM
                             |
          +------------------+------------------+
          |                  |                  |
     ARCHITECTURE        SECURITY           FINANCE
          |                  |                  |
     Organisation          RBAC              Tags
     Subscriptions         Policy            CostCentre
     Resource Groups       Least privilege   BusinessUnit
     Naming                Locks             Cost Management
     Terraform             Governance        FinOps
          |                  |                  |
          +------------------+------------------+
                             |
                         OPERATIONS
                             |
                    Activity Log
                    Terraform State
                    Monitoring
                    Diagnostics
                    Change Control
                    Incident Response
                             |
                             ↓
                  GOVERNED AZURE PLATFORM

---

## 4. Architecture Review

### Leadership question

How have you organised the Azure environment, and why does that matter to the business?

### Answer

I organised the Azure environment around clear management and resource boundaries rather than treating Azure as one flat collection of resources.

The model uses Management Groups, Subscriptions, Resource Groups and Azure resources, supported by consistent naming, tagging and Infrastructure as Code.

Resource Groups provide logical lifecycle boundaries for related workloads.

This matters because good organisation provides the foundation for governance. It makes it easier to apply Policy, RBAC, cost allocation, operational controls and lifecycle management consistently.

Without clear organisation, every resource becomes an individual exception and governance becomes difficult to scale.

---

## 5. Security Review

### Leadership question

How do you prevent engineers from having excessive access to Azure?

### Answer

I use least privilege and Role-Based Access Control.

Engineers should receive only the permissions required for their responsibilities rather than broad Owner permissions by default.

RBAC controls who can perform actions and allows permissions to be assigned at an appropriate scope such as Management Group, Subscription, Resource Group or Resource.

Where practical, access should be managed through groups and privileged access should be controlled and reviewed.

This reduces the blast radius of compromised accounts and operational mistakes.

---

## 6. RBAC Versus Azure Policy

### Leadership question

What problem does Azure Policy solve that RBAC does not?

### Answer

RBAC and Azure Policy solve different problems.

RBAC answers:

> Who is allowed to perform an action?

Azure Policy answers:

> What configuration or resource state is allowed or required?

An engineer may have permission to create a Storage Account while Policy can independently evaluate whether that Storage Account meets organisational requirements.

Therefore, permission to perform an action does not automatically mean that the resulting resource configuration is compliant.

---

## 7. Azure Policy

### Leadership question

Why is Azure Policy important to an enterprise platform?

### Answer

Azure Policy provides a mechanism to define, evaluate and, where appropriate, enforce organisational configuration standards.

It allows the organisation to identify resources that do not meet required standards.

This creates a consistent governance mechanism across the Azure estate rather than relying entirely on individual engineers remembering every requirement.

The business benefit is reduced configuration risk and improved visibility of compliance.

---

## 8. Non-Compliant Resources

### Leadership question

What do you do when Azure Policy reports that a resource is non-compliant?

### Answer

I would not immediately delete or modify the resource.

First I would identify which Policy evaluated the resource as non-compliant and determine exactly which condition failed.

I would then establish whether the resource is genuinely outside the organisational standard or whether an approved exception exists.

If it is genuinely non-compliant, I would assess the risk and determine the appropriate remediation through the normal controlled change process or Infrastructure as Code.

The objective is to turn compliance information into an informed operational decision.

---

## 9. Resource Locks

### Leadership question

Why did you introduce Resource Locks?

### Answer

A Resource Lock provides an additional protection layer against accidental destructive operations.

RBAC controls who is authorised to perform an operation, but an engineer with legitimate permissions can still make an operational mistake.

A CanNotDelete lock therefore provides defence in depth.

The lock does not replace RBAC, Policy or change control. It complements them.

---

## 10. Finance and FinOps

### Leadership question

How do we know which business unit is responsible for Azure expenditure?

### Answer

I introduced consistent resource tagging including BusinessUnit, CostCentre, Owner, Application and Environment.

The purpose is not simply to label resources.

The tags create an accountability structure that can be used alongside Azure Cost Management to understand where consumption is occurring and who owns the expenditure.

This allows the organisation to investigate unexpected consumption and gives teams greater accountability for the infrastructure they operate.

---

## 11. FinOps

### Leadership question

Is FinOps simply about reducing the Azure bill?

### Answer

No.

FinOps is about visibility, accountability, optimisation and informed decision-making.

The organisation needs to understand what it is spending, where the consumption is occurring, who owns it and whether that expenditure provides appropriate business value.

Cost optimisation should therefore be based on understanding the workload rather than simply deleting or reducing resources.

---

## 12. Operations Review

### Leadership question

What happens when someone makes an unexpected change to Azure?

### Answer

I would first establish what changed, who changed it and when.

I would investigate the Azure Activity Log and the relevant resource state.

I would then compare the actual Azure state with the intended Terraform configuration and Terraform state.

I would also review Git history and Pull Requests where appropriate.

The objective is to determine whether the difference represents an authorised change, configuration drift, an unmanaged manual change or another cause.

I would then choose the safest corrective action rather than blindly restoring the resource.

---

## 13. Terraform and Operational Control

### Leadership question

Why is Terraform important to operations?

### Answer

Terraform represents the desired infrastructure state as code.

This gives the platform team a repeatable way to deploy infrastructure and provides a reference point when investigating differences between the intended and actual Azure state.

Git provides the change history.

Pull Requests provide review and approval evidence.

Azure provides the actual deployed state.

Together these provide a stronger operational model than relying on manual Portal changes alone.

---

## 14. Portal Versus Terraform

### Leadership question

Why use Terraform if engineers can configure Azure through the Portal?

### Answer

The Portal is extremely useful for discovery, administration, troubleshooting and understanding how Azure works.

Terraform provides repeatability, consistency, reviewability and auditability.

During the platform work, I deliberately used the Portal first to understand the capability and what Azure actually created.

I then reproduced the capability in Terraform so the retained implementation was repeatable and reviewable through Git.

Therefore Portal and Terraform are complementary rather than competing tools.

---

## 15. Storage Self-Service Evidence

The Day 13 platform self-service implementation demonstrated the Portal-to-IaC approach.

The temporary Portal Storage Account was used to understand the required configuration.

The Terraform implementation then reproduced the retained capability.

The Terraform configuration included:

- HTTPS-only traffic
- TLS 1.2
- Shared Key disabled
- OAuth/default Microsoft Entra authentication enabled
- anonymous blob access disabled
- seven-day blob retention
- seven-day container retention
- platform tags
- Terraform management

The Terraform resource was:

`azurerm_storage_account.objective9_self_service`

The retained Storage Account was:

`stcontosobj9tf001`

---

## 16. Deliberate Failure Testing

### Leadership question

Why deliberately test a failure?

### Answer

A configuration value alone does not prove runtime behaviour.

During Day 13, Shared Key authentication was intentionally tested against the Terraform-created Storage Account.

Azure rejected the request with:

`KeyBasedAuthenticationNotPermitted`

This was a successful negative test because the expected security control was working.

The lesson is that production engineering should verify behaviour rather than assuming a successful deployment automatically means the design works correctly.

---

## 17. Configuration Investigation

During the Storage implementation, Azure reported:

`DefaultToOAuth: true`

while Terraform initially planned the provider default as false.

This was investigated rather than ignored.

The Terraform configuration was explicitly updated with:

`default_to_oauth_authentication = true`

Terraform was then formatted and validated.

The subsequent plan showed:

`default_to_oauth_authentication = true`

The resource was successfully deployed and Azure verification confirmed:

`DefaultToOAuth: true`

This demonstrated the importance of comparing Portal configuration, Terraform configuration and actual Azure state.

---

## 18. Leadership Challenge — Terraform Drift

### Question

Terraform says one thing but Azure shows another. What do you do?

### Answer

I would stop before applying further changes.

I would compare:

1. Terraform configuration
2. Terraform state
3. Actual Azure resource state
4. Git history
5. Recent authorised changes

I would establish why the difference exists.

It could be intentional manual change, provider behaviour, Azure-side modification or configuration drift.

Only after understanding the difference would I determine the corrective action.

I would not blindly apply Terraform simply because Terraform produced a plan.

---

## 19. Leadership Challenge — Cost Increase

### Question

A business unit's Azure bill suddenly increases. What do you do?

### Answer

I would use Azure Cost Management to identify where the increase occurred.

I would examine the relevant subscription, resource group, application, business unit, cost centre and individual resources.

I would compare current consumption against the historical baseline.

I would then determine whether the increase is legitimate workload growth, an expected change, inefficient consumption or unintended resource usage.

If optimisation is required, I would work with the owning team to identify options and quantify the expected benefit.

---

## 20. Leadership Challenge — Six-Month Improvement Plan

### Question

What would you improve if you owned the platform for the next six months?

### Answer

I would first establish the current platform maturity rather than immediately introducing more technology.

I would strengthen reusable Terraform modules, standardise naming and tagging, expand Policy coverage where there is a clear business requirement and improve identity controls around privileged access.

I would also improve monitoring, diagnostics, alerting and operational runbooks.

For delivery, I would strengthen CI controls around Terraform validation, security scanning, policy checks and plan review before changes reach protected branches.

Finally, I would introduce measurable platform objectives such as Policy compliance, cost allocation coverage, privileged-access exposure, deployment failure rate and mean time to recover.

This would allow the organisation to measure whether the platform is actually improving.

---

## 21. What I Learned

The most important lesson from the governance work is that cloud governance is not one control.

It is the combination of:

- Resource organisation
- Naming
- Tagging
- Identity
- RBAC
- Azure Policy
- Resource Locks
- FinOps
- Monitoring
- Infrastructure as Code
- Change control

These controls work together to create a governed Azure platform.

The objective is not simply to add restrictions.

The objective is to create an environment where the organisation understands:

- who owns resources;
- who can change them;
- what configuration is required;
- what resources cost;
- what changes occurred;
- and how problems can be investigated and recovered.

---

## 22. Day 14 Completion and Portfolio Evidence

### Completed

- [x] Governance Review Meeting
- [x] Architecture review
- [x] Security review
- [x] RBAC review
- [x] Azure Policy review
- [x] Resource Lock review
- [x] Finance and FinOps review
- [x] Operations review
- [x] Terraform operational model review
- [x] Portal versus Terraform model reviewed
- [x] Day 13 failure-testing evidence reviewed
- [x] Leadership questions prepared
- [x] Senior-engineer answers prepared

### Portfolio statement

During Week 2 of my Cloud Engineer residency, I developed and demonstrated an enterprise Azure governance model covering architecture, security, finance and operations.

I worked with Azure Resource Manager, resource organisation, naming, tagging, FinOps, RBAC, Azure Policy, resource locks and Infrastructure as Code.

I applied these concepts to production-style Azure scenarios rather than treating them as isolated theory.

Day 14 brought these engineering controls together in a simulated Contoso leadership governance review where I presented how the platform is organised, how access and configuration are controlled, how costs are attributed and how operational changes are investigated.

### Day 14 status

Engineering review: COMPLETE

Documentation: COMPLETE

Git: PENDING

GitHub: PENDING

The next activity is Git staging, review, commit, push, Pull Request and merge.

