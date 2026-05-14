---
Title: TAD Universal Method — 跨平台跨领域 AI 协作执行框架
Date: 2026-05-02
Status: promoted
Promoted To: Epic (via *analyze — 2026-05-02)
Scope: large
---

## Summary & Problem

TAD 从个人开发工具演进为通用 AI 协作执行框架。核心发现：TAD 的价值不在 Claude Code 工具链（hooks、evidence 目录、Domain Packs），而在底层认知纪律（先想清楚 → 再动手 → 做完验证 → 人在中间决策）。当 Alex/Blake 角色从固定（PM+Dev）变为按项目动态推导时，TAD 方法适用于任何用 AI 做复杂项目的场景——视频脚本、数据分析、设计、学术写作等。

**定位**：开源执行方法工具（不是教学工具）。装上之后，AI 在 terminal 里做复杂任务的效果就是比不装好。

目标用户：用 Codex / Gemini / Claude Code / Kimi / MiniMax 等 CLI AI 工具做复杂项目的人（非开发者为主）。

## 产品架构（三层）

```
┌─────────────────────────────────────────────┐
│  Layer 3: Skills 库 (精选策展，按需加载)      │  ← 后做
│  利用现有开源 skills 仓库，框架定义标准格式    │
├─────────────────────────────────────────────┤
│  Layer 2: 平台适配器 (安装时选择)             │  ← 先做
│  Codex / Gemini / Claude Code / Kimi / ...  │
├─────────────────────────────────────────────┤
│  Layer 1: 核心协议 (固定不变，完整保留TAD精髓) │  ← 先做
│  角色推导 + Socratic + 分离 + 自检 + 验收     │
└─────────────────────────────────────────────┘
```

优先级：Layer 1 + Layer 2 先做，Layer 3 后做。核心协议本身已经有价值。

## 核心协议（Layer 1）— 完整保留 TAD 精髓

Layer 1 核心协议（平台无关）：

```
├── 角色定义
│   ├── Alex：规划角色（不执行产出）
│   ├── Blake：执行角色（不自己设计/不自己决策）
│   └── 角色推导机制（init 时根据项目类型设计具体角色名和职责）
├── Terminal 隔离
│   ├── Alex = Terminal 1, Blake = Terminal 2
│   ├── 人是唯一信息桥梁
│   └── 禁止同 terminal 调用另一 agent
├── 交接协议
│   ├── Socratic 澄清（交接前必须提问）
│   ├── Handoff 格式（任务描述 + AC + 文件清单）
│   └── 人话版解释（让用户理解在做什么）
├── 执行协议
│   ├── 自检（对照计划逐条核对）
│   ├── 完成报告（做了什么 + AC 对照）
│   └── 回传给 Alex 验收
└── 质量关卡
    ├── 交接前检查（Alex 自己的设计完整吗）
    ├── 执行后检查（Blake 对照 AC 全过了吗）
    └── 验收检查（Alex 确认产出符合要求）
```

## 角色动态推导（核心创新点）

角色不是固定的"PM + Dev"，而是 init 时通过 Socratic 对话动态推导：

| 项目类型 | Alex 是谁 | Blake 是谁 |
|---------|----------|----------|
| 软件开发 | PM + 架构师 | 开发工程师 |
| 数据分析 | 研究设计者 | 数据工程师 |
| 视频制作 | 编导 + 策划 | 脚本撰稿人 |
| 学术写作 | 论文导师 | 撰稿者 |
| 内容营销 | 策略师 | 文案写手 |

推导过程不只是角色名，还包括：
- 这类项目常见的失败原因（风险）
- 成功标准 / 核查标准
- 各角色需要的 Skills
- 全部写入配置文件固化

## Init 流程设计（用户体验）

### 第一步：安装（跟平台无关）

```
$ npx tad-method init

Welcome to TAD Method!

? 你想在哪些平台上使用？（多选）
  ✔ Claude Code
  ✔ Codex
  ○ Gemini CLI
  ○ Kimi
  ○ MiniMax
  ○ 通用（纯文本 system prompt）

→ 生成对应平台的入口文件（CLAUDE.md / AGENTS.md / ...）
→ 完成！
```

选完平台后只生成对应入口文件。以后更新框架也只更新已选平台。

### 第二步：进入 AI 工具，自动触发角色设计

```
用户进入 Codex / Claude Code / ...
→ AI 读到入口文件
→ 检测到 initialized: false
→ 自动进入 init 设计对话（同一个 Terminal 内完成）

对话流程：
1. "这个项目做什么？目标受众？最终产出形式？"
2. 推导 Alex = [角色名 + 职责]，Blake = [角色名 + 职责]，用户确认
3. 推导风险："这类项目常见失败原因是... 建议检查标准是..."，用户补充
4. 推导 Skills：各角色需要什么能力，用户确认
5. 写入配置文件
6. 提示用户退出重进
```

