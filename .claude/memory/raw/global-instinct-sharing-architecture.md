---
name: global-instinct-sharing-architecture
description: Architecture for sharing team instincts across personal and team directories
metadata:
  type: project
created: "2026-06-26"
updated: "2026-06-26"
---

The project implements a memory injection system where team instincts are loaded alongside personal memories. The `session-inject.sh` script acts as the canonical entry point (Step 0), fanning out team instincts. The `inject_memory_context.py` script uses a priority grouping system (`["user", "feedback", "pitfall", "project", "reference"]`) and gracefully truncates lower-priority sections to stay within a strict `INJECT_BUDGET` (10 slots).
