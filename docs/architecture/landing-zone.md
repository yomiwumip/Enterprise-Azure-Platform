# Contoso Holdings Azure Landing Zone Architecture

Document Owner: Cloud Platform Engineering
Organisation: Contoso Holdings
Document Status: Draft
Version: 0.1
Last Updated: 8 August 2026

## Purpose

This document defines the proposed Azure Landing Zone architecture for Contoso Holdings. It establishes the structural foundation for governing, securing, connecting, monitoring, and operating Azure workloads across the organisation.


## Scope

This architecture covers the foundational Azure platform required to onboard and operate Contoso Holdings workloads.

The scope includes:

- Microsoft Entra ID and Azure identity boundaries
- Management group and subscription organization
- Platform and workload separation
- Azure governance and policy structure
- Shared platform services
- Network and connectivity foundations
- Security and monitoring foundations
- Resource organization and tagging
- Cost management boundaries
- Infrastructure as Code and platform change management

Application-specific architecture, application code, and detailed workload design are outside the scope of this document unless they directly affect the shared Azure platform.


## Architecture Principles

The Contoso Holdings Azure Landing Zone will be designed and operated according to the following principles:

- Security must be considered as part of the platform design rather than added after deployment.
- Access must follow the principle of least privilege.
- Platform services and application workloads must have clearly defined ownership and boundaries.
- Governance should be applied consistently through Azure Policy and other automated controls where practical.
- Infrastructure should be deployed and managed using Infrastructure as Code.
- Production changes must be traceable through source control and an approved change process.
- Shared platform services should be centrally managed where this provides operational, security, or cost benefits.
- Workloads should remain independently manageable where their operational or security requirements differ.
- Azure resources and services must be deployed only after service, region, SKU, and quota availability has been verified.
- Monitoring, logging, backup, disaster recovery, and cost management must be considered during platform design.
- Architecture decisions must be documented and reviewed as the platform evolves.


## Identity and Tenant Boundary

Contoso Holdings will use Microsoft Entra ID as the identity platform and security boundary for the Azure environment.

Azure subscriptions and management groups will operate within the Contoso Holdings Microsoft Entra tenant.

Human access to Azure resources will use Microsoft Entra identities and will be controlled through Azure role-based access control. Access should be assigned through groups wherever practical rather than directly to individual users.

Workload and platform services should use managed identities where supported instead of storing credentials in application configuration.

The identity architecture must support centralised governance while allowing workload subscriptions to maintain appropriate operational boundaries.


## Management Group Strategy

Contoso Holdings will use Azure Management Groups to organise subscriptions and apply governance consistently across the Azure platform.

The management group hierarchy will remain deliberately simple and will primarily represent governance boundaries rather than the full organisational structure of the company.

The tenant root management group will contain an intermediate Contoso Holdings management group. Azure subscriptions will then be organised beneath management groups according to their platform, security, workload, sandbox, or lifecycle responsibilities.

The initial management group structure is:

- Contoso
  - Platform
  - Security
  - Landing Zones
  - Sandboxes
  - Decommissioned

Management Groups will be used primarily for governance and policy inheritance. Subscription-level and resource-level controls will be used where more specific scope is required.

The management group hierarchy must be reviewed as the platform grows. New management groups should only be introduced where they provide a clear governance, security, or operational benefit.


## Subscription Strategy

Contoso Holdings will use Azure subscriptions as operational, governance, cost, and workload isolation boundaries.

Subscriptions will be placed under the management group that best represents their governance and operational responsibility.

The initial subscription model will separate shared platform services, security capabilities, application workloads, and sandbox environments.

The initial target structure is:

- Platform
  - Connectivity Subscription
  - Management Subscription
  - Identity Subscription
- Security
  - Security Subscription
- Landing Zones
  - Corp Workload Subscriptions
  - Online Workload Subscriptions
- Sandboxes
  - Sandbox Subscriptions
