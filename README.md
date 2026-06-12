# 🧬 Claude Code 自我进化与记忆系统

> 基于得物技术文章实现的 Claude Code 持久化记忆与自我学习系统

## 系统架构

```
用户操作 → Hook捕获 → 观测记录 → 模式提炼 → 规则注入 → 下次会话自动加载
     ↓         ↓          ↓          ↓          ↓
  工具调用  observe.sh  JSONL文件  Instinct  auto-evolved.md
                                 Memory    injected-memory.md
```

三层核心子系统：

| 层 | 目录 | 作用 |
|---|---|---|
| 🔍 **行为观测层** | `.claude/hooks/` + `.claude/bin/` | Hook 捕获工具调用 → JSONL 观测流 |
| 🧠 **模式提炼层** | `.claude/bin/` + `.claude/homunculus/` | 统计+AI 双路径分析 → Instinct 规则 |
| 💾 **记忆注入层** | `.claude/memory/` + `.claude/rules/` | 向量检索 Top-K → 自动注入上下文 |

## 快速开始

### 0. 准备工作（需手动完成）

代码和配置已经全部就绪，但以下两项需要你手动安装：

#### ① 安装 Ollama（向量嵌入引擎）

Ollama 是本地运行的 AI 推理引擎，用于将文本转换为向量以支持语义检索。所有数据仅在本地处理，不上传云端。

**Windows 安装步骤：**

1. 打开浏览器访问 https://ollama.com/download
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

> **降级说明：** 即使 Ollama 未安装，系统的观测层和提炼层仍可正常工作。仅记忆的向量语义检索会降级为全量加载模式（无 Top-K 过滤）。

### 1. 目录结构（已自动创建）

```
.claude/
├── hooks/observe.sh                     # Hook 入口脚本
├── bin/
│   ├── observe.py                       # 观测记录写入器
│   ├── observations_rotate.py           # 数据轮转（5MB/8000行自动归档）
│   ├── auto-analyze-instincts.py        # 双路径模式分析
│   └── auto-evolve.py                   # 进化聚合器
├── memory/
│   ├── embed.py                         # Ollama 向量嵌入
│   ├── vector_store.py                  # Qdrant/NumPy 向量存储
│   └── inject_memory_context.py         # 会话启动记忆注入
├── homunculus/instincts/
│   ├── team/                           # 团队共享规则（Git 追踪）✅
│   └── personal/                       # 个人规则（gitignore）🔒
├── data/
│   ├── observations/                    # 观测 JSONL 数据
│   └── qdrant/                          # 向量数据库存储
├── rules/
│   ├── auto-evolved.md                  # 自动生成的进化规则
│   └── injected-memory.md               # 会话启动时注入的记忆
└── settings.local.json                  # Hook 配置
```

### 3. Hooks 配置（已注册）

在 `.claude/settings.local.json` 中配置了 4 个 Hook：

| Hook | 触发时机 | 作用 |
|------|---------|------|
| `PreToolUse(Bash)` | Bash 命令执行前 | 记录执行意图 |
| `PostToolUse(.*)` | 所有工具调用后 | 记录工具调用详情 |
| `SessionStart` | 会话启动时 | 向量检索 Top-5 记忆注入 |
| `Stop` | 会话结束时 | 分析观测 → 提炼 Instinct → 聚合规则 |

## 数据流

```
1. 用户对话中触发工具调用（如 Edit 文件）            ↓
2. PreToolUse Hook → observe.sh → observations.jsonl ↓
3. 工具执行                                         ↓
4. PostToolUse Hook → observe.sh → observations.jsonl↓
5. 会话结束，Stop Hook 触发                          ↓
6. auto-analyze-instincts.py
   ├── 路径 A：统计模式检测（5 种硬编码模式）
   └── 路径 B：Claude API 语义分析
7. 写入/更新 .claude/homunculus/instincts/personal/*.md↓
8. auto-evolve.py
   ├── 过滤 confidence >= 0.7
   ├── Jaccard 语义去重（Union-Find）
   ├── 按 domain 聚合
   └── 写入 rules/auto-evolved.md
9. 下次会话启动时
   ├── Claude Code 自动加载 rules/*.md
   └── SessionStart Hook → inject_memory_context.py → 注入项目记忆
```

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

## 置信度演化

| 事件 | 变化 |
|------|------|
| 首次发现 | confidence = 0.5 |
| 重复验证 | confidence += 0.05 (上限 0.9) |
| 长期未触发 | confidence -= 0.05 (低于 0.55 标记 deprecated) |

## 防膨胀机制

- **Observations**: 超 5MB/8000行 按月归档，保留 30 天
- **Instinct**: 低置信度自动 deprecated
- **auto-evolved.md**: 每次会话结束覆盖重写
- **Jaccard 去重**: 语义相似的 Instinct 自动合并

## 技术选型

| 组件 | 选型 | 原因 |
|------|------|------|
| 向量嵌入 | Ollama nomic-embed-text | 本地运行，保护隐私，~10ms/条 |
| 向量存储 | Qdrant (本地模式) | 无需 Docker，文件级持久化 |
| 降级方案 | NumPy JSON 索引 | qdrant-client 不可用时自动降级 |
| AI 分析 | Claude CLI (Haiku) | 低成本语义分析 |
