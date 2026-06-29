---
name: isolated-environment-testing
description: Workflow pattern for safely testing memory scripts without corrupting live session data
metadata:
  type: reference
created: "2026-06-29"
updated: "2026-06-29"
---

To test the system without affecting the actual session data, an isolated copy of the project is created in the local temp directory (e.g., `C:/Users/liaoyu/AppData/Local/Temp/cs_e2e_test/`). Scripts like `auto-evolve.py`, `auto-analyze-instincts.py`, and `extract_memory.py` are then executed against this temporary target path to safely verify pipeline functionality and output.
