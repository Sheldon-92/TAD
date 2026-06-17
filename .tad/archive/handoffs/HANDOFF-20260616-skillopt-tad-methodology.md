---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/workflows"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-16
**Project:** TAD
**Task ID:** TASK-20260616-001
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-16

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 两个 workflow 文件的改动点已定位，新 spike 文件位置明确 |
| Components Specified | ✅ | prompt 修改内容、schema 变更、新 stage 逻辑都已设计 |
| Functions Verified | ✅ | pipeline/agent/parallel/workflow 均为现有 Workflow API |
| Data Flow Mapped | ✅ | fixture 持久化路径、regression 数据流、spike 产出目录均明确 |

**Gate 2 结果**: ✅ PASS

---

## §1. Summary

### §1.1 One-Line
SkillOpt 研究启发的 TAD 方法论三项改进：pack-upgrade bounded edit + pack-dogfood regression gate + auto-evolve harvest→gate spike。

### §1.2 Background
SkillOpt (Microsoft, arXiv 2605.23904) 深度研究揭示两个 TAD 流程的结构性风险：(1) pack-upgrade 全文重写有 catastrophic forgetting 风险（好规则被重写时丢失），(2) pack-dogfood 只测 "有包 vs 无包"，不测 "新版 vs 旧版" regression。SkillOpt 的灾难数据（无 gate 自修改 −52.8 pts）证明 regression gate 不是可选的。

### §1.3 Intent Statement
让 TAD 的能力包管理流程更安全：升级时保留已验证的好规则，升级后检测是否退化，并验证从 trace 中自动学习的可行性。

---

## §2. Requirements

### §2.1 Functional Requirements

**FR1 — pack-upgrade bounded edit mode**
修改 pack-upgrade.workflow.js 的 Upgrade stage，默认使用 structured edit (add/modify/delete specific rules) 而非全文重写。当 plan 的 layerA_gaps 包含结构性重组关键词时，允许 full rewrite。

**FR2 — pack-dogfood regression dimension**
修改 pack-dogfood.workflow.js：(a) 持久化 test scenario 到 fixtures 目录，(b) 新增 Regression stage 对比 old-pack vs new-pack 答案，(c) 检测知识丢失。

**FR3 — auto-evolve harvest→gate spike**
新建一个最小 spike 脚本，从 TAD trace 文件中提取 "pack 使用 + 结果" 信号，生成一条候选 edit，用 pack-dogfood 作为 validation gate 验证。

**FR4 — dual-platform sync** (DROPPED per expert review)
Codex does not consume Workflow JS files. No .agents/ sync needed for this handoff.

### §2.2 Non-Functional Requirements

- NFR1: 现有 pack-upgrade 和 pack-dogfood 的所有功能保持向后兼容
- NFR2: spike 脚本 stdlib-only（bash 或 Python stdlib），无外部依赖

---

## §3. Acceptance Criteria

