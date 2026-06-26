---
name: windows-git-push-proxy-timeout
description: Git push to GitHub can hang indefinitely on Windows if a stale proxy is configured
metadata:
  type: pitfall
created: "2026-06-25"
updated: "2026-06-25"
---

- **触发条件**: Running `git push` on a Windows environment (e.g., Git Bash) to GitHub.
- **错误现象**: The command hangs indefinitely for several minutes before eventually timing out or failing.
- **为什么**: Git might be routing traffic through a stale or no-longer-active local proxy (like a VPN client or corporate proxy) that was configured globally.
- **正确做法**: If a push takes longer than a few seconds, interrupt it. Diagnose by running `git config --get http.proxy` and `git config --get https.proxy`. If a proxy is set but not needed, clear it using `git config --global --unset http.proxy`.
