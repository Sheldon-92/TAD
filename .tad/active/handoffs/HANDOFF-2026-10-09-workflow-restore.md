---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/workflows/claude", ".tad/agents/claude"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.2 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-09
**Project:** TAD Framework
**Task ID:** TASK-20261009-WORKFLOW-RESTORE
**Handoff Version:** 3.2.0
**Epic:** EPIC-20261008-multi-harness-restore-and-cleanup.md (Phase 3/6)
**Supersedes:** N/A
**Grounding:** `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-grounding.md`（636 行；文中 `H:<文件>:<行>` 指历史文件 `20223774^` 的行号）

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|---|---|---|
| Architecture Complete | ✅ | 不新增机制：workflow 文件放进既有的、已随框架同步的 `.tad/workflows/`，协议用 `scriptPath` 直调；安装器零改动 |
| Components Specified | ✅ | 10 个文件的翻新清单逐文件封闭列出（§4.2）；3 处调用点与 1 个坏开关的改法写死（§4.4） |
| Functions Verified | ✅ | Workflow 运行时的三项前提由 Alex 实测（§5 MQ2） |
| Data Flow Mapped | ✅ | 协议 → `scriptPath` → `.tad/workflows/claude/*.workflow.js`；非 Claude Code 走既有顺序路径 |

**Gate 2 结果**: ✅ PASS（第 1 轮双审 5 条 P0 经第 2 轮判全部 RESOLVED；第 2 轮查出的 1 处验收脚本自相矛盾已按授权处置，见 §9.2）

---

## 1. Task Overview

### 1.1 What We're Building
把 v3.0.0 删掉的 10 个 workflow 脚本和 2 个子代理定义取回来，放到不在 `.claude/` 下的仓内正本位置，翻新其中已失效的引用，并把协议里调用它们的地方改到能用。

### 1.2 Why
人反馈「编排能力丢了」。摸底发现三件事：
1. 现行协议里有 3 处在调用 workflow（YOLO 执行、锦标赛设计、空闲额度），文件不存在，调用即失败。
2. 设计协议里「按平台选编排方式」的开关判断的是 `"workflow"`，而 `detect-platform.sh` 现在返回 `claude-code|codex|none`；它的 codex 分支调的 `tournament-codex.sh` 早已删除。所以无论在哪个 harness，都只会落到「单代理设计」。
3. 仓库知识库记着「workflow 的 `args` 传不进脚本」，10 个脚本里有 3 个为此带着 KNOWN ISSUE 注释和手工改常量的绕法。Alex 2026-10-09 实测：在 `claude` 2.1.295 上，内联与 `scriptPath` 两种方式下 `args` 都能传到脚本，脚本可放在任意路径，嵌套的 `workflow()` 原语也在。**那条知识已过时。**

**成功的样子**：在 Claude Code 主会话里按协议走到 YOLO / 锦标赛 / 空闲额度时，Workflow 调用能真正启动；在 Codex、Cursor、OpenCode 或子代理里，协议明确指向既有的顺序路径而不是报错。

### 1.3 Intent Statement

**不是要做的**：
- ❌ 不改 `tad.sh`、不往任何 `.claude/` 目录投影东西。workflow 走 `scriptPath`，随 `.tad/` 既有同步到达目标项目；子代理定义向目标项目 `.claude/agents/` 的投影属 Phase 4
- ❌ 不重写 workflow 的编排逻辑。除 §4.2 清单外，一行不动（C3 机械核）
- ❌ 不新增 workflow，不把 workflow 移植到其他 harness 的原生编排面
- ❌ 不在本仓 `.claude/` 下创建任何文件
- ❌ 不运行这些 workflow——子代理调不了 Workflow 工具；真实运行由 Conductor 在 Gate 3 之后做

### 1.4 卸载记录（Offload Log）

| 时间 | 卸载项 | 依据 | 原文指针 | 回取方式 |
|---|---|---|---|---|
| 2026-10-09 | 历史 workflow / 子代理文件逐文件调研、现行引用清点 | Conductor 上下文预算 | `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-grounding.md` | 直接 Read |

---

## 📚 Project Knowledge（Blake 必读）

**MANDATORY READ：**
1. 本单 grounding 文件 A.1、A.2、B.6–B.9、D.13
2. `.tad/project-knowledge/principles.md`
3. `.tad/project-knowledge/patterns/ac-verification.md` 中五条 workflow 相关条目（grounding D.13 给出行号）
4. `.tad/project-knowledge/patterns/gate-design.md`、`pack-evaluation.md` 中提到 workflow 路径的段落（只为改路径引用）

**⚠️ Blake 必须注意的历史教训**：

1. **`node --check` 对 workflow 文件是假门**（ac-verification，2026-06-07 / 06-14）——文件有顶层 `return`/`await`，且仓根 `package.json` 是 `"type":"module"`。只用 §9.1 脚本里的包裹式检查（`sed 's/^export const meta/const meta/'` 不限行号——`handoff-review` 的 `meta` 在第 30 行、`pack-upgrade` 在第 16 行，06-14 条目里只改第 1 行的变体对这两个文件无效）。
2. **`agent({schema})` 的 schema 顶层必须是 object**（ac-verification，2026-06-08）——翻新时不得引入顶层数组 schema（C2 机械核）。
3. **Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical / AR-002**——本单要改 `blake/SKILL.md` 一处括注和三个 reference 文件。改之前逐条写明「改了哪条契约」；`blake/SKILL.md` 只许动那一处（C8 核：增删合计 2 行）。
4. **Never Hand-Write What an Existing Tool Already Does**——取回历史文件用 `git show '20223774^:<路径>'`，不凭记忆重写。
5. **AC Self-Leak from Removal Rationale**（ac-verification，2026-04-27）——C2 会在 workflow 文件里 grep `notebooklm`、`.claude/skills` 等字样；翻新时写的说明性注释里不要再出现这些字面量（要提就说「已退役的笔记本研究层」「旧 skill 树」）。
6. **Triple-Question draft rule / Alex 不写生产 workflow**（alex SKILL）——本单是恢复既有生产文件并做封闭清单内的翻新，由 Blake 执行；不属于「新写生产 workflow」。

---

## 2. Background Context

- 历史文件清单与体量：grounding A.1 表（10 个 workflow 共约 3,030 行；2 个子代理定义 124 行）。
- v3.0.0 前安装器只对 workflow 做过无校验的整目录拷贝；子代理定义**从未**分发给下游，只存在于 TAD 仓自己的 `.claude/agents/`（grounding A.4）。
- `.tad/workflows/` 与 `.tad/agents/` 两个目录现已存在、不在同步排除表里、也在 `package.json` 的 `files` 里——放进去的文件会随既有同步到达所有平台的目标项目（grounding B.7、C.11）。Alex 实测 `bash tad.sh --verify-denylist` 当前 exit 0。
- 现行协议对 6 个 workflow（`handoff-review`、`gate-review`、`epic-audit`、`pack-upgrade`、`pack-dogfood`、`loop-discover`）**没有任何调用点**（grounding B.6）。本单恢复文件但不为它们新造调用点。
- 依赖：本单须在 Phase 2 的改动提交之后开工（C8 的范围栅栏以那次提交为基线）。

---

## 3. Requirements

### 3.1 Functional
- FR1 取回并翻新 10 个 workflow → `.tad/workflows/claude/`（§4.1、§4.2）
- FR2 取回并翻新 2 个子代理定义（§4.3）
- FR3 改 3 处调用点与设计协议的平台开关（§4.4）
- FR4 订正过时知识与陈述（§4.5）
- FR5 completion 里给出逐文件「改了哪些行、对应清单哪一项」的对照表

### 3.2 Non-Functional
- NFR1 安装器、hook、其余平台行为零改动
- NFR2 每个恢复文件相对历史原件的改动限于 §4.2 的封闭清单

---

## 4. Technical Design

### 4.1 位置与取回

