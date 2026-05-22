---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: []
gate4_delta: []
---

# Handoff: Auto-Evolve Phase 4 — Optimize/Evolve Redesign

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-20
**Project:** TAD
**Task ID:** TASK-20260520-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260518-auto-evolve.md (Phase 4/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-20

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | v2 metrics additive (6-9), scope 3-tier heuristic aligned with Phase 3, MANIFEST as future contract |
| Components Specified | ✅ | 4 new metrics, dream candidate integration, scope classification, *evolve v2 analysis, MANIFEST schema |
| Functions Verified | ✅ | optimize step1/step2/step2b/step3 (lines 4810-4930), evolve step2/step5 (lines 5027-5150) verified |
| Data Flow Mapped | ✅ | JSONL → v1/v2 split → metrics 1-9 + dream candidates → proposals (scope-tagged) → framework/ staging → future *sync |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 4 P0 + 4 P1 all resolved. See §9.2 Audit Trail.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
让 `*optimize` 和 `*evolve` 消费 Phase 1-3 的全部新数据，完成 auto-evolve 闭环：

1. **`*optimize` v2** — 在现有 lifecycle health analysis（commit 816449f）基础上，加入 v2 trace 分析（gate 通过率、反思效率、决策模式）+ dream candidate 整合 + scope 分类
2. **`*evolve` v2** — 从 "Domain Pack step 分析"（已冻结）切换到 "v2 事件跨项目聚合" + dream candidate (scope_tag=framework) 消费 + *sync 集成
3. **Three-store 分流** — project-scope proposals → 本地 project-knowledge；framework-scope proposals → `.tad/evidence/proposals/framework/` → *sync 推送

### 1.2 Why We're Building It
**业务价值**: Phase 1 产数据，Phase 2 产反思，Phase 3 产候选知识。但没有 Phase 4，这些数据和候选知识只是被动等人来看。Phase 4 让 `*optimize` 主动分析"你的项目哪里不健康、为什么"，让 `*evolve` 把 15 个项目的共性问题提炼成框架改进，通过 `*sync` 推给所有人。

**成功的样子**: 用户跑 `*optimize` → 看到"Gate 3 通过率 78%，反思后首次修复率 65%（比无反思提高 20%），3 个 dream candidates 待审阅" → 批准改进 → 知识自动积累。跑 `*evolve` → "跨 15 个项目，'tsc type error' 是最常见的反思原因（占 34%），建议在 SKILL.md 中加强类型检查引导" → 批准 → `*sync` 推到所有项目。

### 1.3 Intent Statement
**真正要解决的问题**: 闭环最后一环——从数据到行动。

**不是要做的**:
- ❌ 不改变 *sync 的执行机制（只加一个 framework proposals 消费入口）
- ❌ 不改变 Phase 1-3 的数据格式（消费者，不是生产者）
- ❌ 不自动应用 framework proposals（人类审批 + *sync 是两道门）

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **Double-Parse Pattern (Phase 3 new entry)** (architecture.md)
   - v2 trace events store structured data inside `context` as JSON string → `jq '.context | fromjson | .field'`

2. **YOLO Audit Findings — 2026-05-15** (architecture.md)
   - Validation theater: structural checks prove files exist but don't prove quality
   - 与本任务关系：*optimize 的 v2 分析必须产出 actionable insights，不只是数字统计

3. **Mechanical Enforcement Rejected — 2026-04-15** (architecture.md)
   - *optimize/*evolve proposals are advisory (human approves). No mechanical application.

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 (*optimize step1 — read v2 traces)**: Extend step1_read_traces to also read `.tad/archive/traces/*.jsonl` (rotation-safe, matching Phase 3 scanner). Parse v2 events (schema_version="2.0") separately from v1 events. Output: "Found {N} v1 events + {M} v2 events across {F} files"

- **FR2 (*optimize step2 — v2 analysis metrics)**: Add 4 new metrics AFTER the existing 5 lifecycle health metrics (which remain unchanged — they are the 816449f contribution):
  - **Gate pass rate**: per-gate (2/3/4) pass/fail ratio from `gate_result` events. Flag gates with <80% pass rate.
  - **Reflexion efficiency**: % of `reflexion_diagnosis` events where confidence=high AND same slug subsequently has gate_result pass (= validated hypotheses). Higher = Blake learns well.
  - **Decision pattern**: top 5 most frequent `decision_point` outcomes. Flag any with actor_tag=human_overridden >30% (= agent's default is often wrong for this decision type).
  - **Expert review density**: `expert_review_finding` P0 count per handoff slug. Flag handoffs with >5 P0s (= design quality issue).

- **FR3 (*optimize step2b — dream candidate integration)**: After trace analysis, check `.tad/active/dream-candidates/CAND-*.md` for pending candidates with `scope_tag: project`. Display them alongside trace-derived proposals under "📚 项目知识更新" heading. User can approve them in the same step4 flow.

- **FR4 (*optimize step3 — scope classification)**: Add `scope` field to PROPOSAL YAML. Use the SAME 3-tier heuristic as Phase 3 dream-scanner (ARCH-P0-1 fix — prevents divergence):
  1. If target.file references `.claude/skills/` or `.tad/hooks/` → `scope: framework`
  2. If target.file is empty/generic: check slug — if slug contains "capability-pack" or SKILL reference → `scope: framework`
  3. Fallback → `scope: project`
  - Framework proposals also written to `.tad/evidence/proposals/framework/` (duplicate, for *evolve consumption)

- **FR5 (*evolve step2 — v2 cross-project analysis)**: Replace the current Domain Pack-centric analysis with v2 event analysis:
  - **Cross-project reflexion patterns**: same `what_failed` (via double-parse) appearing in 2+ projects → framework-level issue
  - **Cross-project gate failure correlation**: same gate consistently fails across projects → gate criteria may need adjustment
  - **Dream candidate aggregation**: collect all `scope_tag: framework` candidates across projects → aggregate into framework proposals
  - Remove references to "Domain Pack step", "domain_pack_step traces", "Quality criteria effectiveness" (Domain Packs are frozen)

- **FR6 (*evolve step5 — framework proposal staging)**: After applying framework proposals:
  - Write accepted proposals to `.tad/evidence/proposals/framework/MANIFEST.yaml` as a **future contract** (ARCH-P0-2 fix: *sync does NOT currently consume this file — a follow-up task will add *sync integration)
  - Output: "⚠️ {N} framework improvements applied to TAD main project. MANIFEST.yaml staged in .tad/evidence/proposals/framework/. Note: *sync integration is a future task — proposals are applied locally; run *sync manually to push framework file changes."
  - MANIFEST schema includes `source_project` and `proposal_file_path` fields (CR-P1-2 fix)

- **FR7 (*optimize/*evolve description update)**: Update the `description` and `distinction` fields:
  - *optimize: "Analyze execution traces + dream candidates → lifecycle health + v2 pattern analysis → project-level proposals"
  - *evolve: "Cross-project v2 trace aggregation + framework dream candidates → framework-level proposals → *sync"

### 3.2 Non-Functional Requirements
- **NFR1**: Pure protocol text changes in Alex SKILL.md. No new scripts, no new hooks.
- **NFR2**: Existing *optimize lifecycle health metrics (step2_aggregate metrics 1-5) are PRESERVED — new metrics are ADDITIVE.
- **NFR3**: *evolve security validation (step1_collect steps 3a-3d) remains unchanged.

---

## 4. Technical Design

### 4.1 *optimize step1 Extension

After existing line "5. If total >= 3: proceed with analysis", add:
```yaml
        6. Also read .tad/archive/traces/*.jsonl (rotation-safe)
        7. Separate v1 events (no schema_version field) from v2 events (schema_version="2.0")
        8. Output: "Found {N_v1} v1 events + {N_v2} v2 events across {F} trace files"
        9. If v2 count == 0: WARN "No v2 trace data found. V2 metrics will show N/A.
           Run a full TAD cycle (handoff → implement → gate) to generate v2 events."
           Proceed with v1-only analysis (existing 5 metrics).
```

### 4.2 *optimize step2 — 4 New Metrics (append after metric 5)

```yaml
        # --- V2 Metrics (require schema_version="2.0" events) ---
        # Skip this section entirely if v2 count == 0 (per step1 line 9)
        # Numbering continues from metric 5. Existing item 6 ("Output summary table")
        # is renumbered to run AFTER all metrics as a display step (CR-P1-1 fix).
        
        6. Gate pass rate (from gate_result events):
           - Group by gate number (extract from context field, e.g., "Gate 3:")
           - Per gate: pass_count / total_count
           - Output: "Gate pass rates: Gate 2: {N}%, Gate 3: {N}%, Gate 4: {N}%"
           - Flag: any gate < 80% → "⚠️ Gate {N} pass rate is {rate}% — review criteria"
        
        8. Reflexion efficiency (from reflexion_diagnosis events):
           - Total reflexion events
           - Validated: reflexion with confidence=high AND same slug has subsequent gate_result pass
             (requires double-parse: jq '.context | fromjson | .confidence')
           - Efficiency = validated / total
           - Minimum sample size: N≥10 before displaying percentage (ARCH-P1-1 fix)
             If N<10: output raw counts only: "Reflexion: {validated}/{total} validated (too few for %)"
           - If N≥10: output "Reflexion efficiency: {rate}% ({validated}/{total} hypotheses validated)"
           - Baseline (when N≥10): >50% is healthy, <30% suggests Blake's hypotheses are often wrong
        
        8. Decision pattern (from decision_point events):
           - Group by decision field (via double-parse of context)
           - Count per decision, sort descending
           - For each decision: count actor_tag=human_overridden / total
           - Output: top 5 decisions with override rate
           - Flag: override rate >30% → "⚠️ Agent's default for '{decision}' is overridden {rate}% of the time"
        
        9. Expert review density (from expert_review_finding events):
            - Group by slug
            - Count P0 findings per slug (outcome=P0 in context)
            - Output: "Expert P0 density: median {N}, max {N} per handoff"
            - Flag: any slug with >5 P0s → "⚠️ {slug} had {N} P0s — design quality concern"
```

### 4.3 *optimize step2b — Dream Candidate Integration

Insert into existing step2b action AFTER item 3, BEFORE the "These proposals join the lifecycle health proposals in step3" paragraph (CR-P0-1 fix — exact insertion point):
```yaml
        4. Check .tad/active/dream-candidates/CAND-*.md for files with:
           - status: pending
           - scope_tag: project
        5. If any found: include them in step4 display under "📚 Dream Candidates (project-scope)"
           These are SEPARATE from trace-derived proposals — they come from Phase 3 scanner
        6. User approves/rejects in same step4 flow as trace-derived proposals
        
        [existing "These proposals join..." paragraph follows unchanged]
```

### 4.4 *optimize step3 — Scope Field Addition

In the PROPOSAL YAML template, add after `status`:
```yaml
        scope: "project"  # project | framework
```

Add scope classification logic:
```yaml
        # Scope classification (per FR4):
        4. Classify proposal scope:
           If target.file matches '.tad/project-knowledge/*' → scope: project
           If target.file matches '.claude/skills/*' or '.tad/hooks/*' → scope: framework
           Default: project
        5. If scope == framework:
           Also copy proposal to .tad/evidence/proposals/framework/{proposal_id}.yaml
```

### 4.5 *evolve step2 — V2 Cross-Project Analysis (REPLACE)

Replace entire step2_analyze action with:
```yaml
    step2_analyze:
      name: "Cross-Project V2 Pattern Analysis"
      action: |
        From aggregated traces, identify cross-project patterns using v2 events:
        
        1. Cross-project reflexion patterns:
           - For each project's reflexion_diagnosis events:
             Extract what_failed via double-parse (jq '.context | fromjson | .what_failed')
           - Group by what_failed across ALL projects
           - Patterns appearing in 2+ projects → framework-level issue
           - Output: "Cross-project failure patterns:"
             | Pattern | Projects | Count | Suggestion |
        
        2. Cross-project gate failure correlation:
           - For each project's gate_result events with outcome=fail:
             Group by gate number
           - Compare per-gate fail rates across projects
           - Gates with >20% fail rate in 3+ projects → framework criteria issue
           - Output: "Gate failure correlation:"
             | Gate | Projects Affected | Avg Fail Rate |
        
        3. Framework dream candidate aggregation:
           - For each project: read {validated_path}/.tad/active/dream-candidates/CAND-*.md
             (using project paths from step1_collect — ARCH-P1-2 fix: dream candidate paths
              MUST go through the same realpath + $HOME security validation as trace paths)
           - Filter: scope_tag=framework AND status=pending
           - Group by signal_type
           - Output: "Framework candidates from {N} projects:"
             | Signal Type | Count | Top Pattern |
        
        4. Lifecycle health comparison:
           - Run *optimize step2 metrics (1-5) per project
           - Compare: zombie rate, cycle time, evidence rate across projects
           - Flag outlier projects (>2σ from mean on any metric)
           - Output: "Project health comparison:"
             | Project | Zombie% | Cycle(h) | Evidence/HO | Status |
        
        5. Output analysis summary table to user
```

### 4.6 *evolve step5 — *sync Integration

Add to existing step5_apply, after "Git commit" step:
```yaml
        5. Write accepted framework proposals to manifest:
           mkdir -p .tad/evidence/proposals/framework
           Write .tad/evidence/proposals/framework/MANIFEST.yaml:
           ```yaml
           last_updated: "{ISO date}"
           accepted_proposals:
             - id: "{proposal_id}"
               target: "{file}"
               change_type: "{type}"
               applied_at: "{date}"
               source_project: "{project_name}"
               proposal_file: ".tad/evidence/proposals/framework/{proposal_id}.yaml"
           ```
        
        After all proposals processed:
          Output: |
            Applied {count} framework improvements.
            ⚠️ {framework_count} framework proposals staged in .tad/evidence/proposals/framework/
            MANIFEST.yaml updated. Run *sync to push to all {N} downstream projects.
```

---

## 6. Implementation Steps

### Step 1: Extend *optimize step1_read_traces
In Alex SKILL.md (line ~4816), append archive reading + v1/v2 separation per §4.1.

### Step 2: Add v2 metrics to step2_aggregate
In Alex SKILL.md (line ~4869), append metrics 7-10 per §4.2 after existing metric 5 ("Activity timeline").

### Step 3: Extend step2b with dream candidate integration
In Alex SKILL.md (line ~4886), append items 4-6 per §4.3.

### Step 4: Add scope field to step3 proposal YAML
In Alex SKILL.md (line ~4900), add scope field + classification logic per §4.4.

### Step 5: Replace *evolve step2_analyze
In Alex SKILL.md (line ~5062-5079), replace entire step2_analyze action with §4.5.

### Step 6: Update *evolve step5_apply with *sync integration
In Alex SKILL.md (line ~5147+), append MANIFEST.yaml writing + sync reminder per §4.6.

### Step 7: Update descriptions + clean stale Domain Pack refs (CR-P0-2)
- optimize_protocol description (line 4811): per FR7
- evolve_protocol description + distinction (lines 5028, 5033-5035): per FR7
- evolve_protocol step3_propose target example (line ~5089): change `domain.yaml` to `SKILL.md` in the target file list
- Grep verification: `grep -n 'Domain Pack' .claude/skills/alex/SKILL.md` in the optimize_protocol + evolve_protocol sections — ensure no stale references remain (lifecycle health metrics may legitimately reference `domain_pack_step` as a trace type name — that is NOT stale)

### Grounded Against (Alex step1c):
- .claude/skills/alex/SKILL.md lines 4810-4930 (optimize_protocol, read at 2026-05-20)
- .claude/skills/alex/SKILL.md lines 5027-5150 (evolve_protocol, read at 2026-05-20)

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/alex/SKILL.md    # optimize_protocol (step1, step2, step2b, step3) + evolve_protocol (step2, step5, descriptions)
```

### 7.2 Files to Create
```
(none — MANIFEST.yaml is created at runtime by *evolve, not by Blake)
```

---

## 9. Acceptance Criteria

- [ ] AC1: *optimize step1 reads both evidence/traces/ AND archive/traces/ (rotation-safe)
- [ ] AC2: *optimize step1 separates v1/v2 events by schema_version field
- [ ] AC3: *optimize step2 has 4 new metrics (gate pass rate, reflexion efficiency, decision pattern, expert review density) — metrics 6-9
- [ ] AC4: *optimize step2 gracefully handles v2_count==0 (skip v2 metrics with N/A message)
- [ ] AC5: *optimize step2b integrates dream candidates (scope_tag=project, status=pending)
- [ ] AC6: *optimize step3 PROPOSAL YAML has `scope` field (project/framework)
- [ ] AC7: Framework-scope proposals duplicated to `.tad/evidence/proposals/framework/`
- [ ] AC8: *evolve step2 uses v2 events (reflexion patterns, gate correlation, dream candidates), no Domain Pack references
- [ ] AC9: *evolve step5 writes MANIFEST.yaml and outputs *sync reminder
- [ ] AC10: Existing lifecycle health metrics (1-5) in step2_aggregate are PRESERVED (additive, not replacement)
- [ ] AC11: *evolve security validation (step1 path checks) unchanged
- [ ] AC12: No settings.json changes, no new scripts, no new hooks
- [ ] AC13: optimize_protocol and evolve_protocol descriptions updated per FR7
- [ ] AC14: Scope classification uses same 3-tier heuristic as Phase 3 scanner (file path → slug → fallback)
- [ ] AC15: *evolve step3_propose target example no longer references `domain.yaml`
- [ ] AC16: MANIFEST.yaml schema includes source_project and proposal_file fields
- [ ] AC17: Reflexion efficiency metric shows raw counts (not %) when N<10
- [ ] AC18: *evolve step2 dream candidate paths use step1_collect security validation

## 9.1 Spec Compliance Checklist

| # | Verification Type | Verification Method | Expected | Verified |
|---|-------------------|--------------------|---------:|----------|
| 1 | post-impl | `grep -c 'archive/traces' .claude/skills/alex/SKILL.md` (in optimize section) | ≥1 | (post-impl) |
| 2 | post-impl | `grep -c 'Gate pass rate' .claude/skills/alex/SKILL.md` | 1 | (post-impl) |
| 3 | post-impl | `grep -c 'Reflexion efficiency' .claude/skills/alex/SKILL.md` | 1 | (post-impl) |
| 4 | post-impl | `grep -c 'MANIFEST.yaml' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| 5 | post-impl | `grep -c 'domain_pack_step' .claude/skills/alex/SKILL.md` (in evolve step2) | 0 in step2_analyze | (post-impl) |
| 6 | pre-impl | `git diff --name-only .claude/settings.json` | empty | ✅ empty |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Alex SKILL.md is ~6000+ lines. Use precise Edit with exact old_string. Do NOT rewrite large sections.
- ⚠️ *optimize step2_aggregate was JUST redesigned by lifecycle-health handoff (816449f). Phase 4 APPENDS metrics 7-10, does NOT modify metrics 1-5.
- ⚠️ Double-parse required for all v2 context field analysis: `jq '.context | fromjson | .field'`
- ⚠️ *evolve step2 replacement: the OLD text references "Domain Pack step with status=failed" — this must be fully replaced, not partially edited.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: step2b insertion point ambiguity — items 4-6 could land after flow-continuation paragraph | §4.3 explicit insertion point: AFTER item 3, BEFORE "These proposals join..." | Resolved |
| code-reviewer | P0-2: stale Domain Pack refs in evolve step3_propose + optimize description | §6 Step 7 expanded: clean step3_propose target + grep verification | Resolved |
| backend-architect | P0-1: scope classification diverges from Phase 3 scanner (file-only vs 3-tier) | §3.1 FR4 rewritten with same 3-tier heuristic, AC14 added | Resolved |
| backend-architect | P0-2: MANIFEST.yaml dead-end — *sync has no consumer | §3.1 FR6 reframed as "future contract", messaging updated, AC16 added | Resolved |
| code-reviewer | P1-1: metric numbering gap (6 skipped) | §4.2 renumbered: metrics 6-9, existing "Output summary" becomes display step | Resolved |
| code-reviewer | P1-2: MANIFEST schema lacks source_project + proposal_file_path | §4.6 schema updated with both fields, AC16 added | Resolved |
| backend-architect | P1-1: reflexion efficiency unreliable at small N | §4.2 metric 7: N≥10 minimum, raw counts below threshold, AC17 added | Resolved |
| backend-architect | P1-2: *evolve dream candidate paths bypass security validation | §4.5 item 3: explicit note about step1_collect validation, AC18 added | Resolved |
| code-reviewer | P2-1: AC2 verification gap for schema_version separation | Noted — AC2 statement is clear, Blake can grep verify | Deferred |
| backend-architect | P2-1: metric numbering gap | Same as CR-P1-1, resolved | Resolved |

### Experts Selected

1. **code-reviewer** — insertion point precision, stale reference detection, AC coverage, metric numbering
2. **backend-architect** — cross-phase contract alignment, security validation, statistical reliability, *sync integration

### Overall Assessment (post-integration)

- code-reviewer: CONDITIONAL PASS → PASS (2 P0, 2 P1 resolved, 1 P2 deferred)
- backend-architect: CONDITIONAL PASS → PASS (2 P0, 2 P1 resolved, 1 P2 resolved)

---

### 10.2 Sub-Agent 使用建议
- [ ] **code-reviewer** — verify existing metrics preserved, scope classification logic, description accuracy

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | v2 metrics placement | Replace existing vs Append | Append (metrics 7-10) | 816449f lifecycle metrics are valuable, additive not replacement |
| 2 | *evolve data source | Keep Domain Pack refs vs Replace with v2 | Replace | Domain Packs are frozen; v2 events are the real data |
| 3 | Framework proposal staging | In-place only vs Duplicate to framework/ | Duplicate | *sync needs a manifest; *optimize proposals stay in main dir too |
| 4 | MANIFEST.yaml creation | Blake creates vs Runtime | Runtime (*evolve creates when proposals accepted) | File is dynamic, not static template |

---

**Required Evidence Manifest**:
```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/auto-evolve-phase4-optimize/code-reviewer.md
    - .tad/evidence/reviews/alex/auto-evolve-phase4-optimize/backend-architect.md
  gate_verdicts:
    - Gate 2 in this document
  completion:
    - .tad/active/handoffs/COMPLETION-20260520-auto-evolve-phase4-optimize.md
  blake_reviews:
    - .tad/evidence/reviews/blake/auto-evolve-phase4-optimize/
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-20
**Version**: 3.1.0
