---
name: cjk-parameter-removal-in-tokenizer
description: Removed the `cjk` boolean parameter from a tokenization function to simplify the interface.
metadata:
  type: project
created: "2026-06-26"
updated: "2026-06-26"
---

The `tokenize` function signature in `.claude/bin/auto-evolve.py` was simplified by removing the `cjk: bool = False` parameter. This suggests that either CJK (Chinese, Japanese, Korean) text handling is no longer required, or it is being handled automatically/differently within the function logic without needing an explicit flag.
