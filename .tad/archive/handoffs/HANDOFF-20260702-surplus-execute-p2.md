---
task_type: code
e2e_required: yes
research_required: no
git_tracked_dirs: [".claude/workflows", ".claude/skills/surplus"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-02
**Project:** TAD
**Task ID:** TASK-20260702-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260607-surplus-burn-mode.md (Phase 2/2 — final)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-02

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review (min 2) | ✅ | code-reviewer + security-auditor，evidence: `.tad/evidence/reviews/alex/surplus-execute-p2/` |
| All P0 resolved | ✅ | 5 P0（CR 3 + SA 2）+ 7 P1 全部 Resolved，见 §9.2 Audit Trail |
| Architecture Complete | ✅ | §4.1 + §4.2A（4-step: validate→filter→synthesize→loop，逐 key 对齐 yolo-epic） |
| Components Specified | ✅ | workflow + SKILL + report format |
| Functions Verified | ✅ | yolo-epic args L70-88 逐 key 核对；return shape（error/stop_reason）确认 |
| Data Flow Mapped | ✅ | JSON sidecar（读）→ ephemeral Epic → yolo-epic → report（写） |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素。专家审查抓到 3 个会让整个循环空跑的契约错配（P0 级），全部已修正。Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)
- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」历史教训
- [ ] 理解 budget loop 的三个退出条件（budget 耗尽 / 全部执行完 / circuit breaker）
- [ ] 确认可以独立完成

---

## 1. Task Overview

### 1.1 What We're Building
Surplus Burn Mode Phase 2：从 Phase 1 已有的 ranked JSON sidecar 读取 auto-eligible 任务 → budget-guarded loop 逐条通过 yolo-epic workflow 执行（设计→审查→实现→审查→gate）→ 失败跳过继续 → SAFETY 任务路由到"needs-you"列表 → 最终产出 SURPLUS-REPORT digest 供一次性审阅。然后 dogfood：真实运行 ≥1 条 backlog 任务端到端。

### 1.2 Why We're Building It
*surplus --plan 已经能找到最高价值密度的 backlog 工作（53 个候选，24 个 auto-eligible）。但找到不等于做——如果每条还要手动 *analyze → *handoff → Blake，surplus 的"省事"承诺就是空话。Phase 2 把"找到→做完→汇报"自动化成一次调用，真正把剩余 quota 变成交付物。

### 1.3 🆕 Intent Statement

**真正要解决的问题**：把 `*surplus +500K` 变成"你去喝咖啡，回来看报告"的体验。

**不是要做的**：
- ❌ 不改 surplus-scan / yolo-epic（只调用不修改——它们是校准过的工具）
- ❌ 不执行 SAFETY 任务（principles.md / SKILL SAFETY zones / security / deletes → needs-you 列表）
- ❌ 不跨项目
- ❌ 不改 *accept 流程（digest 是汇总报告，不替代 Gate 4 验收——每条执行完的任务被 yolo-epic 内部的 Gate 3 验过，digest 供用户一次性审阅决定是否 *accept batch）

**Blake请确认理解**：
```
1. budget loop 的三个退出条件各是什么？
2. SAFETY 任务为什么不能自动执行（即使 Gate 2/3 都过）？
3. 如果 yolo-epic 在某任务上挂了，你怎么处理？
```

---

## 📚 Project Knowledge（Blake 必读）

**MANDATORY READ**: `principles.md` + `patterns/gate-design.md` + `patterns/ac-verification.md`

**⚠️ 必须注意的历史教训**：
1. **Workflow-internal stop gates** (gate-design 2026-06-03)——yolo-epic 已有 design_review_p0_count 内部止损，budget loop 不需要重新实现（但需要读它的 return.failed 字段来判断跳过）
2. **Workflow `{name:}` stale copy** (ac-verification 2026-06-08)——直接调用中用 scriptPath 不用 name；但 nested `workflow()` 调用按 name 解析（Phase 2 调 yolo-epic 走 workflow()，需用 name）——确认 yolo-epic 已 committed，name 解析到最新版
3. **`agent({schema})` top-level array** (ac-verification 2026-06-08)——所有 schema 必须是 `type: 'object'` 包裹
4. **workflow args must be JSON values not strings** (Workflow tool doc)——sidecar 行直接传对象
5. **budget.total can be null** (Workflow tool doc)——如果用户没给 budget，`remaining()=Infinity`；循环必须检查 `budget.total` 存在

---

## 2. Background Context

