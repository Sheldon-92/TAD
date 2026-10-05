---
task_type: mixed
e2e_required: no
research_required: no

git_tracked_dirs: []

skip_knowledge_assessment: no

gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-09-04
**Project:** TAD Framework (upstream, self-hosted)
**Task ID:** TASK-20260904-001
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-09-04

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review complete (min 2) | ✅ | R1: 2 名独立 reviewer（gate-design + compat/carrier lens）均 FAIL，8 个 P0；R2: re-review 确认 8/8 P0 closed → PASS。详见 §9.2 Audit Trail |
| All P0 resolved | ✅ | 8/8 closed（F1–F6 修订；R2 逐条确认）。残留仅 P2 polish（HTML-comment token ban、exclusion-regex proof AC，已转 AC） |
| Architecture complete | ✅ | 加法式、可选式；§4 给出精确插入位置、文法、优先级、载体归属 |
| Components specified | ✅ | 2 个组件：① completion-report.md 尾部可选节（3 行）② CHANGELOG `### Upgrade Notes` 约定（无新文件） |
| Functions verified | ✅ | 无新函数调用；只涉及模板文本 + 文档约定。消费者读取惯用法（§4.5）为 BSD-safe grep/sed 管道，MQ2 表见 §5 |
| Data flow mapped | ✅ | 单一载体：COMPLETION 文件内（PM 行）+ CHANGELOG 文件内（Upgrade Notes）；无跨文件同步，§5 MQ5 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 0. Socratic Inquiry Summary & Gate 1

**Task**: 在 TAD 上游设计可选、向后兼容的 PM bridge：completion template 增加可选 3 行（PM 进展）；小版本升级注记（what/upgrade/rollback）。不得破坏现有 Gates、handoffs、evidence 路径、角色分工。设计先行（handoff + Gate 2）。

**Complexity**: small（单模板文件文本增补 + 文档约定；零 Gate/hook/证据路径改动；见 §4 §7）

**Questions Asked**（基于用户指令已明确 small/optional/compat 约束，按 small 档 2–3 问 + 边界锁定；用户以"Design first"授权直接出设计，人类在 Gate 2 / §9.2 审计链处复核）:

1. （价值）PM 行的消费者是谁、用来做什么决策？→ 假设：人类 PM 快速浏览 + 未来脚本可选读取；**永不参与 Gate 判定**（advisory-only，§4.3）。若人类期望 PM 行参与门控，本设计不适用，需重开设计单。
2. （边界）"小版本升级注记"的载体是新文件还是复用 CHANGELOG？→ 裁定：v1 复用 CHANGELOG `### Upgrade Notes` 子节，**不新增 `UPGRADE-NOTES-*.md` 文件类**（避免 version-grep exclusion 契约债，见 §11 权衡）。
3. （风险）什么算"破坏"？→ 判定标准：现有 3 类解析器（`post-write-sync.sh` 的 `^gate3_verdict:` / `## Reflexion History` 分段、`pre-gate-check.sh` 的 checkbox 计数 / Handoff ID / KA 单行 / commit 占位检测、`release-verify.sh` version 模式）在旧文件（无 PM 节）与新文件（含 PM 节，含恶意载荷）下行为一致；Gate 1–4 清单零改动；证据路径零新增。

### Key Insights
- 两次专家审查一致指向同一形状：可选增补的最大风险不是"缺功能"，而是"新文本污染旧机器"（checkbox 计数、`Handoff ID` 无 `head -1` 提取）与"第二阻塞源"（PM-Blockers vs Friction Status）。
- 修订方向是"收窄"而非"加固"：advisory-only + 文法禁令表 + 复用既有载体（CHANGELOG），把验证成本压到 1 个模板文件。

### Clarified Requirements
- PM 节可选（缺席 = 无 PM 信息，消费者视为空，永不失败）；3 行各自可选（缺行 = 空）。
- Friction Status 是**唯一**阻塞权威；PM-Blockers 是非权威镜像；分歧 → WARN。
- v1 不碰任何 verifier/parser 代码；约束只落在模板文本（禁令表）+ §9.1 负控 AC。

### Risks Identified
- R1: PM 自由文本注入 `[...] /**Handoff ID:**/Gate 3` → 由文法禁令 + hostile-fixture AC（AC6）覆盖。
- R2: 新文件类引入 version-gate 误报 → 由"零新文件"范围裁定消除；独立文件约定延期到需触 verifier 的设计单。
- R3: 工作区并发脏状态（多终端共享 index）→ Blake 提交必须用 pathspec（见 §10.1）。

