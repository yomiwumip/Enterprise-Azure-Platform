# UKPropertyDealDesk — Day 2 Lessons Learned

## 1. Architecture

Centralised connectivity creates a clear shared-services boundary.

## 2. Hub-and-Spoke

Workload networks remain separate from shared network infrastructure.

## 3. Egress

Centralised egress provides a controlled inspection path.

## 4. Security

Network Security Groups and Azure Firewall provide different layers of network control.

## 5. DNS

Private Endpoint implementation is incomplete without correct DNS resolution.

## 6. Private Access

Private PaaS connectivity reduces dependence on public network exposure.

## 7. Application Delivery

Application Gateway and Web Application Firewall require a real backend for genuine end-to-end application testing.

## 8. Hybrid Connectivity

Hybrid connectivity must be validated from actual Azure provisioning through tunnel establishment and traffic testing.

## 9. Terraform

Terraform state must accurately represent the real Azure environment.

When resources are deliberately destroyed, stale imported state must be removed.

## 10. Provider Compatibility

The Azure Resource Manager Terraform provider can change supported resource arguments.

Provider compatibility must therefore be checked during implementation.

## 11. Cost

Production-style Azure infrastructure should not be left running unnecessarily.

The environment was destroyed after the required engineering evidence had been captured.

## 12. Engineering Evidence

A professional implementation should distinguish:

- implemented
- validated
- designed
- failed
- deferred
- not applicable

This prevents portfolio documentation from overstating capability.

## 13. Day 3

Day 3 should extend the platform into advanced networking capabilities rather than repeating the Day 2 foundation.
