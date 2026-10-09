---
task_type: docs
e2e_required: no
research_required: no
git_tracked_dirs: ["docs", ".agents/skills", ".tad/guides", ".tad/active"]
handoff_revision: 3
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.2 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-09
**Project:** TAD Framework
**Task ID:** TASK-20261009-RESIDUE-CLEANUP-5A
**Epic:** EPIC-20261008-multi-harness-restore-and-cleanup.md (Phase 5a/6)
**Grounding（逐行工作清单，本单的事实依据）:** `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5-grounding.md`
**规范性附件（与本单同等效力；下文称「文档审查」「代码审查」）:** 同目录的 `phase5a-design-review-docs.md`（真值表 §1、定稿措辞 §3、漏列语句 §4、应保留语句 §5、NEXT 搬迁 §6、OBJECTIVES §7）与 `phase5a-design-review-cr.md`（门禁约束 §4、F1 语义 §3 末）
**派发顺序:** 批 2 可立即派发。批 1 等 Phase 4a-2 提交后再派发（它描述的 hook 锚定、子代理投影、粘性要以落地的代码为准）。

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|---|---|---|
| Architecture Complete | ✅ | 纯文字与状态面清理；两批互不相交的文件集（§7），可并行 |
| Components Specified | ✅ | 每一处改动的文件、行号、现文、处置在 grounding 报告的 A–F 各节 |
| Functions Verified | ✅ | 不改代码；涉及的路径存在性由 grounding 用脚本核过 |
| Data Flow Mapped | ✅ | 不适用 |

---

## 1. Task Overview

### 1.1 What We're Building
Claude Code 支持恢复之后，把仓里还在说「Claude Code 已移除／只有三家／hooks 仍是缺口」的文字、指向已不存在路径的引用、过期的状态面清掉。分两批：

- **批 1：文档与状态面**（README、ROADMAP、AGENTS.md、PROJECT_CONTEXT、docs/*、OBJECTIVES、NEXT.md、session-state、tickets、已完成 Epic 的归档）。
- **批 2：skill 文本、指南、配置里的引用**（Alex 协议里只查 `.claude/skills/` 的可用性判断、三个旧安装 skill、快速参考、几处配置里的悬空路径）。

### 1.2 Why
- 下一个版本里 Claude Code、Codex、OpenCode、Cursor 都是受支持的安装目标。现在 README 第 173 行还写着 `--platform claude-code` 自 v3.0.0 起不再提供。
- 4a 之后，「升级绝不删除／不改写你的 `.claude/` 与 `CLAUDE.md`」这类安全承诺对 `--platform claude-code` 已不成立，文档里还在这么写。
- Alex 判断 capability pack 是否可用时只看 `.claude/skills/{name}/SKILL.md`，这个路径在 Codex、OpenCode、Cursor 的安装里不存在，是功能缺陷，不只是措辞。

### 1.3 Intent Statement
- 真正要解决：读者和代理从仓里读到的平台支持说法与实际一致；活跃面不再指向不存在的东西。
- 不是要做：
  - 把话说满：不写「first-class／一等」「四家均已验证」「all four hook-enabled」。各家的验证深度不同，四家真机回归（Phase 4b）还没跑。
  - 改版本号（仍是 3.2.0；Phase 6 统一改。`state-surface` 检查把几份文件的版本钉在 `version.txt` 上）。
  - 改任何代码、hook、测试、workflow 脚本、安装器（Phase 5b）。
  - 删除或瘦身协议里的约束条文；改写 SAFETY 条目；重定 Objectives 的方向。
  - 动人未提交的三个文件与 `capability-builder-v1` Epic。

### 1.4 Conductor 已定的裁决（Blake 照做）
| 事项 | 裁决 |
|---|---|
| `tad-init`、`tad-status`、`tad-help` 三个旧 skill（grounding F2） | 不退役。把里面的手工安装步骤与检查路径改成现状：安装用 `tad.sh`／`npx github:Sheldon-92/TAD`；检查 `.agents/skills/alex/SKILL.md` 与 `.tad/version.txt`（不写死版本号）。改动尽量小 |
| `save-skill`、`save-workflow` 写 `.claude/skills/local/`（F3） | 不改。只在处置表里记一条「需要设计决策」 |
| Capability Builder 的投影归属（F7） | 不改。处置表记一条 |
| GitHub Registry 扫描、依赖扫描（D） | 不在本单（Phase 5b） |
| tickets 与已完成 Epic 的归档方式 | 普通 `mv`，**不用 `git mv`**（`git mv` 进被忽略的目录会让文件继续被跟踪）。目标目录被 git 忽略；从 `active/` 的删除由 Conductor 提交，原文留在 git 历史与本地归档里。先例：`5ac69cc7` |
| `framework-health-repair` | 归档：整个文件夹与 3 行的桩文件一起移到 `.tad/archive/epics/`；先改 grounding C.5 列出的活引用 |
| 「14 registered downstream projects」 | 改成不带数字、不依赖已退役注册表的说法 |
| pack 数量（24／25／26 不一致） | 以 `ls -d .tad/capability-packs/*/CAPABILITY.md | wc -l` 为准（审查时为 26）；README `:71`、`:171` 与 PROJECT_CONTEXT `:4,:6` 的现行说法改成这个数；版本历史行不动 |
| `expert-criteria.yaml:132` 的 `evidence_template` | 删掉这个键（没有任何读取方） |
| `.tad/config-workflow.yaml` 的 `research_notebook` 块 | 不动（仍有读取方） |

---

## 📚 Project Knowledge（Blake 必读）
- grounding 报告全文（上面的路径）。它的每条都带文件、行号、现文、处置、证据。行号是 2026-10-09 `dd22d2f1` 上的，动手前按现文重新定位。
- `.tad/memory/feedback_verify-before-delete.md`：删除前先核哪份是最新。
- `AGENTS.md` 里关于「改 SKILL／config 超过 20 行须先列契约变化」的条款（AR-002）。本单批 2 的契约变化已列在 §4.2。

---

## 2. Background Context
- **真值表**在文档审查 §1（按 harness 列出安装参数、skill 发现路径、hook 机制与事件、Workflow 工具、子代理、证据等级）。写任何一句平台说法前先对照它。要点：
  - 四家都**附带** lifecycle hook 投影，但覆盖与证据不同：Claude Code 的 `.claude/settings.json` 只在目标项目没有该文件时写入，证据只有无头运行；Codex 没有接 PreCompact，本周期真机整链因额度失败；OpenCode、Cursor 有 2026-10-06 的真机整链 PASS。
  - Claude Code 不读 `.agents/skills/`，安装器在 `.claude/skills/<name>` 建指向 `.agents/skills/<name>` 的链接。Claude Code 只在项目没有 `CLAUDE.md` 时原生读 `AGENTS.md`；已有 `CLAUDE.md` 的项目，安装器在其中维护一个带标记的 `@AGENTS.md` 引用块，不新建 `CLAUDE.md`。
  - OpenCode 与 Cursor 的 hook 投影在**每一种**平台安装里都会写；只有 `.codex/hooks.json` 与 Claude 投影是按平台门控的。不要写成「`--platform cursor` 才安装 Cursor hooks」。
  - 10 个 workflow 在 `.tad/workflows/claude/`，只有 Claude Code 主会话有 Workflow 工具，其余三家走手动编排；安装器不投影它们。
- **措辞规则**：(1) 不写「hook-enabled」「verified」来形容一组 harness，写「ships a lifecycle-hook projection／附带 hook 投影」，证据状态只放在两处：`docs/MULTI-PLATFORM.md` 的状态表与 `AGENTS.md` Known Gaps 的 P4 条；(2) 六份文档里不出现「first-class」「一等」；(3) 不写带版本限定的句子（「since v3.3.0」「3.3.0 新增」），不写「在开发分支上」；现有的 `3.2.0` 字样原样不动；(4) Claude Code 的 YOLO2 适配器成熟度是另一回事，`ROADMAP.md:24` 的「experimental」保留并限定为「YOLO2 adapters」。
- **发布暂存**：这些改动描述的是下一个版本的状态，在 Phase 6 改版本号之前不得推送或合并。
- `.claude/...` 路径在文档里有两种合法用法：描述安装目标（保留），和声称「本仓里有这个文件」（错，应为 `.agents/skills/...`）。只改后一种。grounding A.6 逐文件分了类。
- `.tad/archive/` 与 `.tad/evidence/` 被 git 忽略。新的 NEXT 归档文件必须 `git add -f`（先例：`NEXT-completed-through-20261004.md`）。

---

## 3. Requirements

### 3.1 Functional
- **FR1（批 1）口径统一**：grounding B.3 第 1、2、4、5、6、7、11 条，**加上**文档审查 §4 漏列的语句（README `:171,:181-182,:496`；ROADMAP `:28,:38-42`；MULTI-PLATFORM `:190,:218` 与 Workflow Matrix；CODEX-USER-GUIDE `:45,:151,:459-462`；value-proposition `:36,:40` 对 `:84`；OBJECTIVES `:21`）。README 头部、`AGENTS.md` Runtime status 块、MULTI-PLATFORM 平台表、ROADMAP 三行**直接采用文档审查 §3.1–§3.4 的定稿文字**（按落地的 4a-2 现状微调，见 §6 第 0.5 步）。文档审查 §5 列为历史的语句保留不动。另有两行不在任何清单里、但含被禁用的措辞，一并改：`docs/MULTI-PLATFORM.md:102` 改为 "Codex is a supported install target (`--platform codex`, the default) with native skill loading, hooks, subagents, and MCP support."；`:171` 改为 "Gemini CLI can serve as an external specialized tool via the handoff mechanism. It is **not** a TAD install target."。只列三家的安装目标清单（README `:5`、`:81` 的安装命令示例、MULTI-PLATFORM `:7,:190`、ROADMAP `:28`）都补成四家。CODEX-USER-GUIDE `:40,:192` 的 pack 数量同 §1.4 的规则。
- **FR1b（批 1）安全承诺改实**：README `:5`、MULTI-PLATFORM `:13-14,:96`、CODEX-USER-GUIDE `:19,:263,:277,:459-462` 里「升级绝不删除／不合并不改写 `.claude/`、`CLAUDE.md`」的说法，改为文档审查 §2 P0-3 给出的中英文句子（非 claude-code 平台不读不改；claude-code 平台只归档并替换能逐字节证明是旧版 TAD 装的文件）。
- **FR2（批 1）NEXT.md**：grounding C.8 第 1、2 条。
  - 把 29 个 `### ✅` 小节加 `### 0. ✅`、`### 0d. ✅` 两个小节逐字移到 `.tad/archive/next/NEXT-completed-through-20261008.md`。
  - **移走之前**，在每个小节里查 `Human next|Carry|Later knives|Residual|待办|Orphan|待定|待应用|Remaining|remaining`，把仍未了结的行（文档审查 §6 的表列了 9 处）各用一行抄进新小节 `### Carried from completed sections (2026-10-09)`（放在 ACTIVE 条目之后，每行带 `-> archive: <原小节标题>`，总共不超过约 25 行）。拿不准是否已了结的，抄过来，不丢。逐项的判断写进处置表。
  - 删掉第二个同名二级标题 `## 🔴 优先队列（2026-09-03 …）`（基线 `:147`）。
  - 四行路径：`:34,:35` 改指 `.tad/archive/handoffs/`，`:575,:579` 改为 `.tad/active/ideas/`。
  - ACTIVE 块（`:16-22`）用文档审查 §6 P1-B 的文字，按编辑当天的 Epic Phase Map 更新各 Phase 状态。含 `当前版本` 的那一行必须留在前 15 行内，且行内第一个 `x.y.z` 仍是 `3.2.0`。
  - `0d-2` 小节加一句指向归档文件里的 `0d`。
