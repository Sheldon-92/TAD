---
task_id: TASK-20260915-CLAUDE-DECOUPLE-DESIGN
task_type: docs            # audit + decision brief; no implementation in this handoff
express: false
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: SUPERSEDED                # direction ratified as "完全移除"; see HANDOFF-2026-09-15-claude-removal-plan.md
superseded_by: HANDOFF-2026-09-15-claude-removal-plan.md
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-2026-09-15-claude-decouple-design

> ⚠️ **SUPERSEDED 2026-09-15.** 人已拍板方向为「**彻底移除** Claude 路径」（design §3 的 D1-a/D1-b/D2-a/D3-a 等选项不再采纳）。本决策简报的选项空间已关闭，执行方案固化为
> **`.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md`**。本文件仅作审计/依据保留（§2 的耦合清单与 file:line 证据仍有效），**不要**据此交给 Blake。

**Task ID**: `TASK-20260915-CLAUDE-DECOUPLE-DESIGN`
**From:** Alex (Terminal 1)
**To:** **Human (product owner)** — this is a decision brief, **not** a Blake implementation handoff
**Created**: 2026-09-15
**Status**: `SUPERSEDED` → `HANDOFF-2026-09-15-claude-removal-plan.md` (direction: 完全移除, not 废弃/对等)
**Epic:** N/A (candidate: new Epic `EPIC-20260915-harness-decouple`) — human to decide
**Mode**: **design only. No implementation. No file deletion. No commit / push / tag / release.**
**Supersedes / relates**: NotebookLM whole-layer deprecation (`HANDOFF-2026-09-15-notebooklm-deprecation`, shipped v2.44.6) is the **pattern reference** for "deprecate, don't delete".
**Channel**: Alex ≠ Blake. This brief is not executable; Gate 2 expert review is deferred until the human picks an option set (§10).

> ⚠️ **Why this is not a Blake handoff.** The user has ratified the *direction* ("TAD 与 Claude Code 解绑"), but the *design space is still open* (§3 has 6 decisions). TAD rule: "重要技术决策必须由人拍板". Handing an undecided design to Blake would violate Alex≠Blake. After §3 is answered, Alex turns the chosen options into an executable handoff that passes dual Gate 2.

---

## 🔴 Gate 2: Design Completeness — **DEFERRED (by design)**

**执行时间**: 2026-09-15 (audit + options only)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ⚠️ | Coupling inventory is complete and verified; **target architecture is a set of open options**, not a single design. |
| Components Specified | ❌ | Cannot be specified until §3 (remove/deprecate, SSOT location, platform matrix) is decided. |
| Functions Verified | ✅ | All cited paths/lines exist at HEAD (`c32bde27`, v2.44.6) and were re-verified by an adversarial pass. |
| Data Flow Mapped | ✅ | SSOT direction, install targets, and model-spawn path mapped in §2. |

**Gate 2 结果**: ⏸️ **DEFERRED** — dual expert review will run on the *chosen* executable handoff, not on this options brief.

**Alex确认**: 本文件的职责是把"绑在哪、绑多深、解绑的代价"讲清，并把真正需要人来定的选择摊开；它不替人做选择，也不替 Blake 下任务。

---

## MQ (human lock)

1. **User**: TAD 框架维护者（grokbox 侧）。公开仓库 `github.com/Sheldon-92/TAD`，npm `tad-framework`。
2. **Problem**: 用户已拍板——TAD 与 Claude Code（含 Claude 模型）解绑；理由：已有足够好用的替代（OpenCode / Codex / Cursor 等），Claude Code 没有不可替代性。现状是 Claude Code 在结构上是 **主平台 + skill 唯一源**，不是对等 target 之一。
3. **Scope (this task only)**: 全面审计绑定面 + 输出解绑方案设计（选项 + 分期 + 版本 + 风险/回滚）。**只出设计，不进本版。**
4. **Out**: 不实现、不删除、不迁移、不 commit/push/tag/release；不动 `docs/pm/`；不动历史记录（CHANGELOG 旧条目 / evidence / archive）；不改 `research/`；不替人拍板 §3。
5. **Success**: 一个人类读者读完本文件后，能对 §3 的六个决策**逐条作答**，且知道每个选择对应的 blast radius 与版本含义。
6. **Teeth**: Alex ≠ Blake；不删除；SAFETY 边界（安装器数据安全、release-verify 源方向）显式标出；关键结论有 file:line 证据。

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS（本 lock + §9）。

