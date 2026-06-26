---
name: git-squash-loses-files-pitfall
description: Interactive squash commits can accidentally drop files that were added in squashed commits
metadata:
  type: pitfall
created: "2026-06-25"
updated: "2026-06-25"
---

- **触发条件**: Performing an interactive git rebase to squash commits on a feature branch.
- **错误现象**: Specific files added in earlier commits (like hook scripts) are missing from the final squashed commit.
- **为什么**: During conflict resolution or editing of the commit sequence in the rebase, files can be unintentionally dropped or overwritten by the rebase tooling.
- **正确做法**: After squashing, always verify that all intended files are present in the final commit using `git show --stat`. If a file is missing, restore it via `git checkout <original-branch> -- <file>` and create a new fix-up commit.