- **FR3（批 1）状态面**：grounding C.8 第 3、4、5、6 条：`session-state.md` 正文、tickets、`framework-health-repair` 归档、`OBJECTIVES.md` O3（Why 行与 KR1、KR2 用文档审查 §7 的原文，其中三个目录的文件数在编辑时用 `git ls-files` 重数）。
- **FR4（批 1）悬空引用**：grounding A.7 第 2、3、8 条。
- **FR5（批 2）pack 可用性判断**：grounding F1。Alex 各协议里「Tier 2」与 `mandatory_read` 的路径从 `.claude/skills/{name}/SKILL.md` 改为 `.agents/skills/{name}/SKILL.md`。
- **FR6（批 2）旧安装 skill**：按 §1.4 的裁决改 `tad-init`、`tad-status`、`tad-help`。
- **FR7（批 2）指南与配置**：grounding B.3 第 9 条（Alex 快速参考）、A.7 第 4–7 条、F11、A.6 里标为「Wrong」的两处（`product-thinking/README.md:52`、`capability-upgrade/SKILL.md:12,31,44,45`）及 `product-thinking/references/pressure-test-rubric.md` 里同类引用。
- **FR8（两批）处置表**：两批各写一份，互不覆盖：批 1 写 `.tad/evidence/designs/phase5a-disposition-batch1.md`，批 2 写 `…-batch2.md`。每条残余一行：位置、处置（改／删／归档／保留及理由）、依据。grounding 里标为「leave」的也要列。**批 1 的那份**另有一节，标题必须含「Epic Notes」字样（如 `## Epic Notes 销账`），把 Epic Notes 的 12 条逐条销账，每行形如 `| N | 原问题 | 处置或去向 | 依据 |`（属于 5b、批 2 或人的，写去向）。

### 3.2 Non-Functional
- NFR1 不改版本号字符串。批 1 结束时 `bash .tad/hooks/lib/release-verify.sh state-surface .` 与 `bash .tad/hooks/lib/release-verify.sh version-sweep . 3.2.0` 都 exit 0（批 2 不以 `state-surface` 为门：批 1 改到一半时它可能是红的）。
- NFR2 本单涉及的文件里只有 `product-thinking` 在 `.tad/capability-packs/` 下有孪生副本。只改 `.agents/skills/product-thinking/` 下的 `README.md`（`:52`、`:58`）与 `references/pressure-test-rubric.md`（全部 `.claude/skills` → `.agents/skills`）。**不要**改、也不要覆盖 `.tad/capability-packs/` 下的副本：它们已经是 `.agents` 的写法，而且与 `.agents/skills` 那份本来就有合理差异（README 标题 `### Codex` 对 `### Claude Code`）。`bash .tad/hooks/lib/skill-body-verify.sh` 保持 `ALL CHECKS PASSED`。不要碰 `alex/SKILL.md`（`provenance` 门抽查它）。
- NFR3 移动与归档一律逐字保留原文；不重写被移动的内容。

---

## 4. Technical Design

