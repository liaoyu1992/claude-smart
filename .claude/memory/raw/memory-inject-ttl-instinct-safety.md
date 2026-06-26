---
name: memory-inject-ttl-instinct-safety
description: Instinct memory type must be exempt from standard TTL cleanup rules
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Running memory cleanup with standard TTL rules applied to all memory types.
- **错误现象**: Valuable instinct memories get silently deleted if they have an older `created_date`.
- **为什么**: Instincts represent canonical, long-term team knowledge that does not expire like standard project or reference memories do.
- **正确做法**: Explicitly exclude the `instinct` type from TTL-based cleanup limits in `.claude/memory/inject_memory_context.py` (TEST C validates this behavior).