```
.tad/workflows/claude/<名>.workflow.js      # 10 个；<名> 见 §9.1 脚本的 NAMES
.tad/agents/claude/spec-compliance-reviewer.md
.tad/agents/claude-local/security-auditor.md
```

逐个 `git show '20223774^:.claude/workflows/<名>.workflow.js' > .tad/workflows/claude/<名>.workflow.js`（子代理同理），**先原样落盘，再按 §4.2 / §4.3 改**。另建 `.tad/workflows/README-claude.md`（≤ 25 行；**不放进 `claude/` 子目录**，该目录只放 10 个脚本）：这些文件是什么；只能在 Claude Code 主会话里经 Workflow 工具以 `scriptPath` 调用；`args` 以对象传入；验证语法用哪条包裹式检查。

### 4.2 workflow 翻新清单（封闭——清单之外一行不动）

| 项 | 规则 | 涉及文件（历史行号见 grounding A.1） |
|---|---|---|
| W-a | 旧 skill 树路径 `.claude/skills/` → `.agents/skills/`。`pack-dogfood` 对照组的禁读栅栏改为「不得读取 `.agents/skills/` 下任何文件，也不得读取任何 `.claude` 目录下的文件」——措辞里不得再出现旧树路径的字面量 | handoff-review 第 6 行（1 处）、pack-dogfood（4 处）、pack-upgrade（7 处） |
| W-b | 删除固定模型绑定：只删 `model: 'haiku'` / `model: 'sonnet'` 这一个键值（及随之多余的逗号），**同一选项对象里的其他键（`schema`、`label`、`phase`…）一个不动**。`tournament-design` 里由调用方 `args.models` 决定的 `opts.model` 保留 | epic-audit（3）、gate-review（2）、loop-discover（1）、pack-upgrade（1）、surplus-scan（2） |
| W-c | 过时的「args 传不进来」注释，逐文件处理：(1) `handoff-review` 第 42–45 行、`pack-dogfood` 第 15–17 行、`pack-upgrade` 第 29–31 行的 KNOWN ISSUE 注释段，各改为一行：`// args: injected as an object (measured 2026-10-09 on claude 2.1.295, inline and scriptPath). The DEFAULT_* constant below remains as a fallback.`；(2) `gate-review` 第 98 行那句「Workaround…dot-access」改为 `// args: injected as an object (measured 2026-10-09 on claude 2.1.295, inline and scriptPath).`，**它前一行的用法注释保留**（该文件没有常量兜底，不得写「constant below」）；(3) `handoff-review` 第 69 行、`pack-dogfood` 第 43 行、`pack-upgrade` 第 85 行这三条单行注释，只删其中的括注 `(KNOWN ISSUE guard)`。**常量兜底与「缺参即报错返回」的代码不动** | gate-review、handoff-review、pack-dogfood、pack-upgrade |
| W-d | `handoff-review` 头注释里的协议出处改为 `.agents/skills/alex/references/handoff-creation-protocol.md`。**评审报告首行的 provenance 采集段保持历史原文不动**——它带有 `claude-code` 分支，是现行协议同名段的超集，而这个 workflow 只会在 Claude Code 里运行 | handoff-review 第 6 行 |
| W-e | `pack-upgrade` 的研究阶段去掉已退役的笔记本研究层：不再调用其 CLI，不读其注册表，`RESEARCH_SCHEMA` 去掉笔记本 id 字段，`meta.description`、Plan 阶段 `detail`、文件头注释的措辞同步。研究步骤改为：先查 Local Wiki（**新增**——项目里存在 `research/scripts/search.py` 时运行 `python3 research/scripts/search.py query "<问题>" --scope wiki`），不命中或不存在则 WebSearch（**保留**——历史文件里原有的降级去向）。这是对一个 agent 提示词的小幅改写，不是纯删除。**输出契约不变**：研究 agent 仍返回 `report_path`、`findings[]`、`sources_count`、`open_questions[]`、`confidence`（Plan 阶段读其中四个）；每条承重事实带来源 URL 与取回日期，查不到的标 UNVERIFIED。研究阶段仍是**一个** `agent()` 调用；阶段数、其余 agent 调用、三个评审镜头（`correctness`/`fact-api`/`anti-slop`）、「任一反驳即先核实再修」的逻辑不动 | pack-upgrade |
| W-f | 用法注释与报错字符串里教人「按保存名调用」或指向旧运行路径的写法，改为按路径：`Workflow({scriptPath: ".tad/workflows/claude/<名>.workflow.js", args: {...}})`。已知：`tournament-design` 第 93 行的 `Usage: Workflow({name: "tournament-design", …})`；其余文件里同形态的（如 `gate-review` 第 114 行一带）逐个处理并在 completion 列出 | 凡出现处 |
| W-g | `surplus-execute` 第 142 行的嵌套调用 `workflow('yolo-epic', …)` 改为 `workflow({ scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js' }, …)`，第二个参数不动。依据见 §5：按保存名嵌套调用实测失败，按相对路径对象形式实测成功 | surplus-execute |

预期改动量（Gate 2 审查者按最小正确实现算得，C3 以此加 1 为上限）：epic-audit 3 行、gate-review 3、loop-discover 1、surplus-scan 2、surplus-execute 1、tournament-design 1、yolo-epic **0**、pack-dogfood 8、handoff-review 约 6（第 6 行＋第 42–45 行＋第 69 行）、pack-upgrade 约 70。新增行同样受限（C3）。

completion 必须列出 W-b 去掉的 9 处绑定各自在哪个调用上（原来钉的是便宜模型还是中档模型）——去掉后这些调用继承会话模型，成本会上升，这是有意的取舍，要留痕。

### 4.3 子代理定义

- `spec-compliance-reviewer.md` → `.tad/agents/claude/`：frontmatter 去掉 `model:` 行；正文「Environment facts (this repo)」一节整节替换为下面三行（标题改为 `Environment`）：
  ```
  - Run each §9.1 row's Verification Method exactly as written; do not assume the project has, or lacks, any particular test, lint or type-check command.
  - Shell dialects differ (BSD vs GNU grep/sed/stat). If a command fails for a dialect reason, report that as the row's result; do not rewrite the command.
  - Evidence lives under `.tad/evidence/` unless the handoff says otherwise.
  ```
  正文里其他提到「this repo」的句子（如休眠的 memory protocol 示例里那句）一并改为不特指 TAD 仓的说法；六步协议与报告格式不动。
- `security-auditor.md` → `.tad/agents/claude-local/`：frontmatter 去掉 `model:` 行，`skills:` 预载保留；在原第 8 行的 provenance 注释之后加一行注释：`<!-- claude-local: this definition is synced with the framework files but is NOT projected into any project's .claude/agents/ (a project-level definition would replace a user-level agent of the same name). It is kept for the TAD repository's own use. -->`
- 两个文件都不放进任何 `.claude/` 目录。注意：`.tad/agents/` 会随框架同步到所有平台的目标项目——这两个文件在那里只是普通文件，不会被任何 harness 当作已注册的子代理。

**已知空档（如实记录）**：在子代理定义被投影进 `.claude/agents/` 之前（Epic Phase 4，已在 Epic 中登记为该 Phase 的件目），Claude Code 上没有名为 `spec-compliance-reviewer` 的已注册子代理类型。Blake 协议 Layer 2 Group 0 要求调用它；这段时间按 Friction Protocol 走 `EQUIVALENT_SUBSTITUTE`：用通用子代理，并把 `.tad/agents/claude/spec-compliance-reviewer.md` 的正文作为其任务说明。本单不改 Blake 协议。

### 4.4 协议调用点

**统一判据（三处用同一句，原样写入）**：

> 仅当你自己的可用工具里有 Workflow 工具时才走 workflow（若它是延迟加载的，先用 ToolSearch 取 `select:Workflow`）；没有——Codex、Cursor、OpenCode、以及任何子代理都属于这种情况——就走下面的 WORKFLOW-FALLBACK。不要用 `detect-platform.sh` 的输出来判断：它在 Claude Code 的子代理里同样返回 `claude-code`。

