---
name: consolidate-dry-run-projection-fix
description: Dry-run mode in consolidation scripts must explicitly skip or project file counts without modifying the filesystem.
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Running a consolidation script (e.g., `consolidate_instincts.py`) with a `--dry-run` flag to preview changes.
- **错误现象**: The script reports incorrect post-consolidation file counts or prematurely alters the state before the actual run.
- **为什么**: The file counting logic was placed after the dry-run flag check, meaning it tried to count files assuming modifications had already occurred.
- **正确做法**: Explicitly return early or use projected counts (e.g., `after = before - merged_count`) when `args.dry_run` is true, avoiding any actual filesystem writes or state assumptions.
