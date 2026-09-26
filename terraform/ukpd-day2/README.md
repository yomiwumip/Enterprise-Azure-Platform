# UKPropertyDealDesk Day 2 Networking

This Terraform root reproduces the UKPropertyDealDesk Day 2 Azure networking architecture in UK South.

## Scope

- Connectivity hub Virtual Network (VNet)
- Corp workload spoke VNet
- Hub/spoke peering
- Azure Firewall and Firewall Policy
- NAT Gateway
- Private DNS Resolver
- Central Private DNS
- Network Security Groups (NSGs)
- User Defined Route (UDR)
- Storage Account + Private Endpoint + Private DNS Zone Group
- Application Gateway Web Application Firewall (WAF) V2
- Public frontend, listener, routing rule and empty backend pool
- Production tags

## Deliberate exclusions

- The Azure Virtual Network Gateway (VPN) is not declared as a successful resource because the Portal deployment failed with Azure backend error `VmssGatewayDeploymentFailed`.
- No on-premises Local Network Gateway, IPsec tunnel or Border Gateway Protocol (BGP) peer is invented.
- The existing Azure Bastion resource name was not available in the recorded Day 2 evidence, so Bastion will be added only after its actual deployed name is confirmed.
- Application Gateway has no fabricated backend target.

## State

This root uses a separate remote state key from the existing platform Terraform root.

Backend:
- Storage account: `stcontosogovtf001`
- Resource group: `rg-contoso-platform-prod-uks-001`
- Container: `tfstate`
- Key: `tfstate/ukpd-day2-networking.tfstate`

Do not run `terraform apply` against the Portal-deployed resources until the import/reconciliation strategy is explicitly chosen.