**路径**：协议里的 `scriptPath` 写相对项目根的路径（实测会话在项目根时可解析）；并各加一句：「会话工作目录不是项目根时，用绝对路径 `$(git rev-parse --show-toplevel)/.tad/workflows/claude/<名>.workflow.js`」。子目录启动的情形未测。

1. `.agents/skills/alex/references/yolo-execution-protocol.md`：
   - 两处 `Workflow({ name: 'yolo-epic', args: {…} })` 改为 `Workflow({ scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js', args: {…} })`，`args` 各字段一个不少。
   - 「ALL 7 fields above are REQUIRED (except grounding_path and reviewer_count)」改为与脚本一致：必填六项 `epic_path`、`epic_slug`、`phase_number`、`phase_name`、`handoff_path`、`completion_path`（脚本第 87 行）；`grounding_path`、`reviewer_count`、`steps`、`worktree_path` 可选。
   - 既有的 `fallback:` 一行改写为：`WORKFLOW-FALLBACK: 没有 Workflow 工具时，按 references/yolo-manual-conductor-protocol.md 由 Conductor 手动派发子代理（设计审查 → 实施 → 实施审查），逐步落盘。`
   - 降级目标文件：把 `.tad/archive/protocols/yolo-execution-v1-prose.md`（`.tad/archive/` 不随框架分发，下游拿不到）**原样拷贝**为 `.agents/skills/alex/references/yolo-manual-conductor-protocol.md`，文件头加三行说明（来源、拷贝日期、「内容为 v1 文字版协议原文，其中的路径与命令名未在本单核对」）。正文不改。
2. `.agents/skills/alex/references/design-protocol.md` 第 137–156 行一带：
   - 把能力判断**提到询问用户之前**：先按统一判据判断；没有 Workflow 工具就不提供「锦标赛」选项，直接走正常 *design。
   - 有 Workflow 工具且用户选了锦标赛：`Workflow({ scriptPath: '.tad/workflows/claude/tournament-design.workflow.js', args: {task: <design_task>, prior_art: <sources>, mode: 'standard'|'deep'} })`。
   - `WORKFLOW-FALLBACK: 没有 Workflow 工具 → 不做锦标赛，按单代理 *design 继续（step2 起）。`
   - 删除 `If "workflow"`、`If "codex"`（指向已删除的 `tournament-codex.sh`）、`If "none"` 三个分支以及对 `detect-platform.sh` 的调用。第 4 步「Use the merged_design…」保留，并限定为「仅在跑了锦标赛时」。
3. `.agents/skills/surplus/SKILL.md`：`surplus-scan` 的 `name:` 调用与 `surplus-execute` 的旧路径调用都改为 `scriptPath: '.tad/workflows/claude/<名>.workflow.js'`，`args` 各字段一个不少。加：`WORKFLOW-FALLBACK: 没有 Workflow 工具 → 明说「*surplus 在本 harness 不可用」并停止；不做静默降级。`

`detect-platform.sh`：只改文件头注释里「the Claude workflow backend (.claude/workflows) was removed」这句过时陈述（改为：workflow 脚本现位于 `.tad/workflows/claude/`，经 `scriptPath` 调用；本脚本的输出**不能**用来判断是否可用 Workflow 工具）。**逻辑一个字不动**（C8 机械核）。本单之后该脚本没有调用方，如实写进注释。

### 4.5 过时陈述订正

- `.tad/project-knowledge/patterns/ac-verification.md`：「Workflow `args` Are Not Injected…」条目**原文不删不改**，在其末尾追加以 `AMENDED 2026-10-09` 起头的一段，须包含这些事实：`claude` 2.1.295；内联、`scriptPath`（会话目录下、任意绝对路径、相对项目根）四次零代理探针均收到对象形 `args`；嵌套 `workflow({scriptPath}, args)` 可用且 `args` 传到子 workflow；按保存名嵌套调用失败（报「no workflow with that name」）；顶层按保存名调用未测；原条目的绕法降为「仅在再次观察到注入失败时使用」。证据指针：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-gate-report.md`。
- `.agents/skills/alex/references/workflow-completion-trigger.md` 第 81 行一带：「All 5 current production workflows use >= 3 agents…」改为 `The threshold was validated against the original 5 workflows; ten now live in .tad/workflows/claude/ and not all of them are known to use >= 3 agents.`
- `.agents/skills/blake/SKILL.md` 第 1881 行一带的括注与 `.tad/templates/skillify-candidate-template.md` 第 8 行的同句：改为「(workflow scripts live in `.tad/workflows/claude/`, Claude Code only)」。`blake/SKILL.md` 只许改这一处。
- `.tad/project-knowledge/patterns/gate-design.md`、`pack-evaluation.md`：把 `.claude/workflows/…` 当**现行路径**引用的句子改指新位置；纯历史叙述不动。
- `docs/MULTI-PLATFORM.md` 第 189 行一带的 Workflows 那一格：改为如实（Claude Code：`.tad/workflows/claude/` 经 `scriptPath`，仅主会话；其余 harness：无，走顺序路径）。
- `.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md`：③「扩展来源」加一句 workflow 能力的声明（位置、调用方式、仅主会话、上列四项实测事实，证据指针同上）；⑥ 或残项处登记 `R-CC-7`：顶层按保存名调用与 `/workflows` 列表可见性未提供；子目录启动时相对 `scriptPath` 未测。`runtime-adapter-checklist.md` 残项总册加 `R-CC-7` 行。`.tad/runtime-compat/claude-code.md` 加一行 `workflows` surface（`verified_partial`，`last_verified` 2026-10-09）。
- `.tad/workflows/README-claude.md`（≤ 25 行）：这些脚本是什么；只在 Claude Code 主会话经 Workflow 工具以 `scriptPath` 调用；`args` 以对象传入；其中 `pack-upgrade`、`pack-dogfood`、`surplus-*`、`epic-audit` 面向 TAD 框架仓自身的维护，在一般项目里用处有限；语法校验用哪条包裹式检查。

---

## 5. 强制问题回答

### MQ1 历史代码搜索
是。全部来自 `20223774^`（grounding A.1–A.4）。决定：✅ 复用历史文件本体；❌ 不复用旧安装器的整目录拷贝。

### MQ2 前提验证（Alex 实测，2026-10-09，本会话）

| 前提 | 方法 | 结果 |
|---|---|---|
| `args` 以对象注入（内联脚本） | 零代理探针 workflow，传 `{probe, n}` | 脚本返回 `argsType: object` 及原值 |
| `args` 注入（`scriptPath`，会话目录下的文件） | 同一脚本经 `scriptPath` 重跑，传含数组的对象 | 原值返回 |
| `scriptPath` 可指向任意路径；嵌套 `workflow()` 原语存在 | 探针脚本放在会话 scratchpad，`typeof workflow` | 原值返回；`nestedWorkflowPrimitive: true` |
| 10 个历史文件通过包裹式语法检查 | §9.1 脚本的 `syn()` 对 `git show` 取出的 10 个文件 | 10/10 exit 0 |
| 历史文件的固定绑定与陈旧引用数 | grep | pins：epic-audit 3、gate-review 2、loop-discover 1、pack-upgrade 1、surplus-scan 2；陈旧引用：handoff-review 1、pack-dogfood 4、pack-upgrade 28 |
| `tad.sh --verify-denylist`、`skill-body-verify` | 实跑 | exit 0；ALL CHECKS PASSED |
| 相对项目根的 `scriptPath`（顶层） | 探针放在本仓 `.tad/evidence/…/probes/`，以相对路径调用（会话工作目录＝项目根） | 成功，`args` 原值返回 |
| 嵌套 `workflow({ scriptPath: '<相对路径>' }, args)` | 父探针以对象形式嵌套调用子探针 | 成功，子 workflow 收到 `args` 原值 |
| 嵌套按保存名 `workflow('<名>', args)` | 同一父探针 | **失败**：`no workflow with that name. Available: deep-research` —— W-g 因此是必须的 |
| 顶层按保存名 `Workflow({name:})` | **未测**（需要文件在 `.claude/workflows/` 下） | 故本单一律用 `scriptPath` |
| 会话在项目子目录启动时相对 `scriptPath` 的解析 | **未测**（Conductor 无法改变本会话工作目录） | §4.4 规定此时用绝对路径；记入 R-CC-7 |

### MQ3 / MQ4 / MQ5
不适用（无前后端、无 UI；workflow 正本单一位置，无同步）。

### MQ6
Claude Code 文档事实见 DR-20261008（workflow 与子代理的官方位置）；本单不依赖那些位置。

---

## 6. Implementation Steps
1. Step 0：确认 Phase 2 已提交（`git status --porcelain` 只剩 3 个既有无关改动与未跟踪的 `.claude/`、`.tad/active/handoffs/`）；否则停下报 Conductor
2. Step 1：§4.1 原样取回 12 个文件；跑 `bash "$ACSH" C1`（此时 C2 应失败、C3 的差异数应全为 0——记下来）
3. Step 2：§4.2 逐文件翻新；每改完一个文件跑一次 C1–C3
4. Step 3：§4.3 子代理定义
5. Step 4：§4.4 调用点；§4.5 订正
6. Step 5：`bash "$ACSH" ALL`
7. Step 6：completion 写到 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-completion.md`（含逐文件改动对照表：文件｜历史行号｜改动｜对应 W-x 项）；journal 写到 `.tad/evidence/journal/workflow-restore-2026-10-09.md`

