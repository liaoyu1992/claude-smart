---
name: instinct-merge-id-resolution
description: Instinct analysis relies on finding a merge target ID to properly group or update existing instincts.
metadata:
  type: project
created: "2026-06-26"
updated: "2026-06-26"
---

The instinct workflow uses a function `find_merge_target_id` in `.claude/bin/auto-analyze-instincts.py` to determine where new semantic information should be integrated. It features a fallback mechanism (Path B: AI semantic analysis) to resolve IDs when standard/local resolution fails, ensuring new instincts are appended or merged correctly based on meaning.