### Acceptance Criteria（本设计单的，人类验收）
- [ ] §9.1 AC1–AC8 全绿（含 hostile fixture AC6/AC7）
- [ ] `git diff --name-only` 仅含 `.tad/templates/completion-report.md`（1 文件）
- [ ] Gate 1–4 清单、handoff 模板、hooks、证据路径零 diff

### Gate 1: Requirements Clarity（ размещено此处， Human 复核）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Problem defined | ✅ | 可选 PM 桥 + 小版本注记；痛点：COMPLETION 无机器可读进展行、小版本无升级/回滚标准位 |
| User identified | ✅ | TAD 维护者（人类）+ Blake（填写）+ 未来 PM 脚本（只读） |
| Scope bounded | ✅ | §1.2 非目标 5 条；§7 文件清单 1 文件；§11 延期项 |
| Acceptance criteria verifiable | ✅ | §9.1 8 行，每行可运行命令 |

### ⚖️ 流程深度裁定（请人类确认；默认推荐选项 1）

1. **推荐：Express docs-only 通道** — 单文件模板改动 + 1 名 reviewer 轻量复核（路由正确性 + AC 重跑）+ Gate 3 轻量 / Gate 4 Alex 验收。理由：small、无协议契约变更、AC 含负控。
2. Full 通道（完整 Ralph Loop + Layer 2 双审）。理由：若人类认为模板是"判据本身"（2026-08-12 pattern：判据产物验证成本跃升），则选此项。
3. 退回重设计。若 §4 任一定位（advisory-only / CHANGELOG-only / 禁令表）与人类期望不符。

---

## 1. Task Overview

### 1.1 What We're Building
在 `.tad/templates/completion-report.md` 追加一个**可选**尾部小节 `## 📡 PM Bridge (Optional)`（Blake 领地，位于 `## 📝 Human 验收区` **之前**），含恰好 3 行机器可读行：`PM-Status:` / `PM-Next:` / `PM-Blockers:`；配套小版本升级注记约定：CHANGELOG 内 `### Upgrade Notes <version>` 子节（What / Upgrade / Rollback 三段），patch/minor 适用，major 沿用完整 release handoff。

### 1.2 Why We're Building It
**业务价值**：COMPLETION 报告人类可读但 PM 进展不可速览；小版本升级缺少"改了什么/怎么升/怎么回滚"标准位。
**用户受益**：维护者一眼看到状态/下一步/阻塞；升级者按注记执行、失败可回滚到 pinned SHA。
**成功的样子**：旧 COMPLETION（无 PM 节）与所有旧检查行为一致；新 COMPLETION（含 PM 节，含恶意载荷）不改变任何 Gate 判定；CHANGELOG 注记可被 version-gate 既有排除规则覆盖。

**不是要做的（避免误解）**：
- ❌ 不是 Gate 5 / 新门控：PM 行永不参与任何 Gate 判定（advisory-only）
- ❌ 不是第二阻塞源：Friction Status 仍是唯一阻塞权威
- ❌ 不是新证据路径：PM 行住在既有 COMPLETION 文件内；注记住在既有 CHANGELOG 内
- ❌ 不是 parser/hook 改动：`pre-gate-check.sh` / `post-write-sync.sh` / `release-verify.sh` 一字不改
- ❌ 不是新文件类：v1 不创建 `UPGRADE-NOTES-*.md`（延期，见 §11）

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：给 COMPLETION 加 3 行可选 PM 速览 + 给小版本立升级/回滚注记位，且数学上证明"旧机器行为不变"。

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 15 条（重点 3 条） | Two-Agent（Blake 不重设计）；Four-Gate（Gate 3 技术 / Gate 4 业务）；Express ≠ 免审（≥1 专家） |
| patterns/gate-design.md | 重点 3 条 | Claims Need Carriers（PM 行豁免声明见 §4.3）；Rewiring-Grep-Count（不动锚点引文）；Human Blast Radius（回滚 pin SHA） |
| patterns/handoff-design.md | 重点 3 条 | `git grep` 对 untracked 盲（消费者扫描须 union untracked）；Reachability（本单使休眠缺陷可达即负责）；Count the Copies（模板镜像 parity） |
| patterns/release-sync.md | 重点 2 条 | Self-Updating Installer（Upgrade 必须走 fetch-then-execute + 真机 smoke）；Version-Staleness Exclusion 契约（2026-09-04：新文件类须分类 identity/historical，本单用零新文件规避） |
| patterns/ac-verification.md | 1 条 | Guard 先证触发条件可发生（hostile fixture AC6/AC7 即此） |