不提交、不推送。不调用 Workflow 工具。

---

## 7. File Structure

### 7.1 Create
```
.tad/workflows/claude/{epic-audit,gate-review,handoff-review,loop-discover,pack-dogfood,pack-upgrade,surplus-execute,surplus-scan,tournament-design,yolo-epic}.workflow.js
.tad/workflows/README-claude.md
.tad/agents/claude/spec-compliance-reviewer.md
.tad/agents/claude-local/security-auditor.md
.agents/skills/alex/references/yolo-manual-conductor-protocol.md     # 自 .tad/archive/protocols/yolo-execution-v1-prose.md 原样拷贝＋三行文件头
```
### 7.2 Modify
```
.agents/skills/alex/references/yolo-execution-protocol.md
.agents/skills/alex/references/design-protocol.md
.agents/skills/alex/references/workflow-completion-trigger.md
.agents/skills/surplus/SKILL.md
.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md   # ③ 加 workflow 能力；R-CC-7
.tad/project-knowledge/patterns/runtime-adapter-checklist.md              # R-CC-7 行
.tad/runtime-compat/claude-code.md                                         # workflows 一行
.agents/skills/blake/SKILL.md                      # 仅一处括注
.tad/templates/skillify-candidate-template.md
.tad/hooks/lib/detect-platform.sh                  # 仅文件头注释
.tad/project-knowledge/patterns/ac-verification.md # 仅追加 AMENDED 段
.tad/project-knowledge/patterns/gate-design.md     # 仅现行路径引用
.tad/project-knowledge/patterns/pack-evaluation.md # 仅现行路径引用
docs/MULTI-PLATFORM.md                             # 仅 Workflows 一格
```
### 7.3 Grounded Against
- grounding 文件第 1–490 行（Alex 2026-10-09 读）
- `.agents/skills/alex/references/design-protocol.md:148-155`（经 grounding B.8 引文；Alex `grep -n` 复核 150、152 两行在位）
- `.agents/skills/alex/references/handoff-creation-protocol.md:797`（provenance 段现行文本在位）
- `.tad/workflows/`、`.tad/agents/`（`ls` 实见现有内容）；`package.json` `files`（实见含这两个目录）
- 10 个历史 workflow 文件（经 `git show` 取出并实跑语法检查与 grep）
- 新建文件：(new — will be created)

---

## 8. Testing Requirements

### 8.3 Edge Cases
- 翻新后某文件包裹式检查不过 → 回看刚改的那一项，不得改检查式
- `README.md` 落在 `.tad/workflows/claude/` 会让 C1 的文件名单对不上 → 脚本的名单按 `*.workflow.js` 之外的文件也计入；**所以 README 不放在该目录，改放 `.tad/workflows/README-claude.md`**（§4.1 以此为准）
- W-e 改写后 `pack-upgrade` 的 `agent(` 调用数须与历史一致（研究阶段仍是一个调用；C3 核）

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| Phase 2 尚未提交 | Step 0 | 停下报 Conductor | 无 | BLOCKED |
| `node` 不可用 | 语法检查 | 报 Conductor | 无 | BLOCKED |
| Blake 无法调用 Workflow 工具 | 真实运行 | 不属于 Blake——由 Conductor 在 Gate 3 后执行 | — | 不阻塞本单 |

## 8.5 Feedback Collection
N/A。

---

## 9. Acceptance Criteria
- [ ] §9.1 脚本 `ALL` 末行 `== TOTAL FAILS: 0`
- [ ] completion 含逐文件改动对照表
- [ ]（Conductor）真实运行记录见 gate-report；未真跑的如实列为未跑

## 9.1 Spec Compliance Checklist

可运行正本是下面的脚本块（Alex 编写）。提取与调用：

```
ACSH="<私有路径>/p3-ac.sh"     # 不要用多人共用的固定临时路径
awk '/^### §9.1-RAW/{f=1} f&&/^```bash$/{g=1;next} g&&/^```$/{exit} g' <本 handoff 路径> > "$ACSH"
bash "$ACSH" ALL
```

| # | Acceptance Criterion | Type | Verification Method | Expected | Verified Output (Alex step1d，未修改树) |
|---|---|---|---|---|---|
| AC1 | 10 个 workflow 在正本位置，语法检查过，`meta.name` 与文件名一致 | post-impl | `bash "$ACSH" C1` | 无 `FAIL` | ok 1 / FAIL 11 |
| AC2 | 无已退役标识、旧树路径、固定模型绑定、顶层数组 schema、过时的 args 警告 | post-impl | `bash "$ACSH" C2` | 无 `FAIL` | FAIL 10（文件缺失） |
| AC3 | 相对历史原件的改动量在各文件上限内；除 `pack-upgrade` 外 `agent(` 调用数不变 | post-impl | `bash "$ACSH" C3` | 无 `FAIL` | FAIL 10（文件缺失） |
| AC4 | 两个子代理定义就位、无模型绑定、通用化 | post-impl | `bash "$ACSH" C4` | 无 `FAIL` | ok 2 / FAIL 9 |
| AC5 | 三处调用点改为 `scriptPath` 且各带降级行；坏开关修好；技能里引用的每个 `scriptPath` 文件都存在 | post-impl | `bash "$ACSH" C5` | 无 `FAIL` | FAIL 14 |
| AC6 | 知识订正在位；state-surface、skill-body-verify、destructive-guard、verify-denylist、`bash -n tad.sh` 全过 | post-impl（后五项为防回归） | `bash "$ACSH" C6` | 无 `FAIL` | ok 5 / FAIL 2 |
| AC7 | codex 与 claude-code 全新安装 rc 0，10 个文件与子代理定义逐字节到达目标；本单未往 `.claude/workflows`、`.claude/agents` 投影 | post-impl | `bash "$ACSH" C7` | 无 `FAIL` | 未在基线跑（依赖 Phase 2 提交后的树） |
| AC8 | 改动范围；`blake/SKILL.md` 只动 2 行 | post-impl | `bash "$ACSH" C8` | 无 `FAIL` | FAIL 2（基线含 Phase 2 未提交改动 11 处；Phase 2 提交后第一项应为 0） |

### §9.1-RAW — 可运行正本

