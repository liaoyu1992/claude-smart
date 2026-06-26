---
name: cluade-smart-proxy-dependency
description: Network commands in cluade-smart require a local proxy to be set
metadata:
  type: workflow
created: "2026-06-26"
updated: "2026-06-26"
---

When executing network-dependent commands (like `git push`, `gh pr create`, or API calls) in the `cluade-smart` project, the local proxy must be exported first. Use `export HTTPS_PROXY=http://127.0.0.1:52345 HTTP_PROXY=http://127.0.0.1:52345` before running the commands to avoid connection timeouts.
