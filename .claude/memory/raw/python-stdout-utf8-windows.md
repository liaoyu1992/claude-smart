---
name: python-stdout-utf8-windows
description: Force UTF-8 encoding on stdout for Python scripts running in Windows Git Bash.
metadata:
  type: pitfall
created: "2026-06-26"
updated: "2026-06-26"
---

- **触发条件**: Running Python scripts via `python3 - <<'PY'` heredocs on a Windows environment (Git Bash).
- **错误现象**: The script crashes with a `UnicodeEncodeError` when attempting to print CJK characters or write to standard output.
- **为什么**: The default Windows/Git Bash standard output stream encoding may default to cp1252 or similar, which cannot encode Unicode characters.
- **正确做法**: Add `sys.stdout.reconfigure(encoding="utf-8")` at the very beginning of the script.
