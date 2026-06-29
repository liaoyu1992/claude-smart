---
name: memory-pipeline-workflow
description: The execution sequence for testing the observation and memory extraction pipeline
metadata:
  type: reference
created: "2026-06-29"
updated: "2026-06-29"
---

The memory pipeline is tested in distinct phases. First, synthetic observations are generated. Next, the `auto-analyze-instincts.py` script processes statistical and AI semantic insights, followed by `auto-evolve.py` to generate aggregated rules. Later phases involve running `extract_memory.py` for knowledge extraction, `consolidate_instincts.py` for garbage collection/dry-runs, and `sync-team.py` to synchronize states.
