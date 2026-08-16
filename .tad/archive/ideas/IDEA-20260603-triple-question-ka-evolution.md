# Idea: Triple-Question KA — Knowledge + Skill + Workflow 三问闭环

**ID:** IDEA-20260603-triple-question-ka-evolution
**Date:** 2026-06-03
**Status:** promoted
**Scope:** medium
**Priority:** HIGH — 用户明确要求在干净 context 的 Alex session 中优先执行

---

## 1. 这个 Idea 从哪里来

### 起点：一篇 Anthropic 文章

2026-06-03 Thariq (Anthropic Claude Code 团队) 发布了 "A harness for every task: dynamic workflows in Claude Code"。文章描述了 6 种可组合的 workflow 模式（classify-and-act、fan-out-and-synthesize、adversarial verification、generate-and-filter、tournament、loop-until-done），以及 Claude Code 新增的 Workflow tool——让 Claude 能即时生成自定义 JavaScript 编排脚本。

文章链接：https://x.com/trq212/article/2061907337154367865
本地存档：.tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md

### 核心洞察：TAD 是 Dynamic Workflow 出现之前的手工解法

TAD 的 SKILL.md（alex/SKILL.md 6000+ 行）本质上是用自然语言模拟 JavaScript runtime——每个协议步骤都是文本形式的"如果 P0 则停止，否则继续"。Thariq 文章指出的三大失败模式（agentic laziness、self-preferential bias、goal drift）恰好是 TAD 过去 4 个月用 prompt engineering 解决的问题（anti-rationalization registry、adversarial challenge、session-state recovery）。

平台追上来了：Claude Code 原生支持 agent()/parallel()/pipeline()/schema/isolation:worktree/model routing。TAD 的价值应该从"编排本身"转向"编排里的判断力"——SKILL.md 保留判断规则（WHAT），编排逻辑移到 workflow.js（HOW）。

### 实验验证（同一 session）

在 *discuss 中我们跑了 3 个实验来验证 workflow 对 TAD 的价值：

**实验 1：Epic 审计（fan-out + adversarial + synthesis）**
- 7 个 agent 并行分析 3 个 parked Epic，每个 analyst 有独立 context
- Adversarial challenger 在全部 3 个 Epic 上都发现了 analyst 的盲点
- 结论：多 agent 独立 context + adversarial 比单 agent 串行分析质量明显更高

**实验 2：深度研究（4 researcher + 4 challenger + 1 synthesizer）**
- 研究 4 个 workflow 模式如何适配 TAD
- 9 个 agent challenger 用 TAD 自己的 principles 把 4 个方案都打回来了（"Measure Before Optimizing"）
- 结论：adversarial challenge 有效纠正了 Alex 的乐观偏见

**实验 3：Tournament 设计竞赛（3 competitor + 3 judge + 1 merger）**
- 3 个 agent 各从不同先例（OpenCode/Codex TOML/Claude settings.json）设计 constraint schema
- Tournament winner + 从败者偷的 5 个最佳创意 = 合并方案比单 agent 设计丰富 30%
- 结论：Tournament 的价值不在选赢家，在于从败者提取最佳创意合并

### 从实验到 Epic（同一 session）

实验验证后，我们创建了 EPIC-20260603-dynamic-workflow-integration（6 Phase）：
- P0: 保存第一个可复用 workflow（epic-audit.workflow.js）
- P1: Gate review workflow（per-AC verifier + skeptic）
- P2: Tournament design workflow（N competitor + pairwise judge + merge）
- P3: YOLO execution workflow（hybrid Conductor + workflow，SKILL.md 240→30 行）
- P4: Cross-platform adapter（detect-platform.sh + tournament-codex.sh）
- P5: Loop-discover workflow（loop until K dry rounds）

全部 Gate 通过，v2.23.0 发布并 sync 到 14 个项目。

### Codex 交叉审计

发布后用 Codex CLI 做独立审计：
- 第一轮：12/25（Safety 2/5 — 发现 YOLO workflow 没有 stop-on-P0 gate）
- 修复 + 7 实验安全验证
- 第二轮：16/25（5 个 remaining items）
- 修复全部
- 第三轮：18/25（NEEDS-FIXES → 剩余 2 个 P2：cwd-relative detection + test harness）

### 讨论中诞生的关键洞察

在讨论"文章还有什么启示没覆盖"时，用户指出：