**⚠️ Blake 必须注意的历史教训**：

1. **Claims Need Carriers** (来自 gate-design.md)
   - 问题：COMPLETION 自证式 claim（无盘上载体）= validation theater。
   - 解决方案：本单 PM 行显式声明为 advisory hints 豁免（§4.3），永不替代证据；注记载体 = CHANGELOG（具名）。

2. **`git grep` 对 untracked 盲** (来自 handoff-design.md)
   - 问题：只用 `git grep` 做消费者扫描会漏掉 `active/` 下在飞 handoff。
   - 解决方案：§9.1 AC4/AC5 用 `git diff`（含 staged）+ `git status --short` 双查；Blake 提交用 pathspec（§10.1）。

3. **Version-Staleness Exclusion 契约债** (来自 release-sync.md, 2026-09-04)
   - 问题：新文件类带版本串 → version-grep 每发布误报递增 → 归一化 override。
   - 解决方案：v1 零新文件（CHANGELOG 子节复用既有排除）；独立文件延期专单。

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
- `completion-report.md` 现有机器锚点：frontmatter `^gate3_verdict:`（`post-write-sync.sh:129`，`head -1`）、`## Reflexion History`（`:256`，`/^## /` 分段）、`Gate 3 v2 结果`行（`pre-gate-check.sh:192`，`head -1`）、`**Handoff ID:**`（`:106`，**无 `head -1`** —— 最脆弱点）、checkbox 全文件计数（`:180-181`）、KA 单行检测（`:164`）、commit 占位检测（`:236`）。
- `release-verify.sh` version 模式文件级排除：CHANGELOG 等 basename + `## [X.Y.Z]` heading / semver 首 cell / HISTORICAL-STATUS（`:342-356`）—— CHANGELOG 文件整体已被既有 heading 覆盖排除。
- 工作区现状：多终端并发，index 有他人 staged riders；本单 grounded commit `5d56546d`，模板/Gates/hooks 在工作树零 diff（2026-09-04 实测）。

### 2.2 Current State
现状：COMPLETION 无 PM 速览位；小版本注记无固定格式。目标：加法式可选位 + 注记约定，旧行为零变化。

### 2.3 Dependencies
无新增依赖。消费者读取惯用法见 §4.5（标准 grep/sed，全 BSD-safe）。

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 模板新增 `## 📡 PM Bridge (Optional)` + `<!-- ANCHOR: pm-bridge -->`，位于 `## 📝 Human 验收区` 之前、`## 🎯 验收检查清单` 之后，恰好 3 行 `PM-Status:` / `PM-Next:` / `PM-Blockers:`，全可选。
- FR2: PM 载荷文法：单物理行、每行 ≤200 字符、禁令表（`[` `]` 行首 `#` `**` 反引号 `gate3_verdict:` `Gate 3` `Handoff ID` `what_failed:`/`root_cause_hypothesis:`/`revised_approach:`/`confidence:` `P0-`/`P1-`）。模板 HTML 注释内载明。
- FR3: 优先级：Friction Status 唯一阻塞权威；`遗留问题`第二；PM-Blockers 非权威镜像；分歧 → WARN；PM 行 advisory-only，永不替代证据（carrier 豁免声明入模板）。
- FR4: CHANGELOG `### Upgrade Notes <version>` 子节：What（1–3 bullets）/ Upgrade（fetch-then-execute 命令 + smoke 证据路径）/ Rollback（pin commit SHA 的精确 `git` 恢复命令）。patch/minor 适用；缺席 = advisory WARN，不改变任何 drift exit 语义。
- FR5: 读取惯用法文档化（§4.5 BSD-safe 管道；缺席文件/缺席行 → 空串 exit 0）。

### 3.2 Non-Functional Requirements
- NFR1（向后兼容）：旧 COMPLETION（无节）所有现有检查行为不变；新 COMPLETION（含节，含 §9.1 hostile 载荷）Gate 判定不变。
- NFR2（零扩散）：`git diff --name-only` 仅 1 文件；Gates/handoff 模板/hooks/证据路径零改动。
- NFR3（可移植）：读取管道 BSD/GNU-safe（`LC_ALL=C`、`-e`、无 PCRE、无 `grep -P`）。

### 3.3 Optimization Target
无（不触发 Autoresearch Mode）。

---

## 4. Technical Design

### 4.1 Architecture Overview
加法式尾部可选节 + 文档约定。零 verifier 改动；约束全部落在模板文本（位置、文法、优先级声明）与 §9.1 负控 AC。

