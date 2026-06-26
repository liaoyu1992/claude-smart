---
name: git-remote-sync-reset
description: Reset local branch to match remote state after merge conflicts
metadata:
  type: reference
created: "2026-06-24"
updated: "2026-06-24"
---

When local main branch diverges from remote after merge operations, use `git reset --hard origin/main` to force-reset local state to match remote. Verify alignment with `git log --oneline origin/main -3 && git log --oneline HEAD -3` and check for differences with `git diff origin/main..HEAD`.