- Decommissioned
  - Retired Subscriptions

Application workloads should normally receive dedicated subscriptions where isolation, ownership, cost management, security, or operational requirements justify the boundary.

Subscriptions must have a clearly identified owner, business purpose, environment classification, cost allocation, and lifecycle status.

Subscription creation and configuration should follow a controlled subscription vending process rather than being created manually without the required governance controls.

The subscription model may evolve as the platform grows, but new subscriptions must have a documented reason and must be placed under the appropriate management group before workloads are onboarded.


## Platform and Workload Responsibilities

Contoso Holdings will separate platform responsibilities from application workload responsibilities.

The Cloud Platform Engineering team will own the shared Azure platform capabilities required by workload teams. These capabilities include identity governance, management, connectivity, security controls, monitoring foundations, Azure Policy, subscription governance, and other centrally managed platform services.

Application or workload teams will own their application-specific resources, application configuration, deployment processes, workload-level monitoring, and operational responsibilities within the boundaries established by the platform.

The platform team will provide governed capabilities and reusable patterns rather than directly owning the internal design of every application.

Responsibilities must be clearly documented for shared services and workload components. Where ownership is shared, the service owner and operational responsibilities must be explicitly defined.

Changes to shared platform services must consider their potential impact on all dependent workloads.


## Platform Landing Zones

The Platform management group will contain subscriptions that provide shared capabilities required by multiple workloads or by the Azure platform itself.

The initial platform landing zones will be organised around three primary capabilities:


### Connectivity

The Connectivity subscription will host shared network services required to connect and protect Azure workloads.

Potential services include hub networking, Azure Firewall, shared routing, Private DNS, VPN connectivity, ExpressRoute connectivity where required, and other centrally managed network services.

The design of shared connectivity must prevent individual workload teams from making uncontrolled changes to shared network infrastructure.

### Management

The Management subscription will host shared operational and monitoring capabilities used across the Azure environment.

Potential services include Log Analytics workspaces, Azure Monitor resources, automation services, update management capabilities, and other shared operational tooling.

Management services must provide appropriate separation between platform operations, security monitoring, and workload telemetry while supporting centralised visibility.

### Identity

The Identity subscription will host shared identity-related infrastructure where required by the platform architecture.

Identity services must integrate with Microsoft Entra ID and follow the identity, access, and privileged access requirements defined in the Contoso Holdings Engineering Standards.

Platform subscriptions must be governed using the same security, tagging, monitoring, cost management, and Infrastructure as Code standards as workload subscriptions.


## Workload Landing Zones

The Landing Zones management group will contain subscriptions used by application and business workloads.

Workload subscriptions will be organised according to their connectivity, security, operational, and business requirements.

### Corp Workloads

Corp workload subscriptions will be used for applications that require controlled connectivity to corporate resources or other internal services.

These workloads must use the approved platform connectivity and security controls and must not establish uncontrolled network paths to corporate or shared services.

### Online Workloads

Online workload subscriptions will be used for applications that require controlled internet-facing connectivity.

Public exposure must be explicitly required by the workload architecture and protected using appropriate network, application, identity, monitoring, and security controls.

### Workload Subscription Boundaries

Each workload subscription must have a clearly identified owner, business purpose, environment classification, cost allocation, and operational responsibility.

Workload teams must consume approved platform services rather than bypassing platform governance.

Workload-specific infrastructure must be deployed using Infrastructure as Code and must comply with the Contoso Holdings Engineering Standards.

The workload landing zone structure may evolve as new workload patterns are identified, but changes must be based on a clear governance, security, operational, or business requirement.


## Security Landing Zone

The Security management group will provide a dedicated governance boundary for security-related subscriptions and services supporting the Contoso Holdings Azure environment.

Security capabilities should be centrally managed where centralisation provides consistent visibility, investigation, governance, or operational benefit.