### 4.2 Component Specifications

**组件 1 — PM Bridge 节（模板文本）**：在 `## 🎯 验收检查清单` 之后、`## 📝 Human 验收区` 之前插入：

```markdown
## 📡 PM Bridge (Optional)

<!-- ANCHOR: pm-bridge — OPTIONAL section. Absent = no PM info (consumers treat as empty, never fail).
     Each of the 3 lines is OPTIONAL (missing line = empty). Writer: Blake at *complete.
     ADVISORY-ONLY, NEVER GATING: Friction Status (§Friction) is the SOLE blocker authority;
     PM-Blockers is a non-authoritative mirror; divergence → WARN. PM lines are advisory hints,
     not claims — they never substitute evidence (exempt from claims-need-carriers, scoped to
     exactly these 3 lines).
     GRAMMAR: single physical line each, ≤200 chars, MUST NOT contain: `[` `]` leading-`#`
     `**` backtick `gate3_verdict:` `Gate 3` `Handoff ID` `what_failed:` `root_cause_hypothesis:`
     `revised_approach:` `confidence:` `P0-` `P1-`. -->

PM-Status: <one line>
PM-Next: <one line>
PM-Blockers: <one line>
```

**组件 2 — Upgrade Notes 约定（无新文件）**：CHANGELOG 对应版本节内追加：

```markdown
### Upgrade Notes <version>

- What: <1–3 bullets changed>
- Upgrade: <fetch-then-execute commands; smoke evidence path>
- Rollback: <exact git restore commands pinned to commit SHA>
```

### 4.3 Data Models
PM 行：`^PM-(Status|Next|Blockers):[[:space:]]*(.{0,200})$`（单行，禁令表见上）。

### 4.4 API Specifications
读取惯用法（§4.5）。无新 API。

### 4.5 消费者读取惯用法（normative）

```bash
raw=$(LC_ALL=C grep -E -e '^PM-Status:[[:space:]]*' "$f" 2>/dev/null | head -1 || true)
val=$(printf '%s' "$raw" | sed -E 's/^PM-Status:[[:space:]]*//' | tr -d '\r\n' | cut -c1-200)
# $val 为空 = 无信息；永不以此判定 Gate。
```

（`PM-Next` / `PM-Blockers` 同理替换键名。）

### 4.6 User Interface Requirements
N/A（纯模板文本）。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"、"我们的方案"？

**回答**：
- [x] 否 → 本单是 TAD 上游新约定，无历史 PM 方案可复用。但仍执行消费者扫描（协议要求"设计前先搜"），结果如下。

#### 搜索证据
```bash
# 搜索命令
grep -rn "PM-Status\|PM-Next\|PM-Blockers\|UPGRADE-NOTES\|Upgrade Notes" .tad/templates/ .tad/hooks/ .tad/gates/ 2>/dev/null | head -20
# 搜索结果
# （2026-09-04 实测）0 命中 — 无既有 PM 桥实现，不复用，直接新建（加法式）
grep -n "gate3_verdict:\|Reflexion History\|Handoff ID\|CHECKED\|Gate 3.*结果" .tad/hooks/post-write-sync.sh .tad/hooks/pre-gate-check.sh | head -12
# 结果：post-write-sync.sh:129（^gate3_verdict: head-1）、:256（## 分段）、pre-gate-check.sh:106（Handoff ID 无 head-1）、:180-181（checkbox 全文件计数）、:192（Gate3 结果 head-1）
```

#### 决策说明
- **找到了什么**：7 处机器锚点（§2.1 清单）；最脆弱：Handoff ID 提取无 `head -1`、checkbox 全文件计数。
- **决定**：❌ 不复用既有节（无）；✅ 新建可选尾节 + 文法禁令规避全部 7 处。
- **原因**：加法式是唯一满足"旧行为零变化"的形状。

**Human验证点**：能看到搜索确实执行了吗？决策理由合理吗？→ 是（命令 + 输出 + 逐锚分析）。

---

### MQ2: 函数存在性验证

**问题**：设计中调用了哪些函数？它们都存在吗？

**回答**：本单**不调用任何代码函数**（模板文本 + 文档约定）。涉及的文件存在性：

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| N/A（模板锚点 `## 📝 Human 验收区`） | .tad/templates/completion-report.md | 281 | `## 📝 Human 验收区` | ✅ |
| N/A（模板尾 `Report Created By`） | .tad/templates/completion-report.md | 297 | `**Report Created By**: Blake (Agent B)` | ✅ |
| N/A（frontmatter `gate3_verdict:`） | .tad/templates/completion-report.md | 6 | `gate3_verdict:` | ✅ |
| N/A（读取惯用法 grep/sed） | 系统工具 | — | `LC_ALL=C grep -E -e ... \| head -1 \|\| true` | ✅ |

