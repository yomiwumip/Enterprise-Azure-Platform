# Contoso Holdings Cloud Platform Engineering Standards

Document Owner: Cloud Platform Engineering
Organization: Contoso Holdings
Document Status: Draft
Version: 0.1
Last Updated: 8 August 2026

## Purpose

This document defines the engineering standards that the Contoso Holdings Cloud Platform Engineering team will follow when designing, implementing, securing, and operating cloud infrastructure and platform services.

The standards apply to infrastructure, automation, security, networking, identity, monitoring, deployment pipelines, and operational documentation maintained within the Enterprise Azure Platform.

## Resource Naming and Organization

Contoso Holdings resources must follow a consistent naming convention that identifies the resource type, workload, environment, Azure region, and instance where applicable.

Names must be predictable, unique within the applicable Azure scope, and suitable for use in automation and operational tooling.

### Naming Convention

Where supported by the Azure service, resource names should follow this structure:

<resource-type>-contoso-<environment>-<workload>-<region>-<instance>

Environment codes are:

- prod
- dev
- test
- shared
- sandbox

Region codes must represent the actual Azure region where the resource is deployed. The platform engineer responsible for the deployment must verify service availability, SKU availability, and applicable quota before selecting the region.

Resource-type codes will use a controlled naming vocabulary. Azure service-specific naming restrictions take precedence over the general convention. Resources with global uniqueness requirements, character restrictions, or service-specific length limits must use an approved service-specific naming pattern.

## Resource Tagging

All Azure resources that support resource tags must use the Contoso Holdings tagging standard. Tags must provide enough information to identify ownership, environment, business purpose, and cost allocation.

The platform team will use Azure Policy to enforce required tags where technically supported. Resources that cannot support tags must be documented as exceptions.

### Mandatory Tags

The following tags are required for supported Azure resources:

| Tag | Purpose | Example |
|---|---|---|
| Environment | Identifies the deployment environment | prod |
| Owner | Identifies the responsible team or service owner | Cloud Platform Engineering |
| Application | Identifies the application or platform service | Enterprise Platform |
| CostCenter | Identifies the financial owner | CC-1001 |
| ManagedBy | Identifies how the resource is managed | Terraform |
| DataClassification | Identifies the data sensitivity level | Internal |

## Security and Secret Management

Contoso Holdings infrastructure and application workloads must not store secrets, passwords, API keys, connection strings, or other sensitive credentials in source code, Infrastructure as Code files, Git repositories, documentation, or configuration files that are accessible to unauthorised users.


### Secret Management Requirements

Secrets must be stored in an approved secrets management service. For Azure workloads, Azure Key Vault will be the default service for storing application secrets, certificates, and keys where a secret-based approach is required.

Managed identities should be used instead of stored credentials whenever the Azure service and application architecture support them.


### Credential Restrictions

Engineers must not commit credentials or sensitive configuration to Git repositories. This includes passwords, access keys, tokens, private keys, certificates containing private material, and connection strings containing credentials.

Credentials found in a repository must be treated as compromised and reported to the appropriate platform or security owner so that they can be revoked and replaced.

## Identity and Access Management

Contoso Holdings will use Microsoft Entra ID as the primary identity platform for Azure resources and cloud services. Access to Azure resources must be controlled through role-based access control and granted according to the principle of least privilege.

Access should be assigned to groups rather than individual users wherever practical. Permissions must be granted at the lowest appropriate scope required to perform the user's or service's responsibilities.


### Azure RBAC Requirements

Azure role assignments must use the minimum permissions and scope required for the task being performed.

The Owner role must not be used for routine engineering activities. Contributor and other privileged roles must only be assigned where their permissions are required.

Role assignments must have a documented business or operational purpose and must be reviewed as part of access governance activities.


### Privileged Access

Privileged access must be limited to authorised personnel and used only when required to perform approved administrative activities.

Where supported, privileged roles should use just-in-time access rather than permanent assignment. Privileged access must use strong authentication and be subject to appropriate monitoring and review.

Permanent assignment of highly privileged roles must be treated as an exception and documented with a clear operational justification.


