# Contoso Holdings — Azure Naming Standard

## Purpose

This document defines the standard naming convention for Azure resources in the Contoso Holdings platform.

Consistent resource naming supports searchability, automation, governance, reporting, monitoring, troubleshooting, and operational management.

## Standard Naming Pattern

<resource>-<company>-<environment>-<workload>-<region>-<number>

## Components

| Component | Meaning |
|---|---|
| resource | Azure resource type |
| company | Contoso Holdings identifier |
| workload | Business or platform purpose |
| environment | Deployment environment |
| environment | Deployment environment |
| region | Azure region identifier |
| number | Sequential resource number |

## Examples

Resource Group:

rg-contoso-prod-network-uks-001

Virtual Network:

vnet-contoso-prod-hub-uks-001

Storage Account:

stcontosoprodlogsuks001

## Day 4 Platform Resource Group

The first production-style platform Resource Group will use:

rg-contoso-platform-prod-uks-001

## Engineering Principles

Names must be:

- Consistent
- Predictable
- Searchable
- Automation-friendly
- Meaningful to engineers
- Appropriate for the target environment

Avoid ambiguous names such as:

- myresourcegroup
- test123
- newRG

## Region Convention

For the current Contoso platform:

UK South is represented as:

uks

UK West is represented as:

ukw

## Environment Convention

Production:

prod

Development:

dev

Test:

test

Sandbox:

sandbox

## Numbering

Resources of the same naming scope should use a sequential numeric suffix:

001
002
003

The number should distinguish multiple resources serving the same purpose.

## Day 4 Decision

The first production-style platform Resource Group will be named:

rg-contoso-platform-prod-uks-001

This name follows the Week 1 engineering naming standard and identifies:

- Resource type: Resource Group
- Company: Contoso
- Environment: Production
- Workload: Platform
- Region: UK South
- Number: 001