---

## 1. Task Overview

### 1.1 What this is
一份**解绑审计 + 决策简报**。它回答三件事：
1. TAD 到底"绑"在 Claude Code 的哪里？（§2，逐条证据）
2. 每处绑定"拆"的代价是什么？（§6 blast radius）
3. 有哪些拆法，各自代价/收益/版本含义？（§3-§5）

### 1.2 Intent Statement
**真正的问题**：TAD 的核心资产（两角色协议、四关、handoff、skill 库）绝大多数字节上与 Claude 无关，但它们**物理上住在 `.claude/` 里、并由 Claude Code 作为主平台驱动**。这才是"不可替代性"错觉的来源——不是模型，是**结构性单点**。

**不是要做的**：
- ❌ 不是删掉 `.claude/skills/`（那是 skill 库本体，删了等于删源）。
- ❌ 不是"换一个模型"（`claude_websearch`/`claude_code_reviewer` 根本不是模型绑定，见 §2.C）。
- ❌ 不是把 TAD 做成 OpenCode 独占（目标是对等多平台，不是换一个单点）。

---

## 2. Audit Findings — 绑在哪，绑多深

> 全部结论在 HEAD `c32bde27` (v2.44.6) 核实；粗体结论经独立对抗性复核（§Appendix-verify）。

### 2.A 结构性绑定：`.claude/` 是**主平台 + skill 唯一源**（真绑定，最深）

| 绑定 | 证据 (file:line) | 性质 |
|------|------------------|------|
| skill 唯一源方向固定 Claude→Codex | `tad.sh:1162-1164`（始终读 `$src/.claude/skills/*/`）；`tad.sh:2488-2492`（`both` = claude primary + agents secondary；只有 codex 把 target 设成 `.agents/skills`）；`release-verify.sh:102-104`（"`.claude/skills` as the SOLE source of truth, direction FIXED Claude→Codex"） | **SSOT 单点** |
| 平台矩阵 / 默认值 | `tad.sh:514 KNOWN_PLATFORMS="claude-code codex both"`；`tad.sh:533` 无参默认 `both`；`bin/tad-install.mjs:153` 同默认；`.tad/platform-codes.yaml:6-11` | **Claude 为默认主平台** |
| hooks 注册 | `.claude/settings.json`（7 条 hook：PreCompact / SessionStart / PreToolUse×3 / PostToolUse×2），`tad.sh:1209-1217` 逐字复制（非生成）；`.codex/hooks.json` 才是生成的（`tad.sh:1355-1393`） | **Claude 独有** |
| Workflow 运行时 | `.claude/workflows/*.workflow.js`（10 个，~150KB）；`detect-platform.sh:23` 以其存在作为 "workflow" 后端信号 | **Claude 独有** |
| Claude-only 目录面 | `.claude/agents/`（2）、`.claude/rules/`（1）、`.claude/commands/`（stub）、`.claude/projects/`（machine-local memory）、`settings.local.json`（`autoMemoryDirectory`）；`.agents/` **无**对应面 | **Claude 独有** |
| 记忆重定向 | `memory-redirect.sh:11` 把 auto-memory 指向 `~/.claude/projects/<slug>/memory` | **Claude 独有** |
| 打包/忽略 | `package.json:68` `files` 含 `.claude/`；`package.json:15` keywords `claude-code`；`.gitignore:10,13,19,78` | 分发面 |

**关键点**：`.agents/skills/` 今天只是 `.claude/skills/` 的**逐字节派生镜像**（555/555 相同，仅 `.claude/skills/local/` 两个 gitignore 占位文件不同）。所以"删 `.claude/`"在结构上等于"删源"——**解绑必须先反转 SSOT，而不是删除**。

### 2.B 模型绑定：比表面看起来大（对抗复核修正）

thin-PM 初筛只点了两处命名；核实后**真实 Claude 模型绑定至少 6 类**：

