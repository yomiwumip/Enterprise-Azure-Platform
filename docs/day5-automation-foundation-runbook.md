# Day 5 — Azure Automation Foundation
## Complete Cloud Platform Engineer Runbook

**Contoso Holdings — Enterprise Azure Platform**
**Cloud Platform Engineer Residency — Week 1 / Sprint 1**

---

# 1. Purpose

This runbook documents the actual Day 5 engineering work completed for the Contoso Holdings Enterprise Azure Platform.

Day 5 moves the platform from manually performing Azure management operations toward repeatable automation.

The implementation focuses on:

- Azure CLI automation;
- PowerShell automation;
- resource inventory;
- governance validation;
- management lock verification;
- input validation;
- error handling;
- repeatable operational checks;
- Git version control;
- portfolio evidence.

This document is intended to be reproducible by another engineer without requiring the original engineer to remember the commands.

---

# 2. Day 5 Mission

## Move from clicking to engineering

Day 4 established the Azure platform foundation and introduced Azure Portal operational management.

Day 5 converts selected Day 4 operational activities into scripts.

The engineering progression is:

```text
Azure Portal
     |
     | Manual operation
     v
Azure CLI
     |
     | Repeatable command
     v
PowerShell / Bash automation
     |
     | Validation + error handling
     v
Version-controlled operational tooling
