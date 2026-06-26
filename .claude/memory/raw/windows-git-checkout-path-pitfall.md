---
name: windows-git-checkout-path-pitfall
description: Git checkout fails in Git Bash when mixing Windows backslash paths
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Executing `git checkout` or interacting with file paths in a Git Bash / Unix-style terminal on Windows.
- **错误现象**: Commands fail with path-not-found or invalid argument syntax errors.
- **为什么**: The shell attempts to parse Windows paths (e.g., `C:\Users\...`) but gets confused by escape characters or format mismatches.
- **正确做法**: Always use POSIX-style paths (e.g., `/c/Users/liaoyu/work/cluade-smart`) when `cd`-ing into directories or passing file arguments to git in the terminal.