| 绑定 | 证据 | 是否真实调用 Claude |
|------|------|---------------------|
| Gate 3 审查 agent | `.claude/agents/security-auditor.md:4 model: opus`；`.claude/agents/spec-compliance-reviewer.md:4 model: sonnet` | ✅ 真 model 选型 |
| 文件写前策略 hook | `.claude/settings.json:36 "model": "claude-haiku-4-5-20251001"`（PreToolUse Write\|Edit，`type: prompt`）| ✅ **运行时真调 Claude**（且策略是"全部 ALLOW"，纯开销）|
| Workflow 脚本 | `epic-audit.workflow.js:80,111,136`（haiku/sonnet）；`gate-review.workflow.js:171,212`（sonnet）；`loop-discover.workflow.js:80`（haiku）| ✅ 真 model 选型 |
| 配置 | `.tad/config-agents.yaml:326 teammate_model: "sonnet"  # Claude-Code 值` | ✅ 真 model 选型 |
| YOLO harness | `.tad/scripts/yolo-harness-profiles.json:20 claude-sonnet-4-20250514`，profile `claude-code` = executable `claude` / provider `anthropic`；`.tad/scripts/yolo-harness-runner.mjs:625` spawn；`.tad/scripts/phase2-pair-driver.mjs:773,797` 调 `claude` 二进制 | ✅ **真 spawn `claude` CLI**（实验/判定路径）|
| 文档 | `.tad/sub-agents/README.md:12-16` 记录 Opus 档子代理 | 说明性 |

**注**：`.claude/skills/ai-prompt-engineering/references/claude.md` 是**关于 Claude 模型的领域知识**（capability pack 内容），**不是绑定**，应保留。

### 2.C 命名标签：`claude_websearch` / `claude_code_reviewer` —— **是历史命名，不是真调 Claude**

| 标识 | 定义位置 | 真实机制 | 结论 |
|------|----------|----------|------|
| `claude_websearch` | `.tad/config-workflow.yaml:791`（`fallback_chains.research.secondary`）；另在 `capabilities.yaml` 作 `replaced_by` 字符串 | **harness 原生 WebSearch/WebFetch**（`alex/SKILL.md:709` "Degrade directly to WebSearch"）；无 CLI/API | **标签** |
| `claude_code_reviewer` | `.tad/config-workflow.yaml:796`（全仓仅此一处）| **harness 无关的 `code-reviewer` 子代理**（`subagent_type: code-reviewer`；Codex 草案 TOML 映射到 `gpt-5.5`）| **标签** |

**加强结论**：整个 `fallback_chains` 块**没有任何运行时读者**——没有脚本解析它（仅 `config-workflow.yaml` 自述 + 文档引用）。仓库自己的审查员早已记录这是 orphan name（`.tad/evidence/reviews/.../backend-architect.md:20` P1-3、`code-reviewer.md:33-34` P2-2/P2-3）。

> **直接回答用户的问题**：`claude_websearch` / `claude_code_reviewer` **不是真调 Claude，是历史命名**。改名的 blast radius 极低（无消费者）。

### 2.D 文档双写 / 公共门面（数量大、风险低）

- **`.claude/` 字面引用**：1,215 行 / 220 文件（排除 evidence/archive/git）。集中区：`tad.sh`(44)、`release-verify.sh`(35)、`.tad/capability-packs/*/install.sh`（各 ~7）、`.tad/tests/**`、docs。
- **"Claude Code: X / Codex: Y" 双写分支**：**恰好 12 文件 = 6 源 × 2 镜像**（`alex/SKILL.md`×3 行、`blake/SKILL.md`×3 行、`alex/references/{bug,handoff-creation,idea,learn}-path-protocol.md` 各 1 行）。
- **公共文档**："Claude Code" 提及：`docs/`(81)、`.tad/guides/`(18)、`INSTALLATION_GUIDE.md`(11)、`README.md`(9)；`docs/MULTI-PLATFORM.md` 把 TAD 描述为 "two first-class runtimes: Claude Code and Codex"。
- `runtime-compat/claude-code.md` 是 Claude 的兼容台账（保留即可，它本来就是"某 target 的台账"）。

### 2.E 下游 / 公共面

- 仓库公开 + npm 分发；默认 `--platform both`（README:79 推荐）；`--platform claude-code` 仍是合法值（`tad.sh:514`）。
- **升级安全性（对抗复核确认）**：现有外部用户的 `.claude/skills` **不会被升级自动删除**——
  - `.tad/deprecation.yaml` 只列 `.claude/commands/*.md`，**不列** `.claude/skills`；
  - 平台切换显式保留旧树（`tad.sh:1154-1157` "left intact — remove manually"）；
  - rollback 只在目录**安装前不存在**时才删（`tad.sh:1868` + `:2050-2060`）。