Potential security services may include Microsoft Defender for Cloud, Microsoft Sentinel, security monitoring resources, security automation, and other approved security capabilities.

Security monitoring must maintain appropriate separation of duties from workload teams. Security teams must be able to investigate relevant security events without requiring unnecessary administrative access to application workloads.

Security services must follow the Contoso Holdings requirements for identity, privileged access, monitoring, data protection, cost management, Infrastructure as Code, and change management.

The security architecture must support central visibility while allowing workload-specific security requirements to be applied at the appropriate subscription or resource scope.


## Sandbox Environment

The Sandboxes management group will provide isolated Azure environments for engineering experimentation, development activities, proof-of-concept work, and learning activities that do not require production workload access.

Sandbox subscriptions must remain separate from production and shared platform subscriptions.

Sandbox environments must still comply with applicable Contoso Holdings security, identity, tagging, cost management, and acceptable-use requirements.

Production data, credentials, secrets, and other sensitive information must not be copied into sandbox environments unless explicitly authorised and protected according to the applicable data classification requirements.

Sandbox subscriptions should have appropriate spending controls, resource restrictions, and lifecycle processes to prevent uncontrolled resource growth.

Sandbox resources should be automatically identified and reviewed for removal when they are no longer required.

Sandbox environments must not be used to bypass production governance or to test changes directly against production resources.


## Decommissioned Subscriptions

The Decommissioned management group will contain subscriptions that are no longer used for active workloads but must remain within the Contoso Holdings governance hierarchy during their retirement or retention period.

Subscriptions must not be moved to the Decommissioned management group until the required workload shutdown, data retention, security review, cost review, and ownership activities have been completed.

Before a subscription is decommissioned, the responsible team must confirm that:

- Active workloads have been removed, migrated, or formally retired.
- Required data has been retained or disposed of according to applicable requirements.
- Secrets, credentials, identities, and access assignments are no longer required.
- Network connectivity and dependencies have been removed or transferred.
- Monitoring and alerting requirements have been closed or transferred.
- Cost management and billing ownership have been reviewed.
- Relevant architecture and operational documentation has been updated.

Decommissioned subscriptions must remain identifiable and traceable until the approved retention and retirement process has been completed.



## Initial Azure Hierarchy

The initial Contoso Holdings Azure hierarchy is designed as follows:

```text
Microsoft Entra Tenant
│
└── Tenant Root Management Group
    │
    └── Contoso
        │
        ├── Platform
        │   ├── Connectivity
        │   │   └── Connectivity Subscription
        │   │
        │   ├── Management
        │   │   └── Management Subscription
        │   │
        │   └── Identity
        │       └── Identity Subscription
        │
        ├── Security
        │   └── Security Subscription
        │
        ├── Landing Zones
        │   ├── Corp
        │   │   └── Corp Workload Subscriptions
        │   │
        │   └── Online
        │       └── Online Workload Subscriptions
        │
        ├── Sandboxes
        │   └── Sandbox Subscriptions
        │
        └── Decommissioned
            └── Retired Subscriptions

```

## Azure Region Strategy

Contoso Holdings will use UK South as the preferred primary Azure region and UK West as the preferred secondary region where service availability, workload requirements, resilience requirements, and business needs support their use.

Region selection must not be based solely on geographic preference. Before deploying an Azure service, the platform engineer must verify that the required service, SKU, capacity, and quota are available in the selected region.

Where a required service or SKU is not available in the preferred region, an alternative supported region must be assessed.

Region selection must consider:

- Service availability
- SKU availability
- Regional quota and capacity
- Network latency
- Data residency requirements
- Availability and resilience requirements
- Service dependencies
- Disaster recovery requirements
- Cost
- Integration with shared platform services

Exceptions to the preferred regional strategy must be documented and approved according to the applicable change and architecture governance process.

The selected region must be recorded as part of the infrastructure configuration and architecture documentation so that the deployment remains traceable and reproducible.


