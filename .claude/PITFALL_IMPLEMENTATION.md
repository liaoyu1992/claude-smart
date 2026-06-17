# 业务防坑能力实现总结

## 实现日期
2025-01-17

## 实现内容

### 1. extract_memory.py - AI 提取 prompt 增强

**改动**: 在 `build_extraction_prompt()` 中添加了第 5 类知识提取：

```python
5. **Pitfalls / Anti-patterns**: approaches that FAILED and why
```

**新增类型**: `pitfall` 加入允许的类型列表：
```python
"type": one of ["project", "reference", "pitfall"]
```

**Pitfall 结构**:
```markdown
- **触发条件**: what scenario triggers this pitfall
- **错误现象**: what goes wrong (error message, symptom)
- **为什么**: root cause explanation
- **正确做法**: what to do instead
```

**兼容性**: ✅ 保留原有的 4 类提取（bug solutions、技术决策、项目上下文、工作流知识）

---

### 2. inject_memory_context.py - 注入系统配置

**改动点**:

1. **类型优先级** - pitfall 插入第 3 位（在 feedback 之后，project 之前）:
   ```python
   type_order = ["user", "feedback", "pitfall", "project", "reference"]
   ```

2. **TTL 配置** - pitfalls 永久保留:
   ```python
   "pitfall": None,  # 永久 (pitfalls are long-term knowledge)
   ```

3. **显示标签**:
   ```python
   "pitfall": "⚠️ 业务防坑"
   ```

4. **注入槽位** - 最多注入 3 条 pitfall:
   ```python
   kept.extend(buckets["pitfall"][:3])
   ```

5. **裁剪优先级** - 在 project 之前裁剪（优先级高于 project/reference）

**兼容性**: ✅ 旧记忆不受影响，新类型能正常工作

---

### 3. observe.py - 失败信号捕获

**新增字段**:

```python
exit_code = data.get("exit_code", data.get("result", {}).get("exit_code"))
error_output = data.get("error", data.get("stderr", data.get("result", {}).get("stderr")))
```

**特性**:
- 字段可选（如果 hook 数据没有，就是 None）
- error_output 限制 1000 字符避免膨胀
- 路径会被规范化为相对路径

**兼容性**: ✅ 向后兼容（新增字段不影响现有逻辑）

---

### 4. observe.sh - Hook 脚本

**改动**: 无（已经是通用实现，不需要修改）

---

## 向后兼容性保证

| 组件 | 现有能力 | 影响 |
|------|---------|------|
| 统计提取（Path A） | 当前工作目录 | ✅ 不受影响 |
| AI 提取（Path B） | bug/decision/workflow | ✅ 保留，仅新增 pitfall |
| 旧记忆加载 | project/reference | ✅ 正常工作 |
| 注入系统 | user > feedback > project > reference | ✅ 扩展为 user > feedback > pitfall > project > reference |

---

## 使用方式

### 自动提取
会话结束时，`extract_memory.py` 会自动从观察日志中提取 pitfall 类型记忆。

### 手动创建
在 `.claude/memory/raw/` 目录创建 `.md` 文件：

```markdown
---
name: my-pitfall
description: 某个常见的坑
metadata:
  type: pitfall
created: "2025-01-17"
updated: "2025-01-17"
---

## 坑：某个常见错误

**触发条件**: 什么场景会触发

**错误现象**: 出现什么错误

**为什么**: 根本原因

**正确做法**: 应该怎么做
```

### 注入优先级
新会话启动时，pitfall 记忆会按以下优先级注入：
1. user（用户偏好）
2. feedback（行为反馈）
3. **pitfall（业务防坑）** ← 最多 3 条
4. project（项目知识）
5. reference（参考资源）

---

## 后续增强方向

1. **观察数据增强**: 如果 Claude Code 的 hook 系统开始传递工具执行结果，observe.py 已准备好接收

2. **Instinct 集成**: 当一个 pitfall 被触发 3 次，可以自动升级为 instinct（行为模式检查）

3. **UI 改进**: 可以在 pitfall section 加入更明显的警告样式

---

## 验证清单

- [x] extract_memory.py 语法正确
- [x] inject_memory_context.py 语法正确
- [x] observe.py 语法正确
- [x] 所有 pitfall 配置点已添加
- [x] 向后兼容性验证完成
