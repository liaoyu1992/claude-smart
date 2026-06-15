# 🧬 Claude Code 自我进化与记忆系统

> 基于得物技术文章实现的 Claude Code 持久化记忆与自我学习系统
>
> 📖 参考文章：[让 Claude Code 拥有持久记忆，实现自我进化](https://mp.weixin.qq.com/s/PGT49KORSVZYpJxykWnwOw)

---

## 系统总览

系统由 **5 个阶段** 构成一个闭环学习回路：观测 → 提炼 → 聚合 → 注入 → 下次会话自动加载。

```text
┌─────────────────── 会话中 ───────────────────┐     ┌─── 会话结束 ───┐     ┌─── 下次会话启动 ───┐
│                                               │     │                │     │                    │
│  用户操作                                      │     │  Stop Hook     │     │  SessionStart Hook │
│    ↓                                          │     │    ↓           │     │       ↓            │
│  Claude 工具调用 (Bash/Edit/Read/Grep/...)     │     │  ┌──────────┐  │     │  ┌───────────────┐ │
│    ↓              ↓                           │     │  │ 双路径    │  │     │  │ 记忆检索注入  │ │
│  PreToolUse → PostToolUse                     │     │  │ 分析引擎  │  │     │  │               │ │
│    ↓              ↓                           │     │  └────┬─────┘  │     │  │ embed.py      │ │
│  observe.sh → observe.py                      │     │  ┌────┴─────┐  │     │  │ vector_store  │ │
│    ↓                                          │     │  │ 知识提取  │  │     │  │ BM25 fallback │ │
│  observations.jsonl                           │     │  └────┬─────┘  │     │  └───────┬───────┘ │
│                                               │     │  ┌────┴─────┐  │     │          ↓         │
└───────────────────────────────────────────────┘     │  │ 进化聚合  │  │     │  injected-memory.md│
                                                      │  └────┬─────┘  │     │  auto-evolved.md   │
                                                      └────────┼───────┘     └────────────────────┘
                                                               ↓
                                                    personal/*.md (行为规则)
                                                    memory/raw/*.md (知识记忆)
                                                    rules/auto-evolved.md (聚合规则)
```

三层核心子系统：

| 层 | 目录 | 作用 |
| --- | --- | --- |
| 🔍 **行为观测层** | `hooks/` + `bin/observe*.py` | Hook 捕获工具调用 → JSONL 观测流 |
| 🧠 **模式提炼层** | `bin/auto-analyze*.py` + `bin/extract_memory.py` | 统计+AI 双路径分析 → Instinct 规则 + 知识记忆 |
| 💾 **记忆注入层** | `memory/` + `rules/` | 向量/BM25 检索 Top-K → 自动注入上下文 |

---

## 代码结构图

```text
.claude/
│
├── hooks/
│   └── observe.sh                     ◀── Claude Code Hook 入口
│       ├── → bin/observe.py           (记录工具调用到 JSONL)
│       └── → bin/observations_rotate.py (数据轮转/归档)
│
├── bin/
│   ├── observe.py                     ◀── 观测记录写入器 (176行)
│   │   ├── get_session_id()           会话 ID 管理 (30min 过期)
│   │   ├── normalize_paths()          绝对路径→相对路径
│   │   └── write_observation()        写入 JSONL 记录
│   │
│   ├── observations_rotate.py         ◀── 数据轮转 (117行)
│   │   ├── needs_rotation()           5MB / 8000行阈值检测
│   │   └── archive_old_data()         按月归档，保留30天
│   │
│   ├── auto-analyze-instincts.py      ◀── 行为模式分析 (526行) ★ 核心
│   │   ├── 路径 A: 5个统计检测器
│   │   │   ├── detect_bash_dominant()     Bash 占比 >40%
│   │   │   ├── detect_edit_then_bash()    Edit后紧跟验证 >=40%
│   │   │   ├── detect_read_before_edit()  Read→Edit 比率 >80%
│   │   │   ├── detect_search_first()      先搜索后操作 >=40%
│   │   │   └── detect_project_context()   高频目录 >30%
│   │   ├── 路径 B: AI 语义分析
│   │   │   ├── build_ai_prompt()          构造分析 Prompt
│   │   │   └── run_ai_analysis()          调用 Claude Haiku
│   │   ├── apply_confidence_decay()       置信度衰减 (每日-0.05)
│   │   └── write_instinct_file()          写入 personal/*.md
│   │
│   ├── auto-evolve.py                 ◀── 进化聚合器 (270行) ★ 核心
│   │   ├── load_all_instincts()       加载所有活跃 Instinct
│   │   ├── UnionFind                  并查集数据结构
│   │   ├── jaccard()                  Jaccard 相似度计算
│   │   ├── deduplicate_instincts()    语义去重 (阈值 0.5)
│   │   ├── aggregate_by_domain()      按域分组
│   │   └── write_evolved_rules()      写入 auto-evolved.md
│   │
│   ├── extract_memory.py             ◀── 知识记忆提取 (319行) ★ 核心
│       ├── summarize_session()            生成会话摘要
│       ├── build_extraction_prompt()      构造提取 Prompt
│       ├── run_extraction()               调用 Claude Haiku
│       ├── extract_project_context()      统计提取项目上下文
│       └── write_memory_file()            写入 memory/raw/*.md
│       │
│   ├── promote-to-team.py            ◀── 团队提炼候选生成 (293行)
│       ├── filter_candidates()            筛选 confidence≥0.7 & observed≥3
│       ├── best_team_match()              与 team/ 现有规则比对 (Jaccard)
│       └── write_candidates_file()        写入 promote-candidates.md (gitignore)
│       │
│   └── adopt-instinct.py             ◀── 个人→团队规则采纳器 (162行)
│       └── render_team_rule()             去个性化 + 写入 team/*.md
│
├── memory/
│   ├── embed.py                       ◀── 向量嵌入 (95行)
│   │   ├── embed_text()               单条嵌入 (Ollama API)
│   │   ├── embed_texts()              批量嵌入 (自动降级逐条)
│   │   └── check_ollama_available()   检测 Ollama 可用性
│   │
│   ├── vector_store.py                ◀── 向量存储 (196行)
│   │   └── MemoryVectorStore
│   │       ├── __init__()             Qdrant 优先 / NumPy 降级
│   │       ├── upsert_memory()        插入/更新向量
│   │       ├── recall_memories()      Top-K 余弦相似度检索
│   │       └── delete_memory()        删除向量
│   │
│   ├── inject_memory_context.py       ◀── 记忆注入 (468行) ★ 核心
│   │   ├── load_memory_files()        加载所有记忆文件
│   │   ├── ttl_cleanup()              过期清理 (project=60d, reference=90d)
│   │   ├── sync_embeddings()          增量同步向量索引
│   │   ├── build_query()              构造查询 (项目名+git log)
│   │   ├── bm25_recall()              BM25 检索 (无 Ollama 时降级)
│   │   ├── format_injected_memory()   格式化记忆内容
│   │   ├── prune_to_lines()           裁剪到160行
│   │   └── write_injected_rules()     写入 injected-memory.md
│   │
│   └── raw/                           (自动生成) 提取的知识记忆
│
├── homunculus/instincts/
│   ├── team/                          ✅ 团队共享规则 (Git 追踪)
│   │   ├── TEAM.md                        目录说明
│   │   └── common-pitfalls.md             通用踩坑经验
│   └── personal/                      🔒 个人规则 (gitignore, 自动生成)
│
├── data/
│   ├── observations/                  🔒 运行时观测数据
│   │   ├── observations.jsonl             JSONL 观测流
│   │   ├── .current_session              当前会话 ID
│   │   └── observations-YYYY-MM.jsonl    按月归档
│   └── qdrant/                        🔒 向量数据库 (自动生成)
│
├── rules/
│   ├── auto-evolved.md                🔒 (自动生成) 聚合规则
│   └── injected-memory.md             🔒 (自动生成) 注入记忆
│
└── settings.local.json                Hook 配置 (4个Hook)
```

---

## 关键代码解读

### 1. 观测记录：observe.py

每次工具调用都会通过 Hook 触发，记录一条结构化观测：

```python
# 写入的 JSONL 记录结构
{
    "session_id": "20260612-143000",   # 会话 ID (30分钟过期自动刷新)
    "ts": "2026-06-12T14:30:00+08:00", # ISO 时间戳
    "phase": "pre" | "post",           # 调用前 / 调用后
    "tool": "Bash" | "Edit" | "Read" | "Grep" | ...,
    "input": { "file_path": "src/main.py", ... },  # 工具参数
    "bash_desc": "install dependencies"              # Bash 命令描述 (仅 Bash)
}
```

**路径归一化：** `normalize_paths()` 递归遍历所有参数，将绝对路径转为相对路径，确保不同机器上生成的观测具有可比性。

**会话管理：** `get_session_id()` 基于 `.current_session` 文件，30 分钟无活动自动创建新会话 ID。

### 2. 双路径分析引擎：auto-analyze-instincts.py

这是系统的核心，两条互补的分析路径：

```text
                        观测数据 (observations.jsonl)
                               │
                    ┌──────────┴──────────┐
                    ↓                     ↓
             ┌─────────────┐      ┌──────────────┐
             │  路径 A      │      │  路径 B       │
             │  统计检测    │      │  AI 语义分析  │
             │  (确定性)    │      │  (开放性)     │
             └──────┬──────┘      └──────┬───────┘
                    │                     │
                    ↓                     ↓
             5个硬编码模式          Claude Haiku 分析
             · bash_dominant       提取任意行为模式
             · edit_then_bash      返回 JSON 数组
             · read_before_edit
             · search_first        模型: claude-haiku-4-5-20251001
             · project_context     超时: 60s
                    │                     │
                    └──────────┬──────────┘
                               ↓
                     写入 personal/*.md
                     (YAML frontmatter + Markdown body)
```

**置信度演化逻辑：**

```python
# 新发现的 Instinct
confidence = 0.5

# 重复出现时递增 (每次 +0.05, 上限 0.9)
confidence = min(0.9, confidence + 0.05)

# 每日衰减 (未触发时 -0.05, 低于 0.55 标记 deprecated, 下限 0.1)
confidence = max(0.1, confidence - 0.05)
```

### 3. 进化聚合：auto-evolve.py

将高置信度的个人 Instinct 聚合为 Claude Code 自动加载的规则：

```text
personal/*.md                    auto-evolved.md
  (全部加载)                      (覆盖重写)
       │
       ↓ 过滤 confidence >= 0.7
       │
       ↓ Jaccard 去重 (Union-Find, 阈值 0.5)
       │   tokenize() → 英文技术关键词 (>=3字符, 去停用词)
       │   jaccard(A, B) = |A∩B| / |A∪B|
       │   相似度 > 0.5 的 Instinct 归为同一组
       │   每组只保留 confidence 最高的
       │
       ↓ 按 domain 聚合
       │   workflow / coding / debugging / ...
       │   每个域至少 2 条 Instinct 才输出
       │
       ↓ 生成 Markdown
         └── 写入 rules/auto-evolved.md (Claude Code 自动加载)
```

### 4. 知识提取：extract_memory.py

从观测数据中提取事实性知识（与 Instinct 行为规则互补）：

```text
observations.jsonl
       │
       ├── 统计提取: extract_project_context()
       │   └── 识别访问 >= 5次的目录 → 生成项目上下文记忆
       │
       └── AI 提取: run_extraction()
           ├── Prompt 要求提取:
           │   · Bug 解决方案
           │   · 技术决策及原因
           │   · 项目结构理解
           │   · 工作流知识
           └── 输出 → memory/raw/*.md (YAML frontmatter + Markdown body)
```

提取的知识类型：`project`（项目相关）或 `reference`（参考信息）。

### 5. 记忆注入：inject_memory_context.py

会话启动时的完整注入流水线：

```text
┌── Step 1: 加载 ──────────────────────────────────────────────┐
│  memory/*.md + memory/raw/*.md → 全部记忆文件 (含 frontmatter) │
└──────────────────────────────────────────────────────────────┘
        ↓
┌── Step 2: TTL 清理 ──────────────────────────────────────────┐
│  user: 永不过期  |  feedback: 永不过期                        │
│  project: 60天   |  reference: 90天  |  默认: 90天            │
│  过期文件自动删除                                              │
└──────────────────────────────────────────────────────────────┘
        ↓
┌── Step 3: 向量同步 ──────────────────────────────────────────┐
│  sync_embeddings()                                            │
│  ├── Ollama 可用: embed_text() → MemoryVectorStore.upsert()  │
│  │   向量维度: 768 (nomic-embed-text)                         │
│  │   嵌入内容: name + description + body[:200]               │
│  └── Ollama 不可用: 跳过 (后续走 BM25 降级)                   │
└──────────────────────────────────────────────────────────────┘
        ↓
┌── Step 4: 检索 ──────────────────────────────────────────────┐
│  build_query() → 项目名 + 最近3条 git commit                  │
│  ├── 向量检索: store.recall_memories(query, top_k=5)         │
│  │   余弦相似度排序                                           │
│  └── BM25 降级: bm25_recall(query, top_k=5)                  │
│      k1=1.5, b=0.75, 支持中英文混合                           │
└──────────────────────────────────────────────────────────────┘
        ↓
┌── Step 5: 合并格式化 ────────────────────────────────────────┐
│  向量召回的记忆 (带分数) + 全部记忆 (无分数)                    │
│  → format_injected_memory()                                  │
│  → 按 type 排序: user > feedback > project > reference       │
│  → prune_to_lines(max_lines=160) 优先裁剪 reference          │
└──────────────────────────────────────────────────────────────┘
        ↓
┌── Step 6: 写入 ──────────────────────────────────────────────┐
│  .claude/rules/injected-memory.md                            │
│  (Claude Code 自动加载 rules/*.md → 注入到下次会话上下文)       │
└──────────────────────────────────────────────────────────────┘
```

### 6. 向量存储：vector_store.py

双后端设计，Qdrant 不可用时自动降级：

```python
class MemoryVectorStore:
    """
    优先: Qdrant 本地文件模式 (.claude/data/qdrant/)
    降级: NumPy + JSON 索引 (.claude/data/qdrant/vector_index.json)

    集合名: "memories"
    向量维度: 768 (nomic-embed-text)
    距离度量: COSINE
    """

    def upsert_memory(name, vector, memory_type, file_path, description)
        # 基于 name 的 MD5 哈希生成确定性 ID

    def recall_memories(query_vector, top_k=5, memory_type=None)
        # Qdrant: 原生向量搜索
        # NumPy: 暴力余弦相似度计算
```

---

## 调用关系图

```text
┌─────────────────────────────────────────────────────────────────────┐
│                        Claude Code Hook 系统                        │
├─────────────┬────────────────┬──────────────┬──────────────────────┤
│ PreToolUse  │  PostToolUse   │ SessionStart │       Stop           │
│  (Bash)     │    (.*)        │              │                      │
└──────┬──────┴───────┬────────┴──────┬───────┴──────────┬───────────┘
       │              │               │                  │
       ↓              ↓               │                  ↓
  ┌────────────────────────┐          │    ┌──────────────────────────┐
  │    observe.sh          │          │    │  Stop Hook 串联执行:     │
  │  ├── observe.py ───────┼──→ JSONL │    │                          │
  │  └── rotate.py         │          │    │  ① auto-analyze-instincts│
  └────────────────────────┘          │    │     reads → JSONL        │
                                      │    │     writes → personal/   │
                                      │    │     calls → Claude Haiku │
                                      │    │                          │
                                      │    │  ② auto-evolve           │
                                      │    │     reads → personal/    │
                                      │    │     writes → auto-evolved│
                                      │    │                          │
                                      │    │  ③ extract_memory        │
                                      │    │     reads → JSONL        │
                                      │    │     writes → memory/raw/ │
                                      │    │     calls → Claude Haiku │
                                      │    └────────────┬─────────────┘
                                      │                 │
                                      ↓                 │
                              ┌───────────────────┐     │
                              │ inject_memory_    │     │
                              │ context.py        │     │
                              │                   │     │
                              │ reads ← memory/   │ ◀───┘
                              │ reads ← raw/      │ ◀───┘ (③的产出)
                              │ reads ← qdrant/   │
                              │                   │
                              │ imports embed.py ──┼──→ Ollama API
                              │ imports vector_   │
                              │   store.py ───────┼──→ Qdrant / NumPy
                              │                   │
                              │ writes → injected │
                              │   -memory.md      │
                              └───────────────────┘
```

---

## 数据流详解

```text
1.  用户对话中触发工具调用 (如 Edit 文件)                     ↓
2.  PreToolUse Hook → observe.sh → observe.py → JSONL        ↓
3.  工具执行                                                 ↓
4.  PostToolUse Hook → observe.sh → observe.py → JSONL       ↓
5.  会话结束，Stop Hook 触发                                  ↓
6.  auto-analyze-instincts.py (左分支: 行为模式)
    ├── 路径 A: 统计模式检测 (5 种硬编码模式)
    └── 路径 B: Claude Haiku AI 语义分析                      ↓
7.  写入/更新 personal/*.md (Instinct 规则)                   ↓
8.  auto-evolve.py (聚合器)
    ├── 过滤 confidence >= 0.7
    ├── Jaccard 语义去重 (Union-Find, 阈值 0.5)
    ├── 按 domain 聚合 (每域至少2条)
    └── 写入 rules/auto-evolved.md                           ↓
9.  extract_memory.py (右分支: 知识提取, 与 6-8 并行)
    ├── 统计提取: 高频目录 → 项目上下文
    ├── AI 提取: Claude Haiku → bug方案/技术决策
    └── 写入 memory/raw/*.md                                 ↓
10. 下次会话启动时
    ├── Claude Code 自动加载 rules/*.md
    └── SessionStart Hook → inject_memory_context.py
        ├── 加载 memory/*.md + memory/raw/*.md
        ├── TTL 清理过期记忆
        ├── 向量同步 (Ollama → Qdrant) / BM25 降级
        ├── 检索 Top-5 相关记忆
        └── 写入 injected-memory.md (≤160行)
```

---

## 快速开始

### 0. 准备工作（需手动完成）

代码和配置已经全部就绪，但以下两项需要你手动安装：

#### ① 安装 Ollama（向量嵌入引擎）

Ollama 是本地运行的 AI 推理引擎，用于将文本转换为向量以支持语义检索。所有数据仅在本地处理，不上传云端。

**Windows 安装步骤：**

1. 打开浏览器访问 <https://ollama.com/download>
2. 点击 **Download for Windows** 下载安装包
3. 双击运行安装程序，按提示完成安装
4. 安装完成后，**打开一个新的终端**，运行以下命令拉取嵌入模型：

```bash
ollama pull nomic-embed-text
```

5. 验证安装成功：

```bash
# 检查 Ollama 是否运行
ollama list
# 应该能看到 nomic-embed-text 在列表中
```

> **注意：** Ollama 安装后会作为后台服务自动运行（默认端口 11434）。如果重启电脑后 Ollama 未自动启动，手动运行 `ollama serve` 即可。

#### ② 安装 Python 依赖包

```bash
pip install qdrant-client numpy requests pyyaml
```

#### ③ 验证环境就绪

```bash
# 验证 Ollama + 嵌入模型
python3 -c "from .claude.memory.embed import check_ollama_available; print('Ollama OK' if check_ollama_available() else 'Ollama NOT ready')"

# 验证 Python 依赖
python3 -c "import qdrant_client, numpy; print('Dependencies OK')"
```

全部显示 OK 后，**重启 Claude Code 会话**即可激活完整系统。

> **降级说明：** 即使 Ollama 未安装，系统的观测层和提炼层仍可正常工作。仅记忆的向量语义检索会降级为 BM25 全文检索模式。

### 1. Hooks 配置（已注册）

在 `.claude/settings.local.json` 中配置了 4 个 Hook：

| Hook | 触发时机 | 作用 |
|------|---------|------|
| `PreToolUse(Bash)` | Bash 命令执行前 | 记录执行意图 |
| `PostToolUse(.*)` | 所有工具调用后 | 记录工具调用详情 |
| `SessionStart` | 会话启动时 | 向量检索 Top-5 记忆注入 |
| `Stop` | 会话结束时 | 分析观测 → 提炼 Instinct → 聚合规则 → 生成团队提炼候选 |

---

## 添加自定义记忆

在 `.claude/memory/` 下创建 Markdown 文件：

```markdown
---
name: my-preference
description: 我的代码风格偏好
metadata:
  type: feedback
  created: "2026-06-12"
---

改完代码后不要自动 commit，等确认后再提交。
**Why:** 自动提交会打断验证节奏
**How to apply:** 完成修改后明确告知用户，等待确认
```

记忆类型：`user` | `feedback` | `project` | `reference`

---

## 置信度演化

| 事件 | 变化 |
|------|------|
| 首次发现 | confidence = 0.5 |
| 重复验证 | confidence += 0.05 (上限 0.9) |
| 长期未触发 | confidence -= 0.05 (低于 0.55 标记 deprecated, 下限 0.1) |

---

## 防膨胀机制

- **Observations**: 超 5MB/8000行 按月归档，保留 30 天
- **Instinct**: 低置信度自动 deprecated
- **auto-evolved.md**: 每次会话结束覆盖重写
- **Jaccard 去重**: 语义相似的 Instinct 自动合并 (阈值 0.5)
- **TTL 清理**: project 类型 60 天过期, reference 类型 90 天过期
- **行数裁剪**: injected-memory.md 不超过 160 行，优先裁剪 reference 类型

---

## 团队协作：共享踩坑经验

### 设计思路

```text
个人使用积累              自动提炼 + 人工把关                团队共享
┌───────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│ personal/*.md │     │ promote-to-team.py   │     │ team/*.md       │
│ (gitignore)   │ ──▶ │  自动: 筛选≥0.7+去重  │ ──▶ │ (Git 追踪)      │
│ 自动生成      │     │  自动: 与 team/ 比对  │     │ PR 评审入库     │
└───────────────┘     │ adopt-instinct.py    │     └─────────────────┘
   promote-candidates │  自动: 生成 team 草稿 │
   .md (gitignore)    │  人工: 价值/隐私/合并 │ ← 仅候选+草稿；入库前由人工把关
                      └──────────────────────┘
```

**核心原则：** 个人原始数据留在本地，只把高价值、通用的经验推到 Git 共享。

### 版本管理策略

| 路径 | Git 状态 | 说明 |
|------|---------|------|
| `instincts/team/*.md` | ✅ **追踪** | 团队共享规则，通过 PR 评审后入库 |
| `instincts/personal/*.md` | 🔒 **gitignore** | 个人自动生成的规则，仅本地 |
| `instincts/promote-candidates.md` | 🔒 **gitignore** | 自动生成的提炼候选清单，每次会话覆盖 |
| `rules/auto-evolved.md` | 🔒 **gitignore** | 每次会话结束自动覆盖，不追踪 |
| `data/` | 🔒 **gitignore** | 运行时数据（观测日志、向量库） |

### 如何提炼团队经验

#### ✅ 推荐：自动候选清单 + 一键采纳

系统自动从 `personal/` 筛选高置信度（≥0.7）、经多次验证（≥3 次）的规则，生成团队提炼候选清单。这是推荐主路径——把「扫描全部个人规则 + 改写格式」的体力活自动化，只把「通用价值判断 + 隐私把关 + 去重合并」留给人工。

```bash
# 1. 查看候选清单（Stop hook 每次会话结束自动刷新，也可手动触发）
python3 .claude/bin/promote-to-team.py .claude
cat .claude/homunculus/instincts/promote-candidates.md

# 2. 候选清单分两类：
#    🆕 新候选 —— 团队库中尚无相似规则，每条附可直接采纳的 team 草稿
#    ⚠️ 可能重复 —— 与 team/ 已有规则相似，建议先检查能否合并

# 3. 看中某条后，一键采纳（自动去个性化、改写为 team 格式）
python3 .claude/bin/adopt-instinct.py .claude <id>
#    例: python3 .claude/bin/adopt-instinct.py .claude secrets-before-commit

# 4. 编辑生成的 team/<id>.md 补充 Why / Example，然后提交 PR
git add .claude/homunculus/instincts/team/
git commit -m "docs(team): promote <id> from personal"
```

**闭环自洽：** 采纳后重新运行 `promote-to-team.py`，该规则会从候选清单消失（已被识别为团队库中的相似项）。

**可调阈值**（候选偏多/偏少时）：

```bash
python3 .claude/bin/promote-to-team.py .claude --confidence 0.8 --min-observed 5
```

> **设计取舍：** 自动化只产出**候选**和**草稿**，绝不自动改 Git 追踪的 `team/`——通用价值判断、隐私过滤、去重合并这三个人工才能稳妥完成的判断仍由人工把关。下面的手动方式适用于候选清单未覆盖、或想直接编写团队规则的情况。

#### 方式一：从个人规则迁移（推荐）

当你发现 `personal/` 中某条规则的 confidence 较高（≥0.7）且对其他人也有价值时：

```bash
# 1. 查看个人规则列表
ls .claude/homunculus/instincts/personal/

# 2. 阅读具体规则
cat .claude/homunculus/instincts/personal/some-pattern.md

# 3. 确认这条经验有通用价值后，提炼到团队目录
# （不要直接复制，要改写成通用表述）
```

提炼时需要注意：

- **去个性化：** 删除个人会话的具体数据（如「在 75 次调用中…」），只保留规则本身
- **通用表述：** 把「我发现…」改为「建议…」，让其他成员也能理解
- **合并去重：** 检查 `team/` 中是否已有类似规则，有则合并而非新增
- **补充上下文：** 加上 Why（为什么要这样做）和 Example（具体示例）

#### 方式二：直接编写团队规则

遇到通用踩坑经验，可以直接在 `team/` 目录下创建：

```markdown
---
id: 简短英文标识
trigger: "触发条件描述"
confidence: 0.80
domain: workflow | coding | debugging | testing
source: team-consensus
created_at: "2026-06-12"
author: your-name
---

## 规则标题

### 为什么（Why）
解释为什么需要这条规则，踩过什么坑。

### 怎么做（Action）
具体应该怎么做。

### 示例（Example）
给出一个具体的场景和正确做法。

### 反例（Anti-pattern）
列出常见错误做法。
```

#### 方式三：通过 PR 讨论

对于重大规则变更或有争议的经验：

1. 在本地 `team/` 目录添加新规则
2. 创建分支并提交 PR
3. 团队成员在 PR 中讨论补充
4. 达成共识后合并

### 团队规则示例

参考 `team/common-pitfalls.md`，这是一个已入库的团队规则模板：

```markdown
---
id: common-pitfalls
trigger: "通用踩坑经验，适用于所有成员"
confidence: 0.80
domain: workflow
source: team-consensus
---

## 团队踩坑经验

### 1. 使用 CLI 工具前先检查
在使用 CLI 工具前，先用 `which <tool>` 检查是否已安装...

### 2. Edit 文件前先 Read
在 Edit 文件前，先用 Read 工具读取当前内容...
```

---

## 技术选型

| 组件 | 选型 | 原因 |
|------|------|------|
| 向量嵌入 | Ollama nomic-embed-text | 本地运行，保护隐私，~10ms/条，768维 |
| 向量存储 | Qdrant (本地文件模式) | 无需 Docker，文件级持久化，COSINE 距离 |
| 降级方案 | NumPy JSON 索引 | qdrant-client 不可用时自动降级 |
| AI 分析 | Claude CLI (Haiku) | 低成本语义分析，60s 超时 |
| 文本检索 | BM25 (k1=1.5, b=0.75) | Ollama 不可用时的检索降级方案 |



