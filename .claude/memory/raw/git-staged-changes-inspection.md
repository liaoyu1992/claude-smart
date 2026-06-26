---
name: git-staged-changes-inspection
description: Using git diff to review changes before committing
metadata:
  type: reference
created: "2026-06-18"
updated: "2026-06-18"
---

Before committing changes, the developer inspects staged changes using `git diff | head -100` and `git diff | tail -80` to review both the beginning and end of the diff. This practice ensures comprehensive review of modifications before they're committed to the repository.