### 4.1 批 1 要点
- 定稿文字见文档审查 §3（README §3.1、AGENTS.md §3.2、MULTI-PLATFORM §3.3、ROADMAP §3.4）。照抄为主；只有当 4a-2 已经落地了某项（hook 锚定、子代理投影）时，才去掉与之对应的「尚未」限定，别的不动。
- **会被门禁卡住的写法**（代码审查 §4）：
  - `AGENTS.md` Runtime status 块里不得出现 `no lifecycle hooks`、`the **hook-enabled** runtime`、`currently get skills + routing + packs`、`all three`；`> **Runtime status` 锚点与连续的引用块格式保留；`## Known Gaps` 标题前缀保留；`- **P2 — Hook adapters (implemented …` 这一条里的 `(implemented` 必须保留（否则 check8 会静默跳过）。P4 那一条补上「Claude Code: not yet run」。
  - `AGENTS.md`、`README.md`、`docs/MULTI-PLATFORM.md`、`PROJECT_CONTEXT.md` 里不得新写 `Version X.Y`／`Version: vX.Y` 形式且数字不是 3.2.0 的字样，前 15 行与含「Runtime status」的行里不得有 `(v3.2.0)` 以外的 `(vX.Y.Z)`。行文里的「since v3.0.0」没问题。
  - 保留这几个字符串：README 的 `Version 3.2.0`，PROJECT_CONTEXT 与 MULTI-PLATFORM 的 `Version…: 3.2.0`（`version-sweep` 第 1 层）。
  - `AGENTS.md:171` 只把取值补成 `claude-code|codex|none`，不要扩写成「路由使用它」（`detect-platform.sh` 没有调用方）。
- `docs/MULTI-PLATFORM.md` 是最大的一项：平台表换成文档审查 §3.3 那张六列表（注明日期的 PASS／FAIL 只允许出现在这张表里）；`:3`、`:218` 用 §3.3 给的句子；`:5-14` 引言与 `:88-96` 一节从 Claude Code 账本的 `skill_loading`、`hooks`、`workflows`、`legacy_adoption` 行改写；`:43-56` 的图与 `:54`、`:162` 不再称 Claude 账本为 legacy／RETIRED；`:190` 去掉已退役的 `*sync`；Workflow Matrix 加一行或几列说明各家有什么。`:202` 改为：workflow 脚本在 `.tad/workflows/claude/`，只有 Claude Code 有 Workflow 工具，其余三家走手动编排。
- `README.md:173-174` 的改写保留「`--platform both` 仍被拒绝」，不要再用「不再提供」这个词。`:414` 等版本历史表行是历史，保留。
- NEXT 归档文件的格式照 `NEXT-completed-through-20261004.md`：标题、说明迁出条数的引用块、`---`、逐字小节。Gate 4 时 Conductor 会把 NEXT.md 被删的块与归档文件做一次 diff。
- `session-state.md` 是被忽略的本地文件：把 14–35 行的旧正文与 38–45 行的两段收尾移到 `.tad/archive/session-state/session-state-through-20261006.md`，原处在一个 `##` 标题下写一段当前状态（指向本 Epic 的 Phase Map，写出「Phase Map」字样，不抄内容）。头部索引块（3–12 行）里的每个 `.tad/*.md` 路径必须仍然存在（check5）：`framework-health-repair/session-state.md` 那一行要在移动的同一步里改指 `.tad/archive/epics/framework-health-repair/session-state.md`。
- tickets：先给 `TICKET-20261006-epic-p1-clearance.md` 与 `-epic-p3-runtime.md` 在前 8 行内加一行 CLOSED（依据：父 Epic 已归档并随 v3.2.0 发出），再 `mkdir -p .tad/archive/tickets .tad/archive/session-state`，把除 `TICKET-20260916-codex-ledger-reverification.md` 以外的 11 张用普通 `mv` 移到 `.tad/archive/tickets/`。
- `framework-health-repair`：先改活引用，再用普通 `mv` 把文件夹与桩文件移到 `.tad/archive/epics/`。活引用：`ac-verification.md:609,641`、`DR-20260831-…-r2.md:74`、`AUDIT-20260816-framework-health.md:668,672`、`NEXT.md` 里留存的相关行、`session-state.md` 索引行、`ROADMAP.md:38-42`（把「Active backlog」改成已完成并归档、余项见 NEXT.md）。`.tad/brain-index.md:72` 是生成表里的一行：手工删掉这一行，不要重跑生成器，`Generated:` 日期保持可解析。`EPIC.md` 里没勾的框不要补勾，在归档后的 `EPIC.md` 前 3 行内加一行，写明「归档时有 N 个未勾选框（N 用 `grep -c '\[ \]'` 数），见 epic-audit 结论」。
- `ROADMAP.md:36`（Capability Builder「Phase 1 of 4」）与 NEXT 里的「3/4」不一致：不猜，处置表里列为需要人确认。

### 4.2 批 2 要点与契约变化（AR-002）
契约变化只有一条：**pack 可用性的 Tier 2 判据从 `.claude/skills/{name}/SKILL.md` 改为 `.agents/skills/{name}/SKILL.md`**。涉及 `alex/references/` 下 `intent-router-protocol.md:127`、`discuss-path-protocol.md:37`、`design-protocol.md:49`、`handoff-creation-protocol.md:244-245`、`publish-protocol.md:38,55`、`experiment-path-protocol.md:31,51,103`，以及 `research-github/SKILL.md:494`、`research-notebook/SKILL.md:446`。语义不变（「该 skill 已安装」），只是路径改到四家都存在的位置。这八个文件改完后不应再有任何 `.claude/skills` 字样。`alex/SKILL.md` 整个文件不动（里面成对检查两条路径的循环是对的）。`alex/references/research-plan-protocol.md:8` 的 `# Original source: .claude/skills/alex/SKILL.md` 是出处注释，保留并记入处置表。

`tad-init`：`mkdir -p .claude/commands`、`mkdir -p .claude/skills`、「Copy `.claude/skills/`」、「Create `CLAUDE.md` with TAD rules」这几步都改为指向安装器（手写的 `CLAUDE.md` 会与安装器维护的标记块冲突）。`tad-status`：`:20,:63-65`。`tad-help`：`:154-155`；它的 `Version: v3.2.0`（`:17`）必须保留（`version-sweep` 第 1 层）。`capability-upgrade/SKILL.md`：`:12,31,44,45`，改完后该文件不应再有 `.claude/skills`。

Alex 快速参考（`.tad/guides/tool-quick-reference-alex.md`）在 Alex 激活时被读入：保留 `:6`（现行的回退链 `local_wiki → websearch` 只在这一行）；删除 NotebookLM 弃用横幅与命令块（8–28）、`*research-notebook` 命令表（167–181）、已弃用行（187）、`trace-digest.sh` 行（198）、「Domain Packs (20 packs)」一节（200–204）；`:67,93,190` 里作为本仓路径出现的 `.claude/skills/` 改为 `.agents/skills/`；保留指向 Local Wiki 的现有说明。

其余按 grounding 的逐条处置。`.claude/` 出现在「不得改动框架自身」清单、`MUST NOT touch .claude/settings.json`、双路径循环、历史 `git show` 引用里的，都保留。

---

## 5. 强制问题回答
MQ1 历史搜索：grounding 对每条悬空引用查过 `git log --diff-filter=D`。MQ2 函数存在性：不适用（不改代码）。MQ3 数据流：不适用。MQ4：不适用。MQ5 状态同步：两棵 pack 树（NFR2）。MQ6：不适用。

---