```bash
# Phase 3 acceptance script — run from the repo root: bash <this> ALL | <case...>
# Read-only for the repo. The install smoke (C7) uses throwaway sandboxes under $TMPDIR.
set -u
umask 022
REPO="$(pwd -P)"
[ -f "$REPO/tad.sh" ] && [ -d "$REPO/.tad" ] || { echo "run from repo root"; exit 2; }
for c in git node rsync awk sed; do command -v "$c" >/dev/null 2>&1 || { echo "missing tool: $c"; exit 2; }; done
HIST='20223774^'
W=".tad/workflows/claude"
NAMES="epic-audit gate-review handoff-review loop-discover pack-dogfood pack-upgrade surplus-execute surplus-scan tournament-design yolo-epic"
FAILS=0
ok(){ echo "  ok   $*"; }
bad(){ echo "  FAIL $*"; FAILS=$((FAILS+1)); }
chk(){ local l="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$l"; else bad "$l"; fi; }
eq(){ if [ "$2" = "$3" ]; then ok "$1 = $3"; else bad "$1: got '$2' want '$3'"; fi; }
le(){ if [ -n "$2" ] && [ "$2" -le "$3" ] 2>/dev/null; then ok "$1 = $2 (<= $3)"; else bad "$1: got '$2' want <= $3"; fi; }
syn(){ { echo 'async function __wf(){'; echo 'let args,agent,parallel,pipeline,phase,log,budget,workflow;'; sed 's/^export const meta/const meta/' "$1"; echo '}'; } | node --check /dev/stdin >/dev/null 2>&1; }

C1(){ echo "== C1 the ten workflows are restored to their canonical home"
  eq "files in $W" "$(ls "$W" 2>/dev/null | LC_ALL=C sort | tr '\n' ' ')" "$(for n in $NAMES; do printf '%s.workflow.js ' "$n"; done)"
  local n
  for n in $NAMES; do
    [ -f "$W/$n.workflow.js" ] || { bad "$n: missing"; continue; }
    if syn "$W/$n.workflow.js"; then ok "$n: wrapped-body syntax check"; else bad "$n: wrapped-body syntax check"; fi
    eq "$n: meta name" "$(sed -n "s/^[[:space:]]*name: '\\([a-z-]*\\)',.*/\\1/p" "$W/$n.workflow.js" | head -1)" "$n"
  done
  eq "tracked files under the repo's own .claude/ (must stay 0)" "$(git ls-files .claude | wc -l | tr -d ' ')" 0; }

C2(){ echo "== C2 stale references are gone"
  local n
  for n in $NAMES; do [ -f "$W/$n.workflow.js" ] || { bad "$n: missing"; continue; }
    eq "$n: retired identifiers / old tree paths" "$(grep -ciE 'notebooklm|notebook_id|research-notebooks|\.claude/(skills|workflows|agents)|claude_websearch|claude_code_reviewer' "$W/$n.workflow.js")" 0
    eq "$n: usage text that tells the caller to invoke by saved name" "$(grep -cE 'Workflow\(\{ *name:' "$W/$n.workflow.js")" 0
    eq "$n: fixed model pins" "$(grep -cE "model: *['\"](haiku|sonnet|opus)" "$W/$n.workflow.js")" 0
    eq "$n: top-level array schema at a call site" "$(grep -cE "schema: \\{ type: 'array'" "$W/$n.workflow.js")" 0
    eq "$n: obsolete 'args does not inject' warnings" "$(grep -ciE 'KNOWN ISSUE|does NOT reliably inject|may not support dot-access' "$W/$n.workflow.js")" 0
  done; }

C3(){ echo "== C3 restored files stay close to the historical originals (closed refresh list only)"
  # limits = minimum lines a correct implementation must touch (computed in Gate 2 review) + 1; added lines are capped too
  local n dlim alim del add h
  for n in $NAMES; do [ -f "$W/$n.workflow.js" ] || { bad "$n: missing"; continue; }
    case "$n" in epic-audit) dlim=4; alim=5;; gate-review) dlim=5; alim=6;; loop-discover) dlim=2; alim=3;; surplus-scan) dlim=3; alim=4;; surplus-execute) dlim=2; alim=3;; tournament-design) dlim=2; alim=3;; yolo-epic) dlim=0; alim=0;; handoff-review) dlim=8; alim=5;; pack-dogfood) dlim=9; alim=7;; pack-upgrade) dlim=110; alim=90;; esac
    h="$(git show "$HIST:.claude/workflows/$n.workflow.js")"
    del=$(diff <(printf '%s\n' "$h") "$W/$n.workflow.js" | grep -c '^<'); add=$(diff <(printf '%s\n' "$h") "$W/$n.workflow.js" | grep -c '^>')
    le "$n: historical lines removed or changed" "$del" "$dlim"
    le "$n: lines added" "$add" "$alim"
    eq "$n: number of agent( call sites (comment lines not counted)" "$(grep -v '^[[:space:]]*//' "$W/$n.workflow.js" | grep -c 'agent(')" "$(printf '%s\n' "$h" | grep -v '^[[:space:]]*//' | grep -c 'agent(')"
    eq "$n: number of schema: options (a pin must be removed without taking the schema with it)" "$(grep -c 'schema:' "$W/$n.workflow.js")" "$(printf '%s\n' "$h" | grep -c 'schema:')"
  done
  # pack-upgrade is the one file with a rewritten stage: pin what must survive
  local f="$W/pack-upgrade.workflow.js" hp; hp="$(git show "$HIST:.claude/workflows/pack-upgrade.workflow.js")"
  if [ -f "$f" ]; then
    local k; for k in Plan Upgrade Eval Review; do eq "pack-upgrade: occurrences of phase title '$k'" "$(grep -c "'$k'" "$f")" "$(printf '%s\n' "$hp" | grep -c "'$k'")"; done
    for k in correctness fact-api anti-slop; do [ "$(grep -c "$k" "$f")" -ge 1 ] && ok "pack-upgrade: review lens '$k' still present" || bad "pack-upgrade: review lens '$k' missing"; done
    eq "pack-upgrade: 'any refute' rule lines" "$(grep -c 'refutes.length >= 1' "$f")" "$(printf '%s\n' "$hp" | grep -c 'refutes.length >= 1')"
    for k in report_path findings sources_count open_questions confidence; do [ "$(grep -c "$k" "$f")" -ge 1 ] && ok "pack-upgrade: research output field '$k' still present" || bad "pack-upgrade: research output field '$k' missing"; done
    [ "$(grep -c 'research.report_path' "$f")" -ge 1 ] && ok "pack-upgrade: plan stage still reads research.report_path" || bad "pack-upgrade: plan stage no longer reads research.report_path"
    chk "pack-upgrade: research step names the Local Wiki query command" grep -q 'research/scripts/search.py' "$f"
    chk "pack-upgrade: research step keeps the WebSearch fallback" grep -qi 'websearch' "$f"
  fi; }

C4(){ echo "== C4 the two subagent definitions"
  local a=".tad/agents/claude/spec-compliance-reviewer.md" b=".tad/agents/claude-local/security-auditor.md" f
  for f in "$a" "$b"; do
    if [ ! -f "$f" ]; then bad "$f missing"; continue; fi
    ok "$f exists"
    eq "$f: frontmatter opens on line 1" "$(sed -n '1p' "$f")" "---"
    [ "$(grep -c '^---$' "$f")" -ge 2 ] && ok "$f: frontmatter is closed" || bad "$f: frontmatter not closed"
    eq "$f: model pin inside frontmatter" "$(awk 'NR==1{next} /^---$/{exit} /^model:/' "$f" | wc -l | tr -d ' ')" 0
    eq "$f: references to the old tree" "$(grep -cE '\.claude/(skills|workflows)' "$f")" 0
  done
  [ -f "$a" ] && { eq "spec-compliance-reviewer name" "$(awk 'NR==1{next} /^---$/{exit} /^name:/{print $2}' "$a")" "spec-compliance-reviewer"
    eq "spec-compliance-reviewer: TAD-repo-only wording ('this repo')" "$(grep -ci 'this repo' "$a")" 0
    chk "spec-compliance-reviewer: generic environment section present" grep -q 'do not assume the project has, or lacks' "$a"
    chk "spec-compliance-reviewer: still tells the reviewer to run each row's Verification Method" grep -qi 'Verification Method' "$a"; }
  [ -f "$b" ] && { eq "security-auditor name" "$(awk 'NR==1{next} /^---$/{exit} /^name:/{print $2}' "$b")" "security-auditor"
    chk "security-auditor: keeps the code-security skill preload" grep -q 'code-security' "$b"
    chk "security-auditor: carries the 'NOT projected' note" grep -q 'is NOT projected into any project' "$b"; }
  eq "agent definition files under any .claude directory in the repo" "$(git ls-files '.claude/agents' | wc -l | tr -d ' ')" 0; }

C5(){ echo "== C5 protocol call sites are rewired"
  local y=".agents/skills/alex/references/yolo-execution-protocol.md" d=".agents/skills/alex/references/design-protocol.md" s=".agents/skills/surplus/SKILL.md" m=".agents/skills/alex/references/yolo-manual-conductor-protocol.md" f k
  eq "yolo protocol: scriptPath calls to yolo-epic" "$(grep -c "scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js'" "$y")" 2
  eq "yolo protocol: name-based calls left" "$(grep -c "name: 'yolo-epic'" "$y")" 0
  for k in epic_path epic_slug phase_number phase_name handoff_path completion_path grounding_path reviewer_count; do
    [ "$(grep -c "$k" "$y")" -ge 2 ] && ok "yolo protocol: args field $k kept in both calls" || bad "yolo protocol: args field $k appears fewer than 2 times"; done
  [ "$(grep -c 'steps:' "$y")" -ge 2 ] && ok "yolo protocol: steps kept in both calls" || bad "yolo protocol: steps missing from a call"
  eq "yolo protocol: the wrong 'ALL 7 fields' sentence" "$(grep -c 'ALL 7 fields' "$y")" 0
  chk "yolo protocol: fallback names the manual-conductor reference" grep -q 'WORKFLOW-FALLBACK.*yolo-manual-conductor-protocol.md' "$y"
  eq "yolo protocol: fallback still points into the undistributed archive" "$(grep -c 'archive/protocols' "$y")" 0
  if [ -f "$m" ]; then ok "manual-conductor protocol reference exists"
    chk "manual-conductor reference carries the v1 protocol body" grep -q 'yolo_execution_protocol' "$m"
    [ "$(wc -l < "$m" | tr -d ' ')" -ge 150 ] && ok "manual-conductor reference is the full text (>=150 lines)" || bad "manual-conductor reference is too short to be the full protocol"
    eq "manual-conductor reference ignored by git" "$(git check-ignore -q "$m" && echo yes || echo no)" "no"
  else bad "manual-conductor protocol reference missing"; fi
  eq "design protocol: dead \"workflow\" branch token" "$(grep -c 'If "workflow"' "$d")" 0
  eq "design protocol: reference to the deleted tournament-codex.sh" "$(grep -c 'tournament-codex' "$d")" 0
  eq "design protocol: still calls detect-platform.sh to route" "$(grep -cE '\$\(bash .tad/hooks/lib/detect-platform.sh\)|platform=' "$d")" 0
  eq "design protocol: scriptPath call to tournament-design" "$(grep -c "scriptPath: '.tad/workflows/claude/tournament-design.workflow.js'" "$d")" 1
  for k in 'task:' 'prior_art:' 'mode:'; do chk "design protocol: tournament args keep $k" grep -q "$k" "$d"; done
  eq "surplus skill: scriptPath call to surplus-scan" "$(grep -c "scriptPath: '.tad/workflows/claude/surplus-scan.workflow.js'" "$s")" 1
  eq "surplus skill: scriptPath call to surplus-execute" "$(grep -c "scriptPath: '.tad/workflows/claude/surplus-execute.workflow.js'" "$s")" 1
  eq "surplus skill: name-based call left" "$(grep -c "name: 'surplus-scan'" "$s")" 0
  for k in output_path sidecar_rows 'date'; do chk "surplus skill: args keep $k" grep -q "$k" "$s"; done
  chk "surplus skill: fallback says it stops (no silent degrade)" grep -q 'WORKFLOW-FALLBACK.*不可用' "$s"
  for f in "$y" "$d" "$s"; do
    [ "$(grep -c 'WORKFLOW-FALLBACK' "$f")" -ge 1 ] && ok "$f: carries a WORKFLOW-FALLBACK line" || bad "$f: no WORKFLOW-FALLBACK line"
    chk "$f: uses the tool-presence test (select:Workflow), not the platform probe" grep -q 'select:Workflow' "$f"
    chk "$f: says what to do when the session is not at the project root" grep -q 'git rev-parse --show-toplevel' "$f"; done
  eq "active skill/template/hook files still pointing at .claude/workflows" "$(git grep -n '\.claude/workflows' -- .agents/skills .tad/templates .tad/hooks | wc -l | tr -d ' ')" 0
  local missing=0 p; for p in $(git grep -ohE "scriptPath: '[^']+'" -- .agents/skills | sed -E "s/scriptPath: '([^']+)'/\\1/" | LC_ALL=C sort -u); do [ -f "$p" ] || { missing=$((missing+1)); echo "    missing: $p"; }; done
  eq "scriptPath targets named in skills that do not exist" "$missing" 0
  eq "surplus-execute: nested call by saved name" "$(grep -c "workflow('yolo-epic'" "$W/surplus-execute.workflow.js" 2>/dev/null)" 0
  eq "surplus-execute: nested call by path" "$(grep -c "workflow({ scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js' }" "$W/surplus-execute.workflow.js" 2>/dev/null)" 1; }

C6(){ echo "== C6 knowledge, declarations and gates"
  local a=.tad/project-knowledge/patterns/ac-verification.md k
  chk "ac-verification: the args entry carries a dated amendment" grep -q 'AMENDED 2026-10-09' "$a"
  for k in '2.1.295' 'no workflow with that name'; do chk "ac-verification amendment states: $k" bash -c "awk '/AMENDED 2026-10-09/{f=1} f' '$a' | grep -qF '$k'"; done
  eq "ac-verification: lines removed from the file (the original entry must stay intact)" "$(git diff --numstat -- "$a" | awk '{print $2+0}')" 0
  eq "workflow-completion-trigger: stale 'All 5 current production workflows'" "$(grep -c 'All 5 current production workflows' .agents/skills/alex/references/workflow-completion-trigger.md)" 0
  chk "workflow-completion-trigger: replacement sentence present" grep -q 'validated against the original 5 workflows' .agents/skills/alex/references/workflow-completion-trigger.md
  chk "instance declaration registers R-CC-7" grep -q 'R-CC-7' .tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md
  chk "instance declaration names the workflow location" grep -q '.tad/workflows/claude' .tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md
  eq "checklist residual rows for R-CC-7" "$(grep -cE '^[|] R-CC-7 ' .tad/project-knowledge/patterns/runtime-adapter-checklist.md)" 1
  eq "ledger rows for the workflows surface" "$(grep -cE '^[|] workflows ' .tad/runtime-compat/claude-code.md)" 1
  eq "ledger: forbidden words" "$(grep -cE 'RETIRED|DEPRECATED' .tad/runtime-compat/claude-code.md)" 0
  eq "freshness BLOCK/WARN lines for claude_code" "$(bash .tad/hooks/lib/release-verify.sh freshness . 2>&1 | grep -E '^(BLOCK|WARN)' | grep -c 'claude_code')" 0
  local r=.tad/workflows/README-claude.md
  if [ -f "$r" ]; then le "README-claude.md line count" "$(wc -l < "$r" | tr -d ' ')" 25; chk "README says how to invoke (scriptPath)" grep -q 'scriptPath' "$r"; else bad "$r missing"; fi
  bash .tad/hooks/lib/release-verify.sh state-surface . >/dev/null 2>&1; eq "state-surface exit" "$?" 0
  eq "skill-body-verify" "$(bash .tad/hooks/lib/skill-body-verify.sh 2>&1 | tail -1)" "RESULT: ALL CHECKS PASSED"
  bash .tad/hooks/lib/release-verify.sh installer-destructive-guard . >/dev/null 2>&1; eq "installer-destructive-guard exit" "$?" 0
  bash tad.sh --verify-denylist >/dev/null 2>&1; eq "tad.sh --verify-denylist exit" "$?" 0
  chk "bash -n tad.sh" bash -n tad.sh; }

C7(){ echo "== C7 the files reach an installed project (they ride the existing .tad sync; no new installer logic)"
  local ROOT; ROOT="$(mktemp -d "${TMPDIR:-/tmp}/tad-p3ac.XXXXXX")"; ROOT="$(cd "$ROOT" && pwd -P)"
  mkdir "$ROOT/src"; ( cd "$REPO" && git ls-files -co --exclude-standard -z -- . ':!.claude' | rsync -a -0 --files-from=- . "$ROOT/src/" )
  local p t n
  for p in codex claude-code; do t="$ROOT/$p"; mkdir -p "$t/t" "$t/bk"; ( cd "$t/t" && git init -q . && TAD_BACKUP_ROOT="$t/bk" bash "$ROOT/src/tad.sh" --source "$ROOT/src" --platform "$p" --yes >"$t/log" 2>&1 ); eq "$p: installer rc" "$?" 0
    n=0; for f in $NAMES; do cmp -s "$t/t/$W/$f.workflow.js" "$REPO/$W/$f.workflow.js" && n=$((n+1)); done; eq "$p: workflow files byte-identical in target" "$n" 10
    chk "$p: spec-compliance-reviewer definition present in target" cmp -s "$t/t/.tad/agents/claude/spec-compliance-reviewer.md" "$REPO/.tad/agents/claude/spec-compliance-reviewer.md"
    chk "$p: security-auditor (claude-local) file present in target" cmp -s "$t/t/.tad/agents/claude-local/security-auditor.md" "$REPO/.tad/agents/claude-local/security-auditor.md"
    chk "$p: manual-conductor reference present in target" test -f "$t/t/.agents/skills/alex/references/yolo-manual-conductor-protocol.md"
    chk "$p: self-check passed" grep -q 'Self-check passed' "$t/log"
    chk "$p: nothing projected into .claude/workflows or .claude/agents by this phase" test ! -e "$t/t/.claude/workflows" -a ! -e "$t/t/.claude/agents"
  done
  case "$ROOT" in */tad-p3ac.*) rm -rf "$ROOT";; esac; }

C8(){ echo "== C8 scope fence"
  eq "changed paths outside the allowed set" "$(git status --porcelain | sed -E 's/^.. //; s/.* -> //' | grep -vE '^(\.tad/workflows/claude/.*|\.tad/workflows/README-claude\.md|\.tad/agents/claude(-local)?/.*|\.agents/skills/alex/references/(yolo-execution-protocol|yolo-manual-conductor-protocol|design-protocol|workflow-completion-trigger)\.md|\.agents/skills/surplus/SKILL\.md|\.agents/skills/blake/SKILL\.md|\.tad/templates/skillify-candidate-template\.md|\.tad/hooks/lib/detect-platform\.sh|\.tad/project-knowledge/patterns/(ac-verification|pack-evaluation|gate-design|runtime-adapter-instance-claude-code|runtime-adapter-checklist)\.md|\.tad/runtime-compat/claude-code\.md|docs/MULTI-PLATFORM\.md|\.tad/active/.*|\.claude/|docs/pm/status\.md|\.agents/skills/code-security/references/secret-detection-rules\.md|\.tad/capability-packs/code-security/references/secret-detection-rules\.md)$' | wc -l | tr -d ' ')" 0
  eq "lines changed in blake/SKILL.md (one stale parenthetical only)" "$(git diff --numstat -- .agents/skills/blake/SKILL.md | awk '{print $1+$2}')" 2
  eq "non-comment lines changed in detect-platform.sh (logic must be untouched)" "$(git diff -U0 -- .tad/hooks/lib/detect-platform.sh | grep -E '^[+-][^+-]' | grep -vcE '^[+-][[:space:]]*#')" 0; }

ALLCASES="C1 C2 C3 C4 C5 C6 C7 C8"
run(){ case " $ALLCASES " in *" $1 "*) "$1";; *) echo "unknown case $1"; exit 2;; esac; }
if [ "${1:-ALL}" = ALL ]; then for c in $ALLCASES; do run "$c"; done; else for c in "$@"; do run "$c"; done; fi
echo "== TOTAL FAILS: $FAILS"
[ "$FAILS" -eq 0 ]
```

