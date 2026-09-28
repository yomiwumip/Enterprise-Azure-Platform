# UKPropertyDealDesk — Day 2 Failure Testing and Validation Record

## Validation Model

Network failures are investigated from the workload outward:

Workload
→ Subnet
→ Network Security Group
→ User Defined Route
→ Azure Firewall
→ Firewall Policy
→ NAT
→ DNS
→ Destination

## Routing Failure

### Failure

Incorrect or missing default route.

### Expected impact

Workload loses the intended controlled egress path.

### Checks

- route table association
- 0.0.0.0/0 route
- next hop
- effective routes
- Firewall reachability

## Network Security Group Failure

### Failure

A Network Security Group denies required traffic.

### Checks

- source subnet
- source NSG
- destination subnet
- destination NSG
- effective security rules

## Private Endpoint DNS Failure

### Failure

Private Endpoint exists but DNS resolution is incorrect.

### Checks

- Private Endpoint provisioning
- Private Endpoint NIC
- private IP
- Private DNS zone
- VNet link
- A record
- DNS resolution
- connectivity

## Firewall Failure

### Failure

Outbound traffic does not leave the spoke.

### Checks

- UDR
- Firewall private IP
- Firewall Policy
- rule collection
- priority
- source
- destination
- protocol
- port
- NAT

## Application Gateway Failure

### Failure

Application Gateway exists but application traffic does not succeed.

### Checks

- gateway provisioning
- frontend IP
- listener
- routing rule
- WAF policy
- backend pool
- backend health

No backend health claim was made because no real backend application was deployed.

## Hybrid VPN Failure

### Observed

Azure Virtual Network Gateway provisioning failed with:

VmssGatewayDeploymentFailed

Azure described the failure as an intermittent deployment error.

Correlation ID:

c78ea531-24dd-4046-a414-8427e3c4b689

Operation ID:

09b185d3-a942-4fff-8936-98e3e82b096d

Timestamp:

2026-09-26T16:04:31Z

### Engineering response

The failure was documented.

Hybrid connectivity was not marked complete.

No fabricated on-premises configuration was introduced.

## Validation Principle

Resource deployment success, network connectivity and application availability are separate validation stages.
