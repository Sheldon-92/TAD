# TAD Framework 完整介绍

> 本文档面向外部 agent / 知识库，完整介绍 TAD 是什么、为什么这样做、怎么演进过来的、现在能做什么。
>
> 最后更新：2026-02-18 | 当前版本：v2.4.0

---

## 一、TAD 是什么

**TAD（Triangle Agent Development）** 是一套 **AI 辅助软件开发的方法论框架**。它定义了人类与两个 AI Agent 之间的协作模式，通过「三角形模型」和「四道质量门」来确保 AI 生成的代码既满足业务需求、又达到工程质量标准。

一句话总结：**TAD 是给 AI Coding Agent 用的「开发流程规范」，核心理念是在 AI 越来越强的时代，人类的关键检查点反而越来越重要。**

TAD 不是一个运行时程序，而是一套由配置文件、命令协议、模板和质量规则组成的方法论，安装在任意项目中通过 Claude Code 的 slash command 系统执行。

---

## 二、起源与动机

### 2.1 问题背景

2025 年，AI Coding 工具（如 Cursor、Claude Code、GitHub Copilot Agent）快速普及。开发者发现了一个悖论：

- **AI 能力越强，失控的代价越大**。AI 可以一小时写完一个功能，但如果方向错了，一小时的废代码比手写三天的废代码更难清理。
- **AI 自我验证不可靠**。AI 写了代码，又写了测试，然后告诉你"所有测试通过"——但它是在验证自己的理解，不是你的需求。
- **需求漂移无感知**。人类说了一句模糊的需求，AI 按自己的理解往下跑，中间没有任何检查点，最终交付物可能"技术上正确但方向上偏了"。

### 2.2 核心洞察

**AI 越强，人类的检查点越关键。**

当 AI 弱的时候，人类必须参与每一步。当 AI 强的时候，人类可以退到更高层——但那几个关键节点变得更重要，因为一旦 AI 在那里偏了，它会以更快的速度冲向错误方向。

这就是为什么"完全自主的 AI 开发"是一个伪命题——**不是因为 AI 做不到，而是因为没有人类把关的 AI 产出不可靠。**

### 2.3 第一个版本

TAD 的第一次 commit 是 **2025 年 9 月 26 日**，由 Sheldon Zhao 创建。最初的 v1.0 定义了三角形模型的基本结构：一个人类 + 两个 Agent（Alex 和 Blake），通过 Handoff 文档传递设计，通过 Gate 强制质量检查。

---

## 三、核心设计哲学

### 3.1 Beneficial Friction（有益摩擦）

TAD 的核心哲学不是"让 AI 做更多事"，而是 **"让人类的参与更有价值"**。

摩擦分为两种：
- **有害摩擦**：手动复制代码、格式调整、环境搭建、等编译——应该被自动化消除。
- **有益摩擦**：需求澄清对话、优先级决策、端到端验收——应该被保留甚至强化，因为这是价值创造的节点。

TAD 自动化了所有有害摩擦（Blake 自动写代码、自动跑测试、自动做专家审查），但刻意保留了三个有益摩擦点：

| 摩擦点 | 为什么人类不可替代 | 没有人类会怎样 |
|--------|-------------------|---------------|
| **需求澄清** | 只有人类知道真正要解决的问题 | AI 构建"技术正确但方向错误"的东西 |
| **优先级决策** | 涉及资源、时间、商业判断 | AI 按"技术复杂度"排序而非按价值排序 |
| **端到端验收** | 只有人类能判断"这真的能用吗" | AI 通过所有单元测试但 UX 是坏的 |

### 3.2 Terminal Isolation（终端隔离）

Alex 和 Blake 运行在不同的 terminal 中，**人类是两个 Agent 之间唯一的信息桥梁**。

这不是技术限制，而是**有意的设计约束**：
- 防止 Agent 之间直接通信导致的"回音室效应"
- 确保人类在每个关键节点都有机会介入
- 信息经过人类传递时，人类自然会进行理解和过滤

### 3.3 Design Before Code（先设计后编码）

Alex 完成所有设计后，才由 Blake 实现。没有 Handoff 就不写代码。

这确保了需求在任何代码被写出之前就已经被充分澄清（摩擦点 #1），设计方案在实现之前就已经通过了专家审查。

