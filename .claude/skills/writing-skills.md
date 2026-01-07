# Writing Skills Skill (元技能)

---
title: "Writing Skills"
version: "3.0"
last_updated: "2026-01-07"
tags: [writing, style, clarity, editing]
domains: [all]
level: beginner-intermediate
estimated_time: "20min"
prerequisites: []
sources:
  - "Google Writing Style Guide"
  - "The Elements of Style"
enforcement: recommended
tad_gates: []
---

> 来源: obra/superpowers，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 先目的与受众；后结构与措辞
2. [ ] 短句主动语态；并行结构；术语一致
3. [ ] 列表/表格呈现复杂信息；示例优先
4. [ ] 提交前自检清单；同伴审校
5. [ ] 产出：风格清单/前后对比/参考集合
```

**Red Flags:** 空话、长句、被动语态、术语混乱、无示例

## 触发条件

当用户需要创建新的 Claude Skill 时，自动应用此 Skill。

---

## 核心原则

**"没有失败测试，就不要写 Skill。"**

这是将 TDD 应用于文档的方法——先观察问题，再编写解决方案。

---

## 铁律

```
┌─────────────────────────────────────────┐
│   NO SKILL WITHOUT A FAILING TEST FIRST │
└─────────────────────────────────────────┘
```

你必须先观察 Agent 在没有 Skill 时的失败行为，才能编写 Skill。这确保 Skill 解决的是真实问题，而非假设的问题。

---

## 何时创建 Skill

### ✅ 应该创建

```
技术、模式或工具相关的可复用参考指南：
□ 对你来说不是直觉就能做对的
□ 适用于多个项目
□ 其他人也会受益
```

### ❌ 不应该创建

```
□ 一次性的解决方案
□ 其他地方已有完善文档的标准实践
□ 过于项目特定的内容
```

---

## TDD 创建流程

### 1. RED 阶段（发现问题）

```
在没有 Skill 的情况下运行压力场景：

场景设计:
□ 时间压力（"快点做"）
□ 社交压力（"用户会失望"）
□ 范围压力（"还有很多事"）

记录基线行为:
- Agent 做了什么？
- 哪里出了问题？
- 什么导致了失败？
```

**记录模板**：
```markdown
## 基线测试 - [场景名]

### 输入
[给 Agent 的指令]

### 期望行为
[应该做什么]

### 实际行为
[Agent 做了什么]

### 失败原因
[为什么失败]
```

### 2. GREEN 阶段（编写 Skill）

```
编写解决这些特定失败的最小 Skill：

原则:
□ 只解决观察到的问题
□ 不添加假设的功能
□ 保持简洁
```

### 3. REFACTOR 阶段（堵住漏洞）

```
识别 Agent 可能的借口并明确禁止：

常见借口:
□ "太简单了，不需要"
□ "这次特殊"
□ "之后再补"
□ "显而易见"

在 Skill 中明确禁止这些借口
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type     | Description             | Location                                  |
|-------------------|-------------------------|-------------------------------------------|
| `style_checklist` | 文风与结构检查清单     | `.tad/evidence/writing/checklist.md`      |
| `before_after`    | 修改前后对比样例       | `.tad/evidence/writing/before-after.md`   |
| `references`      | 参考与术语表           | `.tad/evidence/writing/refs.md`           |

### Acceptance Criteria

```
[ ] 目标与受众明确；结构清晰
[ ] 文风简洁一致；示例充分
[ ] 参考/术语表完善
```

### Artifacts

| Artifact         | Path                                     |
|------------------|------------------------------------------|
| Style Checklist  | `.tad/evidence/writing/checklist.md`     |
| Before/After     | `.tad/evidence/writing/before-after.md`  |
| References       | `.tad/evidence/writing/refs.md`          |

## Skill 结构

### 必需的元数据

```yaml
---
name: skill-name
description: 简洁描述触发条件（不要总结工作流）
---
```

### CSO 规则

```
CSO = "Claude Should Only"

描述应该只说明触发条件：
✅ "当 Claude 需要处理用户认证时"
❌ "处理用户认证，包括登录、注册、密码重置..."

原因: 防止 Claude 看描述就觉得"知道了"而不读完整内容
```

### 推荐结构

```markdown
# Skill 名称

## 触发条件
[何时使用这个 Skill]

## 核心原则
[一句话总结]

## 详细流程
[步骤说明]

## 示例
[好的和坏的例子]

## 常见错误
[要避免的问题]

## 与 TAD 框架的集成
[如何配合 TAD 使用]
```

---

## Skill 类型及测试方法

### 纪律执行型

```
目的: 强制某种行为模式
测试: 在压力组合下测试合规性

示例: TDD Skill, Verification Skill
测试场景: 截止日期 + 简单任务 + 疲劳
```

### 技术技能型

```
目的: 教授特定技术
测试: 在新场景中测试应用能力

示例: Git Worktree Skill, API Design Skill
测试场景: 给一个新的、相关的任务
```

### 模式识别型

```
目的: 识别并应用设计模式
测试: 测试模式识别和正确应用

示例: Architecture Skill
测试场景: 给一个需要识别模式的问题
```

### 参考查询型

```
目的: 提供可查询的知识库
测试: 测试检索和正确使用

示例: Security Checklist Skill
测试场景: 需要查找特定信息的任务
```

---

## 测试 Skill

### 测试清单

```
□ 没有 Skill 时确实会失败？
□ 有 Skill 后行为正确？
□ 压力下仍然有效？
□ 没有意外副作用？
```

### 压力测试场景

```markdown
## 压力测试模板

### 场景: [描述]

### 压力因素
- 时间: [紧迫/充裕]
- 复杂度: [高/低]
- 干扰: [多/少]

### 期望行为
[应该发生什么]

### 实际结果
[发生了什么]
```

---

## 常见错误

### ❌ 没有失败测试就写 Skill

```
问题: 可能解决不存在的问题
解决: 先观察失败行为
```

### ❌ 描述中总结工作流

```
问题: Claude 可能不读完整内容
解决: 描述只写触发条件
```

### ❌ 过于泛化

```
问题: 变得不实用
解决: 专注于具体问题
```

### ❌ 缺少反面例子

```
问题: 不知道什么是错的
解决: 添加 ❌ 示例
```

---

## 与 TAD 框架的集成

在 TAD 中创建新 Skill：

```
观察问题 → TDD 测试 → 编写 Skill → 验证效果
              ↓
         [ 此 Skill ]
```

**文件位置**: `.claude/skills/your-skill.md`

**TAD 自动发现**: 符合格式的 Skill 会自动被 TAD 的 Skills System 发现和加载。

---

## Skill 模板

```markdown
# [Skill 名称]

> 来源: [原始来源]，已适配 TAD 框架

## 触发条件

当 Claude [触发条件] 时，自动应用此 Skill。

---

## 核心原则

**"[一句话总结]"**

---

## [主要内容]

### [章节1]

[内容]

### [章节2]

[内容]

---

## 与 TAD 框架的集成

[如何与 TAD 配合使用]

---

*此 Skill [简要说明作用]。*
```

---

## 关键心态

> "未经测试的 Skill 总是有漏洞的。先测试，再部署。"

**创建 Skill 的价值**：
- 固化最佳实践
- 减少重复错误
- 提高一致性
- 加速 Agent 学习

---

*此 Skill 指导如何用 TDD 方法创建新的 Skill。*
