# UKPropertyDealDesk — Day 2 Network Architecture Record

## Architecture

Tenant Root
└── UKPropertyDealDesk
    ├── Platform
    │   ├── Connectivity
    │   ├── Management
    │   └── Identity
    ├── LandingZones
    │   ├── Corp
    │   └── Online
    └── Sandbox

## Connectivity Hub

Resource Group:
rg-ukpd-connectivity-hub-prod-uks

Virtual Network:
vnet-ukpd-hub-prod-uks-001

Address space:
10.0.0.0/20

Subnets:

AzureFirewallSubnet — 10.0.0.0/26
AzureBastionSubnet — 10.0.0.64/26
GatewaySubnet — 10.0.0.128/26
snet-dns-inbound — 10.0.0.192/28
snet-dns-outbound — 10.0.0.208/28
AzureFirewallManagementSubnet — 10.0.1.0/26

## Corp Spoke

Resource Group:
rg-ukpd-corp-network-prod-uks

Virtual Network:
vnet-ukpd-corp-prod-uks-001

Address space:
10.10.0.0/16

Subnets:

snet-app-prod-uks-001 — 10.10.0.0/24
snet-data-prod-uks-001 — 10.10.1.0/24
snet-integration-prod-uks-001 — 10.10.2.0/24
snet-appgw-prod-uks-001 — 10.10.3.0/24
snet-private-endpoints-prod-uks-001 — 10.10.10.0/24
snet-management-prod-uks-001 — 10.10.20.0/24

## Shared Services

Azure Firewall:
azfw-ukpd-hub-prod-uks-001

Firewall Policy:
fwpol-ukpd-hub-prod-uks-001

NAT Gateway:
nat-ukpd-hub-prod-uks-001

DNS Private Resolver:
dnspr-ukpd-hub-prod-uks-001

Inbound endpoint:
dnsin-ukpd-hub-prod-uks-001

Outbound endpoint:
dnsout-ukpd-hub-prod-uks-001

Private DNS:
privatelink.blob.core.windows.net

## Routing

Route table:
rt-ukpd-corp-egress-prod-uks-001

Default route:
0.0.0.0/0

Next hop:
10.0.0.4

Next hop type:
Virtual Appliance

## Private Access

Storage:
stukpdprivproduks001

Private Endpoint:
pe-ukpd-blob-prod-uks-001

Private DNS:
privatelink.blob.core.windows.net

Public Storage network access:
Disabled

## Application Delivery

Application Gateway:
agw-ukpd-corp-prod-uks-001

Web Application Firewall policy:
wafpol-ukpd-corp-prod-uks-001

Public IP:
pip-ukpd-corp-prod-uks-001

The backend pool was intentionally empty because no real application workload was deployed.

## Hybrid

Planned Virtual Network Gateway:

vng-ukpd-hub-prod-uks-001

The gateway provisioning failed and was not treated as operational.

## Design Principle

The hub provides shared connectivity and security.

The Corp spoke provides workload isolation.

Routing forces controlled egress through the central Firewall.

Private Endpoint and Private DNS provide private PaaS access.

Application Gateway and WAF provide application-edge delivery and protection.
