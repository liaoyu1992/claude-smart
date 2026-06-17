# 🧠 项目记忆（自动注入，请优先参考）
> Auto-injected at session start (2026-06-17 08:09 UTC) | 4 memories recalled
> These memories are from past sessions. Apply them proactively.

## 📂 项目知识

**[project]** extract_memory.py updated to import sys module alongside existing standard library imports (100% match)
> The `.claude/bin/extract_memory.py` script was modified to add `import sys` to its import block (alongside json, os, re, shutil). The `run_extraction` function was also updated to handle session observations. Compile validation is performed via `python3 -m py_compile` on both `.claude/bin/_gateway.py` and `.claude/bin/extract_memory.py`.

**[project]** Memory injection replaced merge logic with top-K selection by type priority and relevance (97% match)
> The `.claude/memory/inject_memory_context.py` script was refactored to change how recalled memories are merged with all memories. Instead of a simple merge (Step 5), it now selects the top-K memories based on type priority and relevance scores. The `format_injected_memory` function was renamed/replaced with `select_top_k` to better reflect this selection logic. An anti-bloat limit of `MAX_INJECTED_LINES = 160` is enforced.

**[project]** 当前工作目录: cluade-smart (47% match)
> 当前主要工作在 `C:/Users/liaoyu/work/cluade-smart` 目录（项目 `cluade-smart`）。这是本会话的核心工作目录，操作集中在文件编辑、搜索与阅读。

**[project]** Auto-evolve domain filtering changed from minimum 2 instincts to at least 1 instinct (13% match)
> The `.claude/bin/auto-evolve.py` script had its domain filtering logic relaxed. Previously, only domains with >= 2 instincts were kept; now every domain with at least one instinct is retained. This allows finer-grained instinct tracking across more domains.
