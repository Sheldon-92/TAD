# Skill Creator - 元技能

---
title: "Skill Creator"
version: "3.0"
last_updated: "2026-01-07"
tags: [skills, documentation, templates, knowledge]
domains: [all]
level: beginner-intermediate
estimated_time: "20min"
prerequisites: []
sources:
  - "TAD Framework"
  - "obra/superpowers"
enforcement: recommended
tad_gates: [Gate2_Design, Gate4_Review]
---

> TAD v1.4 内置 Skill - 如何创建新的 Skill

## TL;DR Quick Checklist

```
1. [ ] 先有失败场景或真实需求，再写 Skill（反模式避免）
2. [ ] 使用统一 frontmatter 与章节结构（TL;DR/Outputs/Evidence）
3. [ ] 提供可操作的清单、示例与红旗（误用提示）
4. [ ] 定义 Required Evidence 与 Artifacts（可被 Gate 审查）
5. [ ] 维护 tags/domains/related skills，便于检索与联动
```

**Red Flags:** 没有真实问题驱动、过度理论、无证据/产物映射、与现有技能重复

## 概述

本 Skill 指导如何创建新的 Claude Code Skill，将知识封装为可复用的参考资料。

---

## 1. 什么是 Skill？

### 1.1 定义

Skill 是存放在 `.claude/skills/` 目录下的 Markdown 文件，包含特定领域的知识、最佳实践和参考资料。

### 1.2 与其他概念的区别

| 概念 | 作用 | 类比 |
|------|------|------|
| TAD Agents (Alex/Blake) | 主角色/人格 | 团队成员 |
| Claude Subagents | 专家代理 | 临时顾问 |
| **Skills** | 知识库 | 教科书/手册 |

### 1.3 特点

- **自动发现**：Claude Code 自动加载 `.claude/skills/*.md`
- **被动使用**：作为参考资料，不主动执行
- **可组合**：多个 Skills 可以同时使用

---

## 2. Skill 文件结构

### 2.1 推荐模板

```markdown
# [Skill 名称]

> [简短描述 - 一句话说明用途]

## 概述

[2-3 句话介绍这个 Skill 的内容和价值]

---

## 1. [核心知识模块 1]

### 1.1 [子主题]

[具体内容，使用表格、代码块、列表等清晰呈现]

### 1.2 [子主题]

...

---

## 2. [核心知识模块 2]

...

---

## N. 快速参考

[最常用的内容汇总，方便快速查阅]

---

## 检查清单

[使用此 Skill 时的检查项]

---

> 来源参考: [引用来源]
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description                   | Location                                  |
|---------------|-------------------------------|-------------------------------------------|
| `template`    | 该 Skill 使用的模板样例       | `.tad/evidence/skills/template.md`        |
| `examples`    | 成功应用的示例片段或链接      | `.tad/evidence/skills/examples/`          |
| `styleguide`  | 写作与结构风格指南（可复用）  | `.tad/evidence/skills/styleguide.md`      |

### Acceptance Criteria

```
[ ] frontmatter 与章节结构完整统一
[ ] 提供 TL;DR、红旗、可复制的示例与检查清单
[ ] 定义 Required Evidence + Artifacts，可被 Gate 审查
```

### Artifacts

| Artifact   | Path                                   |
|------------|----------------------------------------|
| Template   | `.tad/evidence/skills/template.md`     |
| Examples   | `.tad/evidence/skills/examples/`       |
| Styleguide | `.tad/evidence/skills/styleguide.md`   |

### 2.2 文件命名规范

```
格式: [领域]-[主题].md

示例:
- ui-design.md           # UI 设计知识
- react-patterns.md      # React 模式
- api-design.md          # API 设计
- security-checklist.md  # 安全检查清单
```

---

## 3. 内容编写指南

### 3.1 内容原则

1. **实用优先**：可直接应用的知识，不是理论概念
2. **结构清晰**：使用标题层级、表格、列表组织
3. **有示例**：关键知识点配合代码或图示
4. **可检查**：提供检查清单或决策树

### 3.2 格式建议

#### 使用表格对比

```markdown
| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| A | ... | ... | ... |
| B | ... | ... | ... |
```

#### 使用代码块示例

```markdown
```javascript
// 好的做法
const result = await fetchData();

// 避免的做法
fetchData().then(result => ...);
```
```

#### 使用检查清单

```markdown
- [ ] 检查项 1
- [ ] 检查项 2
- [ ] 检查项 3
```

#### 使用决策树

```markdown
问题：是否需要状态管理？
├── 简单状态（2-3个组件共享）→ React Context
├── 中等复杂度 → Zustand / Jotai
└── 复杂应用 → Redux Toolkit
```

### 3.3 避免的内容

- ❌ 过于抽象的理论
- ❌ 过时的信息（标注更新日期）
- ❌ 冗长的解释（用表格/列表代替）
- ❌ 没有示例的规则

---

## 4. 创建流程

### 4.1 步骤

```
1. 确定领域和主题
   └── 回答：这个 Skill 解决什么问题？