### Managed Identities

Azure workloads should use managed identities for authentication to supported Azure services instead of storing service credentials in application configuration.

Managed identities must be granted only the permissions required by the workload and should be assigned at the narrowest practical scope.


### Emergency Access

Contoso Holdings must maintain controlled emergency access procedures for situations where normal administrative access is unavailable or a critical recovery action requires elevated privileges.

Emergency access credentials must be protected separately from normal administrative accounts, monitored closely, and tested periodically. Use of emergency access must be documented and reviewed after each use.


## Azure Landing Zone Governance

The Contoso Holdings Azure platform will use a governed landing zone architecture to provide a consistent foundation for deploying and operating cloud workloads.

The landing zone must establish appropriate management group and subscription boundaries, identity and access controls, networking, security, monitoring, governance policies, and cost management before production workloads are onboarded.

Platform services and application workloads must be separated according to their operational responsibilities, security requirements, and lifecycle. Changes to the landing zone must be managed through Infrastructure as Code and reviewed through the standard pull request process where technically appropriate.


### Landing Zone Principles

The landing zone implementation must follow these principles:

- Governance must be established before production workloads are onboarded.
- Access must follow least-privilege principles.
- Platform and workload responsibilities must be clearly separated.
- Security controls must be applied consistently across environments.
- Infrastructure should be deployed and maintained using Infrastructure as Code.
- Policies and guardrails should be automated wherever practical.
- Production changes must be traceable through source control and approved change processes.
- The platform must support monitoring, cost management, backup, and disaster recovery requirements.


## Network Security

Contoso Holdings network architecture must follow a defence-in-depth approach and provide appropriate separation between platform services, application workloads, management services, and external connectivity.

Network access must be restricted to the minimum required communication paths. Public exposure must be avoided unless there is a documented business requirement and appropriate security controls have been implemented.


### Network Access Controls

Network Security Groups, Azure Firewall, routing controls, private endpoints, and other network security mechanisms must be used according to the requirements of the workload and platform architecture.

Network rules must have a documented purpose and should be reviewed periodically. Rules that are no longer required must be removed.

Unrestricted inbound access from the public internet must not be permitted for production workloads unless explicitly approved and protected by appropriate controls.


## Monitoring and Logging

Contoso Holdings cloud resources and platform services must provide appropriate monitoring, logging, and alerting based on their operational and security requirements.

Azure Activity Logs, resource logs, metrics, and application telemetry must be collected and retained according to the requirements of the workload and applicable security and compliance obligations.

Monitoring must provide sufficient information to identify service degradation, failures, security events, and significant configuration changes.


### Operational Monitoring

Production workloads must have appropriate health monitoring, alerting, and operational dashboards.

Alerts must be actionable and have an identified owner. Alert thresholds should be based on expected service behaviour and documented service objectives rather than arbitrary values.

Monitoring configuration must be managed consistently and reviewed when workloads or service requirements change.


## Infrastructure as Code

Contoso Holdings infrastructure should be deployed and maintained using Infrastructure as Code rather than unmanaged manual changes through the Azure portal.

Infrastructure definitions must be stored in the Enterprise Azure Platform repository and managed through source control.

Infrastructure changes must be reviewed before deployment and must follow the repository branching, pull request, and approval process.


### Infrastructure Change Requirements

Infrastructure changes must be reproducible, traceable, and reviewable.

Changes must include an appropriate description of the intended outcome and any relevant security, availability, operational, or cost considerations.

Where practical, infrastructure deployments must use automated validation and deployment pipelines rather than direct production changes from an engineer's workstation.

Manual changes made during incidents or emergency recovery must be documented and reconciled with the Infrastructure as Code definition after the incident.


## Source Control and Change Management

All infrastructure code, automation, configuration, and technical documentation maintained by the platform team must be stored in the Enterprise Azure Platform repository and managed through source control.

Changes must be made through feature branches and reviewed through pull requests before being merged into shared branches.

The main branch represents the production-ready state of the repository. The develop branch is used for integration of reviewed changes before they are promoted towards production.


### Pull Request Requirements

