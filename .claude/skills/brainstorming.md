# Brainstorming Skill

---
title: "Brainstorming & Design Discussion"
version: "3.0"
last_updated: "2026-01-06"
tags: [brainstorming, design, planning, requirements, collaboration]
domains: [all]
level: beginner
estimated_time: "15min"
prerequisites: []
sources:
  - "obra/superpowers"
  - "IDEO Design Thinking"
  - "TAD Framework"
enforcement: recommended
tad_gates: [Gate1_Understanding, Gate2_Design]
---

> 来源: obra/superpowers，已适配 TAD 框架和文档合规标准

## TL;DR Quick Checklist

```
1. [ ] Understand current project state before suggesting
2. [ ] Ask clarifying questions (one at a time)
3. [ ] Propose 2-3 alternative approaches
4. [ ] Evaluate trade-offs for each approach
5. [ ] Document the chosen design with rationale
6. [ ] Apply YAGNI - remove unnecessary features
```

**Red Flags:**
- Jumping to solution without understanding requirements
- Asking too many questions at once
- Recommending complex solutions for simple problems
- Not documenting design decisions
- Adding "just in case" features

---

## 触发条件

当 Claude 需要设计新功能、讨论方案、或帮助用户明确需求时，自动应用此 Skill。

---

## 核心原则

**"在写代码之前，先设计清楚。"**

头脑风暴是将模糊想法转化为详细设计的结构化过程。

---

## 三阶段流程

### Phase 1: 理解想法

```
┌─────────────────────────────────────────┐
│  1. 了解项目当前状态                      │
│  2. 逐个提问澄清需求                      │
│  3. 一次只问一个问题                      │
└─────────────────────────────────────────┘
```

**提问技巧**：
- 优先使用选择题而非开放式问题
- 问题要具体，避免宽泛
- 每次只问一个问题，等待回答

**示例问题**：
```markdown
关于用户认证，你倾向于哪种方案？
A) JWT + 短期 token
B) Session + Cookie
C) OAuth2 第三方登录
D) 其他（请说明）
```

### Phase 2: 探索方案

```
┌─────────────────────────────────────────┐
│  1. 提出 2-3 个不同的解决路径             │
│  2. 分析每个方案的优缺点                  │
│  3. 推荐一个方案并解释原因                │
└─────────────────────────────────────────┘
```

**方案对比模板**：
```markdown
## 方案 A: [名称]
- 优点: ...
- 缺点: ...
- 适用场景: ...

## 方案 B: [名称]
- 优点: ...
- 缺点: ...
- 适用场景: ...

## 推荐: 方案 A
原因: [具体解释为什么推荐这个方案]
```

### Phase 3: 呈现设计

```
┌─────────────────────────────────────────┐
│  1. 分段呈现设计（每段 200-300 字）       │
│  2. 每段后确认理解                        │
│  3. 覆盖所有关键方面                      │
└─────────────────────────────────────────┘
```

**设计文档结构**：
1. **架构概览** - 系统组成和交互
2. **核心组件** - 各模块职责
3. **数据流** - 数据如何流转
4. **错误处理** - 异常情况处理
5. **测试策略** - 如何验证正确性

---

## YAGNI 原则

> **You Aren't Gonna Need It**（你不会需要它的）

在头脑风暴时，主动消除以下"功能"：
- "以后可能会用到"的功能
- "为了扩展性"的抽象
- "万一需要"的配置项

**问自己**：这个功能现在就需要吗？

---

## 设计文档化

确认设计后，保存为文档：

```markdown
文件路径: docs/plans/YYYY-MM-DD-<topic>-design.md

# [功能名称] 设计文档

## 背景
[为什么需要这个功能]

## 目标
[功能要达成什么]

## 设计方案
[详细的技术方案]

## 讨论记录
[头脑风暴中的关键决策]

## 下一步
[实施计划]
```

---

## 与 TAD 框架的集成

头脑风暴是 Alex（方案设计者）的核心工作：