- **OpenCode 现状 = updater-only**：`.opencode/` 仅 1 个 `commands/tad-update.md`，自述"does not provide Alex/Blake/Gate roles, hooks, or gate parity"（`.opencode/commands/tad-update.md`）。**没有任何 OpenCode skill 加载契约**——把 OpenCode 升为一等 target 本身是一个前置小项目，不是改个字符串。

### 2.F thin-PM 初筛核实结论

| 初筛项 | 核实 |
|--------|------|
| `.claude/` 整套（settings.json hooks / agents / skills / rules / workflows / commands）| ✅ 成立，且比初筛更重——`.claude/skills` 是**唯一源**，非普通 adapter |
| `tad.sh` `--platform` 三分支 + `.claude/skills` 安装目标 | ✅ 成立（`KNOWN_PLATFORMS` 514、默认 both 533、target 2492）|
| SKILL 文档 "Claude Code / Codex" 平台双写 | ✅ 成立但小：恰好 12 文件 |
| `claude_websearch` 是 secondary | ⚠️ 是 config 值，但**无运行时读者**；机制=原生 WebSearch，非 Claude |
| `claude_code_reviewer` 是 code_review primary | ⚠️ 是 config 值，**无运行时读者**；机制=`code-reviewer` 子代理，非 Claude |
| 下游公共仓库依赖面 | ✅ 成立；升级不删 `.claude`，deprecate-not-delete 安全 |

---

## 3. Key Decisions (human must answer — NO auto-pick)

> 每项列出选项与代价。Alex 的建议在 §5，但请先独立判断。

### D1. 移除 vs 废弃（核心）
- **D1-a 废弃不删（NotebookLM 模式）**：Claude 面全部标 DEPRECATED、文件保留、默认不再走 Claude。`deprecation.yaml` 不登记（它只记"被删文件"）。
- **D1-b 保留但对等**：不标废弃，把 Claude 降为与 Codex 并列的 target 之一。
- **D1-c 移除**：直接删 `.claude/`（含 skill 源）→ **Alex 不建议**：等于删 skill 库源，且破坏升级路径。
- ⚠️ 注意：即使选 D1-a/D1-b，**SSOT 也必须反转**（D2）——否则"废弃"只是话术。

### D2. 中立的 skill 源放哪（决定解绑是否真实）
- **D2-a 维持 `.claude/skills` 为源，仅改语义**：最便宜，但名字仍绑 Claude，未真解绑。
- **D2-b 反转为 `.agents/skills` 为源，`.claude/skills` 变派生**：中等；`.agents` 语义较中性（"agents"）。
- **D2-c 新建中立源（如 `.tad/skill-library/` 或顶层 `skills/`），所有 harness 目录皆为派生 target**：最干净，blast radius 最大（`release-verify.sh`、`tad.sh`、`package.json`、deprecation、`.gitignore`、docs 同批改）。

### D3. 平台矩阵如何收敛
- **D3-a 最小**：`claude-code | codex | both` → 加 `opencode`；默认 `both` 改为中性（如 `codex`）。
- **D3-b 原则化**：`codex | opencode | claude-code(legacy) | all | none`；默认 neutral；`both` 重命名为 `all`。
- ⚠️ **前置阻塞**：OpenCode 目前无 skill 加载契约（§2.E）。选 D3 任一含 `opencode` 的方案前，必须先设计 OpenCode 如何加载 Alex/Blake SKILL（这是独立前置单）。
- 兼容：`claude-code` 建议**保留为 legacy 别名**，不删除（保护现有用户）。

### D4. 替代路径
- **websearch**：`claude_websearch` → `websearch`（或 `native_websearch`），机制不变（原生 WebSearch/WebFetch）；补 `capabilities.yaml` 目录项。
- **code review primary**：`claude_code_reviewer` → `code_reviewer`（映射到各 harness 的 reviewer；Codex 草案 `gpt-5.5` 已存在）；补目录项 + **补 secondary**（当前缺失）。
- **模型 pin**：从 agent/workflow/config 中移除硬编码，或改为**按 harness 的 model map**（`config-agents.yaml teammate_model` → per-harness 表）。
- **haiku hook**：`.claude/settings.json` 的 `type: prompt` hook 策略是"全部 ALLOW"，**改为纯 command hook 或删除**（去掉运行时 Claude 模型调用）。