| AC | Description | Verification |
|----|-------------|-------------|
| AC1 | pack-upgrade Upgrade stage prompt 以 "BOUNDED EDIT mode" 开头，后续保留 JSON.stringify(plan) + research-honoring rules | Read the prompt string in pack-upgrade.workflow.js; confirm bounded-edit block + plan JSON + research rules all present |
| AC2 | pack-upgrade UPGRADE_SCHEMA.required 包含 'edit_list'，properties 包含 edit_list array schema | Read UPGRADE_SCHEMA in pack-upgrade.workflow.js |
| AC3 | pack-upgrade prompt 包含 full-rewrite escape hatch 条件 (layerA_gaps restructure/reorganize/split/merge) + "set edit_list to []" | Read the prompt string |
| AC4 | pack-dogfood 在 pipeline 前有 baseline snapshot loop（将已有 dogfood-{pack}.md 复制为 .prev.md） | Read pack-dogfood.workflow.js pre-pipeline section |
| AC5 | pack-dogfood 在 Stage 1 和 Stage 2 之间有 fixture persistence stage（写 task 到 fixtures/{pack}.task.md） | Read pack-dogfood.workflow.js pipeline stages |
| AC6 | pack-dogfood Stage 3 (Judge) .then() 包含 `task: b.task`（不丢弃 task text） | Read the Judge .then() return object |
| AC7 | pack-dogfood 新增 Regression stage 读取 .prev.md baseline（非当前运行的 dogfood-{pack}.md） | Read Regression stage prompt — must reference `.prev.md` |
| AC8 | pack-dogfood REGRESSION_SCHEMA 包含 regression_found (boolean) + lost_knowledge (array) | Read REGRESSION_SCHEMA definition |
| AC9 | pack-dogfood meta.phases 包含 Snapshot + Regression（共 5 phases） | Read meta block |
| AC10 | pack-dogfood return value 包含 regression 维度数据 | Read return block |
| AC11 | spike 脚本为 Python stdlib，位于 .tad/evidence/spikes/pack-evolve-spike/spike.py，可执行 | `python3 .tad/evidence/spikes/pack-evolve-spike/spike.py` 不报错 |
| AC12 | spike 脚本 grep 的 event types 匹配真实 trace schema（domain_pack_step 等，不是 capability_pack） | Read spike.py PACK_EVENTS set |
| AC13 | spike 结果（有信号或无信号）写入 spike-report.md | `test -f .tad/evidence/spikes/pack-evolve-spike/spike-report.md` after dry-run |
| AC14 | pack-upgrade Plan/Eval/Review stages 不变（diff HEAD 确认只改 Upgrade stage + schema + 开头常量） | `git diff --stat` 确认只改预期位置 |
| AC15 | **功能测试**: 对一个小 pack 跑 pack-dogfood，Regression stage 不报错，输出 regression_found 字段 | 实际运行验证（用 mock 或 small pack） |

---

## §4. Technical Design

### §4.1 pack-upgrade.workflow.js 改动

**位置**: L262-274 (Upgrade stage — the second callback in the pipeline)

**改动方式**: PREPEND bounded-edit instructions before the existing prompt body. Keep the `JSON.stringify(plan)` interpolation, Layer A/B requirements, and RESEARCH-HONORING RULES sections intact.

**改前开头**: `Apply this upgrade plan to capability pack "${p.name}".`

**改后**: Replace ONLY the opening paragraph (L263-264) with the bounded-edit block below. Everything after (plan JSON, Layer A/B requirements, research-honoring rules L265-274) stays verbatim:

```
Apply this upgrade plan to capability pack "${p.name}" using BOUNDED EDIT mode.

STEP 1: Read the CURRENT .claude/skills/${p.name}/SKILL.md and all references/*.md files.
STEP 2: For each change in the plan, generate a structured edit:
  - add_rule: add a new rule to the specified reference file
  - modify_rule: change an existing rule's content (cite the old rule_id)
  - delete_rule: remove an outdated/wrong rule
STEP 3: Apply each edit to the corresponding file. Do NOT rewrite files that have no edits.
STEP 4: Report the edit_list in your structured output.

⚠️ BOUNDED EDIT RULE: Do NOT rewrite rules that the plan does not mention. Preserve all
unchanged rules VERBATIM. Read each file, locate the specific rules, make ONLY those changes.

EXCEPTION: If the plan's layerA_gaps include structural reorganization (restructure/
reorganize/split/merge), full rewrite is acceptable for the affected files. State this
explicitly in your summary and set edit_list to [].
```

Then the existing prompt body continues unchanged:
```
The plan was produced from a DEEP-RESEARCH report...
PLAN:\n${JSON.stringify(plan, null, 2)}\n\n
REQUIREMENTS (read ${QB} for exact criteria):\n...
RESEARCH-HONORING RULES...\n...
```

**UPGRADE_SCHEMA 扩展**: Add `edit_list` to both `properties` and `required`:
```js
required: ['pack', 'files_changed', 'body_lines_after', 'fixture_written', 'summary', 'edit_list'],
// ...
edit_list: { type: 'array', items: { type: 'object', required: ['op', 'file', 'content'],
  properties: { op: { type: 'string' }, file: { type: 'string' }, rule_id: { type: 'string' },
  content: { type: 'string' }, rationale: { type: 'string' } } } }
```