## Governance and Azure Policy

Contoso Holdings will use Azure Policy and related governance controls to enforce platform standards consistently across management groups, subscriptions, and resources.

Policies will be assigned at the highest appropriate scope where inheritance provides a clear governance benefit. More specific policies may be applied at subscription or resource-group scope where workload requirements differ.

Initial governance areas will include:

- Approved Azure regions
- Required resource tags
- Resource naming and organisation standards
- Security configuration requirements
- Network exposure controls
- Diagnostic and monitoring requirements
- Allowed or restricted resource types
- Data protection requirements
- Cost and resource management controls

Policy effects will be selected according to the maturity and purpose of each control. Audit policies should be used where visibility is required before enforcement, while Deny, Modify, DeployIfNotExists, or other appropriate effects may be introduced when the requirement is sufficiently understood and operationally supported.

Policy assignments must be tested before broad production enforcement. Exceptions must have a documented business or technical justification, an identified owner, and an appropriate review or expiry process.

Policy definitions, initiatives, assignments, and exceptions should be managed through Infrastructure as Code and source control wherever technically practical.

Changes to governance controls must be reviewed for their potential impact on existing workloads before they are applied to production scopes.


## Policy Scope and Inheritance

Azure Policy assignments must be applied at the highest appropriate management scope where inheritance provides consistent governance without creating unnecessary operational restrictions.

Organisation-wide controls should normally be assigned at the Contoso management group where the requirement applies across the Azure estate.

Platform-specific controls should be assigned to the relevant platform or security management group.

Workload-specific requirements may be assigned at subscription, resource-group, or resource scope when a narrower boundary is required.

Policy inheritance must be considered when designing lower-level assignments. A subscription or workload team must not create a policy configuration that conflicts with a higher-level mandatory control without an approved exception.

Policy assignments and exemptions must be traceable to their owner, purpose, scope, and approval.

The platform team must periodically review policy assignments and exemptions to identify redundant, conflicting, ineffective, or expired controls.


## Identity, RBAC and Privileged Access

Azure access within the Contoso Holdings Landing Zone must use Microsoft Entra ID and Azure role-based access control.

Role assignments should be made to Microsoft Entra groups rather than individual users wherever practical.

Permissions must be granted at the narrowest appropriate scope. Management group-level permissions must be limited to roles that genuinely require governance across multiple subscriptions.

Platform engineering roles must be separated from workload administration roles. Workload teams should not receive unrestricted access to shared platform subscriptions unless their responsibilities explicitly require it.

The Owner role must not be used for routine engineering activities. More specific built-in or custom roles should be used where they provide an appropriate least-privilege boundary.

Privileged access should use just-in-time elevation where supported rather than permanent assignment.

Privileged role assignments must use strong authentication and should be monitored and reviewed regularly.

Emergency access procedures must remain available for critical recovery scenarios while being protected separately from normal administrative access.

All significant privileged access changes must be traceable and subject to the Contoso Holdings access governance process.


## Network Architecture

Contoso Holdings will use a hub-and-spoke network architecture as the initial connectivity model for the Azure platform.

The Connectivity platform subscription will provide the central hub network and shared network services required by workload subscriptions.

Workload subscriptions will use spoke networks where network isolation and independent workload management are required.

The hub network may provide shared services such as:

- Azure Firewall
- Shared routing
- Private DNS
- Network monitoring
- VPN connectivity
- ExpressRoute connectivity where required

Workload spokes must not bypass approved network security and routing controls to establish uncontrolled connectivity.

Network traffic between spokes should use approved routing and security controls based on the communication requirements of the workloads.

Internet-facing workloads must use appropriate security and application delivery controls rather than exposing internal workload resources directly to the public internet.

The final network topology, address spaces, subnet structure, routing, DNS design, firewall architecture, and connectivity requirements will be documented in the detailed network architecture before implementation.

