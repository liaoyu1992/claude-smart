---
name: windows-python-tmp-environment-variable
description: Pitfall when setting the Python temp directory via environment variables on Windows
metadata:
  type: pitfall
created: "2026-06-29"
updated: "2026-06-29"
---

- **触发条件**: Attempting to override the temporary directory for Python scripts on Windows by setting a generic environment variable.
- **错误现象**: Scripts fail to locate the intended isolated environment, or Bash commands referencing generic temp variables evaluate incorrectly.
- **为什么**: On Windows, the standard Unix-like environment variables may not translate directly or might be shadowed by system defaults depending on how the shell is invoked.
- **正确做法**: Explicitly define the target path variable using the absolute Windows path format (e.g., `TC="C:/Users/liaoyu/AppData/Local/Temp/..."`) directly in the Bash command before executing the python script.