Pull requests must clearly describe the change, the reason for the change, and any relevant impact on security, availability, cost, or operations.

Changes must be reviewed before merging. Reviewers must verify that the implementation follows applicable engineering standards and that required documentation has been updated.

Direct changes to protected production branches should not be used for normal engineering work.


## Cost Management

Contoso Holdings cloud resources must have an identified business purpose, owner, and cost allocation before they are deployed.

Cloud costs must be monitored throughout the lifecycle of the platform. Engineers must consider the expected cost, operational requirements, performance requirements, and business value when selecting Azure services and SKUs.


### Cost Optimization

Cost optimization must not reduce security, availability, performance, or operational resilience below the requirements of the workload.

Unused resources must be identified and removed or decommissioned when no longer required. Non-production resources should use appropriate lifecycle controls, scheduling, or lower-cost configurations where these are compatible with development and testing requirements.

Significant cost increases must be investigated and documented rather than treated as an expected outcome of platform growth.


## Backup, Disaster Recovery and Business Continuity

Contoso Holdings workloads must have backup and recovery requirements defined according to their business impact, data requirements, and operational dependencies.

Production workloads must have documented recovery objectives and an appropriate backup or disaster recovery strategy where required.

Backup and disaster recovery controls must be monitored and tested periodically. A backup that has never been restored must not be treated as proven recoverable.


### Recovery Objectives

Recovery requirements must define, where applicable:

- Recovery Point Objective (RPO)
- Recovery Time Objective (RTO)
- Recovery dependencies
- Data retention requirements
- Recovery location
- Recovery ownership

Recovery objectives must be agreed with the relevant service or business owner before implementing the recovery solution.


## Incident Management

Contoso Holdings production incidents must be managed using a defined incident response process that prioritises service restoration, clear ownership, accurate communication, and preservation of relevant evidence.

Incidents must be assessed according to their impact and urgency. The response should focus first on stabilising the affected service and reducing customer or business impact before conducting detailed root cause analysis.


### Incident Response

The incident response process should include:

- Detection and initial assessment
- Incident classification
- Assignment of an incident owner
- Service stabilisation and mitigation
- Communication with relevant stakeholders
- Recovery and validation
- Root Cause Analysis where appropriate
- Documentation of actions and findings
- Identification of follow-up improvements


## Site Reliability Engineering

Contoso Holdings platform teams will use Site Reliability Engineering practices to balance service reliability, operational risk, and engineering delivery.

Critical services should have defined service level objectives based on measurable indicators such as availability, latency, error rate, or other workload-specific measures.

Reliability targets must be realistic and supported by the architecture, monitoring, operational processes, and available engineering capacity.


### Service Level Objectives

Service Level Objectives must define measurable reliability targets for applicable production services.

Each SLO should identify:

- The service being measured
- The relevant service level indicator
- The target
- The measurement period
- The data source
- The owner

SLOs should be reviewed when service requirements, architecture, or operating conditions change.

## Documentation

Technical documentation must be maintained alongside the platform and updated when significant architectural, operational, security, or configuration changes are introduced.

Documentation must describe the current state of the platform accurately and must not rely on undocumented assumptions or temporary configuration.

Technical documentation should be written so that another engineer can understand the purpose, dependencies, operational requirements, and known limitations of the component without relying on the original author.

### Architecture Decision Records

Significant architectural decisions must be recorded using Architecture Decision Records (ADRs).

ADRs should document the context, decision, alternatives considered, consequences, and relevant assumptions.

ADRs must be stored in the repository and updated when a decision is superseded by a later architectural decision.

### Operational Runbooks

Production services must have operational runbooks appropriate to their operational complexity and business impact.

Runbooks should provide clear steps for common operational activities, troubleshooting, incident response, recovery, and escalation.

Runbooks must be reviewed after significant operational changes and following incidents where the existing procedure was found to be incomplete or inaccurate.

### Architecture Documentation

Significant platform components must have appropriate architecture documentation showing their relationships, dependencies, security boundaries, and operational responsibilities.

Architecture diagrams must reflect the implemented environment and must be updated when significant architecture changes are introduced.