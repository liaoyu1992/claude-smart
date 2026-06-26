---
name: instinct-ttl-bypass
description: Instinct memories must bypass TTL safety checks to avoid accidental deletion
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Modifying memory loading or cleanup logic (e.g., TTL truncation) in `inject_memory_context.py`.
- **错误现象**: Team instincts with older `created_date` timestamps are accidentally deleted or omitted from the context.
- **为什么**: Standard memory TTL rules would naturally discard older files, but instincts are canonical references that must persist regardless of age.
- **正确做法**: Ensure `load_team_instincts()` bypasses or explicitly handles TTL safety checks, keeping all team instinct files active.
