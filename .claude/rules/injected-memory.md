# 🧠 项目记忆（自动注入，请优先参考）
> Auto-injected at session start (2026-06-26 04:45 UTC) | 10 memories recalled
> These memories are from past sessions. Apply them proactively.

## ⚠️ 业务防坑

**[pitfall]** Interactive squash commits can accidentally drop files that were added in squashed commits (100% match)
> - **触发条件**: Performing an interactive git rebase to squash commits on a feature branch.
> - **错误现象**: Specific files added in earlier commits (like hook scripts) are missing from the final squashed commit.
> - **为什么**: During conflict resolution or editing of the commit sequence in the rebase, files can be unintentionally dropped or overwritten by the rebase tooling.
> - **正确做法**: After squashing, always verify that all intended files are present in the final commit using `git show --stat`. If a file is missing, restore it via `git checkout <original-branch> -- <file>` and create a new fix-up commit.

**[pitfall]** Dry-run mode in consolidation scripts must explicitly skip or project file counts without modifying the filesystem.
> - **触发条件**: Running a consolidation script (e.g., `consolidate_instincts.py`) with a `--dry-run` flag to preview changes.
> - **错误现象**: The script reports incorrect post-consolidation file counts or prematurely alters the state before the actual run.
> - **为什么**: The file counting logic was placed after the dry-run flag check, meaning it tried to count files assuming modifications had already occurred.
> - **正确做法**: Explicitly return early or use projected counts (e.g., `after = before - merged_count`) when `args.dry_run` is true, avoiding any actual filesystem writes or state assumptions.

**[pitfall]** Insufficient domain search condition leading to incorrect data aggregation
> **触发条件**: When searching for 'domain.*2' or '>= 2' patterns in Chinese context
> **错误现象**: Fails to capture Chinese characters '至少' (meaning 'at least') in search patterns
> **为什么**: ASCII regex patterns don't match Chinese text, causing domain aggregation to miss relevant observations
> **正确做法**: Use Unicode-aware patterns or Chinese-specific search terms like '至少' when working with multilingual content

## 🧭 全局 Instinct

**[instinct]** 通用踩坑经验，适用于所有成员
> 在使用 CLI 工具前，先用 `which <tool>` 或 `<tool> --version` 检查工具是否已安装且版本正确，避免因工具缺失导致任务中断。
> 在 Edit 文件前，先用 Read 工具读取该文件的当前内容，特别是当文件较长或最近有其他改动时。不跳过读取直接编辑，以避免基于过时内容产生错误的修改。
> - 使用正斜杠 `/` 而非反斜杠 `\` 作为路径分隔符
> - Git Bash 中 `rm -rf` 对 `C:\` 等系统目录同样有效，需格外小心

## 📂 项目知识

**[project]** Implemented a bash stop hook wrapper to decouple session-end tasks from the core pipeline. (72% match)
> A `.claude/hooks/stop.sh` script was added to decouple session-end tasks from the core memory pipeline. This replaced the direct execution of `auto-analyze-instincts.py` inside `.claude/settings.local.json`. The script was initially cherry-picked from `5274ba0` into a dedicated branch `feat/stop-hook-wrapper` off `origin/main` and deployed via PR to ensure it safely entered the main branch.

**[project]** Instinct analysis relies on finding a merge target ID to properly group or update existing instincts. (50% match)
> The instinct workflow uses a function `find_merge_target_id` in `.claude/bin/auto-analyze-instincts.py` to determine where new semantic information should be integrated. It features a fallback mechanism (Path B: AI semantic analysis) to resolve IDs when standard/local resolution fails, ensuring new instincts are appended or merged correctly based on meaning.

**[project]** 当前工作目录: cluade-smart (50% match)
> 当前主要工作在 `C:/Users/liaoyu/work/cluade-smart` 目录（项目 `cluade-smart`）。这是本会话的核心工作目录，操作集中在文件编辑、搜索与阅读。

**[project]** Claude-smart's automated memory pipeline was overhauled to fix low effectiveness and inject crashes. (45% match)
> The `claude-smart` project's memory pipeline (capture → evolve → inject) was fully automated but its actual output diverged severely from its design: over 100 instinct files only yielded 2 active rules, and high-value AI-generated memories weren't being injected properly. This was addressed by adding crash recovery markers to `inject_memory_context.py` and fixing the `auto-analyze-instincts.py` script. The overhaul was merged via PR #15 into the `main` branch.

**[project]** Auto-evolve domain filtering changed from minimum 2 instincts to at least 1 instinct
> The `.claude/bin/auto-evolve.py` script had its domain filtering logic relaxed. Previously, only domains with >= 2 instincts were kept; now every domain with at least one instinct is retained. This allows finer-grained instinct tracking across more domains.

**[project]** Removed the `cjk` boolean parameter from a tokenization function to simplify the interface.
> The `tokenize` function signature in `.claude/bin/auto-evolve.py` was simplified by removing the `cjk: bool = False` parameter. This suggests that either CJK (Chinese, Japanese, Korean) text handling is no longer required, or it is being handled automatically/differently within the function logic without needing an explicit flag.
