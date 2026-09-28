# UKPropertyDealDesk — Day 2 Enterprise Azure Network Runbook

**Project:** UKPropertyDealDesk  
**Environment:** Production  
**Region:** UK South  
**Platform:** Microsoft Azure  
**Infrastructure as Code:** Terraform  
**Repository:** Enterprise-Azure-Platform  
**Branch:** feature/networking-terraform

---

# 1. Purpose

This runbook documents the Day 2 implementation of the UKPropertyDealDesk enterprise Azure networking platform.

The objective was to build a production-style connectivity foundation supporting:

- centralised network connectivity
- hub-and-spoke architecture
- controlled internet egress
- network security boundaries
- private Platform as a Service (PaaS) access
- central Domain Name System (DNS)
- private DNS resolution
- application delivery
- Web Application Firewall (WAF)
- planned hybrid connectivity
- infrastructure automation
- operational troubleshooting
- cost-controlled teardown

The environment was implemented in Azure, reproduced using Terraform, documented, validated and subsequently destroyed to control cost.

---

# 2. Engineering Principles

The Day 2 design follows these principles:

1. Centralise shared connectivity services.
2. Separate shared platform networking from workload networking.
3. Use private connectivity wherever practical.
4. Force controlled outbound traffic through central inspection.
5. Use Network Security Groups (NSGs) for subnet-level security boundaries.
6. Use Azure Firewall for centralised network inspection and controlled egress.
7. Treat DNS as a core network dependency.
8. Keep workload spokes independently addressable.
9. Avoid unnecessary public exposure.
10. Do not claim functionality that was not successfully validated.
11. Use Terraform as the reproducible infrastructure definition.
12. Record failures and operational limitations rather than hiding them.
13. Control Azure cost through deliberate teardown when the environment is no longer required.

---

# 3. Management Group Architecture

The management group structure created for UKPropertyDealDesk was:

Tenant Root
└── UKPropertyDealDesk
    ├── Platform
    │   ├── Connectivity
    │   ├── Management
    │   └── Identity
    │
    ├── LandingZones
    │   ├── Corp
    │   └── Online
    │
    └── Sandbox

## Purpose

Management groups provide governance boundaries above subscriptions.

They are not network resources.

### Platform

Contains shared platform capabilities.

### Connectivity

Defines the governance location for shared network infrastructure.

### Management

Reserved for operational management capabilities.

### Identity

Reserved for dedicated identity platform resources where required.

### LandingZones

Contains governed workload environments.

### Corp

Represents workloads requiring internal or corporate connectivity.

### Online

Represents workloads that do not require corporate or on-premises connectivity.

### Sandbox

Provides controlled experimentation without mixing experimental resources into production platform boundaries.

---

# 4. Subscription

The implementation used:

Azure subscription 1

The subscription was placed under:

UKPropertyDealDesk
└── Platform
    └── Connectivity

The design treats the subscription as the connectivity subscription.

A production organisation could use separate subscriptions for other platform and workload functions, but those subscriptions were not fabricated for this implementation.

---

# 5. Governance Tags

The standard production tags were:

Company             = UKPropertyDealDesk
Environment         = Production
ManagedBy           = Terraform
Application         = Platform-Networking
BusinessUnit        = Technology
Owner               = Platform Engineering
CostCentre          = CC-001
DataClassification   = Internal
Criticality         = High
Project             = UKPropertyDealDesk-Platform

During the Azure Portal implementation ManagedBy was initially AzurePortal.

Once Terraform became authoritative, ManagedBy was set to Terraform.

---

# 6. Connectivity Hub

## Resource Group

rg-ukpd-connectivity-hub-prod-uks

## Virtual Network

vnet-ukpd-hub-prod-uks-001

## Region

UK South

## Address Space

10.0.0.0/20

The hub provides shared connectivity and network security services.

---

# 7. Hub Subnet Architecture

| Subnet | Address Range | Purpose |
|---|---|---|
| AzureFirewallSubnet | 10.0.0.0/26 | Azure Firewall data plane |
| AzureBastionSubnet | 10.0.0.64/26 | Azure Bastion |
| GatewaySubnet | 10.0.0.128/26 | Planned Virtual Network Gateway |
| snet-dns-inbound | 10.0.0.192/28 | DNS Private Resolver inbound endpoint |
| snet-dns-outbound | 10.0.0.208/28 | DNS Private Resolver outbound endpoint |
| AzureFirewallManagementSubnet | 10.0.1.0/26 | Azure Firewall management plane |

