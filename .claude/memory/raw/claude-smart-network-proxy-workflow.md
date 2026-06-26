---
name: claude-smart-network-proxy-workflow
description: Network commands in Claude Code require explicit local proxy setup on this machine
metadata:
  type: workflow
created: "2026-06-26"
updated: "2026-06-26"
---

When executing network-dependent commands (like `git push`, `gh pr create`, or API requests) in the Claude Code environment on this Windows machine, you must explicitly set the proxy variables first. The required command prefix is `export HTTPS_PROXY=http://127.0.0.1:52345 HTTP_PROXY=http://127.0.0.1:52345`. Without this, network operations will fail to connect.
