---
name: memory-injection-top-k-selection
description: Memory injection replaced merge logic with top-K selection by type priority and relevance
metadata:
  type: project
created: "2026-06-17"
updated: "2026-06-17"
---

The `.claude/memory/inject_memory_context.py` script was refactored to change how recalled memories are merged with all memories. Instead of a simple merge (Step 5), it now selects the top-K memories based on type priority and relevance scores. The `format_injected_memory` function was renamed/replaced with `select_top_k` to better reflect this selection logic. An anti-bloat limit of `MAX_INJECTED_LINES = 160` is enforced.