### 2.1 Previous Work
- `surplus-scan.workflow.js`（Phase 1，已 committed）→ 产出 JSON sidecar（53 行结构化数据：slug/title/cost_numeric/expected_value/density/risk_tag/safety_flag/auto_eligible）
- `yolo-epic.workflow.js`（已 committed，被 6+ 个 YOLO Epic 使用过）→ 输入 = Epic 上下文 + Phase 定义；输出 = design + review + implement + impl_review 结果
- `surplus` SKILL（Phase 1）→ `*surplus --plan` 路径已存在；Phase 2 需新增 `*surplus +<budget>` 执行路径

### 2.2 Current State
JSON sidecar 最新版：`.tad/active/SURPLUS-PLAN-2026-06-14.json`（可作为 dogfood 数据源）。

### 2.3 Dependencies
yolo-epic.workflow.js 必须已 committed 且 name 可解析。无新外部依赖。

---

## 3. Requirements

- FR1: `surplus-execute.workflow.js`——budget loop + SAFETY skip + failure skip + report 生成
- FR2: `surplus` SKILL 新增 `*surplus +<budget>` 执行路径（解析 budget 数字 → 调用 workflow → persist report）
- FR3: SURPLUS-REPORT digest——executed/skipped/failed 三类，每条含 slug/result/token-spent/理由
- FR4: Dogfood——对最新 sidecar 的 auto_eligible 行真实执行 ≥1 条，端到端产出已归档的交付物
- NFR1: Expert review 不跳过（AR-001 hard rule）——yolo-epic 内部已含 design review + impl review
- NFR2: SAFETY 任务零自动执行——safety_flag=true → 跳过并记入 needs-you

---

## 4. Technical Design

### 4.1 Architecture
```
*surplus +500K
  │
  surplus SKILL: parse budget → stamp date → read latest sidecar JSON
  │
  └─ Workflow({ scriptPath: surplus-execute.workflow.js,
       args: { sidecar_rows: [...], date: '<stamp>' } })
       │
       ├─ filter: auto_eligible && !safety_flag → sorted by expected_value desc
       ├─ LOOP (while budget.remaining() > per_task_reserve):
       │    pick top → workflow('yolo-epic', { ... }) → result
       │    success → record; fail → honest_partial + skip; next
       ├─ needs_you: safety_flag rows → passthrough list
       └─ return: { executed: [...], skipped: [...], failed: [...],
                     needs_you: [...], report_markdown: '...' }

  surplus SKILL: persist SURPLUS-REPORT-<stamp>.md via Write tool
```

### 4.2 Component Specifications

**A. surplus-execute.workflow.js**

输入 `args`：
```js
{
  sidecar_rows: [ { slug, title, cost_numeric, expected_value, density, risk_tag, safety_flag, auto_eligible, source, rationale }, ... ],
  date: 'YYYY-MM-DD'
}
```

**Step 0: Sidecar 校验（SA P0-2 fix）**——读入后逐行检查：
- 每行必须含 `id`(string), `safety_flag`(boolean), `auto_eligible`(boolean), `expected_value`(number), `summary`(string)
- 任一行校验失败 → 整 workflow throw（fail-closed，不执行任何任务）

**Step 1: 分流（SA P0-1 fix）**——用严格相等，不用 truthiness：
```
eligible = validated_rows.filter(r => r.auto_eligible === true && r.safety_flag === false)
           .sort((a,b) => b.expected_value - a.expected_value)
needs_you = validated_rows.filter(r => r.safety_flag === true)
not_eligible = validated_rows.filter(r => r.auto_eligible !== true && r.safety_flag !== true)
// 三类合计 = 总行数（report 输出全部，不静默丢弃——SA P2 fix）
```

**Step 2: Ephemeral Epic 合成（CR P0-3 fix）**——大多数 sidecar 行没有现成 Epic 文件。对每个 eligible 任务：
1. 用 `agent()` 生成一个 ephemeral Epic + handoff pair（写到 `.tad/active/epics/EPHEMERAL-surplus-{id}.md` + `.tad/active/handoffs/HANDOFF-surplus-{id}.md`）
   - prompt 含 sidecar 行的 summary + deliverable + source + value_rationale
   - schema 约束输出必须含 phase_name, scope, ac_list (≥3 ACs)
2. 设置 yolo-epic 所需的 7 key args

