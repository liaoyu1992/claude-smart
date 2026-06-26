---
name: github-access-proxy-port
description: Working local proxy port for accessing GitHub API from this machine
metadata:
  type: project
created: "2026-06-26"
updated: "2026-06-26"
---

When GitHub API access (e.g., `gh pr create`) fails due to network issues on this machine, the working local proxy is at `127.0.0.1:52345`. Standard proxy ports (7890, 7891, 1080) were probed and failed. To use it, export the environment variables: `HTTPS_PROXY=http://127.0.0.1:52345 HTTP_PROXY=http://127.0.0.1:52345` before running git or `gh` commands.
