---
name: dry-run-side-effects-in-cli-scripts
description: Pitfall where a --dry-run flag caused filesystem side effects because it only skipped the final output step
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Testing consolidation scripts using a `--dry-run` flag.
- **错误现象**: The script modifies the filesystem (e.g., moving or deleting files) before reaching the final output stage, defeating the purpose of the dry run.
- **为什么**: The script was architected to perform filesystem mutations early in its execution and only checked the `dry_run` flag right before the final file generation, causing intermediate side effects.
- **正确做法**: Short-circuit or branch out of filesystem mutation operations immediately if `args.dry_run` is true, ensuring no destructive actions occur at any stage.
