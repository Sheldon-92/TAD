# 自家欠账只读普查报告 — TAD 仓四件挂账

- step_id：`tad-housekeeping-survey-01`
- 执行者：PM 普查执行者（只读普查，处置由 PM 另定）
- 日期：2026-10-04
- 字节数：14582
- 对照基线：`.tad/evidence/phase3-census.md`（D36 条）、`.tad/evidence/phase3-inflight-chains.md`（在飞链 #2/#3/#4/#5/#6 行）
- active HANDOFF 总数自核：`.tad/active/handoffs/` 共 13 个文件 ＝ HANDOFF 8 件 ＋ COMPLETION 5 件；下文 8 件 HANDOFF 逐条判定：已收口 5／未收口 1／子件（SUPERSEDED、DRAFT）2，合计 8，对得上。

---

## 1. 已收口链未迁 archive

### archive 侧现有形态（预期落点）

- `.tad/archive/handoffs/` 为主落点：709 件平铺，HANDOFF 与 COMPLETION 同名混放（如 `COMPLETION-20260402-ai-agent-self-evolution-capability.md` 与 handoff 件同层）。
- 另有按 Epic 分子夹的形态：`.tad/archive/handoffs/EPIC-20260816-framework-health/`、`.tad/archive/handoffs/EPIC-20260824-yolo2-verified-orchestration/`（EPIC-20260816 链件在该子夹内）。
- 即：已收口链的 HANDOFF 与其 COMPLETION 的预期落点为 `.tad/archive/handoffs/`（平铺同名迁入；属 EPIC-20260816 的链可入其 Epic 子夹，二形态盘上均有实证）。

### 全名单：已收口但 HANDOFF 仍在 active（5 条）

| # | 链 | HANDOFF（仍在 active） | 收口证据（在盘） |
|---|---|---|---|
| 1 | notebooklm-deprecation | `.tad/active/handoffs/HANDOFF-2026-09-15-notebooklm-deprecation.md` | `.tad/active/handoffs/COMPLETION-20260915-notebooklm-deprecation.md` |
| 2 | platform-adapters P1P3（EPIC-20260816） | `.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md` | `.tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md`；Gate 4 终态件 `.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md` |
| 3 | tad-research-mechanism | `.tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md` | `.tad/active/handoffs/COMPLETION-20260915-tad-research-mechanism.md` |
| 4 | tad-state-surface-closeout（自查 R1 第一批） | `.tad/active/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md` | `.tad/active/handoffs/COMPLETION-2026-10-04-tad-state-surface-closeout.md`；Gate 4 验收件 `.tad/evidence/reviews/2026-10-04-gate4-acceptance-state-surface-closeout.md` |
| 5 | maintainer-evidence-revival | `.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md` | `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md`；RG4 收口件 `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md` |

### 不在名单内的 active 件（逐条交代，防遗漏）

- `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md`：未收口，见第 2 节。
- `.tad/active/handoffs/HANDOFF-2026-09-15-claude-decouple-design.md`：claude-removal 链前置设计件，已自标 SUPERSEDED（原文见第 2 节），随该链处置。
- `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan-codex.md`：claude-removal 链 DRAFT 摘要件，随该链处置。
- 附带：`.tad/active/handoffs/COMPLETION-20260816-phase2-partial-p0-fix.md` 本身也仍在 active（自标 partial、部分收口）；其链 HANDOFF 不在 active（EPIC-20260816 链件在 `.tad/archive/handoffs/EPIC-20260816-framework-health/` 子夹），故不入上表，特此注明。

**建议处置**：迁 archive——上表 5 条链的 HANDOFF 与其 COMPLETION 一并迁入 `.tad/archive/handoffs/`（platform-adapters 可入 EPIC-20260816 子夹），phase2-partial 的 COMPLETION 随其链件归位。

---

## 2. claude-removal 链（TASK-20260915-CLAUDE-REMOVAL）

### 盘上件清单（逐项有无）

