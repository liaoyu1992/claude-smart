---
name: dry-run-safely-handles-file-counting
description: Dry-run modes for filesystem operations must account for file counts safely when skipping mutations.
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Testing a consolidation script using a `--dry-run` flag that expects to report filesystem changes.
- **错误现象**: The script crashes or provides incorrect projections if it tries to calculate differences in file counts before the actual files exist or are modified.
- **为什么**: The script logic tried to execute normal post-execution logic (like counting files in a directory) even when the mutation step was bypassed.
- **正确做法**: Add an early return or conditional block (e.g., `if args.dry_run: return`) right after the simulated mutation logic so that dry-runs skip actual filesystem state assertions.