2. 收集知识来源
   └── GitHub 项目、文档、最佳实践文章

3. 组织内容结构
   └── 按使用场景或知识类型分模块

4. 编写内容
   └── 使用模板，注重实用性

5. 添加快速参考
   └── 最常用内容的汇总

6. 创建检查清单
   └── 使用此 Skill 时的验证点

7. 放入 .claude/skills/ 目录
```

### 4.2 示例：创建 "API 设计" Skill

```markdown
# API Design Knowledge Base

> REST API 设计最佳实践和常见模式

## 概述

本 Skill 提供 REST API 设计的核心知识，帮助设计一致、易用的 API。

---

## 1. URL 设计

### 1.1 资源命名

| 规则 | 好 | 不好 |
|------|-----|------|
| 使用复数 | /users | /user |
| 使用名词 | /orders | /getOrders |
| 小写连字符 | /user-profiles | /userProfiles |

### 1.2 层级关系

```
# 获取用户的订单
GET /users/{id}/orders

# 获取订单的商品
GET /orders/{id}/items
```

---

## 2. HTTP 方法

| 方法 | 用途 | 幂等 |
|------|------|------|
| GET | 获取资源 | 是 |
| POST | 创建资源 | 否 |
| PUT | 完整更新 | 是 |
| PATCH | 部分更新 | 是 |
| DELETE | 删除资源 | 是 |

---

## 3. 状态码

...

---

## 快速参考

| 操作 | 方法 | URL | 状态码 |
|------|------|-----|--------|
| 列表 | GET | /resources | 200 |
| 详情 | GET | /resources/{id} | 200 |
| 创建 | POST | /resources | 201 |
| 更新 | PUT | /resources/{id} | 200 |
| 删除 | DELETE | /resources/{id} | 204 |

---

## 检查清单

- [ ] URL 使用复数名词
- [ ] 正确使用 HTTP 方法
- [ ] 返回合适的状态码
- [ ] 错误响应包含有用信息
```

---

## 5. 知识来源推荐

### 5.1 从哪里获取知识

| 来源类型 | 示例 | 优先级 |
|---------|------|--------|
| 官方文档 | React Docs, MDN | 高 |
| 权威指南 | Google Style Guide, Airbnb | 高 |
| GitHub 项目 | awesome-xxx 系列 | 中 |
| 技术博客 | 公司技术博客 | 中 |
| 个人经验 | 项目中的最佳实践 | 中 |

### 5.2 如何筛选内容

```
筛选标准:
1. 是否经过验证？（生产环境使用）
2. 是否有广泛认可？（star 数、引用数）
3. 是否仍然有效？（检查更新日期）
4. 是否可直接应用？（不需要大量改造）
```

---

## 6. 维护和更新

### 6.1 更新时机

- 发现更好的实践
- 原有知识过时
- 使用中发现遗漏
- 新技术/新版本发布

### 6.2 版本标注

```markdown
# [Skill 名称]

> 最后更新: 2024-01-15
> 适用版本: React 18+, Next.js 14+
```

---

## 7. Skills 分类建议

### 7.1 开发类

```
.claude/skills/
├── ui-design.md          # UI/UX 设计
├── api-design.md         # API 设计
├── react-patterns.md     # React 模式
├── testing-strategies.md # 测试策略
└── performance.md        # 性能优化
```

### 7.2 领域类

```
.claude/skills/
├── domain/
│   ├── ecommerce.md      # 电商领域
│   ├── fintech.md        # 金融科技
│   └── healthcare.md     # 医疗健康
```

### 7.3 工具类

```
.claude/skills/
├── tools/
│   ├── git-workflow.md   # Git 工作流
│   ├── docker-basics.md  # Docker 基础
│   └── ci-cd.md          # CI/CD 配置
```

---

## 检查清单：创建新 Skill

- [ ] 确定了明确的领域和主题
- [ ] 收集了可靠的知识来源
- [ ] 使用了推荐的文件结构
- [ ] 内容以实用为主，有示例
- [ ] 包含快速参考部分
- [ ] 包含检查清单
- [ ] 文件命名符合规范
- [ ] 放入 `.claude/skills/` 目录

---

> 本 Skill 帮助你创建更多有价值的 Skills，持续增强 TAD 的知识库。