The Azure Firewall management subnet used the exact required subnet name and appropriate address space.

---

# 8. Azure Firewall

## Resource

azfw-ukpd-hub-prod-uks-001

## Configuration

- SKU: Standard
- Firewall Policy: fwpol-ukpd-hub-prod-uks-001
- Region: UK South
- Availability zones: zone redundant
- Management Network Interface Card (NIC): enabled
- Management subnet: AzureFirewallManagementSubnet
- Firewall public IP: pip-azfw-hub-prod-uks-001
- Management public IP: pip-azfw-mgmt-ukpd-hub-prod-uks-001
- NAT Gateway: enabled

The Firewall private IP was:

10.0.0.4

---

# 9. Firewall Policy

Firewall Policy:

fwpol-ukpd-hub-prod-uks-001

A network rule collection was created:

rc-ukpd-corp-egress-prod-uks-001

Priority:

500

Action:

Allow

Rule:

allow-ukpd-corp-web-egress

Source:

10.10.0.0/16

Protocol:

Transmission Control Protocol (TCP)

Destination:

*

Ports:

80, 443

The rule was designed to permit controlled web egress from the Corp spoke through the central Firewall.

---

# 10. Firewall Architecture

The intended traffic path is:

Corp workload
    |
    v
Corp subnet
    |
    v
User Defined Route (UDR)
    |
    v
Azure Firewall
10.0.0.4
    |
    v
Controlled external egress

The workload subnet does not independently provide uncontrolled public outbound access.

---

# 11. NAT Gateway

## Resource

nat-ukpd-hub-prod-uks-001

## Configuration

- SKU: StandardV2
- Public IP: pip-nat-ukpd-hub-prod-uks-001
- Static public IPv4
- Zone redundant

The NAT Gateway was associated with the central Firewall architecture.

It was not attached directly to Corp workload subnets.

This preserves the central inspection model.

---

# 12. DNS Private Resolver

## Resource

dnspr-ukpd-hub-prod-uks-001

## Endpoints

Inbound:

dnsin-ukpd-hub-prod-uks-001

Outbound:

dnsout-ukpd-hub-prod-uks-001

The resolver was associated with:

vnet-ukpd-hub-prod-uks-001

The inbound and outbound endpoints provide a central architecture for DNS integration with external or hybrid DNS environments.

No forwarding rules were fabricated because no real on-premises DNS targets were available during Day 2.

---

# 13. Private DNS

Central Private DNS zone:

privatelink.blob.core.windows.net

Hub link:

vnetlink-ukpd-hub-prod-uks-001

Corp link:

vnetlink-ukpd-corp-prod-uks-001

Auto-registration was disabled.

The Private DNS zone provides private name resolution for Azure Storage Private Endpoint access.

The Terraform implementation explicitly manages the required A record rather than relying on an unsupported provider resource.

---

# 14. Corp Production Spoke

## Resource Group

rg-ukpd-corp-network-prod-uks

## Virtual Network

vnet-ukpd-corp-prod-uks-001

## Address Space

10.10.0.0/16

The Corp spoke represents a production workload network separated from the shared connectivity hub.

---

# 15. Corp Subnets

| Subnet | Address Range | Purpose |
|---|---|---|
| snet-app-prod-uks-001 | 10.10.0.0/24 | Application workloads |
| snet-data-prod-uks-001 | 10.10.1.0/24 | Data workloads |
| snet-integration-prod-uks-001 | 10.10.2.0/24 | Integration workloads |
| snet-appgw-prod-uks-001 | 10.10.3.0/24 | Application Gateway |
| snet-private-endpoints-prod-uks-001 | 10.10.10.0/24 | Private Endpoints |
| snet-management-prod-uks-001 | 10.10.20.0/24 | Management workloads |

The workload subnets were configured as private subnets.

---

# 16. Network Security Groups

The following Network Security Groups (NSGs) were created:

nsg-ukpd-corp-app-prod-uks-001

nsg-ukpd-corp-data-prod-uks-001

nsg-ukpd-corp-integration-prod-uks-001

nsg-ukpd-corp-private-endpoints-prod-uks-001

nsg-ukpd-corp-management-prod-uks-001

Each NSG represents a security boundary appropriate to the subnet function.

The Application Gateway subnet intentionally did not have an NSG applied during Day 2.

This avoided introducing unnecessary configuration into a specialised application delivery subnet before backend requirements existed.

