---
name: domain-pitfall-initial-search
description: Insufficient domain search condition leading to incorrect data aggregation
metadata:
  type: pitfall
created: "2026-06-18"
updated: "2026-06-18"
---

**触发条件**: When searching for 'domain.*2' or '>= 2' patterns in Chinese context
**错误现象**: Fails to capture Chinese characters '至少' (meaning 'at least') in search patterns
**为什么**: ASCII regex patterns don't match Chinese text, causing domain aggregation to miss relevant observations
**正确做法**: Use Unicode-aware patterns or Chinese-specific search terms like '至少' when working with multilingual content