**Human验证点**：每个函数都有"✅存在"和具体位置吗？→ 是（无新函数；锚点行号为 grounded commit `5d56546d` 下实测）。

---

### MQ3: 数据流完整性

**问题**：后端计算/返回了哪些字段？前端都显示了吗？

**回答**：N/A —— 本单无后端/前端数据流。数据模型为单一静态文本（§4.3），生产者 Blake（填写）→ 载体 COMPLETION 文件 → 消费者人类速览/可选脚本（只读）。对照表：

| 后端字段 | 用途说明 | 前端组件 | 是否显示 | 不显示原因 |
|---------|---------|---------|---------|-----------|
| PM-Status / PM-Next / PM-Blockers | 进展速览 | 人类速览 / 可选脚本 | ✅ | —（advisory；缺席视为空） |

**Human验证点**：无不显示字段；无遗漏。

---

### MQ4: 视觉层级

**问题**：功能有不同状态/类型吗？用户如何区分？

**回答**：
- [ ] 无不同状态 → 跳过。模板文本变更，无 UI 状态。

---

### MQ5: 状态同步

**问题**：数据存在几个地方？什么时候同步？

**回答**：

#### 状态存储位置

| 数据 | 存储位置1 | 存储位置2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| PM 进展 | COMPLETION 内 PM 行（Source of Truth，Blake 写） | NEXT.md（Alex 在 Gate 4 按需镜像，非自动） | Gate 4 人工 | COMPLETION → NEXT.md（人工摘录，非同步协议） |
| 升级注记 | CHANGELOG 内子节（Source of Truth） | 无第二存储 | — | —（唯一存储） |

```
[Blake 填写] → COMPLETION PM 行 (Source of Truth)
                ↓ Gate 4 人工摘录（按需，非协议）
             NEXT.md（Alex 业务验收处置，不替代）
✅ PM 行无第二机器存储，无需同步协议；分歧规则见 §4.3（Friction 唯一权威）
```

**Human验证点**：主状态已标注；同步时机明确（人工、按需）；无静默不同步（PM 永不 gating）。

---

## 6. Implementation Steps（分Phase）

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | .tad/templates/completion-report.md | Insert §4.2 block between `## 🎯 验收检查清单` end and `## 📝 Human 验收区` | `grep -c "ANCHOR: pm-bridge" .tad/templates/completion-report.md` → `1` | 3 min |
| 2 | .tad/templates/completion-report.md | Verify grammar comment + advisory text byte-present | `grep -c "ADVISORY-ONLY, NEVER GATING\|SOLE blocker authority\|MUST NOT contain" .tad/templates/completion-report.md` → `≥2` | 2 min |
| 3 | repo | Scope guard: only 1 file changed | `git diff --name-only -- .tad/templates/completion-report.md \| wc -l` → `1`; `git diff --name-only -- .tad/gates/ .tad/hooks/ .tad/templates/handoff-a-to-b.md` → empty | 2 min |

**🆕 Phase划分原则**：单 Phase（docs-only，≤30 分钟）。

### Phase 1: 模板增补 + 全 AC 自验（预计0.5小时）

#### 交付物
- [ ] `.tad/templates/completion-report.md`（+§4.2 块）
- [ ] §9.1 AC1–AC8（含 hostile fixture）执行证据

#### 实施步骤
1. 按 §4.2 精确插入（含 HTML 注释原文）。
2. 逐行运行 §9.1 Verification Method，粘贴输出。
3. 跑 1 名 reviewer（路由正确性 + AC 重跑），见 §9.2 R2 要求。

#### 验证方法
- `grep -n "pm-bridge\|PM-Status" .tad/templates/completion-report.md` 应显示新节恰好 1 处、位于 `:281` 之前。
- hostile fixture（AC6/AC7）脚本 exit 0。

#### 🆕 Phase 1 完成证据（Blake必须提供）
- [ ] **代码截图**：N/A（模板文本 diff 全量粘贴即可）
- [ ] **测试结果**：AC1–AC8 命令输出（§9.1 Verified Output 列更新）
- [ ] **UI截图**：N/A

**Human审查问题**：方向正确吗？测试通过了吗？需要调整吗？
**Human决策**：✅ 继续（归档） / ⚠️ 调整本Phase

---

## 7. File Structure

