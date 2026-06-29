---
name: evolve-early-exit-pitfall
description: Removing early-exit optimizations from auto-evolve.py fixed logic errors during the instinct evolution step.
metadata:
  type: pitfall
created: "2026-06-29"
updated: "2026-06-29"
---

- **触发条件**: Loading and processing active instincts in `auto-evolve.py` (Step 1).
- **错误现象**: Instinct evolution fails or skips valid entries due to premature termination of the loading loop.
- **为什么**: An early-exit optimization condition was flawed, causing the script to think it had finished loading all active instincts before actually reaching the end of the dataset.
- **正确做法**: Remove early-exit conditions in the instinct loading loop and process the full dataset sequentially.