---

# 17. Network Security Model

NSGs provide subnet-level traffic filtering.

Azure Firewall provides centralised inspection and controlled egress.

The two controls serve different purposes.

The Firewall is not a replacement for NSGs.

NSGs are not a replacement for centralised Firewall inspection.

---

# 18. Hub-to-Spoke Peering

Two peering relationships were created:

peer-ukpd-corp-to-hub-prod-uks-001

peer-ukpd-hub-to-corp-prod-uks-001

Configuration included:

- virtual network access enabled
- forwarded traffic enabled
- gateway transit disabled
- remote gateway use disabled

The peering provides network connectivity between the Corp spoke and the connectivity hub.

---

# 19. User Defined Routing

Route table:

rt-ukpd-corp-egress-prod-uks-001

Border Gateway Protocol (BGP) route propagation was disabled.

Default route:

Destination:
0.0.0.0/0

Next hop type:
Virtual Appliance

Next hop:
10.0.0.4

The route table was associated with:

- Application subnet
- Data subnet
- Integration subnet
- Management subnet

It was not associated with:

- Application Gateway subnet
- Private Endpoint subnet

This prevents indiscriminate routing changes to specialised network components.

---

# 20. Private Endpoint Architecture

Azure Storage was used as the Private Endpoint target.

Storage account:

stukpdprivproduks001

Private Endpoint:

pe-ukpd-blob-prod-uks-001

Subresource:

blob

Private Endpoint subnet:

snet-private-endpoints-prod-uks-001

Public network access to the Storage account was disabled.

The Private Endpoint provides private network access to the Azure Storage service.

---

# 21. Private Endpoint DNS

Private DNS zone:

privatelink.blob.core.windows.net

The Storage Private Endpoint requires correct DNS resolution.

The intended sequence is:

Application
    |
    v
Storage hostname
    |
    v
Private DNS
    |
    v
Private Endpoint address
    |
    v
Azure Storage

A Private Endpoint being provisioned successfully does not by itself prove application connectivity.

DNS must also resolve correctly.

---

# 22. Storage Security Configuration

The Storage account used:

- Standard StorageV2
- Locally-redundant storage (LRS)
- secure transfer enabled
- anonymous access disabled
- public network access disabled
- Transport Layer Security (TLS) 1.2
- Microsoft-managed encryption keys
- storage key access enabled
- soft delete configured for 7 days

Defender for Storage was not enabled during this implementation.

---

# 23. Application Gateway

## Resource

agw-ukpd-corp-prod-uks-001

## Configuration

- Application Gateway Web Application Firewall (WAF) V2
- autoscale minimum: 1
- autoscale maximum: 2
- IPv4
- availability zones 1, 2 and 3
- HTTP/2 disabled
- Federal Information Processing Standard (FIPS) mode disabled

Subnet:

snet-appgw-prod-uks-001

Public IP:

pip-ukpd-corp-prod-uks-001

---

# 24. Application Gateway Listener and Routing

Listener:

listener-ukpd-corp-http-prod-uks-001

Protocol:

HTTP

Port:

80

Frontend:

Public

Routing rule:

rule-ukpd-corp-web-prod-uks-001

Priority:

100

The backend pool:

pool-ukpd-corp-web-prod-uks-001

was intentionally left without fabricated application servers.

---

# 25. Web Application Firewall

WAF policy:

wafpol-ukpd-corp-prod-uks-001

Mode:

Prevention

The Azure Portal implementation showed Microsoft-managed rule sets.

The Terraform implementation defines the managed rule configuration separately and should be reconciled against the exact Portal rule-set versions before treating Terraform as an exact configuration-equivalent deployment.

No custom exclusions or custom rules were introduced.

---

# 26. Hybrid Connectivity

A Virtual Network Gateway was planned in the hub.

Configuration attempted:

- route-based VPN
- VpnGw1AZ
- active-active
- two Standard Static public IP addresses
- Border Gateway Protocol (BGP) enabled
- Autonomous System Number (ASN): 65010
- GatewaySubnet in hub

No real on-premises peer was fabricated.

---

# 27. Hybrid Connectivity Failure

The Azure Virtual Network Gateway deployment failed.

Azure reported:

VmssGatewayDeploymentFailed

with an intermittent deployment error.

The Activity Log recorded the failed operation.

Correlation ID:

c78ea531-24dd-4046-a414-8427e3c4b689

Operation ID:

