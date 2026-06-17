---
name: auto-evolve-domain-filter-relaxed
description: Auto-evolve domain filtering changed from minimum 2 instincts to at least 1 instinct
metadata:
  type: project
created: "2026-06-17"
updated: "2026-06-17"
---

The `.claude/bin/auto-evolve.py` script had its domain filtering logic relaxed. Previously, only domains with >= 2 instincts were kept; now every domain with at least one instinct is retained. This allows finer-grained instinct tracking across more domains.