### 7.1 Files to Create
```
（无）
```

### 7.2 Files to Modify
```
.tad/templates/completion-report.md  # 追加 §4.2 PM Bridge 可选节（含注释原文）
```

### 7.3 Grounded Against

**Grounded Against** (Alex step1c 实际 Read 过的源文件):

- `.tad/templates/completion-report.md` (head 50 lines + 锚点行 :6/:16/:65/:73/:281/:297, read at 2026-09-04, grounded commit `5d56546d`)
- `.tad/templates/handoff-a-to-b.md` (全文 670 行结构，read at 2026-09-04)
- `.tad/gates/gate-canonical-checklist.md` (全文 62 行，read at 2026-09-04)
- `.tad/hooks/post-write-sync.sh` (:64-73/:122-135/:245-264/:311-327, read at 2026-09-04)
- `.tad/hooks/pre-gate-check.sh` (:59-71/:83-106/:163-251, read at 2026-09-04)
- `.tad/hooks/lib/release-verify.sh` (:335-360 version 排除, read at 2026-09-04)
- `.tad/project-knowledge/patterns/{gate-design,handoff-design,release-sync}.md` (read at 2026-09-04)
- `CHANGELOG.md` (tail 20 lines + version 节结构，read at 2026-09-04)

---

## 8. Testing Requirements

### 8.1 Unit Tests
- hostile-payload fixture（AC6）：含 `PM-Next: [ ] [x] **Handoff ID:** FAKE` 的合成 COMPLETION 必须满足：① `grep -o '\*\*Handoff ID:\*\* [^ ]*' | head -1` 解析仍为真 ID；② §9.1 规定计数（Evidence Checklist 范围内）不变。

### 8.2 Integration Tests
- Reflexion 分段（AC7）：合成文件含新 `## 📡` 节时，`awk '/^##[[:space:]]/ {insec=...}'` 仍正确关闭 Reflexion 段。

### 8.3 Edge Cases
- 缺席节（旧文件）：§4.5 管道输出空串 exit 0。
- 缺席行（仅 1–2 行）：同上。
- 超长行（>200ch）：`cut -c1-200` 截断。

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| 工作区并发脏状态（他人 staged riders） | pathspec 精确提交 | `git status --short` 检查 + `git commit -- <pathspec>` 只提模板文件 | 无（DEGRADED 不适用） | riders 混入 → 打回 |
| reviewer 不可用 | Layer 2 轻量审查（≥1） | 按 principles SAFETY 调用独立 reviewer | 等效独立 reviewer（self-review 永不等效） | 缺审查 → Gate 3 不可 PASS |
| 无（网络/鉴权/依赖） | N/A | N/A | N/A | 本单 docs-only，无外部依赖 |