**AC Dry-Run Log**（Alex step1d，2026-10-09）：`bash -n` 通过；C1–C6、C8 在当前树实跑，结果见上表；`syn()` 对 10 个历史原件 10/10 通过，证明判式对已知良好文件成立；`pins`/`stale` 计数对历史原件为非零（见 §5），证明 C2 对未翻新文件会失败。

---

## 9.2 Expert Review Status
_(待第 1 轮双审后填)_

### Audit Trail

第 1 轮（2026-10-09，全文审查）。报告：`…/phase3-design-review-cr.md`（CONDITIONAL PASS，1 P0）、`…/phase3-design-review-arch.md`（CONDITIONAL PASS，4 P0）；均自报 `claude-sonnet-5-5`。

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer P0-1 ＋ backend-architect P0-4(a) | 协议里写的都是相对 `scriptPath`，却只测过绝对路径 | §5 MQ2 新增三行（Alex 2026-10-09 以零代理探针实测：相对项目根可用）；§4.4「路径」；子目录情形记 R-CC-7 | Resolved |
| backend-architect P0-4(b) ＋ code-reviewer P1-1 | 嵌套 `workflow({scriptPath}, args)` 未测 | §5 MQ2（实测成功；按保存名嵌套实测失败）；§4.2 W-g | Resolved |
| backend-architect P0-1 | YOLO 降级目标在 `.tad/archive/`，不随框架分发，下游悬空 | §4.4-1（原样拷为 `references/yolo-manual-conductor-protocol.md`）；脚本 C5 核该文件存在且被跟踪面覆盖 | Resolved |
| backend-architect P0-2 | 子代理投影推到 Phase 4 却没写进 Epic；空档期 Blake Layer 2 Group 0 无已注册类型 | Epic Phase 4 件目（已加）；§4.3「已知空档」 | Resolved |
| backend-architect P0-3 | 设计改了人裁定 D2、SC5 与 Epic Phase 3 的 AC，却没回改 Epic | Epic 已修订（D2 执行注、SC5、Phase 3 AC），标明为 Conductor 在人授权范围内的裁定；§11 第 1、6 行 | Resolved |
| code-reviewer P1-2 | W-d 的逐字拷贝会删掉 `claude-code` 分支 | §4.2 W-d（保留历史原文）；§11 第 8 行 | Resolved |
| code-reviewer P1-3 / P1-4 | W-e 的前提有误（历史文件无 Local Wiki 步）；C2 看不到 W-e 的大部分 | §4.2 W-e（如实改写、输出契约写明）；脚本 C2 增补三类标识，C3 对 `pack-upgrade` 核调用数、阶段、镜头、契约字段 | Resolved |
| code-reviewer P1-5 | C3 上限过松且不计新增行 | 脚本 C3：上限取最小改动量加 1，`yolo-epic` 为 0；新增行另设上限 | Resolved |
| code-reviewer P1-6 | W-c 对 `gate-review` 的措辞不对；三条单行注释有歧义 | §4.2 W-c 逐文件写明 | Resolved |
| code-reviewer P1-7 ＋ backend-architect P1 | `claude-local`「不分发」不属实（会随 `.tad/` 同步） | §4.3 注释原文改为「不投影」；§10.2 | Resolved |
| code-reviewer P1-8 | `tournament-design` 第 93 行等教人按名调用的字符串 | §4.2 W-f 扩大 | Resolved |
| code-reviewer P1-9 ＋ backend-architect P1 | 「主会话」无可操作判据；锦标赛的询问先于能力判断；「7 个必填」有误 | §4.4 统一判据；§4.4-2 判断前置；§4.4-1 订正为六项 | Resolved |
| code-reviewer P1-10 | 「5 个生产 workflow」的替换句可能造假 | §4.5 给出原句 | Resolved |
| backend-architect P1 | 运行时实例声明与台账未随 workflow 能力更新 | §4.5 末两条；§7.2 | Resolved |
| backend-architect P1 | 去掉绑定须留下清单 | §4.2 表后一段 | Resolved |
| backend-architect P1 | 10 个脚本会到达所有平台 | §10.2（接受并写明）；README | Resolved（接受为已知取舍） |
| code-reviewer P2 | 脚本对缺失文件空过；C7 只核一个定义；C8 看不到 `detect-platform.sh` 的逻辑改动 | 脚本 C4/C7/C8 | Resolved |
| code-reviewer P2 | `pack-dogfood` 栅栏未含 `.tad/capability-packs/`（历史既有缺口） | 不在 W-a 内 | Deferred（completion「建议」项） |