When the full-rewrite escape hatch fires, the agent sets `edit_list: []` and documents the reason in `summary`. Schema still validates.

### §4.2 pack-dogfood.workflow.js 改动

**4.2.1 Baseline snapshot** (BEFORE pipeline starts)

⚠️ P0 fix: The current-run Judge (Stage 3) writes `dogfood-{pack}.md`, overwriting any
previous baseline. The Regression stage (Stage 4) needs the PREVIOUS run's judgment.
Solution: snapshot existing baselines before the pipeline starts.

```js
// Before pipeline: snapshot existing baselines for regression comparison
for (let i = 0; i < packs.length; i++) {
  const p = typeof packs[i] === 'string' ? packs[i] : packs[i].name
  // Snapshot done by a dedicated agent (reliable file I/O, no side-effect delegation)
  await agent(
    `If the file ${EV}/dogfood-${p}.md exists, copy it to ${EV}/dogfood-${p}.prev.md (overwrite if exists). ` +
    `If it does not exist, do nothing. Report what you did.`,
    { label: `snapshot:${p}`, phase: 'Snapshot' }
  )
}
```

**4.2.2 Fixture persistence** (Stage 2 `.then()`, NOT Judge)

⚠️ P0 fix: Fixture persistence must be deterministic, not delegated to an agent's
side-effect. Persist in Stage 2's `.then()` where `task` is a resolved string:

```js
// In Stage 2 .then():
.then((ans) => {
  const control = ans[0] || '(control failed)'
  const withpack = ans[1] || '(with-pack failed)'
  const packFirst = (idx % 2 === 1)
  // Persist fixture for future regression baselines
  // (agent writes it — this is a dedicated side-effect, not conflated with another task)
  // Alternative: have the Stage 2 withpack agent also persist, but separate is cleaner.
  return {
    pack, task,
    answer1: packFirst ? withpack : control,
    answer2: packFirst ? control : withpack,
    pack_is: packFirst ? '1' : '2',
  }
})
```

Additionally, add a dedicated mini-agent between Stage 1 and Stage 2 to persist the fixture:
```js
// After Stage 1 (task extraction), before Stage 2 (answers):
(task, pack) => {
  // Persist fixture if not already present (for future regression runs)
  agent(
    `Write the following task text to ${EV}/fixtures/${pack}.task.md (create dir if needed, ` +
    `overwrite if exists):\n\n${task}`,
    { label: `persist:${pack}`, phase: 'Task' }
  )
  return task  // pass through to Stage 2 unchanged
},
```

**4.2.3 Thread task through Stage 3**

⚠️ P0 fix: Stage 3 (Judge) `.then()` currently returns `{pack, pack_is, verdict}` —
dropping the task text. The Regression stage needs it as fallback.

```js
// Modify Judge stage .then() (current L109):
// FROM:
.then((j) => ({ pack, pack_is: b.pack_is, verdict: j || ... }))
// TO:
.then((j) => ({ pack, pack_is: b.pack_is, task: b.task, verdict: j || ... }))
```

**4.2.4 Regression stage** (Stage 5, after Judge)

```js
// Stage 5: Regression check (uses .prev.md baseline from snapshot)
(judged, pack) => agent(
  `REGRESSION CHECK for capability pack "${pack}".

  1. Check if ${EV}/dogfood-${pack}.prev.md exists. If NOT → return regression_found=false
     (no previous baseline — this is the first run or first run after adding regression).
  2. Read ${EV}/dogfood-${pack}.prev.md — this is the PREVIOUS run's judgment (baseline).
  3. Read the task from: ${EV}/fixtures/${pack}.task.md (persisted by the current run).
     Fallback: use this task text: "${judged.task || '(unavailable)'}"
  4. Read .claude/skills/${pack}/SKILL.md and references/ (the CURRENT version).
  5. Answer the task using the CURRENT pack rules.
  6. Compare your answer against the PREVIOUS judgment's winning answer.
  7. Identify any knowledge/rules/specifics that the PREVIOUS answer had correctly
     but the CURRENT answer LOST.

  regression_found = true if any correct knowledge was lost.
  Write analysis to ${EV}/regression-${pack}.md`,
  { label: `regression:${pack}`, phase: 'Regression', schema: REGRESSION_SCHEMA }
)
```