### D5. 文档双写如何合并
- **D5-a 中性化**：12 个双写文件改为中性表述 + 附录列出真正因平台而异的部分（hooks 安装路径 / skill 目录）。
- **D5-b 保持双写，仅补 OpenCode 分支**：三写，维护负担更大。
- 公共文档（README / INSTALLATION_GUIDE / MULTI-PLATFORM / CODEX-USER-GUIDE）默认平台叙述需与新矩阵一致。

### D6. 分期与目标版本
见 §4。

---

## 4. Phasing & Version (recommendation, human decides)

### 4.1 分期
**Alex 建议：两阶段，先小后大**（与用户"CLI 先行"的建议顺序相反，理由如下）：

- **Phase 1 — 模型 / 标签解绑**（小、低风险、可独立验证）
  - 去 Claude 模型 pin（§2.B 的 6 类）、改名两个标签、去掉 haiku prompt hook、补 `capabilities.yaml`。
  - **不与结构解绑耦合**，因其文件在 D1-a 下都会保留，不会白做。
- **Phase 2 — 结构解绑**（大、高风险）
  - D2（SSOT 反转）+ D3（平台矩阵/默认）+ D5（文档）+ installer/release-verify 同批。

**为什么建议模型先行而非 CLI 先行**：模型/标签是**廉价且独立**的一刀（无运行时消费者、无安装面），先落地可立即消除"真调 Claude"的残余（haiku hook + opus/sonnet pin）；而结构解绑是高风险单，值得单独设计、单独 Gate 2、单独回滚。若人坚持 CLI 先行也可（Phase 2 先行），但两阶段都应**各自过一个完整 Gate**，不要塞进同一 commit。

**前置（Phase 0，若目标含 OpenCode）**：OpenCode skill 加载契约设计单（阻塞 D3）。

### 4.2 版本
| 情形 | 版本 | 理由 |
|------|------|------|
| 仅废弃 + 改名，**不改默认平台**、不加新 target | **2.44.7**（patch）| 与 2.44.6 NotebookLM 同口径（retire-but-keep）|
| 改默认平台 **和/或** 加 OpenCode target **和/或** 反转 SSOT | **2.45.0**（minor）| 新增 target（additive）+ 默认行为变化（behavior change）|
| 删除 `--platform claude-code` / 删除 `.claude` | **3.0.0**（major）| breaking；Alex 不建议 |

**Alex 建议**：整体解绑按 **2.45.0**；若分阶段，则 Phase 1 = **2.44.7**，Phase 2 = **2.45.0**。不采用 2.44.7 一版装下全部（行为变化不属于 patch）。

---

## 5. Alex Recommendation (advisory only — human still decides)

- **D1 = a（废弃不删）**，但**必须配 D2 的真实 SSOT 反转**，否则是假解绑。
- **D2 = c（新建中立源）为目标，b 为过渡**——建议一次设计到 c，实施可先 b 后 c，但不要把 a 当终点。
- **D3 = b（原则化矩阵 + 中性默认 + opencode）**，`claude-code` 保留 legacy 别名；**OpenCode skill 契约列为前置阻塞**。
- **D4**：按 §3 D4 逐条改名/去 pin；haiku hook 直接删（策略本就是 ALLOW）。
- **D5 = a（中性化 + 平台附录）**。
- **D6**：模型/标签先（2.44.7），结构后（2.45.0）；各自独立 Gate。

---

## 6. Risk & Rollback (blast radius per class)

| 类别 | blast radius | 回滚 | 风险 |
|------|-------------|------|------|
| 2.A 结构 / SSOT 反转 | **全平台安装器 + release-verify + 所有下游安装**；`release-verify.sh`/`tad.sh` 同批改，否则 parity 门自相矛盾 | revert commit；安装器已有 rollback 快照机制（`tad.sh:1846+`）| **高** |
| 2.A 默认平台改变 | README/docs 承诺 `both` 的下游用户下一次升级会多装 target（**不会少装/删**）| 改回默认值；legacy 别名保 `claude-code` | 中 |
| 2.B 模型 pin 去除 | Gate 3 审查模型选择 + workflow 行为 + haiku hook | 逐文件 revert | 低 |
| 2.B `claude` CLI spawn（YOLO harness）| 仅实验/判定路径（`yolo-harness-runner.mjs`, `phase2-pair-driver.mjs`）| 保留 profile 或改 executable | 低-中 |
| 2.C 标签改名 | **无运行时消费者**；仅配置一致性 + 需补目录项 | 改回字符串 | **极低** |
| 2.D 文档 | 公共门面（README/docs），无功能 | revert | 低 |
| 2.E 下游 | 现有 `.claude/skills` 不被自动删（已核实）；风险在"用户以为会被迁移"的沟通 | 文档说明 + 保留 legacy 路径 | 低 |