### 3.4 Evidence-Based Quality（基于证据的质量）

每道 Gate 都需要证据文件。子 Agent 的审查是强制性的，不是可选的。审查文件存放在 `.tad/evidence/reviews/`。

不接受"我检查过了"这种口头声明——必须有可追溯的审查记录。

---

## 四、架构模型

### 4.1 三角形模型

```
              Human
          (Value Guardian)
               /\
              /  \
             /    \
            /      \
      Agent A ───── Agent B
     (Solution)   (Execution)
      Terminal 1   Terminal 2
```

三个角色，各有明确职责：

**Human（价值守护者）**：
- 定义什么是有价值的
- 在 Alex 和 Blake 之间桥接信息
- 在冲突时做决策
- 验证最终交付

**Agent A — Alex（解决方案负责人）**：
- 通过苏格拉底式提问挖掘需求
- 设计技术方案并通过专家审查
- 创建 Handoff 文档给 Blake
- 负责 Gate 1（需求清晰度）和 Gate 2（设计完整度）
- 最终验收 Blake 的实现（Gate 4）
- **绝对不写实现代码**

**Agent B — Blake（执行大师）**：
- 严格按照 Handoff 实现
- 通过 Ralph Loop 自动迭代质量
- 负责 Gate 3（实现质量）
- 生成完成报告给 Alex 审查
- **不独立做设计决策**

### 4.2 四道质量门（Quality Gates）

| Gate | 名称 | 负责人 | 检查内容 |
|------|------|--------|---------|
| Gate 1 | 需求清晰度 | Alex | 需求是否充分理解，是否有遗漏 |
| Gate 2 | 设计完整度 | Alex | 方案是否经过专家审查，是否有 P0 问题 |
| Gate 3 v2 | 实现 + 集成质量 | Blake | 代码是否通过 build/test/lint、是否通过专家审查 |
| Gate 4 v2 | 验收 + 归档 | Alex | 业务需求是否满足、用户是否接受 |

Gate 是**强制检查点**，不可跳过。不通过就阻塞，必须修复后重新检查。

### 4.3 Handoff 机制

Handoff 是 Alex 和 Blake 之间的**唯一正式通信协议**。它是一份结构化的 Markdown 文档，包含：
- 任务描述和上下文
- 技术设计方案
- 验收标准（Acceptance Criteria）
- 文件清单和修改范围
- 风险和注意事项

生命周期：Alex 创建 → 人类传递 → Blake 读取执行 → Blake 完成后报告 → Alex 验收 → 归档到 `.tad/archive/handoffs/`

### 4.4 Ralph Loop（v2.0 核心机制）

Ralph Loop 是 Blake 的**迭代质量循环**，是 v2.0 引入的最重要的机制创新。

```
  ┌──────────────────────────┐
  │     Layer 1: Self-Check  │
  │  build → test → lint     │
  │  (最多 15 次, 断路器)      │
  └─────────┬────────────────┘
            │ ALL PASS
  ┌─────────▼────────────────┐
  │     Layer 2: Expert      │
  │  code-reviewer (阻塞)     │
  │  → test-runner           │
  │  → security-auditor      │  (并行)
  │  → performance-optimizer │
  │  (最多 5 轮, 升级到 Alex) │
  └──────────────────────────┘
```

核心原则：
- **专家说 PASS 才算完成**，不是 Blake 自己判断自己
- **断路器**：同一错误连续 3 次 → 自动升级到人类介入
- **状态持久化**：每层完成后 checkpoint，支持崩溃恢复
- **分层关注**：Layer 1 做廉价/快速检查，Layer 2 做昂贵/深度审查

---

## 五、版本演进全史

### v1.0（2025-09-26）— 框架诞生
- 定义三角形模型（Human + Alex + Blake）
- 基础的 4-Gate 质量系统
- Handoff 文档协议
- 基本的 slash command 系统

### v1.1（2025-09-28）— BMAD 强化
- 引入 BMAD（Build Measure Analyze Decide）强制机制
- 增强 Agent 角色定义

### v1.2（2025-09-30）— MCP 集成
- 集成 MCP（Model Context Protocol）工具支持
- Agent 驱动的 MCP 安装
- 强制子 Agent 调用

### v1.3（2025-11-26）— 基于证据的开发
- **里程碑**：从"口头声明"到"必须有证据文件"
- 证据目录系统（`.tad/evidence/`）
- Gate 通过需要审查文件作为证据

