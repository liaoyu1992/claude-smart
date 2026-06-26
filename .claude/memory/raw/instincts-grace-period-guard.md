---
name: instincts-grace-period-guard
description: Instinct consolidation scripts require a grace-period guard to prevent processing newly created files.
metadata:
  type: project
created: "2026-06-26"
updated: "2026-06-26"
---

The instinct consolidation workflow includes a guard mechanism to respect a 'grace period' for new instinct files. This ensures that recently generated instincts are not immediately consolidated or overwritten, giving them time to be reviewed or utilized individually before being merged into larger rules.
