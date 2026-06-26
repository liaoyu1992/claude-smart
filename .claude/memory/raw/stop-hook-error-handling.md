---
name: stop-hook-error-handling
description: Stop hook wrapper script for robust error handling and script execution sequencing
metadata:
  type: project
created: "2026-06-18"
updated: "2026-06-18"
---

The stop hook uses a wrapper script (.claude/hooks/stop.sh) that executes multiple scripts sequentially with error handling. This prevents session termination if any script fails, ensuring complete processing of observations, instinct提炼, rule aggregation, and rule generation. The wrapper approach provides resilience in the session lifecycle management.