### v1.4（2026-01-06）— 知识系统
- 主动技术研究协议
- 项目知识系统（`.tad/project-knowledge/`）
- 技能自动匹配机制（43 个技能）
- 文档门户结构化

### v1.5（2026-01-07）— 框架与数据分离
- 框架文件和用户数据分离
- 智能升级脚本（保留用户数据）
- 统一安装/升级命令

### v1.8（2026-01-25）— Human-in-the-Loop
- **里程碑**：明确定义 Terminal Isolation 规则
- 苏格拉底式提问协议（Alex 在写 Handoff 前必须提问）
- 知识评估（Knowledge Assessment）加入 Gate

### v2.0（2026-01-26）— Ralph Loop Fusion ★
- **重大架构变更**：引入 Ralph Loop 两层质量循环
- Gate 3 扩展（吸收旧 Gate 4 的技术部分）
- Gate 4 简化（纯业务验收）
- 专家驱动的退出条件
- 断路器和升级机制
- 状态持久化和崩溃恢复

### v2.1（2026-01-26）— 平台无关架构
- 8 个 P0 平台无关技能（testing, code-review, security 等）
- 多平台支持（Claude Code + Codex CLI + Gemini CLI）
- YAML frontmatter 技能格式

### v2.1.1（2026-01-31）— 文档生命周期
- `/tad-maintain` 命令（CHECK/SYNC/FULL 三模式）
- Handoff 过期检测（年龄 + 话题交叉引用）
- 自动触发文档健康检查

### v2.2（2026-01-31）— 模块化配置
- **架构变更**：2398 行单体 config.yaml 拆分为 6 个聚焦模块
- 双向消息协议（Alex ↔ 人类 ↔ Blake 的结构化消息）
- 自适应复杂度评估（Small/Medium/Large → Full/Standard/Light/Skip TAD）

### v2.2.1（2026-01-31）— 配对测试
- 跨工具 E2E 测试协议（TAD CLI ↔ Claude Desktop）
- TEST_BRIEF.md 8 节模板
- `Beneficial Friction` 哲学正式写入 README

### 后续演进（2026-02）：
- **认知防火墙**（v2.2.1+）：3 支柱人类赋能系统 — 研究优先、决策透明、致命操作保护
- **Agent Teams**（实验性）：并行审查和实现模式
- **Design Playground v2**：独立 `/playground` 命令，前端/UI 设计探索
- **多会话配对测试**：从单例升级为目录隔离 + manifest 管理
- **CLAUDE.md 路由架构**：657 行瘦身到 109 行（路由器模式）
- **Intent Router**：Alex 支持多模式切换（*analyze / *bug / *discuss / *idea / *learn）
- **Idea Pool**：结构化想法存储和生命周期管理
- **ROADMAP.md**：战略级聚合视图

### v2.3（2026-02-17）— 多平台清理
- 移除 Codex/Gemini 完整运行时（~1100 行，20 个文件）
- Codex/Gemini 重新定位为通过 Handoff 机制使用的专用工具

### v2.4（2026-02-17）— 发布与同步 ★（当前版本）
- `*publish`：GitHub 发布工作流（版本检查 + push + tag）
- `*sync`：跨项目同步（注册表 + 弃用 + CLAUDE.md 合并策略）
- 已同步到 3 个活跃项目

---

## 六、当前能力全景

### 6.1 Alex 能做什么（解决方案端）

| 模式 | 触发 | 说明 |
|------|------|------|
| 分析模式 | `*analyze` | 新功能设计的完整流程：苏格拉底提问 → 设计 → 专家审查 → Handoff |
| Bug 诊断 | `*bug` | 快速诊断 → 生成 mini-handoff 给 Blake |
| 讨论模式 | `*discuss` | 产品方向讨论，不产出 Handoff |
| 想法捕获 | `*idea` | 结构化存储想法到 `.tad/active/ideas/` |
| 教学模式 | `*learn` | 苏格拉底式教学，帮助理解技术概念 |
| 设计探索 | `*playground` | 前端/UI 可视化设计探索 |
| 状态总览 | `*status` | 4 层全景扫描（epics / handoffs / ideas / next） |
| 发布 | `*publish` | GitHub 版本发布（检查 + push + tag） |
| 同步 | `*sync` | 跨项目框架同步 |