Network infrastructure must be deployed and managed using Infrastructure as Code.


## Network Security Boundaries

Contoso Holdings will use defence-in-depth network security controls to restrict and monitor traffic between the internet, shared platform services, workload networks, and Azure services.

Network access must be permitted only where there is a defined business or technical requirement.

Network Security Groups should be used to control traffic at appropriate subnet or network interface boundaries. Rules must follow the principle of least privilege and should avoid unrestricted inbound or outbound access where a more specific rule is practical.

Azure Firewall or other approved central network security controls should be used to inspect and control traffic that crosses defined network trust boundaries.

Private Endpoints should be used for supported Azure services where private connectivity provides an appropriate security and architectural benefit.

Public network access to Azure services should be disabled where the service architecture supports private connectivity and there is no approved requirement for public exposure.

Network security rules must have a documented purpose, owner, and appropriate review process.

Network security configuration must be managed through Infrastructure as Code where technically practical and must be monitored for unauthorised or unexpected changes.


## DNS Architecture

Contoso Holdings will use a centrally governed DNS architecture to support Azure platform services, workload connectivity, private endpoints, and hybrid connectivity where required.

Private DNS zones required by shared Azure services and platform capabilities should be centrally managed where shared ownership provides operational and security benefits.

Workload teams must use approved DNS patterns rather than creating unmanaged or conflicting private DNS configurations.

Private Endpoint name resolution must be designed so that workloads resolve supported Azure services to their private addresses when private connectivity is used.

The DNS architecture must support resolution between workload spokes, shared platform services, and connected corporate environments where required.

DNS changes must be controlled through Infrastructure as Code where technically practical and must be monitored for unauthorised or unexpected changes.

The detailed DNS architecture will define private DNS zones, DNS forwarding, resolution paths, ownership, integration with corporate DNS, and the operational model before production implementation.


## Monitoring and Management Architecture

Contoso Holdings will provide centralised monitoring and management capabilities through the Management platform subscription while allowing workload teams to maintain appropriate workload-specific monitoring.

Azure Monitor and Log Analytics will provide core platform monitoring and telemetry capabilities where supported.

The monitoring architecture should collect relevant Azure activity logs, resource logs, metrics, and diagnostic data required to operate and troubleshoot the platform.

Monitoring must provide visibility into:

- Platform availability
- Resource health
- Performance
- Network connectivity
- Configuration changes
- Operational failures
- Capacity and quota considerations
- Security-relevant events where appropriate

Alerts must be based on defined operational requirements and should identify the responsible team or service owner.

Workload teams remain responsible for application-specific monitoring and alerting, while the platform team remains responsible for shared platform health and foundational monitoring capabilities.

Monitoring data must be protected according to its data classification and retained according to operational, security, and regulatory requirements.

Monitoring configuration and diagnostic settings should be deployed consistently through Infrastructure as Code and Azure Policy where supported.

The detailed monitoring architecture will define workspace design, data collection, retention, alerting, dashboards, ownership, and integration with security monitoring capabilities.


## Security Monitoring Architecture

Contoso Holdings will maintain dedicated security monitoring capabilities to provide central visibility into security-relevant activity across the Azure environment.

Security monitoring will be logically separated from general platform monitoring while allowing required telemetry to be correlated across both capabilities.

Security monitoring should provide visibility into:

- Identity and authentication activity
- Privileged access activity
- Azure resource changes
- Network security events
- Security alerts
- Policy compliance
- Suspicious or anomalous activity
- Relevant workload security events

Microsoft Defender for Cloud, Microsoft Sentinel, Azure Monitor, and other approved security capabilities may be used where appropriate to provide detection, investigation, monitoring, and response capabilities.

Security teams must have sufficient visibility to investigate security events without receiving unnecessary administrative permissions over workload resources.

Security telemetry must be protected according to its data classification and retained according to security, operational, and regulatory requirements.