## 6. Implementation Steps
0. `git status --porcelain -uall` 记基线；跑 `state-surface` 与 `skill-body-verify` 记起点；记下 `git rev-parse HEAD` 作 `P5_BASE`；对人未提交的三个文件算一次指纹：`git diff -- docs/pm/status.md .agents/skills/code-security/references/secret-detection-rules.md .tad/capability-packs/code-security/references/secret-detection-rules.md | shasum`，结束时再算一次，两次必须相同。
0.5.（批 1）重读 `.tad/runtime-compat/claude-code.md` 的 `hooks`、`workflows`、`release_sync_install` 行，以及 `git log --oneline -5 -- tad.sh .tad/templates/claude/`，按**已经提交**的状态写 hook、子代理、更新入口的说法。
1. 按批做。两批文件不相交，可由两个执行者并行；各自只碰 §7 里自己那一批。
2. 每改完一个文件，回 grounding 对应条目核一遍「现文」是否就是你改的那处。
3. 写各自那份处置表。
4. 跑 §9.1-RAW 脚本；`state-surface`；`skill-body-verify`。输出进 completion。

---

## 7. File Structure

### 7.1 批 1（文档与状态面）
Modify：`README.md`、`ROADMAP.md`、`AGENTS.md`、`PROJECT_CONTEXT.md`、`OBJECTIVES.md`、`NEXT.md`、`docs/MULTI-PLATFORM.md`、`docs/CODEX-USER-GUIDE.md`、`docs/value-proposition.md`、`docs/process-tax-cut.md`、`.tad/active/session-state.md`、`.tad/active/TICKET-20261006-epic-p1-clearance.md`、`.tad/active/TICKET-20261006-epic-p3-runtime.md`、`.tad/active/TICKET-20261006-epic-p2-measurement.md`（如归档前需修引用则改，否则直接移）、`.tad/brain-index.md`、`.tad/project-knowledge/patterns/ac-verification.md`、`.tad/decisions/DR-20260831-yolo2-phase2-scope-proof-amendment-r2.md`、`.tad/active/designs/AUDIT-20260816-framework-health.md`
Create：`.tad/archive/next/NEXT-completed-through-20261008.md`（`git add -f`）、`.tad/archive/session-state/session-state-through-20261006.md`、`.tad/evidence/designs/phase5a-disposition-batch1.md`
Move（普通 `mv`）：11 张 ticket → `.tad/archive/tickets/`；`.tad/active/epics/framework-health-repair/` 与 `EPIC-20260816-framework-health-repair.md` → `.tad/archive/epics/`

### 7.2 批 2（skill、指南、配置）
Modify：`.agents/skills/alex/references/{intent-router,discuss-path,design,handoff-creation,publish,experiment-path}-protocol.md`、`.agents/skills/{research-github,research-notebook,tad-init,tad-status,tad-help,capability-upgrade}/SKILL.md`、`.agents/skills/product-thinking/README.md`、`.agents/skills/product-thinking/references/pressure-test-rubric.md`（`.tad/capability-packs/` 下的孪生副本不改，见 NFR2）、`.tad/guides/{tool-quick-reference-alex,pack-collision-detection,nondev-execution-track,tool-quick-reference-blake,cross-model-invocation}.md`、`.tad/hooks/lib/parity-criterion.md`、`.tad/codex/README.md`、`.tad/dependencies/REGISTRY.yaml`、`.tad/config.yaml`、`.tad/ralph-config/expert-criteria.yaml`、`.tad/templates/acceptance-verification-guide.md`
Create：`.tad/evidence/designs/phase5a-disposition-batch2.md`

### 7.3 两批都不得碰
`tad.sh`、`bin/`、`.tad/tests/`、`.tad/scripts/`、`.tad/workflows/`、`.tad/capability-packs/`、`.agents/skills/alex/SKILL.md`、`.tad/hooks/` 下除 `lib/parity-criterion.md` 外的一切、`.tad/templates/claude/`、`.tad/provenance/`、`INSTALLATION_GUIDE.md`、`.tad/runtime-compat/`、`.tad/project-knowledge/patterns/runtime-adapter-*`、`package.json`、`.tad/version.txt`、`CHANGELOG.md`、`docs/pm/status.md`、两份 `secret-detection-rules.md`、`.claude/` 下任何东西、`.tad/active/epics/capability-builder-v1/` 与 `EPIC-20260831-capability-builder-v1.md`、本 Epic 文件、`.tad/active/handoffs/`。
（另一个执行者正在改 `tad.sh` 与安装器文档；上面这些正是它的文件集。）

---

## 8. Testing Requirements

### 8.3 Edge Cases
移动小节后 NEXT.md 里出现空的二级标题（删掉空标题）；归档目标目录被忽略导致文件没进跟踪（NEXT 归档文件必须在 `git ls-files` 里）；改 `AGENTS.md` 后 `state-surface` check8 变红；pack 文件只改了一棵树；把描述安装目标的 `.claude/` 路径误改成 `.agents/`。

## 8.4 Friction Preflight
| 可能的摩擦 | 预案 |
|---|---|
| grounding 的行号已漂移 | 以「现文」定位，不以行号 |
| 某条处置与现状不符（已被别人改过） | 处置表记 DONE-ALREADY，不硬改 |
| 拿不准一个 `.claude/` 引用属于哪一类 | 保留不改，在处置表里列为「未定，留给 Alex」 |

## 8.5 Feedback Collection
completion 里单列「grounding 或本单哪条在实施时发现不成立」。

---

## 9. Acceptance Criteria
- [ ] AC1 NEXT.md ≤ 500 行、没有 `### ✅` 小节；归档文件在 git 跟踪里且含被移走的小节标题。
- [ ] AC2 口径：§9.1-RAW 列出的过时语句在六份文档里计数为 0；`AGENTS.md` 的 Runtime status 块提到四家与 `--platform claude-code`。
- [ ] AC3 pack 可用性判断不再只看 `.claude/skills/`。
- [ ] AC4 grounding A.3 的悬空引用在活跃面里计数为 0（留在 5b 或属于人的除外，脚本里列明）。
- [ ] AC5 活跃面只剩 1 张 ticket；`framework-health-repair` 不在 `active/epics/`；`capability-builder-v1` 原样。
- [ ] AC6 `state-surface` exit 0；`skill-body-verify` 通过；§7.3 的文件无改动。
- [ ] AC7 两份处置表存在；批 1 那份里 Epic Notes 12 条逐条有处置与依据。
- [ ] AC8 NEXT.md 有「Carried from completed sections」小节；安全承诺的旧说法计数为 0；六份文档里没有「first-class」类措辞。

## 9.1 Spec Compliance Checklist

基线（2026-10-09，`P5_BASE=dd22d2f1`，第 3 版脚本，审查者在 `/bin/bash` 3.2 下跑）：90 项 FAIL、26 项 ok、1 项 PEND；审查者把定稿文字套到文档副本上后，文档类检查全部通过。标为 PEND 的一行（NEXT 归档文件进 git 跟踪）只有 Conductor 能做，不计入失败。已通过的都是回归守卫（门禁、不得改动的文件、应保留的字符串）。GUARD 的「forbidden paths」在并行的 4a-2 提交之前会把它的改动算进来。

### §9.1-RAW — 可运行正本

