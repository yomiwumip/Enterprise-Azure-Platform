# ADR-001: Infrastructure as Code Strategy

- Status: Accepted
- Date: 11 August 2026
- Decision Owners: Cloud Platform Engineering
- Organization: Contoso Holdings

## Context

Contoso Holdings requires a repeatable Infrastructure as Code approach for implementing and operating the Azure platform.

The Day 2 Landing Zone architecture establishes Azure-native platform capabilities including management groups, subscriptions, Azure Policy, identity, networking, security, monitoring, and shared platform services.

The repository contains both Terraform and Bicep directories. A primary Infrastructure as Code technology is required so that the initial Azure platform implementation follows a consistent engineering approach.

The platform must also retain the ability to use Azure-native Infrastructure as Code where a service capability, implementation requirement, or engineering decision makes that approach appropriate.

## Decision

Contoso Holdings will use **Terraform as the primary Infrastructure as Code technology** for the Azure platform implementation.

**Bicep will remain a supported secondary Infrastructure as Code capability** for Azure-native implementations where its capabilities provide a clear engineering benefit.

Terraform will be used as the default technology for the main platform infrastructure unless a documented technical requirement justifies the use of another approach.

## Rationale

Terraform provides a mature Infrastructure as Code workflow that can be used across multiple infrastructure providers and environments.

Using Terraform as the primary technology provides the platform team with a consistent approach to:

- Infrastructure provisioning
- Reusable modules
- Infrastructure state management
- Environment configuration
- Pull-request-based infrastructure changes
- CI/CD integration
- Automated validation and planning
- Multi-provider infrastructure where required

Bicep remains valuable because it provides an Azure-native declarative Infrastructure as Code experience and closely integrates with Azure Resource Manager.

Retaining Bicep allows the platform team to use Azure-native capabilities where they provide a meaningful technical or operational advantage without making Bicep the default platform-wide IaC technology.

The decision therefore balances enterprise Infrastructure as Code portability with Azure-native implementation capabilities.

## Technology Position

### Terraform

Terraform is the primary Infrastructure as Code technology for:

- Shared Azure platform infrastructure
- Landing Zone implementation
- Network infrastructure
- Monitoring infrastructure
- Security infrastructure
- Workload infrastructure
- Reusable platform modules
- CI/CD-driven infrastructure deployments

### Bicep

Bicep is a secondary Infrastructure as Code technology for:

- Azure-native resource implementations
- Service-specific Azure deployments
- Azure capabilities where Bicep provides a clear implementation advantage
- Demonstrating and maintaining Azure-native Infrastructure as Code capability

The use of Bicep must still follow the Contoso Holdings Engineering Standards, Git workflow, security requirements, naming standards, tagging standards, and change-management process.

## Consequences

### Positive

- Establishes Terraform as the primary enterprise IaC skill.
- Provides reusable infrastructure modules.
- Supports a consistent Git-based infrastructure workflow.
- Supports automated CI/CD workflows.
- Provides portability across infrastructure providers where required.
- Retains Azure-native Bicep capability.
- Gives engineers practical experience with both major IaC approaches used in Azure environments.

### Negative

- Engineers must develop and maintain Terraform expertise.
- Engineers must also understand Bicep sufficiently to support approved Azure-native implementations.
- Maintaining two IaC technologies introduces additional tooling and knowledge requirements.
- The platform team must define clear rules for when Terraform or Bicep should be used.
- Terraform state requires deliberate security, storage, access-control, backup, and recovery design.

## Implementation

The primary Terraform codebase will be established under the existing:

terraform/

directory.

The Terraform implementation will be developed incrementally and will follow the Contoso Holdings Engineering Standards and Azure Landing Zone architecture.

The implementation will establish standards for:

- Terraform providers
- Provider authentication
- Backend configuration
- Remote state
- State locking
- Variables
- Outputs
- Locals
- Modules
- Environment separation
- Naming
- Resource tagging
- Validation
- Security scanning
- CI/CD
- Pull-request review
- Deployment approvals

Bicep implementations will be maintained under:

bicep/

and will follow equivalent source-control, validation, security, and change-management requirements.

No production Azure resources will be deployed until the relevant Infrastructure as Code implementation has been reviewed and validated.

## Decision Rules

Terraform should be used by default for new platform infrastructure.

Bicep may be selected when:

- An Azure-native implementation provides a clear technical advantage.
- A specific Azure capability is better represented through Bicep.
- A documented platform or workload requirement justifies its use.
- An approved architecture decision specifies Bicep.

Where Bicep is selected instead of Terraform for a platform capability, the reason should be documented.

## Review

This decision should be reviewed if:

- Azure platform requirements materially change.
- Terraform capabilities or organisational requirements change.
- Bicep provides significant capabilities that materially change the trade-off.
- The organisation adopts a different enterprise Infrastructure as Code strategy.
- Operational experience demonstrates that the current strategy creates significant technical or operational disadvantages.