**meta.phases 扩展**: Add Snapshot and Regression:
```js
phases: [
  { title: 'Snapshot', detail: 'Copy existing dogfood baselines to .prev.md for regression comparison' },
  { title: 'Task', detail: 'Extract user-facing scenario from each pack fixture' },
  { title: 'Answers', detail: 'Control + with-pack answers; blind order by index parity' },
  { title: 'Judge', detail: 'Blind rubric scoring + WebSearch fact-check' },
  { title: 'Regression', detail: 'Compare current-pack vs previous-baseline; detect lost knowledge' }
]
```

**Return value 扩展**: rows 增加 regression 数据。

### §4.3 auto-evolve spike

**文件**: `.tad/evidence/spikes/pack-evolve-spike/spike.py` (Python stdlib, not bash — JSONL parsing is fragile in bash)

⚠️ P1 fix: Actual trace events use types like `domain_pack_step`, `tool_call_outcome`,
`gate_result`, NOT `capability_pack` or `pack_loaded`. The spike must grep for real event types.
Also: current traces may not contain pack-usage signals at all — documenting this gap IS
a valid spike outcome.

**逻辑**:
```python
#!/usr/bin/env python3
"""SkillOpt-inspired spike: harvest trace → mine pack-related signals → report.
This is a feasibility SPIKE — proving whether TAD traces contain usable signals
for automatic pack improvement. A negative result (no signal) is valid evidence."""

import json, glob, os, sys
from collections import Counter

TRACE_DIR = ".tad/evidence/traces"
OUTPUT_DIR = ".tad/evidence/spikes/pack-evolve-spike"

# Real trace event types to look for (from TAD trace v2 schema)
PACK_EVENTS = {"domain_pack_step", "domain_pack_created"}
OUTCOME_EVENTS = {"gate_result", "tool_call_outcome", "task_completed"}
FEEDBACK_EVENTS = {"reflexion_diagnosis", "expert_review_finding"}

def harvest():
    """Read all trace JSONL, extract pack-related and outcome events."""
    events = []
    for path in sorted(glob.glob(f"{TRACE_DIR}/*.jsonl")):
        with open(path) as f:
            for line in f:
                try:
                    ev = json.loads(line.strip())
                    if ev.get("type") in PACK_EVENTS | OUTCOME_EVENTS | FEEDBACK_EVENTS:
                        events.append(ev)
                except (json.JSONDecodeError, KeyError):
                    continue
    return events

def mine(events):
    """Count events by type, identify pack usage patterns."""
    type_counts = Counter(ev["type"] for ev in events)
    # ... further analysis
    return type_counts

def report(type_counts):
    """Write spike findings."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    with open(f"{OUTPUT_DIR}/spike-report.md", "w") as f:
        f.write("# Pack-Evolve Spike Report\n\n")
        if not type_counts:
            f.write("## Finding: NO pack-related signals in traces\n\n")
            f.write("The current trace schema (v2) does not emit pack-usage events.\n")
            f.write("**Prerequisite for auto-evolve**: add trace emission for pack loading + outcome.\n")
        else:
            f.write(f"## Event counts ({sum(type_counts.values())} total)\n\n")
            for t, c in type_counts.most_common():
                f.write(f"- {t}: {c}\n")
    print(f"Report written to {OUTPUT_DIR}/spike-report.md")

if __name__ == "__main__":
    events = harvest()
    counts = mine(events)
    report(counts)
```

**Evidence 目录**: `.tad/evidence/spikes/pack-evolve-spike/`

