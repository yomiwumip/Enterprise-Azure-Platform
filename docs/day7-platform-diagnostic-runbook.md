# Day 7 — Azure Platform Operations & Diagnostics

## Complete Cloud Platform Engineer Runbook

**Contoso Holdings — Enterprise Azure Platform**  
**Cloud Platform Engineer Residency — Week 1 / Sprint 1**

---

# 1. Purpose

Day 7 extends the Day 6 platform health automation into operational diagnostics.

Day 6 established a basic platform health check answering:

> Is the platform healthy?

Day 7 introduces the next operational capability:

> If something requires investigation, how does an engineer collect evidence and determine what is happening?

The objective is to move the platform toward a repeatable operational investigation process rather than relying on manually executed Azure CLI commands.

The Day 7 diagnostic automation retrieves the Resource Group name from the existing Terraform output and collects operational information from Azure.

The diagnostic provides:

- Resource Group information
- Resource inventory
- Resource count
- Management-lock inventory
- Management-lock count
- Explicit diagnostic success/failure states
- Exit-code handling
- Working-directory portability

---

# 2. Day 7 Engineering Objective

The primary Day 7 engineering objective is to establish a repeatable platform diagnostic capability.

The operational progression is:

```text
Day 5
Automation Foundation
        |
        v
Day 6
Platform Health
        |
        v
Day 7
Platform Operations & Diagnostics