第 2 轮（2026-10-09，增量复核，新审查者，自报 `claude-sonnet-5-5`）。报告：`…/phase3-design-review-r2-cr.md`。verdict：CONDITIONAL PASS——五条 P0 全部 RESOLVED；一条回归记为 P0。

| 来源 | 第 2 轮观察 | 处置 |
|---|---|---|
| R2 回归（P0） | 脚本 C5 断言 `design-protocol.md` 中 `detect-platform` 出现 0 次，而 §4.4 的统一判据要求把含该文件名的句子原样写进三处——照规格实现必然不过 | 属验收脚本与规格自相矛盾，非设计缺陷。按审查者给出的修法，改为只查「调用形式」（`$(bash .tad/hooks/lib/detect-platform.sh)` 或 `platform=`）为 0。**处置依据**：人 2026-10-08 预授权（两轮后仍有遗留 P0 时 Conductor 可自行缩小范围）与其后的全 Epic 自主决策授权；本项是把一条检查收窄到它本来要查的东西，不进第 3 轮 |
| R2-P1 | C3 把注释里的 `agent(` 也计入，`pack-upgrade` 第 13 行注释在 W-e 改写时易触发误报 | 脚本 C3 改为不计注释行 |
| R2-P1 | `gate-review` 的改动上限零余量（W-f 触及第 114 行时） | `dlim` 4→5、`alim` 5→6 |
| R2-P1 | Epic Phase 4 尚无与「子代理投影」对应的 AC | Phase 4 设计时由 Conductor 写入（件目已在 Notes (9)） |
| R2-P1 | 「工作目录不是项目根时用绝对路径」解决不了脚本内部相对路径的问题 | 已知限制：workflow 脚本内的路径本就假定项目根；记入 R-CC-7 的说明 |