**SAFETY 边界（不可顺手做）**：安装器删除逻辑、`release-verify.sh` 源方向、rollback 集合——任何改动必须按 installer-data-safety 与 release-sync 的既有 SAFETY 条目评审，不得作为"顺手清理"。

---

## 7. Downstream / Public Impact

- TAD 是公开仓库 + npm 包；默认 `both`、README 推荐 `both`。
- 现有 Claude Code 用户：升级**不会**被删 `.claude/`（§2.E）；若默认改为中性，其升级会**增装** codex/opencode，不减少 Claude。
- 需要发布一份**迁移说明**：Claude Code 从"主平台"降为"legacy target/可选"，以及 `--platform claude-code` 继续可用。
- npm `files` / keywords、`README`、`INSTALLATION_GUIDE`、`MULTI-PLATFORM` 同批更新，避免"文档说 two first-class runtimes"而矩阵已变。

---

## 8. Open Questions / Prerequisites

1. **OpenCode skill 加载契约**（阻塞任何含 `opencode` 的 D3 方案）：OpenCode 如何发现并加载 `alex`/`blake` SKILL？是否有 skill 目录约定？——需独立前置设计单。
2. **中立项是否对 glossary/历史可读**：`.claude/skills/local/`（gitignored 用户本地 skill）与 memory redirect 在反转后落在哪？需在 D2 落地设计里给迁移/映射规则。
3. **workflow 运行时**（`.claude/workflows/*.js`）在非 Claude harness 上是否有等价物？无 → 标 legacy / accepted limitation（Codex 台账已记 "no workflow equivalent"）。
4. **用户是否要保留 Claude Code 作为"仍官方支持但非默认"的 target**（影响 D1/D3 的措辞与版本）。

---

## 9. Acceptance Criteria (for THIS brief)

- [ ] AC1（pre-impl-verifiable）：本文件存在于 `.tad/active/handoffs/`，且 §2 每条粗体结论有 `file:line` 证据。
- [ ] AC2（pre-impl-verifiable）：`docs/pm/` 未被改动（`git status --porcelain docs/pm` 为空）。
- [ ] AC3（pre-impl-verifiable）：未产生任何非本文件的写操作（`git status --porcelain` 仅此文件）。
- [ ] AC4（human）：人对 §3 的 D1–D6 **逐条给出选择**。
- [ ] AC5（human）：人确认 §5 建议是否采纳，或改选。

**不在本文件验收范围**：实现、发布、任何 Claude 面的改动。

---

## 10. Next Steps (after human answers)

1. 人回答 §3 / §8 → Alex 把选择固化成可执行 handoff（候选切分：`TASK-…-decouple-phase1-model-labels`、`TASK-…-decouple-phase2-ssot-platform`，必要时前置 `TASK-…-opencode-skill-contract`）。
2. 每个可执行 handoff 过 **dual Gate 2**（建议专家：release/sync、installer data-safety、shell-portability、架构）。
3. Blake 实现 → Gate 3 → Alex Gate 4 → （若人决定）发布对应版本（2.44.7 / 2.45.0）。

---

## 11. Grounding / Verification

- **审计命令**：`rg -n --hidden --glob '!.git' --glob '!.tad/evidence' --glob '!.tad/archive' '\.claude/'` → 1,215 行 / 220 文件（明细 `/tmp/opencode/claude_refs.txt`）。
- **对抗性复核（2026-09-15，独立 agent）**：Claim1 SSOT 方向 VERIFIED；Claim2 标签无读者 VERIFIED（但仓库别处确有 `claude` spawn → §2.B）；Claim3 "只有 3 处模型绑定" **REFUTED**（实为 ≥6 类 → §2.B）；Claim4 升级不删 `.claude` VERIFIED；Claim5 OpenCode updater-only VERIFIED；Claim6 双写恰好 12 文件 VERIFIED。
- 版本/HEAD：`c32bde27` (`release: v2.44.6`)。
- 模式参照：`HANDOFF-2026-09-15-notebooklm-deprecation.md`（retire-not-delete；`deprecation.yaml` 只记删除）。

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-09-15
**Status**: AWAITING_HUMAN_DECISION