### 6.2 Blake 能做什么（执行端）

| 命令 | 说明 |
|------|------|
| `*develop` | 启动 Ralph Loop 完整开发周期（Layer 1 + Layer 2） |
| `*layer1` | 仅运行自检（build/test/lint） |
| `*layer2` | 仅运行专家审查 |
| `*gate 3` | 执行 Gate 3 v2 技术质量门 |
| `*ralph-status` | 查看当前 Ralph Loop 状态 |
| `*ralph-resume` | 从 checkpoint 恢复 |
| `*complete` | 生成完成报告 |

### 6.3 系统能力

- **8 个 P0 技能**：testing, code-review, security-audit, performance, ux-review, architecture, api-design, debugging
- **自适应复杂度**：根据任务大小自动建议流程深度
- **Epic 管理**：多阶段任务的跟踪和约束（同时只能有 1 个活跃阶段）
- **知识积累**：通过 Gate 自动捕获项目知识，启动时自动加载
- **文档健康**：`/tad-maintain` 定期检查文档一致性和过期
- **认知防火墙**：研究优先协议、致命操作保护、风险翻译
- **跨项目同步**：通过 `*sync` 将框架更新推送到注册的活跃项目

---

## 七、项目结构

```
TAD/
├── .tad/                          # 框架核心（2.1MB）
│   ├── config.yaml                # 主配置索引（模块化）
│   ├── config-agents.yaml         # Agent 定义、三角模型
│   ├── config-quality.yaml        # 质量门、证据、子 Agent 强制
│   ├── config-workflow.yaml       # 文档管理、Epic 生命周期
│   ├── config-execution.yaml      # Ralph Loop、发布管理
│   ├── config-platform.yaml       # MCP 工具集成
│   ├── config-cognitive.yaml      # 认知防火墙
│   ├── version.txt                # 当前版本号
│   ├── skills/                    # 8 个 P0 平台无关技能
│   ├── ralph-config/              # Ralph Loop 配置
│   ├── templates/                 # 20+ 模板（handoff, completion, epic 等）
│   ├── active/                    # 活跃工作区（handoffs, epics, ideas）
│   ├── archive/                   # 归档区（23 个历史 handoffs）
│   ├── evidence/                  # 质量证据（审查、指标、模式）
│   └── project-knowledge/         # 项目知识库（自动加载）
│
├── .claude/commands/              # 20 个 slash command 定义
│   ├── tad-alex.md (2395 行)      # Alex 完整协议
│   ├── tad-blake.md (850 行)      # Blake + Ralph Loop
│   ├── tad-gate.md (595 行)       # 质量门执行
│   ├── playground.md (474 行)     # 设计探索
│   └── ...                        # 其他命令
│
├── CLAUDE.md                      # 项目规则路由（109 行）
├── PROJECT_CONTEXT.md             # 当前状态
├── NEXT.md                        # 下一步行动
├── ROADMAP.md                     # 战略路线图
├── CHANGELOG.md                   # 版本变更日志
├── README.md                      # 主文档
├── tad.sh                         # 一键安装/升级脚本
└── docs/                          # 文档门户
```

---

## 八、实际效果与数据

### 8.1 使用规模
- **100 次 git 提交**，从 v1.0 到 v2.4.0
- **23 个已完成的 Handoff**（归档在 `.tad/archive/handoffs/`）
- **13 条架构知识**被自动积累
- **3 个活跃项目**已同步部署（menu-snap、my-openclaw-agents、O1 for builder）
- **1 个完整的 5 阶段 Epic** 被成功执行和归档

### 8.2 证据系统
- **10+ 份专家审查报告**存档
- **4 个任务的验收测试**记录
- **3 个任务的 Ralph Loop 状态**追踪
- 成功/失败模式文档化

### 8.3 框架自举
TAD 框架本身就是用 TAD 方法论开发的。从 v2.0 开始，每个功能都经过完整的 TAD 流程：
- Alex 设计 + 苏格拉底提问 + 专家审查
- Handoff 传递
- Blake 实现 + Ralph Loop
- Gate 3 + Gate 4 验收
- 知识记录

这意味着 TAD 的每一个迭代都在验证和改进自身的流程。

### 8.4 典型工作流示例

