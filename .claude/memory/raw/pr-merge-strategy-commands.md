---
name: pr-merge-strategy-commands
description: GitHub CLI PR merge workflow using squash strategy
metadata:
  type: reference
created: "2026-06-24"
updated: "2026-06-24"
---

Use `gh pr merge <number> --squash --delete-branch` to merge a PR with squash commit and delete the feature branch. If merge fails due to CODEOWNERS restrictions, first approve with `gh pr review <number> --approve` then retry merge. For CI blocks or merge conflicts, check status with `gh pr checks <number>` and `gh pr view <number> --json mergeStateStatus`.
