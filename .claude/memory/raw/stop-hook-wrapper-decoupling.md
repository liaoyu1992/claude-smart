---
name: stop-hook-wrapper-decoupling
description: Implemented a bash stop hook wrapper to decouple session-end tasks from the core pipeline.
metadata:
  type: project
created: "2026-06-17"
updated: "2026-06-17"
---

A `.claude/hooks/stop.sh` script was added to decouple session-end tasks from the core memory pipeline. This replaced the direct execution of `auto-analyze-instincts.py` inside `.claude/settings.local.json`. The script was initially cherry-picked from `5274ba0` into a dedicated branch `feat/stop-hook-wrapper` off `origin/main` and deployed via PR to ensure it safely entered the main branch.