| 件 | 有无 | 路径／查无说明 |
|---|---|---|
| 票 TICKET | **查无** | 查过 `.tad/active/` 根目录：在盘仅 `TICKET-20260916-codex-ledger-reverification.md`、`TICKET-20261004-evidence-carrier-recovery-execution.md`、`TICKET-20261004-maintainer-evidence-branch-revival.md` 三票，无本链票 |
| HANDOFF（主件） | 有 | `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md` |
| HANDOFF（前置设计，已被主件 supersede） | 有 | `.tad/active/handoffs/HANDOFF-2026-09-15-claude-decouple-design.md` |
| HANDOFF（Codex 摘要件） | 有 | `.tad/active/handoffs/HANDOFF-2026-09-15-claude-removal-plan-codex.md` |
| Gate 2 评审件 | **查无** | 查过 `.tad/evidence/reviews/` 全目录（文件名含 claude 者仅下述 Gate 3／Gate 4 四件）＋全仓 `find .tad -iname "*gate2*claude*" -o -iname "*claude*gate2*"`，零命中 |
| Gate 3 CODE 评审 | 有 | `.tad/evidence/reviews/2026-09-15-gate3-code-review-claude-removal.md`（结论 CONDITIONAL，据裁决件转述「Gate 3 双审均 CONDITIONAL、CODE 零功能缺陷」） |
| Gate 3 SAFETY 评审 | 有 | `.tad/evidence/reviews/2026-09-15-gate3-safety-review-claude-removal.md`（结论 CONDITIONAL，同上） |
| Gate 3 裁决 | 有 | `.tad/evidence/reviews/2026-09-15-gate3-adjudication-claude-removal.md`（2026-09-16） |
| Gate 3 返工件 | 有 | `.tad/evidence/reviews/2026-09-16-gate3-rework-r3-waiver.md`、`.tad/evidence/reviews/2026-09-16-gate3-rework-vp7-zeromutation.md` |
| Gate 4 验收 | 有 | `.tad/evidence/reviews/2026-09-15-gate4-acceptance-claude-removal.md`（2026-09-16，结论 CONDITIONAL，见下） |
| COMPLETION | **查无** | 查过全仓 `find .tad -iname "*COMPLETION*claude-removal*"`（零命中）、`.tad/evidence/completions/`（无 2026-09-15 件）、`docs/pm/open-cards/`（无该链完事卡） |
| 完事卡 | **查无** | 同上 open-cards 目录 |

### status 原文逐字引

主件 HANDOFF frontmatter 第 8 行：

> `status: READY_FOR_GATE2        # executable plan; dual Gate 2 review, then Blake`

正文第 20 行：

> **Status**: `READY_FOR_GATE2` — 可执行方案。Blake 只按 §6.2 步骤落地，不重新设计。

前置设计件 frontmatter 第 8 行：

> `status: SUPERSEDED                # direction ratified as "完全移除"; see HANDOFF-2026-09-15-claude-removal-plan.md`

Codex 摘要件第 3 行：

> 状态：DRAFT（结论摘要；完整正文因执行沙箱只读未能落盘）

### 最新裁定／验收结论原文摘录

Gate 3 裁决（2026-09-16）结论速览原文要点：R2 五点全部「**保留**」；R3「**二选一 → (b) Gate 4 书面 waiver** + 强制另立单」；C-3「**二选一 → 是，加 carve-out**」；C-4「**二选一 → 是，同一处置**」。

Gate 4 验收（2026-09-16）结论原文：

> # Gate 4 裁决：**CONDITIONAL**
>
> 核心 SAFETY 全部成立、SSOT 反转/tombstone/S7 删除/S9 版本物料全部与 handoff 一致、返工 8 点中 **7 点实质闭合**。**唯一未闭合的返工项是 R1**（`.gitignore` 机器本地保护规则恢复不完整），另叠加一项 AC20 字面判据未同步（验证剧场风险）。
>
> **发布建议：暂缓打 `v3.0.0` tag**，先闭合下方 §3 的 R1 两处 + AC20 判据三处（预计 <30 分钟，纯 `.gitignore`/handoff/grep 判据）。闭合或经人书面 waiver 后即可发布。

### 明确回答

- **缺哪一件**：缺 COMPLETION（正式收口件）——另 Gate 2 评审件与票在盘上同样查无（见上表）。
- **状态停在哪一步**：实施、Gate 3 双审、裁决、返工、Gate 4 均已发生，链件止于 2026-09-16；停在 **Gate 4 CONDITIONAL 待闭合**（R1 两处＋AC20 判据三处，盘上无其后续闭合证据——查过上表全部目录，本链最新件即 2026-09-16 返工件与 Gate 4 件），且未写 COMPLETION、HANDOFF status 仍停在开工时的 `READY_FOR_GATE2`。

