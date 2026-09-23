# Azure Network Engineering — Terraform Network Foundation

## 1. Purpose

This document records the production-style Azure networking foundation implemented for the UKPropertyDealDesk engineering environment.

The objective was to move beyond a basic Azure networking lab and demonstrate:

- Azure Virtual Network design
- Enterprise-style subnet segmentation
- Network Security Groups
- Controlled outbound connectivity
- Azure Bastion private administration
- VNet peering
- Network Watcher troubleshooting
- Controlled failure and recovery
- Terraform infrastructure as code
- Terraform drift detection and correction
- Git-based engineering workflow

The environment was intentionally temporary and disposable so that networking capabilities could be implemented, tested and evidenced without leaving unnecessary billable resources running.

---

## 2. Engineering Environment

| Item | Value |
|---|---|
| Organisation | UKPropertyDealDesk |
| Environment | Production-style portfolio environment |
| Azure Region | UK South |
| Infrastructure as Code | Terraform |
| Terraform Provider | AzureRM ~> 4.0 |
| Git Branch | feature/networking-terraform |
| Primary Resource Group | rg-wlt-network-tf-prod-uks-001 |
| Primary VNet | vnet-wlt-tf-prod-uks-001 |
| Primary CIDR | 10.0.0.0/16 |
| Shared VNet | vnet-wlt-tf-shared-uks-001 |
| Shared VNet CIDR | 10.1.0.0/16 |
| Management Model | Private workload / Bastion administration |
| State Model | Local Terraform state for disposable residency environment |
| Remote Backend | Not implemented for this disposable environment |

---

## 3. Network Architecture

### Primary VNet

`vnet-wlt-tf-prod-uks-001`

CIDR:

`10.0.0.0/16`

Subnets:

| Subnet | CIDR | Purpose |
|---|---|---|
| snet-app | 10.0.0.0/24 | Application / management workload |
| snet-db | 10.0.1.0/24 | Database workload |
| AzureBastionSubnet | 10.0.2.0/26 | Azure Bastion management connectivity |

### Shared Services VNet

`vnet-wlt-tf-shared-uks-001`

CIDR:

`10.1.0.0/16`

Subnet:

`10.1.0.0/24`

Purpose:

Shared-services network demonstrating a separate network boundary and VNet peering architecture.

---

## 4. Security Model

Network Security Groups were deployed to the application and database subnets.

Resources:

- nsg-tf-app
- nsg-tf-db

The final baseline deliberately contains no custom security rules.

Azure default NSG behaviour remains in place.

A controlled deny rule was temporarily introduced during failure testing:

`TEMP-DENY-RDP-TEST`

The rule:

- Direction: Inbound
- Access: Deny
- Protocol: TCP
- Destination port: 3389
- Priority: 100
- Source: VirtualNetwork
- Destination: management VM private IP

The rule was intentionally temporary and was removed after testing.

Terraform required an explicit:

`security_rule = []`

to make the desired empty rule collection explicit and ensure the temporary rule was removed from Azure.

---

## 5. Controlled Outbound Connectivity

NAT Gateway was implemented for the application and database subnets.

Resources:

- natgw-tf-app-prod-uks-001
- natgw-tf-db-prod-uks-001

Public IP resources were associated with the NAT gateways.

The management VM had no public IP.

Outbound internet connectivity was therefore provided through controlled NAT rather than exposing the workload VM directly to the internet.

---

## 6. Private Administration

Azure Bastion was implemented to provide administrative access to the management VM without assigning a public IP to the VM.

Bastion:

`bas-wlt-tf-prod-uks-001`

The management VM:

`vm-wlt-tf-mgmt-prod-uks-001`

was deployed into:

`snet-app`

with private IP:

`10.0.0.4`

The VM used:

- Windows Server 2025 Datacenter Gen2
- Standard_D2nls_v6
- Availability Zone 1
- Accelerated networking
- System-assigned managed identity
- Secure Boot
- vTPM
- Trusted Launch
- Microsoft Entra ID login extension

---

## 7. Connectivity Verification

The management VM was successfully accessed through Azure Bastion.

Verified from the VM:

### Host identity

`hostname`

Returned:

`mgmt-tf-prd-01`

### IP configuration

The VM received:

`10.0.0.4`

Default gateway:

`10.0.0.1`

Azure DNS:

`168.63.129.16`

### HTTPS connectivity

A TCP connectivity test to:

`www.microsoft.com:443`

returned:

`TcpTestSucceeded: True`

### DNS

DNS resolution for:

`www.microsoft.com`

was successful.

### NAT verification

The VM's outbound public IP was verified through:

`https://api.ipify.org`

The returned public IP matched the NAT Gateway public IP.

This demonstrated:

Private VM
→ subnet
→ NAT Gateway
→ controlled public egress

without assigning a public IP directly to the VM.

---

## 8. VNet Peering

Bidirectional peering was implemented between:

`vnet-wlt-tf-prod-uks-001`

and:

`vnet-wlt-tf-shared-uks-001`

Peering:

- Production → Shared
- Shared → Production

Both directions reached:

`Connected`

Configuration:

- Allow virtual network access: enabled
- Allow forwarded traffic: disabled
- Allow gateway transit: disabled
- Use remote gateways: disabled

The implementation demonstrated that VNet peering is directional and both peering objects are required for full bidirectional connectivity.