1. **Skillify（昨天刚发布的功能）和 Workflow 在概念上交织**——Skillify 提取的工作模式，有些本质上是编排模式（应该产出 .workflow.js）不是判断模式（SKILL.md）
2. **三问应该统一**——Gate KA 不只是问"有没有新知识"和"有没有新 skill"，还应该问"有没有编排模式值得做成 workflow"
3. **三问不只在 Blake 的 Gate 3/4**——Alex 也有大量执行（*discuss、*research-plan、YOLO、workflow 实验），这些执行完成后也应该触发三问
4. **闭环**：用 → 发现 → 三问 → 改进/新建 → 再用

---

## 2. 核心设计

### 三问统一

每次"有产出的执行"结束时，问三个问题：

| # | 问题 | 判断标准 | 产出 | 载体 |
|---|------|---------|------|------|
| 1 | 新知识？ | 发现了之前不知道的事实/规律 | project-knowledge entry | .tad/project-knowledge/*.md |
| 2 | 新 skill？ | 可复用的判断模式（≥3 步，非 trivial，Skillify 4-gate） | Skillify candidate | .tad/active/skillify-candidates/SCAND-*.md → .claude/skills/*/SKILL.md |
| 3 | 新/改 workflow？ | 手动做了多轮 agent 编排 / 发现现有 workflow 有缺陷 | Workflow candidate 或 KA 改进记录 | .claude/workflows/*.workflow.js |

第三问的子判断（决定是新建还是改进）：
- "我手动做了一个多 agent 编排，效果很好" → 新建 workflow candidate
- "现有 workflow 跑了但有缺陷（prompt 不好、判定太松、缺少维度）" → KA 记录 → 下次 session 修

### 第 5 步：判断型 vs 编排型

Skillify (v2.22.1) 的 4-gate 评估：Reusable / Non-trivial / Verified / Not-duplicate。

增加第 5 步：**"这个模式是判断型还是编排型？"**

| 信号 | 类型 | 产出路径 |
|------|------|---------|
| "评估 X 时要检查 Y 和 Z" | 判断型 | → SKILL.md（Skillify 现有路径） |
| "每次做 code review 我们都是 per-AC verifier + skeptic" | 编排型 | → .workflow.js candidate |
| "做重要设计决策时让多个方案竞争然后合并" | 编排型 | → .workflow.js candidate |
| "当发现 rubric 分数异常时，要同时检查 inter-rater reliability" | 判断型 | → SKILL.md |
| "循环找 bug 直到连续 2 轮无新发现" | 编排型 | → .workflow.js candidate |

长期收敛：Skillify 变成**统一的模式提取器**，根据模式类型产出不同载体（SKILL.md 或 .workflow.js）。

### 触发点统一

不只是 Gate 3/4。任何"有产出的执行"都触发三问：

**Blake 触发点：**
- Gate 3 Layer 1 完成后（已有 KA，扩展为三问）
- Gate 3 Layer 2 expert review 完成后

**Alex 触发点：**
- *accept (Gate 4) 完成后 ← 已有 KA，扩展为三问
- *discuss 退出时 ← 新增（讨论经常产生洞察但不记录）
- *research-plan 完成时 ← 新增（研究发现可能包含编排模式）
- Workflow tool 调用完成后 ← 新增（每次 workflow 跑完是最自然的反思点）
- YOLO Phase Y8 (KA step) ← 已有但只问 2 问，扩展为 3 问

**频率控制：**
- Express handoff / 简单 *discuss → 轻量三问（1 句话判断，不深入）
- Standard/Full handoff / 复杂 workflow → 完整三问（逐条评估）
- 判断标准：执行过程中 agent 数量 > 3 或耗时 > 10 分钟 → 完整三问

### Workflow 改进闭环

```
用（调用现有 workflow）
  ↓
发现（跑完后 KA 三问发现问题或新模式）
  ↓
记录（KA entry：knowledge / skill candidate / workflow candidate）
  ↓
改进（下次 session Alex 读 KA → handoff → Blake 修 .workflow.js）
  ↓
再用（改进后的 workflow 被调用 → 回到第一步）
```

### 与动态 Workflow 生成的关系

三问闭环的自然演进路径：

1. **手动编排**（当前大部分场景）→ 三问发现"这个编排模式反复出现"
2. **保存为 .workflow.js**（当前 5 个 saved workflow）→ 直接调用
3. **Alex 遇到类似但不完全匹配的场景** → 以 saved workflow 为模板，通过 Workflow tool `script` 参数动态生成变体
4. **变体效果好** → 三问再次触发 → 保存为新 workflow 或合并到现有

最终态：TAD 不是"5 个固定 workflow"，而是一个**不断从实践中提取和改进编排模式的系统**。5 个 workflow 只是种子。

---

## 3. 今天的实验为什么证明这个方向对

### 证据 1：Tournament 实验

我们用 Tournament 模式做了 declarative constraints schema 设计。如果当时三问存在：
- Q1（知识）："Codex 有 --output-schema 做机械化 JSON 校验" → 知识
- Q2（skill）：无
- Q3（workflow）："这个 3-competitor + pairwise-judge + merge 的模式以后设计决策都可以用" → 直接保存为 tournament-design.workflow.js

实际发生的是：我们手动决定保存这个 workflow。三问会让这个决定**系统化**。

### 证据 2：Codex 审计

Codex 审计发现 YOLO workflow 的 stop-on-P0 缺失。如果当时三问存在：
- 审计 workflow 跑完后 → Q3："gate-review.workflow.js 的 adversarial 模式可以用来审计其他 workflow" → 可能会更早发现

### 证据 3：Alex 违规写代码

P0/P1 我（Alex）直接写了 workflow.js 代码——违反了 terminal isolation。如果三问存在，这次违规本身是一个 KA 发现：
- Q1（知识）："Alex 不写代码" 这条规则在 workflow 场景下需要 carve-out（发布操作 vs 实现代码的边界模糊了）
- 实际记录为：feedback_alex-no-code-violation.md

---

## 4. Open Questions

1. **Workflow candidate 的格式**：跟 Skillify 的 SCAND-*.md 类似？需要新的 WCAND-*.md 模板？还是直接复用 SCAND 加一个 `type: workflow` 字段？
2. **三问的交互方式**：全部用 AskUserQuestion（3 个问题一次问完）？还是先问 Q1，有发现再展开 Q2/Q3？
3. **Alex 触发点的频率**：*discuss 每次退出都问三问会不会太 noisy？是否应该只在"讨论产生了具体结论或决策"时触发？
4. **Workflow candidate 的审批流程**：跟 Skillify 一样在 Alex STEP 3.57 启动时检测？还是单独的 STEP 3.58？
5. **"判断型 vs 编排型"的第 5 步**：放在 Skillify 4-gate 之后，还是替代 4-gate 的某一步？可能应该放在 Reusable 和 Non-trivial 之间（先确认可复用，再判断类型，再验证）

---

## 5. Implementation Guidance for Next Session

**给下一个 Alex session 的上下文：**

这个 idea 来自 2026-06-03 一个很长的 session（从 Thariq 文章 → 3 个 workflow 实验 → 6-Phase Epic → Codex 3 轮审计 → 讨论 workflow 持续改进 → 讨论 Skillify 和 workflow 的关系 → 用户提出三问闭环）。

用户明确说了两件事：
1. "这个东西对我们来说很重要"
2. "我希望是另外开一个很干净的 alex 上下文比较干净的，然后头脑比较清醒的来做这个事情"

所以下次 session 应该：
- 不要急着写代码（Handoff → Blake）
- 先 *discuss 理清三问在 Alex SKILL.md 和 Blake SKILL.md 里的具体嵌入点
- 考虑是否需要 Socratic 提问来细化设计（用户对频率控制和格式有疑问）
- 可能适合用 Tournament 模式来设计三问的交互方式（3 种方案竞争）

**关键文件参考：**
- .claude/skills/alex/SKILL.md `acceptance_protocol.step7` (当前 KA 两问)
- .claude/skills/blake/SKILL.md `knowledge_assessment` (Blake KA)
- .claude/skills/alex/SKILL.md `skillify_command_protocol` (*skillify 命令)
- .tad/templates/skillify-candidate-template.md (Skillify candidate 格式)
- .claude/workflows/*.workflow.js (5 个现有 workflow — 三问第三类的产出目标)
- .tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md (源头文章)
- .tad/archive/epics/EPIC-20260603-dynamic-workflow-integration.md (workflow Epic 完整记录)

---

## 6. Related Ideas

- **IDEA-20260603-skillify-at-knowledge-assessment** — Skillify 是三问的第二问。三问是 Skillify 的超集。
- **EPIC-20260603-dynamic-workflow-integration** — Workflow 体系是三问第三类的基础设施。没有 workflow 基础设施，第三问没有产出目标。
- **IDEA-20260602-sac-thin-protocol-thick-tools** — "薄协议 + 厚工具"。三问产出的 skill 和 workflow 就是"厚工具"，SKILL.md 里的判断规则是"薄协议"。三问闭环是实现 thin-protocol 方向的**机制**。
- **IDEA-20260603-dual-platform-orchestration-adapter** — 跨平台适配。三问产出的 workflow 需要在 Claude Code 和 Codex 上都能跑。

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