**建议处置**：如实标注缺件＋由 PM 核定 Gate 4 CONDITIONAL 遗留项（R1／AC20）是否已在链外闭合；未闭合则先补闭合证据、再补件（补 COMPLETION），最后回写 status。

---

## 3. 已收口链 HANDOFF status 未回写（实际条数：3 条）

第 1 节名单 5 条中，status 停在未收口表述的为 2026-09-15 三条链，逐条原文对照如下。

### 3.1 notebooklm-deprecation

- HANDOFF：`.tad/active/handoffs/HANDOFF-2026-09-15-notebooklm-deprecation.md`
- status 原文（frontmatter 第 8 行）：`status: READY_FOR_GATE2`
- status 原文（正文第 19 行）：`**Status**: READY_FOR_GATE2 (design only — Blake lands the files; **no NotebookLM/CLI is executed by Blake**)`
- 收口证据：`.tad/active/handoffs/COMPLETION-20260915-notebooklm-deprecation.md`

### 3.2 platform-adapters-p1p3

- HANDOFF：`.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md`
- status 原文（frontmatter 第 8 行）：`status: READY_FOR_GATE2`
- status 原文（正文第 19 行）：`**Status**: READY_FOR_GATE2 (design only — Blake lands files; **no commit by Alex**)`
- 收口证据：`.tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md`；`.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md`

### 3.3 tad-research-mechanism

- HANDOFF：`.tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md`
- status 原文（frontmatter 第 8 行）：`status: READY_FOR_GATE2`
- status 原文（正文第 19 行）：`**Status**: READY_FOR_GATE2 (design only — Blake lands the mechanism files; **no research is executed by Blake**)`
- 收口证据：`.tad/active/handoffs/COMPLETION-20260915-tad-research-mechanism.md`

### 不属于未回写的两条（注明口径差异）

- state-surface-closeout 与 maintainer-evidence-revival 两条 2026-10-04 链的 HANDOFF **无 `status:` 字段**（查过两件头部：frontmatter 为 Quality Chain Metadata，无 status 键；全文 grep `status` 仅命中正文无关行）——无可回写字段，收口状态只由各自 COMPLETION 承载，与上三条「有字段未回写」性质不同，单列注明。

**建议处置**：回写 status——3.1–3.3 三件 HANDOFF 的 status 改为与其 COMPLETION 一致的收口表述（与第 1 节迁 archive 同批做）；两条无 status 字段的新链无须动。

---

## 4. hillclimb 链查盘一致性（TASK-20260929-AGENT-EVAL-HILLCLIMB-L2）

### 与 `.tad/evidence/phase3-inflight-chains.md` 第 2 行记录逐项对照

| 记录所述 | 盘面实况 | 一致性 |
|---|---|---|
| 链首步 2026-09-29（HANDOFF 文件名日期） | `.tad/archive/handoffs/HANDOFF-20260929-agent-eval-hillclimb-l2-hybrid.md` 在盘，日期相符 | 一致（但位置已不在 active，见下行） |
| 已收口（session-state 索引行：Gate 4 PASS、提交 `b78173b3`） | session-state `.tad/active/session-state.md` 第 4 行原文：`agent-eval-hillclimb-l2（TASK-20260929，已收口（`b78173b3`））`；`git log` 实证提交 `b78173b3` 存在（`docs(L2): Gate3 land hillclimb method sentences [TASK-20260929-AGENT-EVAL-HILLCLIMB-L2]`） | 一致 |
| 「其 HANDOFF/COMPLETION 件普查期间在 `.tad/active/handoffs/` 的在列情况两次查盘不一致」（存疑 ④） | 本次查盘定论：HANDOFF **不在** active，已在 `.tad/archive/handoffs/`（已迁归档）；COMPLETION **全仓查无**（查过 `.tad` 全树 `find -iname "*hillclimb*"` 10 件与 `*COMPLETION*20260929*`，均无 COMPLETION 命名件） | 记录的不一致到此定论：HANDOFF 已迁、COMPLETION 从无落盘件 |
| 记录未列 COMPLETION 缺位的原因 | 归档内 Gate 4 件 `.tad/archive/handoffs/GATE4-20260929-agent-eval-hillclimb-l2.md` 的 Prerequisite 表原文自述：`Completion report | ⚠️ Absent (informal docs-only land). Gate 3 evidence on disk substitutes for COMPLETION gate3_verdict; not blocking for this knife.` | 盘上有自述，缺位非遗漏未记 |