09b185d3-a942-4fff-8936-98e3e82b096d

Timestamp:

2026-09-26T16:04:31Z

The failure occurred during Azure platform provisioning.

## Operational conclusion

Hybrid VPN connectivity was NOT marked as operational.

No fabricated Local Network Gateway, on-premises public IP, Internet Protocol Security (IPsec) tunnel or BGP peer was created.

This is a documented infrastructure provisioning failure, not a completed hybrid connectivity implementation.

---

# 28. End-to-End Validation

Validation should follow the network path rather than jumping directly to an assumed root cause.

## Internet egress

Check:

1. Workload
2. Subnet
3. NSG
4. Route table
5. Default route
6. Firewall private IP
7. Firewall Policy
8. Firewall rule
9. NAT
10. Destination

## Private Endpoint

Check:

1. Private Endpoint state
2. Private Endpoint Network Interface Card (NIC)
3. Private IP
4. Private DNS zone
5. VNet link
6. DNS record
7. Name resolution
8. Application connectivity

## NSG failure

Check:

1. Source
2. Source subnet
3. Source NSG
4. Destination subnet
5. Destination NSG
6. Effective security rules

## Routing failure

Check:

1. Route table association
2. Default route
3. Next hop
4. Effective routes
5. Firewall reachability

## Application Gateway

Check:

1. Gateway provisioning
2. Frontend IP
3. Listener
4. Rule
5. WAF policy
6. Backend pool
7. Backend health

---

# 29. Failure Testing

## Scenario A — Missing default route

Expected result:

Controlled egress fails because traffic no longer reaches the central Firewall.

Investigation:

- subnet association
- route table
- 0.0.0.0/0
- next hop
- effective routes

---

## Scenario B — NSG denies traffic

Expected result:

Permitted workload communication fails.

Investigation:

- source NSG
- destination NSG
- security rules
- effective security rules

Do not change rules before identifying the actual deny.

---

## Scenario C — Private DNS failure

Expected result:

Private Endpoint exists but service hostname resolves incorrectly or fails.

Investigation:

- Private Endpoint
- Private Endpoint NIC
- Private DNS zone
- VNet link
- A record
- DNS resolution

---

## Scenario D — Firewall rule failure

Expected result:

Outbound traffic fails despite a correct route.

Investigation:

- Firewall Policy
- rule collection
- priority
- source
- destination
- protocol
- port

---

## Scenario E — VPN Gateway provisioning failure

Observed:

Azure Virtual Network Gateway deployment failed.

Response:

- capture Activity Log evidence
- record correlation ID
- record operation ID
- identify provisioning stage
- do not claim successful hybrid connectivity

---

## Scenario F — Application Gateway without backend

Expected result:

Gateway infrastructure exists but no application transaction succeeds.

Reason:

No real backend application workload was deployed.

Response:

Do not fabricate backend health or end-to-end application success.

---

# 30. Terraform Implementation

Terraform configuration was stored under:

terraform/day2/

Files:

01-provider.tf
02-variables.tf
03-locals.tf
10-hub-network.tf
20-firewall.tf
21-nat-gateway.tf
22-dns-resolver.tf
23-private-dns.tf
30-corp-network.tf
31-peering.tf
32-nsg.tf
33-routing.tf
40-storage-private-endpoint.tf
50-application-gateway.tf

Terraform provider:

Azure Resource Manager provider version family 4.x

Terraform minimum version:

1.5

---

# 31. Terraform Engineering Issues Resolved

The Day 2 implementation exposed provider compatibility issues.

## Route table

The original argument was unsupported.

It was replaced with:

bgp_route_propagation_enabled = false

## Private DNS zone group

The installed provider did not support the planned resource.

The implementation used an explicit Azure Private DNS A record instead.

## Application Gateway

The deprecated HTTP/2 argument was replaced with:

http2_enabled

## NAT Gateway

StandardV2 NAT Gateway configuration required the zones argument to be omitted.

These changes were made to align the configuration with the installed provider behaviour.

---

# 32. Terraform State and Import

Existing Azure resources were imported into Terraform state where appropriate.

The imported resources included:

- resource groups
- hub VNet
- Corp VNet
- hub subnets
- Corp subnets

After Azure teardown, the imported resources were removed from Terraform state.

This was necessary because the actual Azure resources no longer existed.

The final clean configuration produced:

54 to add
0 to change
0 to destroy

This demonstrated that Terraform could calculate a complete Day 2 deployment from the configuration.