以 "Design Playground v2" 功能为例：
1. Alex 分析需求，发现需要从嵌入式子阶段提取为独立命令
2. 苏格拉底提问确认设计方向（全页 HTML 生成 vs token 策展）
3. 创建 Handoff，专家审查通过
4. Blake 实现 475 行独立命令 + 32 种设计风格库 + 模板
5. Ralph Loop：Layer 1 自检通过 → Layer 2 code-reviewer 发现 3 个 P0 并修复 → ux-expert 通过
6. Gate 3 通过，17/17 验收标准验证通过
7. Gate 4 Alex 验收归档

---

## 九、设计决策记录

以下是 TAD 演进中的关键设计决策，解释了"为什么这样做"：

### 为什么用两个 Agent 而不是一个？
一个 Agent 自己设计、自己实现、自己测试 = 自己验证自己。两个 Agent + Terminal Isolation 确保了"实现者不是设计者"的制衡。

### 为什么 Handoff 是 Markdown 而不是 JSON/YAML？
Handoff 需要人类阅读和传递。Markdown 对人类最友好，同时对 AI 也足够结构化。

### 为什么 Ralph Loop 用两层而不是一层？
Layer 1（自检）快而便宜，Layer 2（专家审查）慢而昂贵。分层让大部分问题在 Layer 1 就被捕获，只有真正需要深度审查的才进入 Layer 2。

### 为什么 Gate 3 和 Gate 4 在 v2.0 重新划分？
v1.x 中 Gate 3（实现）和 Gate 4（集成）由不同 Agent 负责，导致技术问题在 Gate 4 才被发现（太晚了）。v2.0 把所有技术检查集中到 Gate 3（Blake），Gate 4 简化为纯业务验收（Alex）。

### 为什么 CLAUDE.md 从 657 行瘦身到 109 行？
CLAUDE.md 每次 Agent 启动都会被加载。657 行中大部分是具体协议，应该放在各个命令文件中按需加载。109 行的路由架构只告诉 Agent "什么时候做什么"，具体"怎么做"在命令文件中。

### 为什么移除 Codex/Gemini 完整运行时？
维护三个平台的完整运行时（~1100 行额外代码）不划算。Codex/Gemini 通过现有的 Handoff 机制作为专用工具使用更简洁。

---

## 十、当前状态与下一步

### 当前状态（2026-02-18）
- **版本**：v2.4.0
- **活跃工作**：无
- **活跃 Handoff**：0
- **活跃 Epic**：0
- **已部署项目**：3（menu-snap、my-openclaw-agents、O1 for builder）

### 待验证项
- 在下次 TAD 发布时使用 `*publish` 和 `*sync` 验证新工作流
- 在真实项目中验证认知防火墙效果
- 在 Full/Standard TAD 任务中测试 Agent Teams
- 在真实 E2E 测试周期验证多会话配对测试
- 考虑将 config-platform.yaml 重命名为 config-mcp.yaml

### 战略方向
1. **Alex 灵活性**：继续增强多模式交互（已完成 5/5 阶段）
2. **质量系统**：稳定现有 4-Gate + Ralph Loop，验证认知防火墙和 Agent Teams
3. **开发者体验**：迭代 Playground、配对测试、知识管理

---

## 十一、关键术语表

| 术语 | 含义 |
|------|------|
| TAD | Triangle Agent Development，三角 Agent 开发方法论 |
| Alex | Agent A，解决方案负责人，负责设计和验收 |
| Blake | Agent B，执行大师，负责实现和技术质量 |
| Handoff | Alex 给 Blake 的结构化设计文档 |
| Gate | 质量门，强制检查点 |
| Ralph Loop | Blake 的两层迭代质量循环（自检 + 专家审查） |
| Beneficial Friction | 有益摩擦，TAD 的核心设计哲学 |
| Terminal Isolation | 终端隔离，Alex 和 Blake 必须在不同 terminal 运行 |
| Knowledge Assessment | 知识评估，Gate 通过后记录学到的项目知识 |
| Epic | 多阶段任务的跟踪单元 |
| Intent Router | Alex 的多模式切换路由器 |
| Adaptive Complexity | 自适应复杂度，根据任务大小自动建议流程深度 |

---

*本文档由 TAD 框架项目自动生成，供外部知识库使用。*