### 不一致处汇总（以盘面为准）

1. **session-state 正文路径过期**：`.tad/active/session-state.md` 第 22 行仍记 `**Handoff**: .tad/active/handoffs/HANDOFF-20260929-agent-eval-hillclimb-l2-hybrid.md`，实物已迁 `.tad/archive/handoffs/`；且该文件第 3 行自注「该链收口时迁入其归属文件夹」未随迁执行（正文 Last Updated 仍 2026-09-29）。
2. **PM 收口件引用路径与实物不符**：`.tad/evidence/gate4/2026-09-29-pm-close-agent-eval-hillclimb-l2.md` 证据节引 `.tad/evidence/reviews/2026-09-29-gate4-acceptance-agent-eval-hillclimb-l2.md`，该路径盘上查无；Gate 4 验收实物在 `.tad/archive/handoffs/GATE4-20260929-agent-eval-hillclimb-l2.md`（内含 `**Verdict:** **ACCEPT / PASS**` 与 `verdict: PASS`）。
3. **归档 HANDOFF 自身 status 两处表述不一**：frontmatter 第 8 行 `status: GATE4_PASS`；正文第 34 行 `- **Status**: `READY_FOR_GATE4`. Local commit only, no push, no tags.`（正文未随 frontmatter 更新）。

### 该链当前真实件清单（盘面为准，共 10 件）

1. `.tad/archive/handoffs/HANDOFF-20260929-agent-eval-hillclimb-l2-hybrid.md`
2. `.tad/archive/handoffs/GATE4-20260929-agent-eval-hillclimb-l2.md`
3. `.tad/evidence/designs/2026-09-29-agent-eval-hillclimb-l2-hybrid.md`
4. `.tad/evidence/discuss/2026-09-29-claude-eval-hillclimb-vs-tad.md`
5. `.tad/evidence/gate4/2026-09-29-pm-close-agent-eval-hillclimb-l2.md`
6. `.tad/evidence/impl/2026-09-29-gate3-selfcheck-agent-eval-hillclimb-l2.md`
7. `.tad/evidence/impl/2026-09-29-request-dispatch-agent-eval-hillclimb-l2.md`
8. `.tad/evidence/reviews/2026-09-29-gate2-review-agent-eval-hillclimb-l2-scope.md`
9. `.tad/evidence/reviews/2026-09-29-gate2-review-agent-eval-hillclimb-l2-spec.md`
10. `.tad/evidence/reviews/2026-09-29-gate3-review-agent-eval-hillclimb-l2.md`

（另 `.tad/active/session-state.md` 索引与正文有该链状态记录，属索引件、非链件，不计入。）

**建议处置**：如实标注缺件（COMPLETION 缺位已有 Gate 4 件自述、不补造）＋回写两处过期引用（session-state 正文 Handoff 路径、pm-close 的 Gate 4 引用路径）与归档 HANDOFF 正文 Status 行；链件本身无须动。

---

## 结论行汇总

1. 已收口未迁 archive：**5 条链**（notebooklm-deprecation、platform-adapters-p1p3、tad-research-mechanism、tad-state-surface-closeout、maintainer-evidence-revival）。
2. claude-removal：**缺 COMPLETION（另缺票与 Gate 2 评审件）**，停在 Gate 4 CONDITIONAL 待闭合，HANDOFF status 仍为 `READY_FOR_GATE2`。
3. status 未回写：**实际 3 条**（即 2026-09-15 三链，均停 `READY_FOR_GATE2`）；两条 2026-10-04 新链无 status 字段、不属此列。
4. hillclimb：记录大头一致；**定论 HANDOFF 已迁 archive、COMPLETION 从无落盘件（Gate 4 件有自述）**，另有 3 处引用／表述不一致待回写。