---

# 33. Terraform Validation

The standard validation commands are:

terraform -chdir=terraform/day2 fmt
terraform -chdir=terraform/day2 validate

The configuration returned:

Success! The configuration is valid.

---

# 34. Git Workflow

The Day 2 Terraform implementation was committed using:

Add UKPropertyDealDesk Day 2 networking Terraform

Commit:

a1e0d94

The branch was:

feature/networking-terraform

The commit was pushed to:

Enterprise-Azure-Platform

The working repository remains the local:

azure-lab

The Git remote is the GitHub Enterprise-Azure-Platform repository.

---

# 35. Cost Governance

The environment was deliberately destroyed after:

- Portal implementation
- validation
- failure investigation
- Terraform reproduction
- state cleanup
- Git commit
- Git push

This prevented unnecessary ongoing Azure charges.

The architecture remains reproducible from source control.

This is an intentional engineering control, not an incomplete teardown.

---

# 36. Teardown Procedure

When the environment is no longer required:

1. Capture required Azure configuration evidence.
2. Confirm Terraform source is committed.
3. Confirm documentation is committed.
4. Confirm required failure evidence is recorded.
5. Delete production-style test resources.
6. Confirm resource groups are deleted.
7. Remove destroyed imported resources from Terraform state.
8. Run Terraform formatting and validation.
9. Confirm Git working tree.
10. Commit and push documentation.

---

# 37. Operational Change Procedure

For future network changes:

## Before change

Record:

- change objective
- affected resources
- business reason
- expected traffic impact
- security impact
- rollback plan
- validation criteria

## During change

- make the smallest controlled change
- capture evidence
- monitor provisioning
- validate dependencies

## After change

Confirm:

- provisioning state
- routing
- DNS
- NSGs
- Firewall
- application connectivity
- monitoring
- documentation

---

# 38. Security Considerations

The Day 2 design establishes:

- central network inspection
- subnet-level security boundaries
- private workload networking
- controlled egress
- private PaaS access
- central DNS architecture
- WAF protection at the application edge
- management separation
- governance tagging
- infrastructure automation

Security controls should be implemented according to actual workload requirements rather than speculative rules.

---

# 39. Known Limitations

The following were intentionally not represented as complete:

### Hybrid VPN

Azure Virtual Network Gateway provisioning failed.

### End-to-end application transaction

No real application backend existed.

### DNS forwarding

No real on-premises DNS target existed.

### Effective route validation

No workload Network Interface Card existed after the infrastructure teardown.

### Application Gateway backend health

No backend workload existed.

### Exact WAF Terraform parity

The Portal managed rule sets and Terraform managed rule configuration should be reconciled before declaring exact configuration parity.

---

# 40. Day 2 Completion Criteria

Day 2 is considered complete when the following are evidenced:

- enterprise governance structure
- connectivity subscription architecture
- hub network
- subnet architecture
- Azure Firewall
- Firewall Policy
- NAT Gateway
- DNS Private Resolver
- central Private DNS
- production Corp spoke
- Network Security Groups
- hub-to-spoke peering
- User Defined Routes
- Private Endpoint
- Private DNS integration
- Application Gateway
- Web Application Firewall
- hybrid connectivity attempt
- hybrid failure documentation
- Terraform reproduction
- Terraform validation
- Git version control
- cost-controlled teardown
- operational documentation

---

# 41. Day 3 Handover

Day 3 can extend the platform into capabilities not fully exercised during Day 2.

Potential areas include:

- Application Security Groups
- Azure Load Balancer
- deeper Application Gateway testing
- Point-to-Site Virtual Private Network (VPN)
- site-to-site VPN recovery
- ExpressRoute
- Azure Front Door
- Online workload spoke
- deeper hybrid DNS
- advanced routing
- advanced network security
- full end-to-end workload validation

Day 3 must build on Day 2 rather than repeat it.

---

# 42. Final Architecture Statement

The Day 2 UKPropertyDealDesk platform established a production-style Azure enterprise networking foundation based on a central connectivity hub and governed production workload spoke.

The architecture provides centralised connectivity, controlled egress, network security boundaries, private PaaS access, DNS infrastructure and application delivery.

Terraform provides a reproducible infrastructure definition.

The Azure Virtual Network Gateway provisioning failure was retained as operational evidence rather than hidden.

The environment was subsequently removed to control cost while preserving the architecture, Terraform configuration, Git history and operational documentation.