---

## 9. Controlled Failure Test — NSG

A deliberate security failure was introduced.

### Failure

The temporary rule:

`TEMP-DENY-RDP-TEST`

blocked TCP/3389 traffic to the management VM.

A new Bastion connection subsequently failed.

### Diagnosis

Azure Network Watcher IP Flow Verify was used.

The test targeted:

- Destination: `10.0.0.4`
- Destination port: `3389`
- TCP
- Source within the Bastion subnet

Network Watcher reported:

`Access denied`

The responsible rule was identified as:

`TEMP-DENY-RDP-TEST`

associated with:

`nsg-tf-app`

### Recovery

The temporary rule was removed from the Terraform configuration.

Terraform initially reported no change because the inline NSG security-rule collection needed to be explicitly declared empty.

The configuration was changed to:

`security_rule = []`

Terraform then detected the required change and removed the temporary rule.

The final desired state contained no custom NSG rules.

### Engineering lesson

The failure demonstrated the complete operational cycle:

Change
→ Failure
→ Evidence collection
→ Root-cause identification
→ Corrective action
→ Terraform reconciliation
→ Recovery

---

## 10. Terraform Drift Test

A controlled configuration drift test was performed.

### Drift introduced

A temporary Portal tag was manually added to the Terraform-managed VNet:

`DriftTest=PortalChange`

### Detection

Terraform plan detected the difference and proposed removal of the unmanaged tag.

The plan reported:

`0 to add, 1 to change, 0 to destroy`

### Remediation

Terraform apply restored the VNet to the declared configuration.

A subsequent Terraform plan reported:

`No changes. Your infrastructure matches the configuration.`

### Engineering lesson

Terraform was demonstrated as the source of truth for the environment.

Manual Portal changes were detectable and could be reconciled back to the declared IaC configuration.

---

## 11. Terraform Engineering

Terraform configuration was separated into logical files covering:

- Provider
- Resource group
- Variables
- Virtual networks
- Subnets
- NSGs
- VNet peering
- NAT Gateway
- Bastion
- Management VM

The Terraform provider was pinned to:

`azurerm ~> 4.0`

The Terraform lock file was committed to Git.

The Terraform configuration was validated before Git commit.

---

## 12. Terraform State and Environment Lifecycle

This was a temporary engineering residency environment.

The environment was intentionally destroyed rather than left running.

The final Terraform destroy command reported:

`No changes. No objects need to be destroyed.`

and:

`Destroy complete! Resources: 0 destroyed.`

This confirms that, at the point of the final destroy operation, Terraform had no remaining managed objects requiring destruction.

The environment was therefore treated as disposable rather than as a long-lived production platform.

### Future production requirement

For a real shared/team/CI-CD environment, Terraform state should use a secured remote backend with:

- Centralised state
- State locking
- Access control
- Encryption
- Backup/recovery
- Controlled CI/CD access

A remote backend was intentionally not introduced into this disposable residency environment.

---

## 13. Git Engineering Workflow

The Terraform baseline was committed to Git.

Baseline commit:

`feat: establish terraform azure network baseline`

The repository was then moved from the default `master` branch to:

`main`

A working feature branch was created:

`feature/networking-terraform`

The networking implementation and documentation are being developed on the feature branch rather than directly on `main`.

The intended long-term workflow is:

Feature branch
→ Terraform fmt
→ Terraform validate
→ Terraform plan
→ Review
→ Pull Request
→ Approval
→ Merge
→ Controlled apply
→ Verification
→ Documentation

---

## 14. Security and Operational Principles Demonstrated

The implementation deliberately applied:

- Private VM administration
- No direct public IP on management workload
- Controlled NAT egress
- Network segmentation
- NSG enforcement
- Least-privilege security-rule design
- Infrastructure as Code
- Drift detection
- Controlled failure testing
- Network diagnostics
- Disposable infrastructure
- Git-based change tracking
- Separation of baseline and feature work

---

## 15. Evidence Produced

The completed foundation provides portfolio evidence for:

- Azure VNet design
- CIDR planning
- Subnet design
- NSG implementation
- NAT Gateway
- Private administration
- Azure Bastion
- VNet peering
- Network Watcher
- Network troubleshooting
- Failure injection
- Failure recovery
- Terraform
- Terraform state
- Terraform drift detection
- Git branching
- Infrastructure documentation
- Production-style engineering decisions

---

## 16. Current Engineering Position

### Completed

VNet
→ Subnets
→ NSGs
→ NAT Gateway
→ Bastion
→ Management VM
→ VNet Peering
→ Network Watcher
→ Controlled Failure
→ Recovery
→ Terraform
→ Drift Detection
→ Git

### Next Networking Capability

Private Endpoint
→ Private DNS
→ Private workload connectivity
→ DNS resolution validation
→ Private access failure testing
→ Terraform implementation
→ Git documentation

---

## 17. Important Engineering Principle

The objective of this residency is not to demonstrate that Azure resources can be created.

The objective is to demonstrate the complete engineering lifecycle:

Understand
→ Design
→ Implement
→ Secure
→ Test
→ Break safely
→ Troubleshoot
→ Recover
→ Automate
→ Monitor
→ Document
→ Version control

This foundation is therefore treated as the first completed engineering capability within the wider Azure Network Engineer track.