### §4.4 Dual-platform sync

⚠️ P1 fix: `.agents/workflows/` does NOT exist and Codex does not consume Workflow JS files
(Workflows are a Claude Code feature, not Codex). **Drop the .agents sync for workflow files.**
Only `.claude/workflows/` is modified.

If future Codex support adds workflow consumption, sync can be added at that time.

---

## §5. Implementation Hints

- pack-upgrade: 只改 Upgrade stage 的 agent prompt 和 UPGRADE_SCHEMA，不碰 Plan/Eval/Review stages
- pack-dogfood: Judge stage 保持不变，Regression 是新增的第 4 stage 加在 pipeline 末尾
- spike 脚本保持极简 — 目的是 "证明 trace 里有可用信号"，不是 "做完整管道"
- 测试: 改完后对一个小 pack（如 code-security）跑一次 pack-dogfood 验证 regression stage 不报错

---

## §6. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Bounded edit 可能导致 Upgrade agent 改不彻底 | 保留 full-rewrite escape hatch (layerA_gaps 含 restructure 时) |
| Regression stage 增加 dogfood 运行时间 | Regression 是 pipeline 最后一步，不阻塞前面的 Task/Answers/Judge |
| Spike 从 trace 中提取不到有用信号 | Spike 是验证性质的，即使发现 trace 信号不够 = 有价值的负面结果 |

---

## §7. Scope Estimation