**Step 3: Budget loop**
```
per_task_reserve = 250000  // 250K tokens — yolo-epic 实测 200-500K（CR P1-2 fix, 上调）
consecutive_fail = 0

for each task in eligible:
  if budget.total && budget.remaining() < per_task_reserve: break

  // Step 2 产出
  ephemeral = synthesize_epic(task)  // agent() call

  var before = budget.spent()
  var result = await workflow('yolo-epic', {
    epic_path:       ephemeral.epic_path,
    epic_slug:       'surplus-' + task.id,
    phase_number:    1,
    phase_name:      ephemeral.phase_name,
    handoff_path:    ephemeral.handoff_path,
    completion_path: ephemeral.completion_path,
    steps:           ['design', 'review', 'implement', 'impl_review']
  })
  var spent = budget.spent() - before

  // CR P0-2 fix: yolo-epic RETURNS error/stop_reason, never throws
  if (result.error || result.stop_reason) {
    results.failed.push({ id: task.id, reason: result.error || result.stop_reason, tokens: spent })
    consecutive_fail++
    if (consecutive_fail >= 3) { log('circuit breaker: 3 consecutive failures'); break }
  } else {
    results.executed.push({ id: task.id, result_summary: result, tokens: spent })
    consecutive_fail = 0  // CR P1-1 fix: reset on success
  }
```

**退出条件（三个，排他）**：
1. `budget.total && budget.remaining() < per_task_reserve`（预算耗尽；budget.total null 时循环跑到 eligible 完——SA P1-2 已标注）
2. `eligible` 全部处理完
3. 3 次**连续**失败（counter reset on success——CR P1-1 fix）

**yolo-epic 调用契约（CR P0-1 fix——逐 key 对齐 yolo-epic.workflow.js L70-88）**：
| yolo-epic key | 来源 |
|---------------|------|
| `epic_path` | Step 2 合成的 ephemeral Epic 文件路径 |
| `epic_slug` | `'surplus-' + task.id` |
| `phase_number` | 固定 `1`（每个 surplus 任务是单 Phase） |
| `phase_name` | Step 2 agent 输出的 `phase_name` |
| `handoff_path` | Step 2 合成的 handoff 路径 |
| `completion_path` | `.tad/active/handoffs/COMPLETION-surplus-{id}.md` |
| `steps` | `['design', 'review', 'implement', 'impl_review']` |

yolo-epic **不 throw**——所有失败通过 `result.error` 或 `result.stop_reason` 返回（CR P0-2）。`stop_reason = 'design review found N P0(s)'` 视为 failed（设计被毙），不是 executed。

**B. surplus SKILL 新增执行路径**
在现有 `*surplus --plan` 下方新增 `*surplus +<budget>` 节：
1. 解析 budget：`+500K` → 500000（K=1000, M=1000000）
2. 读最新 sidecar：`ls -t .tad/active/SURPLUS-PLAN-*.json | head -1`
3. 调用 `surplus-execute.workflow.js`（scriptPath，因为是新文件首次运行）
4. 持久化 `SURPLUS-REPORT-<stamp>.md` 到 `.tad/active/`
5. 显示摘要 + 指向 report

**C. SURPLUS-REPORT 格式**
```markdown
# Surplus Report — YYYY-MM-DD

## Summary
- Budget: +{N} tokens
- Executed: {n} tasks ({tokens} spent)
- Failed: {n} tasks (skipped, honest_partial)
- Needs You: {n} SAFETY tasks (not executed)
- Remaining budget: {n} tokens

## Executed Tasks
| # | Task | Result | Tokens | Evidence |
|---|------|--------|--------|----------|
| 1 | {slug} | ✅ PASS | ~{n}K | .tad/evidence/... |

## Failed Tasks (skipped)
| # | Task | Error | Tokens Wasted |
|---|------|-------|---------------|
| 1 | {slug} | {1-line} | ~{n}K |

## 🔒 Needs You (SAFETY — not auto-executed)
| # | Task | Risk | Why |
|---|------|------|-----|
| 1 | {slug} | {risk_tag} | safety_flag=true: {rationale} |
```

### 4.3 数据流
JSON sidecar（读）→ surplus-execute workflow → yolo-epic(内嵌) → SURPLUS-REPORT + 已归档交付物（写）

---

## 5. 🆕 强制问题回答

### MQ1: 历史代码搜索
[x] 是——yolo-epic.workflow.js 已被 6+ 次真实使用（YOLO Epic 全部通过它跑），调用契约稳定。

### MQ2: 函数存在性
yolo-epic.workflow.js 在 `.claude/workflows/` 已 committed；`workflow('yolo-epic', args)` 按 name 解析已被其它 workflow 验证过（handoff-review 等）。

---

## 6. Implementation Steps