审查者以模拟实现验证了 C1–C3 可满足（9 个文件按 W-a/b/c/d/f/g，`pack-upgrade` 尽力按 W-e），各文件实测改动量均在上限内。

**Gate 2 判定（Alex，读盘后）**：PASS。

### Experts Selected
1. **code-reviewer** — 翻新清单的封闭性、验收脚本判别力、协议改写的一致性
2. **backend-architect** — 「`scriptPath` 直调、不投影」这一结构决定及其对四个 harness 的影响

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 清单之外不改 workflow 的任何一行；觉得某处「顺手该修」的，写进 completion 的「建议」里，不动手。
- ⚠️ 不得改 `tad.sh`、`release-verify.sh`、任何 `.tad/hooks/*.sh` 的逻辑；`detect-platform.sh` 只改头注释。
- ⚠️ 不得在本仓 `.claude/` 下创建文件；不得调用 Workflow 工具。
- ⚠️ 三个 reference 文件与 `blake/SKILL.md` 属协议文本：每处改动在 completion 里写明「原句 → 新句」。

### 10.2 Known Constraints / 明确延后
- 子代理定义向目标项目 `.claude/agents/` 的投影；本仓自举安装：Phase 4（已写入 Epic Phase 4 件目）。空档期的处置见 §4.3 末段
- 10 个脚本会随 `.tad/` 同步到**所有平台**的目标项目，包括面向 TAD 仓自身维护的几个；非 Claude Code 用户拿到的是用不上的文件。接受：与 `.tad/` 现有同步模型一致，README 写明
- 为 6 个无调用点的 workflow 设计调用点：不在本 Epic
- 顶层按保存名调用与 `/workflows` 列表可见性：未测、未提供（R-CC-7）
- `yolo-manual-conductor-protocol.md` 是旧文字版协议的原样拷贝，其内容的时效性本单不核（Phase 5 清理项）

### 10.3 Sub-Agent 使用建议
- [ ] bug-hunter — 翻新后语法检查不过且原因不明时

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|---|---|---|---|
| 1 | workflow 如何到达并被调用 | 投影到 `.claude/workflows/` 按名调用／留在 `.tad/` 用 `scriptPath` 直调 | 后者 | 实测 `scriptPath`（绝对、相对项目根、嵌套）可用且 `args` 可注入；不需要安装器改动；知识库记有「按名调用会加载过期缓存副本」。**这改变了 Epic Phase 3 原 AC1（装进 `.claude/workflows/`）——已在 Epic 中修订并注明** |
| 2 | 固定模型绑定 | 保留 `haiku`/`sonnet`／去掉 | 去掉 | v3.0.0 已定「teammate_model: inherit」的 harness 中立口径 |
| 3 | `security-auditor` 定义 | 分发给目标项目／仅 TAD 仓自用 | 仅自用 | 历史上从未分发；项目级定义会顶替用户级同名子代理 |
| 4 | `pack-upgrade` 的研究阶段 | 原样带回（含已退役层）／改写为 Local Wiki（新增）→ WebSearch（原有） | 后者 | 该层 2.44.6 已整层退役；现行研究链即 `local_wiki → websearch`（`.tad/config-workflow.yaml`） |
| 5 | 6 个无调用点的 workflow | 一并恢复／只恢复有调用点的 4 个 | 一并恢复 | 人裁定 D2：10 个全部恢复 |
| 6 | 真实运行 | 10 个全跑／有副作用或开销大的不跑 | Conductor 真跑 8 个（其中 `yolo-epic` 只跑 `steps:["design"]`）；`pack-upgrade`、`surplus-execute` 只做零代理装载与缺参校验 | 这两个一跑即改正本 pack 或自动执行积压任务并派数十代理。**这改变了人裁定 D2「各至少真跑一次」与 Epic SC5——已在 Epic 中修订并注明为 Conductor 在授权范围内的裁定** |
| 7 | 「能否用 workflow」的判据 | `detect-platform.sh` 输出／自己的工具列表里有无 Workflow 工具 | 后者 | 前者在子代理里也返回 `claude-code` |
| 8 | `handoff-review` 的 provenance 段 | 换成现行协议段的逐字拷贝／保留历史原文 | 保留 | 历史原文带 `claude-code` 分支，是超集；该 workflow 只在 Claude Code 运行 |
| 9 | YOLO 降级协议的位置 | 继续指向 `.tad/archive/`／拷进随框架分发的 references | 后者 | `.tad/archive/` 不分发，下游是悬空路径 |

Conductor 在人授权范围内裁定（2026-10-08/09）。

---

## 12. Sub-Agent使用记录
Blake 完成后填写。

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-design-review-cr.md
  - .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-design-review-arch.md
blake_reviews:
  - .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-impl-review-{cr,arch}.md
completion:
  - .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-completion.md
workflow_runs:
  - .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-gate-report.md   # Conductor
journal:
  - .tad/evidence/journal/workflow-restore-2026-10-09.md
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-10-09
**Version**: 3.2.0
