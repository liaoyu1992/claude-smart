---
name: instinct-confidence-type-validation
description: Instinct confidence values must be numeric, as float inputs can trigger deprecated/invalid type errors.
metadata:
  type: pitfall
created: "2026-06-29"
updated: "2026-06-29"
---

- **触发条件**: Updating or decaying instinct confidence values in `auto-analyze-instincts.py`.
- **错误现象**: Confidence values stored as floats inadvertently cause the instinct to be marked as deprecated or invalid.
- **为什么**: The logic handling confidence decay does not strictly enforce or correctly cast numeric types, causing float values to fail type checks or trigger legacy deprecation logic.
- **正确做法**: Ensure confidence values are strictly validated and properly cast during decay/update operations to prevent float-to-deprecated classification.