| Task | Effort |
|------|--------|
| FR1: pack-upgrade bounded edit | ~40 行 prompt 修改 + ~10 行 schema 修改 |
| FR2: pack-dogfood regression | ~80 行 (snapshot loop + fixture stage + thread task + regression stage + schema/meta/return) |
| FR3: spike prototype | ~60-80 行 Python |
| FR4: dual-platform sync | DROPPED (Codex doesn't consume workflows) |
| Total | ~180-210 行改动/新增 |

---

## §8. Additional Sections

### §8.1 Testing Strategy
- pack-upgrade: 对一个 small pack 跑 upgrade，确认 edit_list 有内容且文件改动精准
- pack-dogfood: 对一个 pack 连跑两次 dogfood（第二次应触发 regression stage）
- spike: dry-run 确认能读取 trace 文件并输出有意义的统计

### §8.2 Rollback Plan
所有改动在 .claude/workflows/ 和 .agents/workflows/ 中，git revert 一个 commit 即可。

### §8.3 Dependencies
无外部依赖。

### §8.4 Friction Preflight
无 friction-sensitive prerequisites — 所有工具都是现有 Workflow API + bash。

---

## §9. Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0: Fixture persistence delegated to Judge agent unreliable | §4.2.2 redesigned: dedicated persist stage between Stage 1-2 | ✅ Fixed |
| code-reviewer | P0: .agents/workflows/ doesn't exist + Codex doesn't consume workflows | §4.4 + FR4: DROPPED .agents sync entirely | ✅ Fixed |
| code-reviewer | P1: Upgrade prompt replacement scope ambiguous (missing plan JSON + research rules) | §4.1: clarified PREPEND only opening paragraph, keep existing body | ✅ Fixed |
| code-reviewer | P1: ACs use grep (Validation Theater) | §3 ACs rewritten: Read-based verification + functional test AC15 | ✅ Fixed |
| code-reviewer | P1: Spike greps for nonexistent event types in traces | §4.3: rewrote as Python, correct event types, negative result = valid | ✅ Fixed |
| code-reviewer | P1: Judge .then() drops task text | §4.2.3: thread `task: b.task` through Stage 3 | ✅ Fixed |
| backend-architect | P0: Regression stage has no access to task text | §4.2.3 + §4.2.4: thread task + fixture fallback | ✅ Fixed |
| backend-architect | P1: Regression reads current-run dogfood-{pack}.md, not previous baseline | §4.2.1: pre-pipeline snapshot to .prev.md | ✅ Fixed |
| backend-architect | P2: edit_list not in required array | §4.1: added to required + documented [] escape for full-rewrite | ✅ Fixed |
| backend-architect | P2: .agents/workflows/ doesn't exist | §4.4: DROPPED (same as code-reviewer P0) | ✅ Fixed |
| backend-architect | P2: Spike location (.tad/hooks/lib/) wrong | §4.3: moved to .tad/evidence/spikes/pack-evolve-spike/spike.py | ✅ Fixed |

---

## §10. Files to Modify

| File | Action |
|------|--------|
| `.claude/workflows/pack-upgrade.workflow.js` | Modify Upgrade stage prompt + UPGRADE_SCHEMA |
| `.claude/workflows/pack-dogfood.workflow.js` | Add Regression stage + schema + fixture persistence + meta.phases |
| `.tad/evidence/spikes/pack-evolve-spike/spike.py` | New — spike prototype (Python stdlib) |
| `.tad/evidence/spikes/pack-evolve-spike/spike-report.md` | New — spike output (generated by spike.py) |

---

## §11. Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Edit mode default | Bounded edit (full rewrite when plan layerA_gaps say restructure; edit_list=[] in that case) | SkillOpt proves bounded edit safer; full rewrite reserved for structural changes |
| Regression scope | Both blind eval + same-scenario replay, with .prev.md baseline snapshot | Comprehensive regression detection without overwriting baseline |
| Auto-evolve scope | Python stdlib spike (harvest real trace events + report signal availability) | Validate feasibility; negative result (no signal) is valid evidence |
| Platform | .claude/workflows/ only (DROPPED .agents sync — Codex doesn't consume workflows) | Expert review finding: .agents/workflows/ doesn't exist and isn't consumed |
| Fixture persistence | Dedicated persist stage between Stage 1-2, not delegated to Judge | Expert review P0: agent side-effect is unreliable for file I/O |
| Task text threading | Stage 3 .then() carries task: b.task through to Regression | Expert review P0: task was dropped at pipeline boundary |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Deny-List Must Be Applied at EVERY Copy Granularity** (principles.md) — sync 到 .agents/ 时确保文件级一致，不只是目录级
- **Never Hand-Write What an Existing Tool Already Does** (principles.md) — spike 脚本如果和现有 trace 工具重复，用现有的
- **YOLO Audit: Validation Theater** (patterns/pack-evaluation.md) — 结构性检查（grep, word count）不等于功能验证，regression stage 的 judge 必须做真判断

---

## 📨 Blake 消息

```
📨 新 Handoff 待执行

任务: SkillOpt-Informed TAD Methodology Improvements
文件: .tad/active/handoffs/HANDOFF-20260616-skillopt-tad-methodology.md
优先级: Medium
范围: 2 个 workflow 文件修改 + 1 个 spike 脚本新建（~180-210 行）
涉及文件:
  - .claude/workflows/pack-upgrade.workflow.js (Upgrade stage prompt + UPGRADE_SCHEMA)
  - .claude/workflows/pack-dogfood.workflow.js (snapshot loop + fixture persist + thread task + regression stage)
  - .tad/evidence/spikes/pack-evolve-spike/spike.py (new)

关键 AC:
- AC1-3: pack-upgrade bounded edit mode (PREPEND to existing prompt, keep plan JSON + research rules)
- AC4-10: pack-dogfood regression (snapshot .prev.md + fixture persist + thread task + regression stage)
- AC11-13: auto-evolve spike prototype (Python stdlib, real trace event types)
- AC14: backward compat (Plan/Eval/Review unchanged)
- AC15: functional test (run dogfood on small pack, regression stage outputs regression_found)

⚠️ Expert review 修了 3 个 P0:
1. task text 在 pipeline Stage 3 被丢弃 → 现在 thread through
2. fixture persistence 委托给 Judge agent 不可靠 → 现在是独立 persist stage
3. regression 读的是当前运行的 baseline → 现在 pre-pipeline snapshot 到 .prev.md

⚠️ .agents/ sync DROPPED — Codex 不消费 Workflow JS 文件
```
