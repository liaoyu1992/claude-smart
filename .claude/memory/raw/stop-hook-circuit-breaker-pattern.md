---
name: stop-hook-circuit-breaker-pattern
description: Stop hook uses circuit breaker pattern to prevent script failures from stopping subsequent scripts
metadata:
  type: project
created: "2026-06-18"
updated: "2026-06-18"
---

The Stop Hook implements a circuit breaker pattern where each script in the chain wraps its execution in error handling. If a script fails, it logs the error but continues with the next script instead of aborting the entire process. This ensures partial progress even when individual components fail.