Security monitoring configuration must be managed through controlled change processes and Infrastructure as Code where technically practical.

The detailed security monitoring architecture will define telemetry sources, collection methods, workspace or data architecture, retention, alerting, investigation workflows, ownership, and integration with incident management processes.


## Cost Management Architecture

Contoso Holdings will treat cost management as a core component of Azure platform governance.

Azure subscriptions must have a clearly identified financial owner and cost allocation model.

Resource tagging will support cost allocation and reporting where supported, using the mandatory tags defined in the Contoso Holdings Engineering Standards.

Cost management controls should include:

- Subscription-level budgets
- Cost alerts
- Regular cost reporting
- Resource-level cost analysis where available
- Identification of unexpected or abnormal spending
- Review of unused or underutilised resources
- Forecasting and capacity planning
- Cost optimisation opportunities

Shared platform costs must be identifiable and allocated to the appropriate platform or business cost centre.

Workload teams remain responsible for understanding and managing the costs generated by their workloads within the governance boundaries established by the platform.

The platform team will provide common cost governance, reporting, tagging standards, and optimisation practices.

New platform or workload resources should consider expected cost before deployment, particularly for services with consumption-based pricing or significant baseline costs.

Cost management configuration should be managed through Infrastructure as Code or approved governance processes where technically practical.


## Backup and Disaster Recovery Architecture

Contoso Holdings will design backup, resilience, and disaster recovery capabilities as part of the platform and workload architecture rather than treating recovery as a post-deployment activity.

Platform and workload teams must identify the recovery requirements applicable to the services they own.

Recovery requirements should define, where applicable:

- Recovery Point Objective (RPO)
- Recovery Time Objective (RTO)
- Backup frequency
- Retention requirements
- Recovery location
- Dependency recovery order
- Recovery ownership
- Recovery testing requirements

Shared platform services must have documented recovery procedures appropriate to their importance and dependencies.

Workload teams remain responsible for defining the business recovery requirements of their applications and ensuring that their workloads use approved backup and recovery capabilities.

Backup data must be protected according to its data classification and must not rely solely on the availability of the primary production environment.

Disaster recovery designs should consider regional failure, service failure, accidental deletion, configuration errors, security incidents, and other relevant failure scenarios.

Recovery procedures must be documented and tested periodically. A backup configuration must not be considered sufficient evidence of recoverability until restoration has been successfully tested.

The detailed disaster recovery architecture will define service-specific backup mechanisms, regional recovery strategies, dependency mapping, recovery sequencing, testing frequency, and operational ownership.


## Infrastructure as Code Architecture

Contoso Holdings will use Infrastructure as Code as the primary method for deploying and maintaining Azure platform infrastructure.

Infrastructure definitions must be stored in source control and managed through the approved Git workflow.

Infrastructure as Code should be used for:

- Management group configuration where supported
- Subscription configuration where supported
- Azure Policy definitions and assignments
- RBAC configuration
- Networking
- Monitoring
- Security controls
- Shared platform services
- Workload infrastructure
- Resource configuration

Infrastructure changes must be reviewed through pull requests before being applied to production environments.

Infrastructure code must use reusable modules, consistent naming, tagging, and configuration patterns where practical.

Secrets, passwords, API keys, and other sensitive credentials must not be stored directly in Infrastructure as Code repositories.

Infrastructure deployments must support repeatability, traceability, and controlled change.

The platform team will select appropriate Infrastructure as Code technologies based on service support, maintainability, organisational standards, and operational requirements.

The detailed Infrastructure as Code architecture will define repository structure, module strategy, state management, environment separation, deployment pipelines, testing, validation, and secrets handling.


## Source Control and Change Management

Contoso Holdings will use Git-based source control as the authoritative system for infrastructure code, platform configuration, architecture documentation, and other controlled engineering artefacts.

Changes to the Azure platform must be developed through feature branches and submitted through pull requests before being merged into protected integration or production branches.