```bash
# Phase 5a acceptance script (handoff revision 3). Read-only. Run from the repo root:
#   P5_BASE=<commit before this task> bash <this> ALL | B1 | B2 | GUARD
set -u
REPO="$(pwd -P)"; [ -f "$REPO/tad.sh" ] && [ -d "$REPO/.tad" ] || { echo "run from repo root"; exit 2; }
BASE="${P5_BASE:-HEAD}"
FAILS=0
PENDING=0
ok(){ echo "  ok   $*"; }
# cond: a result only the Conductor can make true (git add -f); reported, not counted as FAIL
cond(){ if [ "$2" = "$3" ]; then ok "$1 = $3"; else echo "  PEND $1: got '$2' want '$3' (Conductor step)"; PENDING=$((PENDING+1)); fi; }
bad(){ echo "  FAIL $*"; FAILS=$((FAILS+1)); }
chk(){ local l="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$l"; else bad "$l"; fi; }
eq(){ if [ "$2" = "$3" ]; then ok "$1 = $3"; else bad "$1: got '$2' want '$3'"; fi; }
ge(){ if [ "${2:-0}" -ge "$3" ] 2>/dev/null; then ok "$1 ($2, need at least $3)"; else bad "$1: got '${2:-}' need at least $3"; fi; }
# cnt/cntE <pattern> <file...> -> matching lines across the files (missing files count 0)
cnt(){ local s="$1"; shift; cat "$@" 2>/dev/null | grep -cF -- "$s" | tr -d ' '; }
cntE(){ local s="$1"; shift; cat "$@" 2>/dev/null | grep -ciE -- "$s" | tr -d ' '; }
D6="README.md AGENTS.md ROADMAP.md PROJECT_CONTEXT.md docs/MULTI-PLATFORM.md docs/CODEX-USER-GUIDE.md"
D5="README.md ROADMAP.md PROJECT_CONTEXT.md docs/MULTI-PLATFORM.md docs/CODEX-USER-GUIDE.md"

B1(){ echo "== B1 documents and state surface"
  # --- NEXT.md
  ge "NEXT.md is at most 500 lines (500 - lines)" "$(( 500 - $(wc -l < NEXT.md | tr -d ' ') ))" 0
  eq "completed sections left in NEXT.md" "$(grep -cE '^### ([0-9]+[a-z]?\. )?✅' NEXT.md | tr -d ' ')" 0
  eq "priority-queue H2 headings in NEXT.md" "$(grep -c '^## 🔴 优先队列' NEXT.md | tr -d ' ')" 1
  eq "'Carried from completed sections' headings in NEXT.md" "$(grep -c '^### Carried from completed sections' NEXT.md | tr -d ' ')" 1
  ge "open items carried (-> archive: lines inside the Carried section)" "$(awk '/^### Carried from completed sections/{f=1;next} f&&/^##+ /{exit} f&&/-> archive:/' NEXT.md | wc -l | tr -d ' ')" 5
  local A=.tad/archive/next/NEXT-completed-through-20261008.md hmiss=0 h
  cond "NEXT archive file tracked by git" "$(git ls-files -- "$A" | wc -l | tr -d ' ')" 1
  while IFS= read -r h; do grep -qxF -- "$h" "$A" 2>/dev/null || { hmiss=$((hmiss+1)); echo "    missing in archive: $h"; }; done <<EOF
$(git show "$BASE:NEXT.md" | grep -E '^### ([0-9]+[a-z]?\. )?✅')
EOF
  eq "completed-section headings of $BASE missing from the archive" "$hmiss" 0
  ge "archive size in lines (the moved sections are about 320 lines)" "$(wc -l < "$A" 2>/dev/null | tr -d ' ')" 300
  eq "NEXT.md still points at .tad/ideas/ (should be .tad/active/ideas/)" "$(grep -cE '(^|[^e])\.tad/ideas/' NEXT.md | tr -d ' ')" 0
  eq "NEXT.md points at the research-mechanism files under active/handoffs" "$(grep -c 'active/handoffs/.*tad-research-mechanism' NEXT.md | tr -d ' ')" 0
  eq "NEXT.md ACTIVE entry still says 'Next: Phase 2 installer'" "$(grep -c 'Next: Phase 2 installer' NEXT.md | tr -d ' ')" 0
  # --- stale statements that must be gone
  eq "docs say hooks are missing, planned, P2 or a known gap" "$(cat $D5 | grep -iE '(no|without|lacks?|missing) (lifecycle )?hooks?|hooks?[^.|]{0,40}(not yet|planned|known gap|unsupported|codex[- ]only)|codex[- ]only[^.|]{0,30}hooks?|hooks? P2|P2[^.|]{0,40}(hook|not yet|known gap)|do(es)? not ship[^.|]{0,20}hooks?|\(Platform Adapters P2' | grep -vciE 'implemented' | tr -d ' ')" 0
  eq "install-target lists that stop at three (codex|opencode|cursor)" "$(cat $D6 | grep -cE '(targets?|accepts|目标)[^.]{0,20}`codex\\?\|opencode')" 0
  eq "README quick-install line without claude-code" "$(grep -E '^bash tad\.sh --platform' README.md | grep -vc 'claude-code' | tr -d ' ')" 0
  eq "docs say the Claude Code target is removed or unavailable" "$(cntE 'claude.{0,60}(已移除|已在 v3\.0\.0 移除|不再提供|path removed|RETIRED in v3)|claude-code. 自 v3' $D5)" 0
  eq "'Claude Code via AGENTS.md' / 'Via AGENTS.md' status cells" "$(cntE 'Claude Code via AGENTS\.md|\| *Via AGENTS\.md|served at instruction level' $D6)" 0
  eq "'no separate installer target' / 'no installer target on that runtime'" "$(cntE 'no separate installer target|no installer target on that runtime' $D6)" 0
  eq "'Supported Harnesses (Codex · OpenCode · Cursor)'" "$(cnt 'Supported Harnesses (Codex · OpenCode · Cursor)' $D6)" 0
  eq "'all three' anywhere in README (the AGENTS.md block is checked separately below)" "$(cntE 'all three' README.md)" 0
  eq "'workflow runtime was removed'" "$(cnt 'workflow runtime was removed' docs/MULTI-PLATFORM.md)" 0
  eq "MULTI-PLATFORM footer or header still says v3.0.0 / legacy adapter / ledger retired" "$(cntE 'TAD v3\.0\.0 —|legacy adapter|legacy — historical record|legacy install path' docs/MULTI-PLATFORM.md)" 0
  eq "retired *sync command presented as current" "$(cntE '\*sync. run from the repo|`\*publish` / `\*sync`|\*sync. 同步 TAD 到注册项目' docs/MULTI-PLATFORM.md docs/CODEX-USER-GUIDE.md)" 0
  eq "unqualified .claude safety promises (paragraph mentions .claude and a never-touch promise, with no claude-code or byte-for-byte qualifier)" "$(cat README.md docs/MULTI-PLATFORM.md docs/CODEX-USER-GUIDE.md | awk -v RS= '/\.claude/ && /never delet|never touch|never read|不会\**删除|不删除|原样保留|字节不变|stay byte-identical/ && !/claude-code|逐字节|byte-for-byte/' | grep -c . | tr -d ' ')" 0
  eq "the Epic's original stale-wording grep" "$(grep -nE 'no longer offered|was removed in TAD v3\.0\.0|Returns: "codex" \| "none"' README.md ROADMAP.md AGENTS.md .tad/hooks/lib/detect-platform.sh | wc -l | tr -d ' ')" 0
  eq "README still counts '14 registered downstream' projects" "$(tr '\n' ' ' < README.md | grep -c '14 registered  *downstream' | tr -d ' ')" 0
  eq "'*sync to 14 projects' (PROJECT_CONTEXT live line)" "$(cnt '*sync to 14 projects' PROJECT_CONTEXT.md)" 0
  eq "'operator's 14 projects' (value-proposition)" "$(cnt "operator's 14 projects" docs/value-proposition.md)" 0
  chk "PROJECT_CONTEXT keeps the 2026-05 release-history line" grep -qF 'SYNCED to 14 projects' PROJECT_CONTEXT.md
  eq "stale pack counts in live lines" "$(cat README.md PROJECT_CONTEXT.md | grep -ciE '24-pack|全部 25 个|\+ 25 capability packs' | tr -d ' ')" 0
  ge "live pack-count lines carrying the real number ($(ls -d .tad/capability-packs/*/CAPABILITY.md | wc -l | tr -d ' '))" "$(cat README.md PROJECT_CONTEXT.md | grep -ciE "$(ls -d .tad/capability-packs/*/CAPABILITY.md | wc -l | tr -d ' ')([- ]pack| 个 capability| capability packs)" | tr -d ' ')" 4
  chk "ROADMAP names the four harnesses and the claude-code installer value" sh -c 'grep -qE "Claude Code, Codex, OpenCode,? and Cursor" ROADMAP.md && grep -qE "accepts .claude-code" ROADMAP.md'

  eq "ROADMAP still lists framework health repair as active backlog" "$(awk '/^### Framework health repair/{f=1;next} f&&/^##/{exit} f' ROADMAP.md | grep -ci 'active backlog' | tr -d ' ')" 0
  # --- over-claims that must not appear
  eq "over-claims (first class / tier-1 / hook-enabled / verified or tested on all four)" "$(cat $D6 | grep -ciE 'first[- ]?class|一等|tier-?1|hook-enabled|hook-capable|(verified|tested|validated)[^.]{0,30}(all|every) (four|harness)|(all|every) (four|harness)[^.]{0,60}(verified|tested|hook-enabled|hook-capable|equally)' | tr -d ' ')" 0
  eq "new 3.3.0 tokens in the six documents" "$(cat $D6 | grep -c '3\.3\.0' | tr -d ' ')" "$(for f in $D6; do git show "$BASE:$f" 2>/dev/null; done | grep -c '3\.3\.0' | tr -d ' ')"
  # --- statements that must now be present
  ge "README names the four install targets together" "$(grep -cE 'claude-code\|codex\|opencode\|cursor' README.md | tr -d ' ')" 2
  chk "README keeps 'Version 3.2.0' (version-sweep)" grep -qF 'Version 3.2.0' README.md
  chk "README says --platform both is still rejected" grep -qE 'platform both.{0,20}(仍被拒绝|still rejected|is rejected)' README.md
  local RS; RS="$(mktemp "${TMPDIR:-/tmp}/p5a-rs.XXXXXX")"; awk '/Runtime status/{f=1} f&&!/^>/{exit} f' AGENTS.md > "$RS" 2>/dev/null
  chk "AGENTS.md runtime-status block names all four harnesses" sh -c 'grep -q "Claude Code" "$1" && grep -q Codex "$1" && grep -q OpenCode "$1" && grep -q Cursor "$1"' _ "$RS"
  chk "AGENTS.md runtime-status block names the claude-code install target" grep -qF 'claude-code' "$RS"
  chk "AGENTS.md runtime-status block explains how Claude Code gets skills and hooks" sh -c 'grep -q "\.claude/skills" "$1" && grep -q "settings\.json" "$1"' _ "$RS"
  eq "AGENTS.md runtime-status block: literals that break state-surface check8" "$(grep -cE 'no lifecycle hooks|the \*\*hook-enabled\*\* runtime|currently get skills \+ routing \+ packs|[Aa]ll three' "$RS" | tr -d ' ')" 0
  rm -f -- "$RS"
  chk "AGENTS.md keeps the '(implemented' fact line that check8 reads" grep -qF 'Hook adapters (implemented' AGENTS.md
  chk "AGENTS.md Known Gaps P4 bullet names Claude Code" sh -c 'grep -E "^- \*\*P4" AGENTS.md | grep -q "Claude Code"'
  chk "AGENTS.md TAD_PLATFORM values include claude-code" grep -qE 'TAD_PLATFORM=.*claude-code' AGENTS.md
  eq "MULTI-PLATFORM status table rows for Claude Code" "$(grep -c '^| \*\*Claude Code\*\*' docs/MULTI-PLATFORM.md | tr -d ' ')" 1
  chk "that row names --platform claude-code" sh -c 'grep "^| \*\*Claude Code\*\*" docs/MULTI-PLATFORM.md | grep -qF -- "--platform claude-code"'
  chk "that row carries an evidence caveat" sh -c 'grep "^| \*\*Claude Code\*\*" docs/MULTI-PLATFORM.md | grep -qiE "headless|not (yet )?(run|measured)"'
  ge "MULTI-PLATFORM status table rows for the other three" "$(grep -cE '^\| \*\*(Codex|OpenCode|Cursor)\*\*' docs/MULTI-PLATFORM.md | tr -d ' ')" 3
  chk "MULTI-PLATFORM keeps its 3.2.0 version line (version-sweep)" grep -qE 'Version.*: 3\.2\.0' docs/MULTI-PLATFORM.md
  chk "safety wording now distinguishes the claude-code target" sh -c 'grep -qE "byte-for-byte|逐字节" README.md && grep -qE "byte-for-byte|逐字节" docs/MULTI-PLATFORM.md && grep -qE "逐字节|byte-for-byte" docs/CODEX-USER-GUIDE.md'
  eq "version.txt" "$(tr -d '[:space:]' < .tad/version.txt)" 3.2.0
  # --- other documents
  eq "value-proposition.md cites .claude/skills as repo paths" "$(grep -c '\.claude/skills/' docs/value-proposition.md | tr -d ' ')" 0
  chk "process-tax-cut.md points at the archived Epic" grep -qF '.tad/archive/epics/EPIC-20260912-p2-process-tax-cut.md' docs/process-tax-cut.md
  eq "OBJECTIVES O3 KR1/KR2 rows still describe the NotebookLM notebook as current" "$(grep -E '^\| KR[12] ' OBJECTIVES.md | grep -cE 'in NotebookLM notebook|notebook active \(37cfefa5' | tr -d ' ')" 0
  ge "OBJECTIVES O3 KR1/KR2 rows pointing at the Local Wiki" "$(grep -E '^\| KR[12] ' OBJECTIVES.md | grep -cE 'research/(wiki|canon|raw)|Local Wiki' | tr -d ' ')" 2
  eq "OBJECTIVES O3 Why line still calls the knowledge base a NotebookLM notebook" "$(grep -c 'A persistent NotebookLM notebook' OBJECTIVES.md | tr -d ' ')" 0
  # --- tickets and epics
  eq "tickets left in .tad/active" "$(ls .tad/active/TICKET-*.md 2>/dev/null | wc -l | tr -d ' ')" 1
  chk "the Codex ledger ticket is the one that stays" test -f .tad/active/TICKET-20260916-codex-ledger-reverification.md
  eq "tickets in the archive" "$(ls .tad/archive/tickets/TICKET-*.md 2>/dev/null | wc -l | tr -d ' ')" 11
  eq "archived items still tracked by git (plain mv, not git mv)" "$(git ls-files -- .tad/archive/tickets .tad/archive/epics/framework-health-repair .tad/archive/epics/EPIC-20260816-framework-health-repair.md .tad/archive/session-state | wc -l | tr -d ' ')" 0
  eq "the two stale tickets carry CLOSED in their first 8 lines" "$(n=0; for t in epic-p1-clearance epic-p3-runtime; do head -8 ".tad/archive/tickets/TICKET-20261006-$t.md" 2>/dev/null | grep -q CLOSED && n=$((n+1)); done; echo $n)" 2
  eq "framework-health-repair still under active/epics" "$(ls -d .tad/active/epics/framework-health-repair .tad/active/epics/EPIC-20260816-framework-health-repair.md 2>/dev/null | wc -l | tr -d ' ')" 0
  chk "framework-health-repair is in the archive" test -f .tad/archive/epics/framework-health-repair/EPIC.md
  chk "its stub moved too" test -f .tad/archive/epics/EPIC-20260816-framework-health-repair.md
  chk "archived EPIC.md notes its unticked boxes in the first 3 lines" sh -c 'head -3 .tad/archive/epics/framework-health-repair/EPIC.md | grep -q "未勾选"'
  eq "live references to the old Epic location" "$(git grep -lE 'active/epics/(EPIC-20260816-)?framework-health-repair' -- . ':!.tad/active/handoffs' ':!.tad/active/epics/EPIC-20261008-multi-harness-restore-and-cleanup.md' ':!CHANGELOG.md' ':!docs/pm' ':!.tad/memory' 2>/dev/null | wc -l | tr -d ' ')" 0
  chk "capability-builder-v1 Epic untouched (folder)" test -d .tad/active/epics/capability-builder-v1
  eq "capability-builder-v1 files changed since $BASE" "$(git diff --name-only "$BASE" -- .tad/active/epics/capability-builder-v1 .tad/active/epics/EPIC-20260831-capability-builder-v1.md | wc -l | tr -d ' ')" 0
  # --- session-state (local, ignored file)
  eq "session-state.md still carries the closed hillclimb task" "$(grep -c 'TASK-20260929-AGENT-EVAL-HILLCLIMB-L2' .tad/active/session-state.md 2>/dev/null | tr -d ' ')" 0
  eq "session-state.md still says Last Updated 2026-09-29" "$(grep -c 'Last Updated.*2026-09-29' .tad/active/session-state.md 2>/dev/null | tr -d ' ')" 0
  chk "session-state body points at the Epic Phase Map" sh -c 'awk "/^##/{f=1} f" .tad/active/session-state.md | grep -q "Phase Map"'
  chk "session-state archive written" test -s .tad/archive/session-state/session-state-through-20261006.md
  # --- release gates
  ( bash .tad/hooks/lib/release-verify.sh state-surface . >/dev/null 2>&1 ); eq "state-surface rc" "$?" 0
  ( bash .tad/hooks/lib/release-verify.sh version-sweep . 3.2.0 >/dev/null 2>&1 ); eq "version-sweep rc" "$?" 0
  chk "disposition table (batch 1) exists" test -s .tad/evidence/designs/phase5a-disposition-batch1.md
  local N=.tad/evidence/designs/phase5a-disposition-batch1.md i miss=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do awk -F'|' -v n="$i" '/^#+ .*Epic [Nn]otes/{s=1;next} s&&/^#+ /{s=0} s&&$2 ~ /^ *[0-9]+ *$/ && $2+0==n && $3 ~ /[^ ]/ && $4 ~ /[^ ]/ && $5 ~ /[^ ]/ {f=1} END{exit !f}' "$N" 2>/dev/null || { miss=$((miss+1)); echo "    no complete row for Epic note $i"; }; done
  eq "Epic notes 1-12 lacking a row with disposition and evidence" "$miss" 0; }

B2(){ echo "== B2 skills, guides, config"
  local R=.agents/skills/alex/references f1
  local F1="$R/intent-router-protocol.md $R/discuss-path-protocol.md $R/design-protocol.md $R/handoff-creation-protocol.md $R/publish-protocol.md $R/experiment-path-protocol.md .agents/skills/research-github/SKILL.md .agents/skills/research-notebook/SKILL.md"
  eq "pack-availability files still citing .claude/skills" "$(cat $F1 | grep -c '\.claude/skills' | tr -d ' ')" 0
  for f1 in $F1; do ge "uses .agents/skills: $f1" "$(grep -c '\.agents/skills' "$f1" | tr -d ' ')" 1; done
  chk "intent-router Tier 2 wording" grep -qF 'Tier 2: .agents/skills/{name}/SKILL.md exists' $R/intent-router-protocol.md
  eq "alex/SKILL.md changed since $BASE" "$(git diff --name-only "$BASE" -- .agents/skills/alex/SKILL.md | wc -l | tr -d ' ')" 0
  chk "provenance comment in research-plan-protocol.md kept" grep -qF 'Original source: .claude/skills/alex/SKILL.md' $R/research-plan-protocol.md
  local Q=.tad/guides/tool-quick-reference-alex.md
  eq "quick reference: 'Domain Packs (20 packs)'" "$(grep -cF 'Domain Packs (20 packs)' $Q | tr -d ' ')" 0
  eq "quick reference: trace-digest.sh" "$(grep -cF 'trace-digest.sh' $Q | tr -d ' ')" 0
  eq "quick reference: tools-registry.yaml" "$(grep -cF 'tools-registry.yaml' $Q | tr -d ' ')" 0
  eq "quick reference: *research-notebook command table" "$(grep -cF '*research-notebook' $Q | tr -d ' ')" 0
  eq "quick reference: .claude/skills used as a repo path" "$(grep -c '\.claude/skills/' $Q | tr -d ' ')" 0
  chk "quick reference keeps the fallback-chain line" grep -qF 'local_wiki → websearch' $Q
  eq "other guides citing .claude/skills as repo paths" "$(grep -c '\.claude/skills' .tad/guides/pack-collision-detection.md .tad/guides/nondev-execution-track.md .tad/guides/tool-quick-reference-blake.md .tad/guides/cross-model-invocation.md .tad/hooks/lib/parity-criterion.md | awk -F: '{n+=$NF} END{print n+0}')" 0
  eq "tad-init manual-install steps" "$(grep -cE 'mkdir -p \.claude/(commands|skills)|Copy .*\.claude/skills|Create `CLAUDE\.md`' .agents/skills/tad-init/SKILL.md | tr -d ' ')" 0
  chk "tad-init points at the installer" grep -qE 'tad\.sh|npx github:Sheldon-92/TAD' .agents/skills/tad-init/SKILL.md
  eq "tad-status .claude/skills or pinned 2.4" "$(grep -cE '\.claude/skills|should read 2\.4' .agents/skills/tad-status/SKILL.md | tr -d ' ')" 0
  chk "tad-status checks .agents/skills/alex/SKILL.md" grep -qF '.agents/skills/alex/SKILL.md' .agents/skills/tad-status/SKILL.md
  eq "tad-help .claude/skills repo paths" "$(grep -c '\.claude/skills' .agents/skills/tad-help/SKILL.md | tr -d ' ')" 0
  chk "tad-help keeps its version pin (version-sweep)" grep -qE 'Version: v3\.2\.0' .agents/skills/tad-help/SKILL.md
  eq "capability-upgrade .claude/skills" "$(grep -c '\.claude/skills' .agents/skills/capability-upgrade/SKILL.md | tr -d ' ')" 0
  eq "codex README names the deleted parity script" "$(grep -cF 'codex-parity-check.sh' .tad/codex/README.md | tr -d ' ')" 0
  eq "dependency registry names the wrong post-write-sync path" "$(grep -cF '.tad/hooks/lib/post-write-sync.sh' .tad/dependencies/REGISTRY.yaml | tr -d ' ')" 0
  chk "dependency registry names the real post-write-sync path" grep -qF '.tad/hooks/post-write-sync.sh' .tad/dependencies/REGISTRY.yaml
  eq "config.yaml names the deleted config-full-backup.yaml" "$(grep -cF 'config-full-backup.yaml' .tad/config.yaml | tr -d ' ')" 0
  eq "expert-criteria.yaml names the template that never existed" "$(grep -cF 'code-review-format.md' .tad/ralph-config/expert-criteria.yaml | tr -d ' ')" 0
  # product-thinking is the only twinned set; its capability-packs copy already says .agents and must not be edited
  chk "product-thinking rubric twins identical after the edit" cmp -s .agents/skills/product-thinking/references/pressure-test-rubric.md .tad/capability-packs/product-thinking/references/pressure-test-rubric.md
  eq "product-thinking README twins: differing lines" "$(diff .agents/skills/product-thinking/README.md .tad/capability-packs/product-thinking/README.md | grep -c '^[<>]' | tr -d ' ')" 2
  eq "product-thinking README names .claude/skills" "$(grep -c '\.claude/skills' .agents/skills/product-thinking/README.md | tr -d ' ')" 0
  eq "capability-packs tree edited (excluding the human's code-security file)" "$(git diff --name-only "$BASE" -- .tad/capability-packs ':!.tad/capability-packs/code-security' | wc -l | tr -d ' ')" 0
  ( bash .tad/hooks/lib/skill-body-verify.sh >/dev/null 2>&1 ); eq "skill-body-verify rc" "$?" 0
  chk "disposition table (batch 2) exists" test -s .tad/evidence/designs/phase5a-disposition-batch2.md; }

GUARD(){ echo "== guard: files this task must not touch (judge with the right P5_BASE once parallel work has landed)"
  eq "forbidden paths changed since $BASE" "$(git diff --name-only "$BASE" -- tad.sh bin .tad/tests .tad/scripts .tad/workflows .tad/templates/claude .tad/provenance INSTALLATION_GUIDE.md .tad/runtime-compat package.json .tad/version.txt CHANGELOG.md .agents/skills/alex/SKILL.md .tad/active/handoffs | wc -l | tr -d ' ')" 0
  eq "hook scripts changed since $BASE" "$(git diff --name-only "$BASE" -- .tad/hooks | grep -vc 'lib/parity-criterion.md$' | tr -d ' ')" 0
  eq "files under .claude/ tracked by git" "$(git ls-files .claude | wc -l | tr -d ' ')" 0
  chk "provenance gate" bash .tad/hooks/lib/release-verify.sh provenance .
  echo "  note fingerprint of the human's three uncommitted files (compare with the value recorded at step 0): $(git diff -- docs/pm/status.md .agents/skills/code-security/references/secret-detection-rules.md .tad/capability-packs/code-security/references/secret-detection-rules.md | shasum | cut -c1-12)"; }

[ $# -ge 1 ] || { echo "usage: $0 ALL | B1 | B2 | GUARD"; exit 2; }
[ "$1" = ALL ] && set -- B1 B2 GUARD
for c in "$@"; do case "$c" in B1|B2|GUARD) "$c";; *) echo "unknown case $c"; exit 2;; esac; done
echo "== TOTAL FAILS: $FAILS   PENDING (Conductor): $PENDING"
[ "$FAILS" -eq 0 ]
```

注意：另一个执行者同时在改 `tad.sh` 等文件，所以 GUARD 的两条「changed since」在它提交之前会把它的改动也算进来。并行期间以 B1、B2 为准；GUARD 由 Conductor 在两边都落定后用正确的 `P5_BASE` 判定。

## 9.2 Expert Review Status
### Audit Trail
（Gate 2 审查后填写）
### Experts Selected
code-reviewer（必选）、docs-writer（文档口径）。

| 轮次 | 审查 | 结论 | 处置 |
|---|---|---|---|
| 1 | docs-writer | CONDITIONAL PASS：4 P0、7 P1、8 P2 | P0-1、P0-2 → §2 措辞规则与 §10.1；P0-3 → FR1b；P0-4、P1-6 → 脚本 B1 重写；P1-1 → 发布暂存、第 0.5 步、§10.2；P1-2 → FR1；P1-3、P1-4 → FR2；P1-5 → FR3；P1-7 → §4.1。其定稿文字作为规范性附件 |
| 2 | code-reviewer | CONDITIONAL PASS：0 P0、6 P1、9 P2（`phase5a-design-review-r2.md`） | N1、N3、N4、N5、N6 → 采用审查者打过补丁并实测的脚本；N2 → FR1 补两行；另补 `mkdir`、`##` 标题、Epic Notes 小节标题。两轮后 0 P0，Gate 2 通过 |
| 1 | code-reviewer | CONDITIONAL PASS：3 P0、8 P1、9 P2 | P0-1 → 脚本 F1 检查；P0-2 → NFR2 与孪生检查；P0-3 → `14 projects` 检查；P1-1 → 普通 `mv`；P1-2 → 活引用正则；P1-3 → skill 检查；P1-4 → FR2 与标题检查；P1-5 → 两份处置表；P1-6 → §4.1 门禁写法与两条门禁检查；P1-7 → 语义正则；P1-8 → OBJECTIVES 检查；P2-2、7、8 已改入 |

---

## 10. Important Notes

### 10.1 Critical Warnings
- 这些改动是发布暂存的：描述下一个版本的状态，Phase 6 改版本号之前不得推送或合并。
- 六份文档里不得出现「first-class」「一等」「verified on all four」。
- 不提交、不推送。所有改动留在工作区，由 Conductor 提交（NEXT 归档文件的 `git add -f` 也由 Conductor 做；Blake 只需把文件写好，验收脚本那一行在 Conductor 暂存后才会变绿，completion 里注明即可）。
- 不读、不列、不改本仓的 `.claude/`。
- 不写未经验证的声明：四家真机回归尚未做。
- 拿不准就保留，并在处置表里说明。

### 10.2 Known Constraints / 明确延后
- `INSTALLATION_GUIDE.md` 里的三处过时说法、`runtime-freshness-verify.sh` 的过时注释、workflow 脚本的四处问题、fixture 的五项基线失败、`package.json` 的 test 脚本与 keywords、依赖扫描与 GitHub Registry 扫描、路径检查器、根目录旧 `tad` 脚本、`tad-update.sh` 的过时注释、`startup-health.sh` 告警、`tad-install.mjs` 行为用例：Phase 5b。
- `.tad/runtime-compat/claude-code.md:34` 的畸形行：已交给 4a-2 的执行者。
- Epic 验收标准的改写：Conductor。
- Phase 4b 收尾时要翻转 MULTI-PLATFORM 状态表里 Claude Code、Codex 两行与 `AGENTS.md` P4 条的证据状态；Phase 6 要统一处理各处 `3.2.0` 字样（清单见文档审查 §3.5 第 3 点）。两条都由 Conductor 记进 Epic。
- 归档后，若干被跟踪的文件会指向被 git 忽略的归档目录（干净克隆里不存在）：这是既有惯例，处置表里列一次。
- `docs/pm/status.md` 的版本、两份 `secret-detection-rules.md`：等人处理。

### 10.3 Sub-Agent 使用建议
批 1、批 2 各一个执行者并行。

---

## 11. Decision Summary
见 §1.4。

## 12. Sub-Agent使用记录
（Blake 填写）

## Required Evidence Manifest
- `.tad/evidence/designs/phase5a-disposition-batch1.md`、`phase5a-disposition-batch2.md`
- `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5a-completion-batch1.md`、`phase5a-completion-batch2.md`：基线、验收脚本对应用例的完整输出、`state-surface` 与 `skill-body-verify` 输出、§8.5 反馈。
