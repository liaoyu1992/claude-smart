---
name: git-push-proxy-config-gitee-github
description: Network requires specific proxy configuration depending on the remote host (GitHub vs Gitee)
metadata:
  type: workflow
created: "2026-06-26"
updated: "2026-06-26"
---

When interacting with remote repositories in this environment, specific proxy configurations are required depending on the host. For GitHub pushes, set `HTTPS_PROXY=http://127.0.0.1:52345` and `HTTP_PROXY=http://127.0.0.1:52345`. For Gitee pushes, the proxy must be disabled by running `env -u HTTPS_PROXY -u HTTP_PROXY -u https_proxy -u http_proxy`.