Pull requests should provide sufficient context for reviewers to understand:

- What is changing
- Why the change is required
- What components are affected
- Security implications
- Operational impact
- Cost implications
- Testing and validation performed
- Rollback or recovery considerations

Production changes must not rely on undocumented manual portal changes where the configuration can be managed through Infrastructure as Code.

Emergency changes may follow an expedited process where necessary to restore service or address a critical security issue. Emergency changes must still be documented, reviewed retrospectively, and incorporated into the controlled source configuration.

Changes to shared platform services must consider their potential impact on dependent workloads.

The Git history, pull requests, reviews, deployment records, and relevant architecture documentation must provide an auditable record of significant platform changes.


## Subscription Vending and Workload Onboarding

Contoso Holdings will use a controlled subscription provisioning process to ensure that new Azure subscriptions are created with the required governance, security, identity, monitoring, tagging, and cost management controls.

New subscriptions must have a defined:

- Business purpose
- Workload or service owner
- Technical owner
- Environment classification
- Cost centre
- Data classification
- Required region or regions
- Connectivity requirements
- Security requirements
- Operational support requirements

The subscription provisioning process should include:

1. Validate the subscription request.
2. Create or provision the subscription through the approved process.
3. Place the subscription under the appropriate Management Group.
4. Apply required Azure Policy assignments and governance controls.
5. Configure required tags and cost management controls.
6. Establish appropriate Azure RBAC assignments.
7. Configure required monitoring and diagnostic settings.
8. Configure required network connectivity and security controls.
9. Validate the subscription against the landing zone baseline.
10. Approve the subscription for workload onboarding.

Subscription provisioning should be automated through Infrastructure as Code or approved platform automation wherever technically practical.

Workload teams must not begin production deployment until the subscription has passed the required landing zone validation.

Exceptions to the subscription onboarding baseline must be documented, approved, owned, and reviewed.


## Landing Zone Validation

Every new workload subscription must pass a defined landing zone validation before production workloads are onboarded.

The validation must confirm that the subscription has been correctly integrated into the Contoso Holdings platform and that required baseline controls are operational.

The validation should assess:

- Correct Management Group placement
- Required Azure Policy assignments
- Policy compliance status
- Required resource tags
- Appropriate Azure RBAC assignments
- Privileged access controls
- Network connectivity and security configuration
- Monitoring and diagnostic configuration
- Security monitoring integration
- Cost management and budget controls
- Backup and recovery requirements where applicable
- Infrastructure as Code ownership
- Required documentation and service ownership

Validation results must be recorded and associated with the subscription or onboarding request.

Failed validation items must be remediated or formally approved as exceptions before production onboarding.

Landing zone validation should be automated where practical to provide repeatable and objective compliance checks.

The platform team must periodically review the validation criteria to ensure that the landing zone baseline remains aligned with current security, governance, operational, and business requirements.


## Architecture Exceptions and Governance

Contoso Holdings recognises that some workloads may have legitimate technical, security, regulatory, operational, or business requirements that cannot be satisfied by the standard landing zone architecture.

Exceptions must not be implemented informally or used to permanently bypass platform governance.

Each exception must document:

- The requirement that cannot be met by the standard architecture
- The affected subscription, workload, or resource
- The reason the standard cannot be applied
- The proposed alternative
- Security implications
- Operational implications
- Cost implications
- Risk introduced by the exception
- Compensating controls where applicable
- Exception owner
- Approver
- Review or expiry date where appropriate

Architecture exceptions must be reviewed by the appropriate platform, security, or architecture authority before implementation where the risk or scope requires formal approval.

Temporary exceptions should have an agreed remediation plan and target date for returning to the standard architecture.

Exception records must be maintained alongside the relevant architecture and operational documentation.

The platform team must periodically review exceptions to identify recurring requirements that may justify an update to the standard landing zone architecture.