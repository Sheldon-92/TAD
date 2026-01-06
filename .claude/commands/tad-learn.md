# /tad-learn Command (Framework Learning Recorder)

> TAD v1.4 - 框架级建议记录系统

## 功能说明

`/tad-learn` 用于记录框架级的改进建议，帮助 TAD 持续进化。

**注意**：此命令只记录 **框架级** 内容，不记录项目级内容。

---

## 执行流程

当此命令被调用时，执行以下流程：

### Step 1: 确认记录类型

首先确认这是框架级建议：

```yaml
框架级内容（应该记录）:
  - 开发流程改进建议
  - Agent (Alex/Blake) 配合问题/优化
  - 方法论发现
  - 有用的工具/项目/库（如 Semantic Router）
  - 新的检查点建议（新的 MQ）
  - Skills 改进建议

项目级内容（不应记录，由 Alex 自行处理）:
  - 项目特定的配置/决策
  - 项目的业务逻辑
  - 项目的代码实现
  - 项目特定的技术选型原因
```

如果是项目级内容，提示用户：
> "这看起来是项目级内容，建议通过 Alex 的 handover 或项目文档记录，而非 /tad-learn。"

### Step 2: 收集信息

收集以下信息：

1. **类别** (Category)
   - `workflow`: 开发流程改进
   - `agent-collaboration`: Agent 配合优化
   - `methodology`: 方法论发现
   - `tool-discovery`: 工具/项目/库发现
   - `checkpoint`: 检查点建议
   - `skill`: Skill 改进

2. **发现内容** (Discovery)
   - 具体发现了什么
   - 为什么这个发现有价值

3. **建议** (Suggestion)
   - 建议如何改进 TAD
   - 具体的实施方向

4. **来源** (Source)
   - 来源 URL（如果有）
   - 发现的上下文

### Step 3: 生成记录文件

创建 Learning Entry 文件：

```markdown
## Learning Entry

- **Date**: {YYYY-MM-DD HH:mm}
- **Agent**: {Alex | Blake}
- **Category**: {category}
- **Status**: pending

### 发现

{discovery_description}

### 建议

{suggestion_description}

### 来源

{source_url_or_context}

### 相关文件

{optional_related_files}

---

> 此记录由 /tad-learn 命令生成
> 待 Human 确认后推送到 TAD 仓库
```

保存到：`.tad/learnings/pending/{YYYY-MM-DD}-{short-description}.md`

### Step 4: 请求确认

向 Human 展示记录内容，提供选项：

```
📝 Learning Entry 已创建

内容预览:
{preview}

请选择:
1. ✅ 确认并推送到 TAD 仓库
2. 📝 修改后再推送
3. 💾 仅保存本地（不推送）
4. ❌ 取消记录
```

### Step 5: 执行操作

根据 Human 选择：

**选项 1 - 确认推送**:
1. 将文件从 `pending/` 移动到 `pushed/`
2. 复制到 TAD 仓库的 `.tad/learnings/suggestions/`
3. 提示：可以通过 `git push` 推送到远程

**选项 2 - 修改后推送**:
1. 等待 Human 提供修改
2. 更新文件内容
3. 重复 Step 4

**选项 3 - 仅保存本地**:
1. 保留在 `pending/` 目录
2. 提示：可以稍后再决定是否推送

**选项 4 - 取消**:
1. 删除创建的文件

---

## 使用示例

### 示例 1: 发现有用的工具

```
User: /tad-learn

Alex: 好的，让我记录这个框架级建议。

请描述你的发现：

User: 我发现了一个叫 Semantic Router 的项目，可以用来做意图识别和路由

Alex: 收到。让我创建 Learning Entry...

📝 Learning Entry 已创建

- Category: tool-discovery
- Discovery: Semantic Router - 用于意图识别和语义路由的开源项目
- Suggestion: 可以考虑在 Alex 的需求分析中使用，提高意图理解准确性
- Source: GitHub - aurelio-labs/semantic-router

请选择:
1. ✅ 确认并推送到 TAD 仓库
...
```

### 示例 2: Agent 配合问题

```
User: /tad-learn

Alex: 好的，让我记录这个框架级建议。

User: Blake 在实现时经常会忽略我在 handover 中的注意事项

Alex: 这是一个 Agent 配合问题。让我记录...

📝 Learning Entry 已创建

- Category: agent-collaboration
- Discovery: Blake 实现时可能忽略 handover 中的注意事项
- Suggestion:
  1. 在 Blake 的描述中增加强制检查 handover 注意事项的步骤
  2. 或在 handover 模板中增加"必须确认的事项"章节
- Source: 项目实践中发现
...
```

---

## 后续处理

推送到 TAD 仓库的建议会存放在 `.tad/learnings/suggestions/` 目录。

**处理时机**: TAD 版本升级时

**处理方式**: 由维护者审阅后决定：
- 更新 Alex/Blake 的描述文件
- 创建新的 Skill
- 更新 config.yaml 配置
- 添加新的 MQ 问题
- 其他改进方式

---

## 相关命令

- `/tad-status`: 查看 TAD 状态，包括待处理的 learnings
- `/alex`: Alex 的日常工作中可以调用 /tad-learn
- `/blake`: Blake 的日常工作中可以调用 /tad-learn

---

[[LLM: 当调用 /tad-learn 时，按照上述流程执行。首先确认是框架级内容，然后收集信息、生成记录、请求确认、执行操作。]]