```
用户需求 → Alex 头脑风暴 → 设计文档 → Gate 审核 → Blake 实施
              ↓                    ↓
         [ 此 Skill ]        [证据收集]
```

**TAD 集成点**：
1. 在 `/tad-alex` 启动后使用
2. 结合 MQ（Mandatory Questions）收集信息
3. 设计完成后触发 Gate 审核

### Gate Mapping

```yaml
Gate1_Understanding:
  brainstorming_inputs:
    - User requirements clarified
    - Current state understood
    - Constraints identified
    - Success criteria defined

Gate2_Design:
  brainstorming_outputs:
    - Multiple approaches explored (2-3 minimum)
    - Trade-offs documented
    - Recommended approach selected with rationale
    - Design document created
    - YAGNI review completed
```

### Evidence Template

```markdown
## Brainstorming Evidence - [Feature/Topic Name]

**Date:** [Date]
**Facilitator:** [Name]
**Participants:** [List]

---

### 1. Problem Statement

**Problem:** [Clear description of what we're solving]

**Context:**
- [Background point 1]
- [Background point 2]

**Constraints:**
- [Technical constraint]
- [Business constraint]
- [Time constraint]

---

### 2. Requirements Gathered

| Requirement | Priority | Source | Notes |
|-------------|----------|--------|-------|
| [Req 1] | Must | User | |
| [Req 2] | Should | Stakeholder | |
| [Req 3] | Could | Technical | |

**Clarifying Questions Asked:**
1. Q: [Question] → A: [Answer]
2. Q: [Question] → A: [Answer]

---

### 3. Options Explored

#### Option A: [Name]

| Aspect | Assessment |
|--------|------------|
| Description | [What this approach does] |
| Pros | [List of advantages] |
| Cons | [List of disadvantages] |
| Effort | [Low/Medium/High] |
| Risk | [Low/Medium/High] |

#### Option B: [Name]

| Aspect | Assessment |
|--------|------------|
| Description | [What this approach does] |
| Pros | [List of advantages] |
| Cons | [List of disadvantages] |
| Effort | [Low/Medium/High] |
| Risk | [Low/Medium/High] |

#### Option C: [Name] (if applicable)

[Same structure]

---

### 4. Decision

**Selected Option:** [Option A/B/C]

**Rationale:**
1. [Primary reason for selection]
2. [Secondary reason]
3. [How it addresses constraints]

**Rejected Options Reasoning:**
- Option X rejected because: [reason]
- Option Y rejected because: [reason]

---

### 5. YAGNI Review

Features explicitly excluded (not needed now):
- [ ] [Feature removed] - Reason: [why not needed]
- [ ] [Feature removed] - Reason: [why not needed]

---

### 6. Next Steps

| Action | Owner | Timeline |
|--------|-------|----------|
| [Create design doc] | @name | [Date] |
| [Prototype] | @name | [Date] |
| [Review] | @name | [Date] |

---

**Brainstorming Complete:** ✅ Yes
**Ready for Gate2:** ✅ Yes
```

---

## 常见模式

### ✅ 好的头脑风暴
```
用户: "我想加个搜索功能"

Claude: "好的，让我先了解一下需求。
搜索的数据来源是什么？
A) 本地数据库
B) 第三方 API
C) 全文搜索引擎（如 Elasticsearch）"

用户: "A，本地数据库"

Claude: "了解。搜索结果需要实时更新吗？
A) 需要（用户输入时即时搜索）
B) 不需要（用户点击搜索按钮后搜索）"
```

### ❌ 不好的头脑风暴
```
用户: "我想加个搜索功能"

Claude: "好的！我推荐使用 Elasticsearch 配合 React Instant Search，
这样可以支持模糊搜索、分词、高亮显示、自动补全..."

[问题: 没有先理解需求就推荐复杂方案]
```

---

## 关键心态

> "花在设计上的时间，会在实施中省回来十倍。"

**头脑风暴的价值**：
- 避免返工
- 明确方向
- 建立共识
- 降低风险

---

*此 Skill 确保 Claude 在动手写代码前，先和用户充分讨论和设计。*
