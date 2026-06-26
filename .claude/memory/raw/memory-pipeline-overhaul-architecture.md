---
name: memory-pipeline-overhaul-architecture
description: Architecture of the memory pipeline overhaul in the .claude directory
metadata:
  type: project
created: "2026-06-17"
updated: "2026-06-17"
---

The `.claude` directory contains an automated memory pipeline consisting of scripts in `.claude/bin/` (e.g., `auto-analyze-instincts.py`, `auto-evolve.py`, `_gateway.py`, `extract_memory.py`) and `.claude/memory/inject_memory_context.py`. The pipeline appears to process and inject memory context into Claude Code sessions. A crash recovery mechanism was added to `inject_memory_context.py` via a `_maybe_recover_analysis` helper function.
