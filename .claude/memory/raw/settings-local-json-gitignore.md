---
name: settings-local-json-gitignore
description: settings.local.json is not tracked in git
metadata:
  type: project
created: "2026-06-17"
updated: "2026-06-17"
---

The `.claude/settings.local.json` file is explicitly not tracked in git (verified via `git ls-files`). It should not be committed, as it contains local environment configurations such as custom hook commands.
