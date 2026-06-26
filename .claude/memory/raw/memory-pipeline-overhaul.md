---
name: memory-pipeline-overhaul
description: Claude-smart's automated memory pipeline was overhauled to fix low effectiveness and inject crashes.
metadata:
  type: project
created: "2026-06-17"
updated: "2026-06-17"
---

The `claude-smart` project's memory pipeline (capture → evolve → inject) was fully automated but its actual output diverged severely from its design: over 100 instinct files only yielded 2 active rules, and high-value AI-generated memories weren't being injected properly. This was addressed by adding crash recovery markers to `inject_memory_context.py` and fixing the `auto-analyze-instincts.py` script. The overhaul was merged via PR #15 into the `main` branch.
