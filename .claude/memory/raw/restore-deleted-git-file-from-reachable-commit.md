---
name: restore-deleted-git-file-from-reachable-commit
description: Technique to restore a deleted file by extracting it from a past reachable commit using git show
metadata:
  type: reference
created: "2026-06-25"
updated: "2026-06-25"
---

If a tracked file is accidentally deleted or removed in a later commit but exists in a prior reachable commit, you can restore it byte-for-byte. First, locate the commit hash containing the file using `git log --all --diff-filter=D --oneline -- 'path'`. Then, restore it directly using `git show <commit-hash>:<file-path> > <file-path>`.
