---
name: team-instinct-sync-architecture
description: Architecture for syncing team instincts globally across multiple Claude targets
metadata:
  type: project
created: "2026-06-26"
updated: "2026-06-26"
---

The `cluade-smart` project implements a global team instinct sharing architecture. It uses `.claude/bin/sync-team.py` to distribute memory state across 3 separate target directories. The `session-inject.sh` hook handles this via "Step 0" (fanning out team instincts to the canonical target), which then feeds into `inject_memory_context.py`.