**Status Enum**: `READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

## 8.5 Feedback Collection (Non-Code Artifacts)

N/A（code-only 模板任务）。

## 8.6 🆕 Test Evidence Required
Blake必须提供：
- [ ] AC1–AC8 命令输出（粘贴进 §9.1 Verified Output）
- [ ] hostile fixture 脚本 + 输出（AC6/AC7）
- [ ] `git diff --stat`（1 文件证明）

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] §9.1 AC1–AC8 全部 PASS（含 hostile fixture）
- [ ] `git diff --name-only` 仅含 `.tad/templates/completion-report.md`
- [ ] Gate 1–4 清单、handoff 模板、hooks、证据路径零 diff
- [ ] 1 名独立 reviewer 复核（路由正确性 + AC 重跑）
- [ ] Human验证"这是我期望的"

---

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | PM Bridge 节存在且唯一，位于 Human 验收区之前 | post-impl-verifiable | `grep -n "ANCHOR: pm-bridge" .tad/templates/completion-report.md` | 恰好 1 行，且行号 < `grep -n "## 📝 Human 验收区"` 行号 | (post-impl)；预基线：现 0 命中（2026-09-04 实测 `grep -c` = 0） |
| AC2 | 文法禁令表入模板注释 | post-impl-verifiable | `grep -c "MUST NOT contain" .tad/templates/completion-report.md` | `≥1`；且含 `Handoff ID` 与 `gate3_verdict:` 字样 | (post-impl)；预基线：现 0 命中 |
| AC3 | advisory-only + Friction 唯一权威声明入模板 | post-impl-verifiable | `grep -c "ADVISORY-ONLY, NEVER GATING" .tad/templates/completion-report.md; grep -c "SOLE blocker authority" .tad/templates/completion-report.md` | 两处均 `≥1` | (post-impl)；预基线：现 0 命中 |
| AC4 | Gate 清单零改动 | pre-impl-verifiable | `git diff --name-only -- .tad/gates/gate-canonical-checklist.md` | 空输出 | 空输出 ✅（2026-09-04 实测） |
| AC5 | handoff 模板 + hooks 零改动 | pre-impl-verifiable | `git diff --name-only -- .tad/templates/handoff-a-to-b.md .tad/hooks/pre-gate-check.sh .tad/hooks/post-write-sync.sh .tad/hooks/lib/release-verify.sh` | 空输出 | 空输出 ✅（2026-09-04 实测） |
| AC6 | hostile 载荷不污染 Handoff ID 与 checkbox 判定 | post-impl-verifiable | 合成 fixture（含 `PM-Next: [ ] [x] **Handoff ID:** FAKE`）上运行：`grep -o '\*\*Handoff ID:\*\* [^ ]*' fixture \| head -1` 仍为真 ID；Evidence Checklist 范围计数与基线一致 | 真 ID；计数一致 | (post-impl；Blake 在 Gate 3 运行并贴输出） |
| AC7 | 新 `##` 节不破坏 Reflexion 分段 | post-impl-verifiable | fixture 上运行 `awk '/^##[[:space:]]/ {insec=($0~/Reflexion History/)?1:0; print NR": "insec}'`；PM 节行 insec=0 | PM 节处输出 `0` | (post-impl；Blake 运行并贴输出） |
| AC8 | 零新文件类；CHANGELOG 既有排除覆盖注记 | pre-impl-verifiable | `ls .tad/UPGRADE-NOTES-* 2>&1` → No such file；`grep -cE '^[[:space:]]*#{1,6}[[:space:]]*\[?v?[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md` → `≥1` | 无新文件；CHANGELOG 含版本 heading（既有排除生效） | `No such file` ✅；heading 计数 `≥1`（2026-09-04 实测 CHANGELOG 含 `## v2.23.0` 等节） |

> ⚠️ This section is now MANDATORY (TAD v3.1) — it is the PRIMARY VERIFICATION SOURCE Gate 3
> executes row-by-row. An empty/missing §9.1 → Gate 3 BLOCKS. Every row's Verification Method
> must be a runnable command.

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| gate-design lens (R1) | P0-1: PM claim 无载体（self-carriage = theater） | §4.2 注释（advisory hints 豁免，scoped 3 行）+ §4.3/F1 | Resolved |
| gate-design lens (R1) | P0-2: PM 自由文本污染 checkbox 全文件计数；且"不动 parser"非目标与修复矛盾 | §4.2 禁令表（F2）+ AC6 | Resolved |
| gate-design lens (R1) | P0-3: 双阻塞源 + FAIL-open（PM-Blockers 空 = 无信息） | §4.3 优先级（Friction 唯一权威，分歧 WARN）+ §4.2 注释 | Resolved |
| gate-design lens (R1) | P0-4: 新版本文件类无 exclusion 契约；"never blocks" 误述 release-verify 语义 | §4 组件2（CHANGELOG-only，零新文件，F4）+ AC8 | Resolved |
| gate-design lens (R1) | P1-1: 机器节置于人类签核之后，owner 未命名 | §4.2 位置（Human 验收区之前）+ Writer/Verifier 命名（F3） | Resolved |
| gate-design lens (R1) | P1-2: 分段安全依赖未声明的字符纪律 | §4.2 禁令表（含 `what_failed:`/`confidence:`/`P0-`） | Resolved |
| gate-design lens (R1) | P1-3: Upgrade/Rollback 无验证 claim | §4 组件2（smoke 证据路径 + pin SHA 要求） | Resolved |
| compat/carrier lens (R1) | P0-1: `UPGRADE-NOTES-*.md` 触发 version-grep 误报递增 | 同上（零新文件，F4） | Resolved |
| compat/carrier lens (R1) | P0-2: 载荷碰撞（checkbox + Handoff ID 无 head-1 为最重） | §4.2 禁令表 + §4.5 `head -1` 惯用法 + AC6 | Resolved |
| compat/carrier lens (R1) | P1-1: "never fail" 非 `set -e` 安全惯用法 | §4.5（`LC_ALL=C` + `-e` + `head -1 \|\| true`） | Resolved |
| compat/carrier lens (R1) | P1-2: 新文件 sync 分类未声明 | 零新文件 → `derive-sync-set.sh` 无需变更（AC8 隐含） | Resolved |
| compat/carrier lens (R1) | P1-3: 多行走私 | 单物理行 + `tr -d '\r\n'` + `cut -c1-200` | Resolved |
| re-reviewer (R2, v2 fixes) | 复核全部 8 个 P0：F1–F6 关闭确认 | §4 全体 + §9.1 | Resolved → **PASS**（0 residual P0；P2 polish 已转 AC2/AC8） |