### 第三步：正常使用

```
重新进入项目
→ AI 读到完整的角色定义
→ Terminal 1 使用 Alex（规划），Terminal 2 使用 Blake（执行）
→ 人在中间传话和决策
```

## 文件结构

```
项目目录/
├── AGENTS.md          ← Codex 入口（如果用户选了 Codex）
├── CLAUDE.md          ← Claude Code 入口（如果用户选了 Claude Code）
├── GEMINI.md          ← Gemini 入口（如果选了）
└── .tad-lite/
    ├── protocol.md    ← 核心协议（Layer 1，所有平台共享，只写一份）
    ├── state.yaml     ← 状态：initialized: true/false
    ├── roles/         ← init 完成后，角色定义写在这里
    └── skills/        ← 按需加载的 skills
```

核心知识只写一份（protocol.md），平台入口文件只是指针。加新平台只需加一个入口文件。

## 平台适配器（Layer 2）

| 平台 | 入口文件 | 说明 |
|------|---------|------|
| Claude Code | CLAUDE.md + .claude/skills/ | 已有完整实现（TAD 主线） |
| Codex | AGENTS.md | 项目根目录，自动加载 |
| Gemini | GEMINI.md | 类似 Codex 的指令文件 |
| Kimi | 待研究 | CLI 工具的指令加载方式 |
| MiniMax | 待研究 | CLI 工具的指令加载方式 |
| 通用 | 纯文本 system prompt | 复制粘贴到任何 AI 工具 |

每个适配器做同一件事：把 protocol.md + roles/ 格式化为该平台能理解的指令。

## Skills 库（Layer 3）— 后做

策略：**框架是 Skills 的策展人，不是生产者。**

- 市面上已有大量开源 skills / prompt 仓库
- 框架定义一个标准格式，让外部 skills 能被 Alex/Blake 读懂
- init 时，AI 根据角色定义推荐现成 skills，用户确认后拉取
- 精选策展 > 大而全的列表
- 即便没有 skills，核心协议本身已经能解决很多问题

## 与 TAD 的关系

- TAD (当前 repo) = power-user 开发工具，继续独立迭代
- 新产品 = 从 TAD 提炼方法论，独立 repo，面向普通用户
- 新产品不带 TAD 工程包袱（no hooks, no evidence dirs, no Gate 机械、no Domain Pack YAML）
- 保留 TAD 精髓：Terminal 隔离、Socratic、角色分离、自检、验收、人类桥梁

## 关键设计决策（已讨论确认）

1. **定位是执行方法工具** — 不是教学工具，装上就能让 AI 做复杂任务做得更好
2. **完整保留 TAD 精髓** — 不做"最小集"精简，Terminal 隔离 + Socratic + 自检 + 验收全保留
3. **角色动态推导** — init 时 Socratic 对话设计角色 + 风险 + 标准 + skills，不是预设模板
4. **安装时选平台** — npx 安装时多选平台，只生成对应入口文件，后续更新也只更新已选平台
5. **init 在 AI 工具内完成** — 不是单独的 CLI 流程，进入 AI 工具后自动触发
6. **协议固定，角色流动** — 底层方法论不变，角色按项目定制
7. **Skills 按需加载，后做** — 核心协议本身已有价值，Skills 策展后面做
8. **独立产品** — 新 repo，可以有新名字
9. **平台入口文件只是指针** — 核心知识只写一份 protocol.md

## Open Questions

- 新产品叫什么名字？（不一定叫 TAD — 需要一个更通用的身份）
- Skills 的标准格式是什么？（需要兼容外部仓库的多种格式）
- 社区共建 Skills 还是自己精选维护？
- Expert Review（调 subagent 做专家审查）跨平台怎么适配？不同平台 subagent 能力差异大
- 商业模式：开源核心 + 精选 skills？还是全开源？
- 第一个要适配的平台选哪个？（用户朋友们主要用什么工具？）
- 什么时候开始做 MVP？

## MVP 建议

1. Layer 1（protocol.md）+ Layer 2（2 个平台 adapter：Claude Code + Codex）
2. Init 流程跑通（安装 → 选平台 → 进入工具 → 设计角色 → 生成配置 → 退出重进 → 使用）
3. 让 1-2 个朋友在真实项目试用
4. 根据反馈决定是否扩展 Layer 3

## 启发来源

- TAD v2.9.0 Codex 适配过程中发现：剥离 Claude Code 机制层后，剩下的方法论本身是通用的
- BMAD Method v6 的反面教训：不要把所有场景都塞进一个膨胀的系统
- 用户原话："我一直在纠结该不该把 TAD 给朋友用，但它越来越偏开发了。如果简化为小框架，适用不同平台，而且可以定制，就容易多了。"
