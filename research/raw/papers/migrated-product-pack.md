# Product Management Capability Pack — Research Findings
> Source: NotebookLM notebook `a8f77481` (40 sources)
> Date: 2026-05-07 | 4 rounds of systematic questioning
> Status: Research complete, pending synthesis + recommendation

---

## Landscape Summary

### What Exists

| Project | 做了什么 | 核心理念 | 问题 |
|---------|---------|---------|------|
| **pm-skills** (product-on-purpose) | 40 skills, Triple Diamond 框架, 9 workflows | 覆盖全生命周期的模板集 | 仓鼠收集——多≠好，填模板≠做对产品 |
| **Product-Manager-Skills** (deanpeters) | 46 skills, 三层架构 | 互动式辅导 + SaaS 财务 + 职业发展 | 内容更好但仍是模板导向 |
| **GStack** (Garry Tan) | 23 skills, 角色化团队 | "虚拟 YC 合伙人团队" — 质疑你、挑战你、逼你做决定 | 最接近真正有用，但绑定 GStack 生态 |
| **startup-pressure-test** | 1 skill | 对抗性诊断 — verdict + 致命缺陷 + 2 周 MVP | 单点极好，但只覆盖 idea 验证 |
| **pm-brain** | 框架集 | 组织政治导航 + 利益相关者模拟 + Brier 分数 | 独特视角但无 AI agent 实现 |
| **AI Product Dev Toolkit** | 提示词模板 | MVP 概念 + PRD + UX 规格 | 纯提示词，无工作流 |

### 3 种交互模式

1. **模板模式** (pm-skills, deanpeters): "这里是 PRD 模板，请填写" → 被动
2. **教练模式** (GStack office-hours, pressure-test): "回答我这 6 个问题" → 主动质疑
3. **团队模式** (GStack 整体, TAD): "我是你的 CEO/设计师/工程经理" → 角色协作

### GStack 核心洞察

1. **Office Hours 6 个逼问**:
   - Demand Reality（需求真实性——证据在哪？）
   - Status Quo（用户现在怎么解决？）
   - Desperate Specificity（说出一个真实人名）
   - Narrowest Wedge（最小付费版本）
   - Observation & Surprise（你亲眼看过用户用吗？）
   - Future-Fit（3 年后还有用吗？）

2. **Design Shotgun**:
   - 并行生成 4-6 个完全不同的设计变体
   - 强制反收敛——不允许长得像
   - 建立"口味记忆"——学习用户偏好

3. **CEO Review 4 模式**:
   - SCOPE EXPANSION / SELECTIVE EXPANSION / HOLD SCOPE / SCOPE REDUCTION

4. **Skillify**: 把成功操作固化为新 skill（学习→固化→复用）

5. **ETHOS**: "AI 是钢铁侠战甲" + "Boil the Lake（完整实现变便宜了，别再偷工减料）"

### 用户明确不要的

- ❌ 一大堆 skill 文档描述（pm-skills 模式）
- ❌ 模板集合
- ❌ 更多的"填表"工具

### 用户接近想要的

- ✅ 对抗性诊断（startup-pressure-test + office-hours 模式）
- ✅ 创意倍增（design-shotgun 的并行变体思路）
- ✅ 角色化思考伙伴（GStack 的 CEO/Designer/Eng Manager）
- ? 还有一个模糊的部分没找到

---

## Key Gap: What's Missing?

用户说"稍微近一点点"和"还没想清楚"。可能缺失的拼图：

1. **不只是验证想法（what），还要帮你想出想法（generate）**
   - GStack 和 pressure-test 都假设你已经有了想法，它们只是验证
   - 真正的 ideation（从零到一）没有工具覆盖
   
2. **不只是单次使用，而是持续进化**
   - 研究 notebook 积累知识（我们已经有了）
   - 但产品决策的积累呢？每次验证/pivot 的记录和学习？

3. **跨项目复用**
   - 在一个项目中学到的市场洞察，能否复用到下一个项目？

---

## 待综合：给用户的建议

（下一步：Alex 基于以上所有研究给出综合判断）

---

# Round 3-4: GStack + Non-Software + Tool Integration (2026-05-07)
> Sources expanded to 52 (added GStack 12 files + last30days + aso-skills + Amazon tools + ecommerce)

## GStack Core Insights

### Office Hours 6 Forcing Questions
1. Demand Reality — evidence of real demand
2. Status Quo — what users do now
3. Desperate Specificity — name a real person
4. Narrowest Wedge — smallest payable version
5. Observation & Surprise — watched someone use it?
6. Future-Fit — still relevant in 3 years?

### Design Shotgun — parallel variant generation
- 4-6 variants simultaneously, forced anti-convergence
- Taste memory builds user profile over time

### CEO Review 4 Modes
- SCOPE EXPANSION / SELECTIVE EXPANSION / HOLD SCOPE / SCOPE REDUCTION

### Skillify — auto-generate skills from successful operations

### Philosophy: "Iron Man suit" — augment, don't replace

## Non-Software Product Validation

### Tool Availability Matrix
| Product Type | CLI/API Tools | Web-Only | Gaps |
|-------------|--------------|----------|------|
| Software | last30days, aso-skills, tam-calculator | G2, Crunchbase | — |
| Ecommerce | Bright Data API, Keepa API, Amazon SP-API | Helium 10, Jungle Scout | — |
| Hardware | — | Kickstarter scrape | Supplier costs, tooling quotes |
| Service | — | Upwork/Fiverr scrape | Pricing benchmark DB |

### Key Insight: 6 Forcing Questions Are Universal
Structure doesn't change across product types. Data sources change.
MVP definition changes: software=2wk code, hardware=3D print+crowdfund, ecommerce=10-unit test, service=5 manual clients

## Design Decision: 3 Deep Skills, Not 40 Templates

### Architecture
```
Product Type Router (6 types)
  ↓
/pressure-test (6 forcing questions + real data + verdict)
  ↓
/shotgun (4-6 business model variants + 4-perspective review)
  ↓
/define (auto-generate lean canvas + MVP scope + type-specific output)
```

### Differentiation vs GStack
- Multi-product-type (GStack = software only)
- Shotgun = business model variants (GStack = UI variants only)
- Define output is executable per product type

### Adapter Pattern
Each product type has a config: data sources + question wording + MVP definition + output format.
Same skill structure, different data layer.