### Experts Selected

1. **gate-design lens** — 本单触及 Gate 责任矩阵/claims-carriers/双阻塞源，需门控视角（R1 FAIL 4×P0 → 修订后 R2 PASS）。
2. **compat/carrier lens** — 本单触及 shell 解析器/version-grep/sync，须向后兼容视角（R1 FAIL 2×P0 → 修订后 R2 逐条 CLOSED）。

注：R2 第二 reviewer 槽位因工具授权被拒 1 次；现有的 R2 PASS 评审覆盖了两名 R1 reviewer 的全部 8 个 P0（逐条 OPEN/CLOSED 表），Gate 2 以此为 v2 依据，并在 §10.2 如实记录。Blake 侧 Layer 2 仍须独立执行。

### Overall Assessment (post-integration)

- gate-design lens: FAIL (R1, 4 P0) → 修订 F1–F4 → R2 re-review PASS (8/8 P0 closed)
- compat/carrier lens: FAIL (R1, 2 P0 + 3 P1) → 修订 F2/F4/F5 → R2 逐条 CLOSED
- **Gate 2: ✅ PASS**（0 residual P0）

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 提交必须用 pathspec：`git commit -- .tad/templates/completion-report.md`；提交前 `git status --short` 检查 staged riders（并发终端共享 index，本工作树当前即脏，见 §2.1）。
- ⚠️ PM 行禁令表是**机器安全边界**，不是文案建议：Blake 填写与 reviewer 复核时逐项对照，违规行视为 AC FAIL。
- ⚠️ `UPGRADE-NOTES-*.md` 文件**禁止**在本单创建（AC8）；确需独立文件时另起 verifier-touching 设计单。

### 10.2 Known Constraints
- R2 第二 reviewer 工具调用被 harness 拒绝 1 次（已记录；R2 PASS 覆盖全部 P0，不隐瞒）。
- 本单 scope 刻意不含 parser 加固（`Handoff ID` 加 `head -1`、checkbox 范围化）：若未来出现真实碰撞，按"消费者侧加固"另起单（触 verifier，需独立 Gate）。
- CHANGELOG `### Upgrade Notes` heading 自身不匹配 version 排除正则的 (b) 项（`###` 后非版本开头），但文件整体已被既有 `## [X.Y.Z]` heading 覆盖排除——AC8 断言此点；若 release-verify 改为行级排除，本约定需重审。

### 10.3 🆕 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **parallel-coordinator** - 本单单文件，无需
- [ ] **bug-hunter** - 如 hostile fixture 失败时
- [x] **test-runner** - AC6/AC7 fixture 执行见证（轻量）
- [ ] **refactor-specialist** - 不需要

完成后在"Sub-Agent使用记录"中说明使用情况。

---

## 11. 🆕 Learning Content（可选）

### 11.1 Decision Rationale: 注记载体（CHANGELOG 子节 vs 独立文件）

**选择的方案**：CHANGELOG `### Upgrade Notes <version>` 子节（零新文件）。

**考虑的替代方案**：

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| CHANGELOG 子节（选中）| 零 version-gate 契约债（文件已被排除）；零 sync 分类；单载体 | 大版本注记可能过长 | ✅ 小版本注记天然短；major 沿用 release handoff |
| 独立 `UPGRADE-NOTES-<v>.md` | 版本文件自包含 | 需改 `release-verify.sh` 排除 + `version-sweep` Layer-2 + sync 分类（触 verifier，需独立 Gate） | ❌ 为 3 段注记动 verifier 不值；延期专单 |

**权衡分析**：核心权衡：[载体纯洁性] vs [verifier 触碰成本]。当前优先级：不碰 verifier（2026-09-04 pattern：触 verifier 需自有 Gate）。

**💡 Human学习点**：可选增补设计先数机器锚点（本单 7 处），再定文法禁令；"旧机器行为不变"是可以写成 AC 的（hostile fixture）。

---

## 12. 🆕 Sub-Agent使用记录

Blake完成后填写：

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| test-runner | ✅/❌ | [...] | [...] | [...] |
| bug-hunter | ✅/❌ | [...] | [...] | [...] |

**Human验证点**：应该调用的都调用了吗？

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-09-04
**Version**: 3.1.0