| # | File | Operation | Est. |
|---|------|-----------|------|
| 1 | surplus-execute.workflow.js | 按 §4.2A 实现（meta + budget loop + SAFETY filter + report render） | 1.5h |
| 2 | surplus/SKILL.md | 新增 `*surplus +<budget>` 执行路径 | 30m |
| 3 | 语法验证 | wrapped-body `node --check` on surplus-execute | 10m |
| 4 | Dogfood dry-run | `*surplus +200K` 对最新 sidecar 真实执行 ≥1 条 auto_eligible 任务 | 30m+ |

## 6.7 AC Dry-Run Log
(Alex step1d — 本 Phase 全部 AC 为 post-impl，语法验证通过)

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/workflows/surplus-execute.workflow.js
.tad/active/SURPLUS-REPORT-{date}.md        (dogfood 产物)
```

### 7.2 Files to Modify
```
.claude/skills/surplus/SKILL.md              (新增执行路径)
```

---

## 8. Testing Requirements

### 8.1 Dogfood（FR4 — E2E 验证）
对最新 sidecar (2026-06-14) 的 top auto_eligible 任务执行完整循环。成功 = 交付物已归档 + 出现在 report 的 Executed 表中。如果首选任务 yolo-epic 失败（可能因为 backlog 任务的 scope 过时）→ 按 skip + honest_partial 跳到下一条，report 中 Failed 表记录原因。

### 8.4 Friction Preflight
| Friction Point | Required Step | Fix Path | Substitute | Gate Impact |
|---|---|---|---|---|
| yolo-epic 内部可能失败 | dogfood E2E | skip+continue 设计 | honest_partial | AC4 要求 ≥1 成功 |
| budget.total null 风险 | 循环前 guard | 检查 budget.total 存在 | 无 budget 时跳过循环 | 无循环 = 无结果 |

---

## 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist

| # | AC | Type | Verification | Expected |
|---|-----|------|-------------|----------|
| AC1 | workflow 语法合法 | post-impl | wrapped-body node --check on surplus-execute.workflow.js | exit 0 |
| AC2 | SAFETY 零执行（双层验证） | post-impl | (a) 源码：`grep -c 'safety_flag === true' .claude/workflows/surplus-execute.workflow.js` ≥1 [CR P1-3 fix：验源码不只验 report]；(b) report：needs-you 表有行 + executed 表无 safety 行 | (a) ≥1 + (b) 成立 |
| AC3 | report 三表齐全 | post-impl | `grep -c '^## Executed\|^## Failed\|^## .*Needs You' .tad/active/SURPLUS-REPORT-*.md` | ≥3 |
| AC4 | Dogfood ≥1 真实任务完成 | post-impl | report Executed 表 ≥1 行 + 对应 evidence 存在 | ≥1 行 + evidence 文件 |
| AC5 | SKILL 执行路径可用 | post-impl | `grep -c 'surplus +' .claude/skills/surplus/SKILL.md` | ≥1 |
| AC6 | circuit breaker 存在 | post-impl | `grep -c 'consecutive.*fail\|circuit.breaker' .claude/workflows/surplus-execute.workflow.js` | ≥1 |
| AC7 | budget guard 存在 | post-impl | `grep -c 'budget.total\|budget.remaining' .claude/workflows/surplus-execute.workflow.js` | ≥2 |
| AC8 | yolo-epic 未修改 | post-impl | `git diff HEAD --stat -- .claude/workflows/yolo-epic.workflow.js` | 0 lines |
| AC9 | sidecar 校验 fail-closed | post-impl | `grep -cE 'throw\|Error.*valid' .claude/workflows/surplus-execute.workflow.js` | ≥1（schema 失败 = throw，不静默跳过 [SA P0-2]） |
| AC10 | 严格相等 safety filter | post-impl | `grep -c 'safety_flag === false' .claude/workflows/surplus-execute.workflow.js` + `grep -c 'safety_flag === true' .claude/workflows/surplus-execute.workflow.js` | 各 ≥1（不用 truthiness [SA P0-1]） |
| AC11 | ephemeral epic 合成存在 | post-impl | `grep -cE 'EPHEMERAL\|synthesize' .claude/workflows/surplus-execute.workflow.js` | ≥1（sidecar→Epic 转换逻辑 [CR P0-3]） |
| AC12 | result.error/stop_reason 检查（不用 try/catch） | post-impl | `grep -cE 'result\.error\|result\.stop_reason' .claude/workflows/surplus-execute.workflow.js` | ≥2 [CR P0-2] |

## 9.2 Expert Review Status

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: yolo-epic args 7-key 契约 vs handoff 的 epic_context 对不上 → 全循环空跑 | §4.2A Step 2 + yolo-epic 调用契约表（逐 key 对齐 L70-88） | Resolved |
| code-reviewer | P0-2: yolo-epic 不 throw → try/catch 死代码 → 失败进 executed | §4.2A Step 3（result.error/stop_reason 检查 + AC12） | Resolved |
| code-reviewer | P0-3: sidecar 行不是 Epic 文件 → yolo-epic 无输入 | §4.2A Step 2（ephemeral Epic 合成 + AC11） | Resolved |
| code-reviewer | P1-1: circuit breaker 无 reset | §4.2A Step 3（`consecutive_fail = 0` on success） | Resolved |
| code-reviewer | P1-2: per_task_reserve 100K 太低 | §4.2A（上调 250K） | Resolved |
| code-reviewer | P1-3: AC2 自引 report 不验源码 | AC2 改双层验证（源码 + report） | Resolved |
| security-auditor | P0-1: !safety_flag 对 undefined 是 fail-open | §4.2A Step 1（`=== false` 严格相等 + AC10） | Resolved |
| security-auditor | P0-2: 无 sidecar schema 校验 | §4.2A Step 0（逐行校验 + throw + AC9） | Resolved |
| security-auditor | P1-1: yolo-epic 无文件 scope 限制 | §10.2（记录为 known-constraint；deny-list 留 Phase 3 如需） | Resolved (documented) |
| security-auditor | P1-2: budget.total null 时循环无界 | §4.2A Step 3 退出条件 #1 注释已标注 | Resolved (documented) |
| security-auditor | P1-3: per_task_reserve 过低 | §4.2A（同 CR P1-2，上调 250K） | Resolved |
| security-auditor | P1-4: sidecar mtime 选择无完整性验证 | §10.2（记录为 advisory；generated_from 字段存在但非阻塞） | Resolved (documented) |
| security-auditor | P2: report 静默丢弃 not_eligible 行 | §4.2A Step 1（not_eligible 分类 + report 输出全部三类） | Resolved |

### Experts Selected
1. **code-reviewer** — workflow 调用契约 + budget loop 边界 + error handling
2. **security-auditor** — SAFETY 路由的完整性（safety_flag=true 零执行保证）

### Overall Assessment (post-integration)
- code-reviewer: FAIL → 3 P0 + 3 P1 + 2 P2 全部 Resolved（§4.2A 大幅重写）
- security-auditor: CONDITIONAL PASS → 2 P0 + 4 P1 + 2 P2 全部 Resolved
- Review evidence: `.tad/evidence/reviews/alex/surplus-execute-p2/{code-reviewer,security-auditor}.md`

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **SAFETY 零执行**是 Epic 的 Success Criteria #3——`safety_flag === true`（严格相等）的任务在循环外；`safety_flag` 缺失/非布尔 = sidecar 校验 throw（fail-closed）
- ⚠️ **不改 yolo-epic / surplus-scan**——它们是校准过的工具；本 Phase 只是消费者
- ⚠️ **AR-001**：expert review 不跳过——由 yolo-epic 内部保证（design review + impl review）
- ⚠️ **yolo-epic 不 throw**——所有失败通过 result.error/stop_reason 返回；**禁止用 try/catch 做失败判断**（catch 只防 workflow() 调用本身的 infra 错误，不是业务逻辑）

### 10.2 Known Constraints
- yolo-epic 对文件写入无机械 scope 限制（SA P1-1）：实现 agent 依 handoff scope 自律。deny-list（principles.md/CLAUDE.md/settings.json）如需可在后续版本加，本 Phase 不做
- budget.total null 时循环跑完全部 eligible（SA P1-2）：这是有意行为——用户不指定 budget 说明不限；但 SKILL 层应在无 budget 时 AskUserQuestion 确认
- sidecar 选取用 mtime（SA P1-4）：generated_from 字段存在但不阻塞；最近 sidecar 是合理默认

---

## Required Evidence Manifest

```yaml
required_evidence:
  completion: ".tad/active/handoffs/COMPLETION-20260702-surplus-execute-p2.md"
  workflow: ".claude/workflows/surplus-execute.workflow.js"
  skill_update: ".claude/skills/surplus/SKILL.md"
  report: ".tad/active/SURPLUS-REPORT-*.md"
  dogfood_evidence: "report Executed 表引用的 evidence 路径存在"
  blake_layer2_reviews: ".tad/evidence/reviews/blake/surplus-execute-p2/*.md (>=2 distinct)"
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-02
**Version**: 3.1.0
