---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs: []
gate4_delta: []
---

# Handoff: Auto-Evolve Phase 2 — Blake Reflexion

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-19
**Project:** TAD
**Task ID:** TASK-20260519-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260518-auto-evolve.md (Phase 2/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-19

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reflexion as structured pause in Layer 1; trace event via env-var convention; crash recovery from JSONL |
| Components Specified | ✅ | reflexion_step block, trace helper, prompt template, state_schema extension, recovery enhancement |
| Functions Verified | ✅ | record_trace in common.sh (Phase 1), trace-writer.sh (Phase 1), layer1_self_check (line 1270) |
| Data Flow Mapped | ✅ | Layer 1 FAIL → reflection → trace write → context accumulation → guided retry → circuit breaker with history |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 3 P0 + 5 P1 all resolved. See §9.2 Audit Trail.

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
在 Blake 的 Ralph Loop Layer 1 中嵌入 Reflexion 模式（verbal reinforcement learning）。当 Layer 1 自检失败时，Blake 不再直接修复重跑，而是先暂停产出结构化诊断（为什么失败、根因假设、改进方案），然后基于诊断指导重试。诊断通过 Phase 1 的 trace-writer.sh 写入 `reflexion_diagnosis` 事件。

### 1.2 Why We're Building It
**业务价值**: 当前 Blake 的重试是"盲重试"——同样的错误跑 3 次后触发 circuit breaker 上报人类。研究表明 Reflexion 模式（来自 Verbal RL 研究）通过结构化反思让 agent 在重试前理解"为什么失败"，显著降低重试次数和重复错误率。不需要模型微调，纯 in-context learning。

**用户受益**: Blake 的重试更聪明——同样的 15 次 Layer 1 上限内解决更多问题，减少 circuit breaker 升级到人类的频率。Circuit breaker 触发时的上报信息也更丰富（包含 N 次反思历史，不只是"同一错误 3 次"）。

### 1.3 Intent Statement
**真正要解决的问题**: Blake 从"死循环重试"升级到"每次失败后反思再重试"。

**不是要做的**:
- ❌ 不改变 Gate 3 结构或 Layer 2 流程
- ❌ 不做 ToolObserver 式的跨 session 工具文档改进（Phase 3/4 范畴）
- ❌ 不改变 circuit breaker 触发条件（仍然是同一错误 3 次）
- ❌ 不改变 Layer 1 的检查项目（build/test/lint/tsc 不变）

---

## 📚 Project Knowledge（Blake 必读）

### ⚠️ Blake 必须注意的历史教训

1. **Ralph Loop Two-Layer Architecture — 2026-01-26** (architecture.md)
   - 关键：Layer 1 fast self-check, Layer 2 expert review, circuit breaker 3 same errors → escalate
   - 与本任务关系：Reflexion 插入 Layer 1 内部（失败 → 反思 → 重试），不影响 Layer 2

2. **Shell Env-Var Convention (Phase 1 new entry)** (architecture.md)
   - 关键：TRACE_* env vars for v2 trace fields
   - 与本任务关系：reflexion_diagnosis event 通过 trace-writer.sh 的 env-var 约定写入

3. **Cognitive Firewall: Embed Into Existing Flows — 2026-02-06** (architecture.md)
   - 关键：Insert, don't create. Embed into existing mandatory flows.
   - 与本任务关系：Reflexion 嵌入现有 Ralph Loop，不是创建新的独立流程

---

## 2. Background Context

### 2.1 Current Ralph Loop Layer 1 Flow
```
Layer 1 check (build/test/lint/tsc)
  → PASS → proceed to Layer 2
  → FAIL → fix the error → retry (up to 15 times)
             → same error 3 times → circuit breaker → escalate to human
```

### 2.2 Target Flow (with Reflexion)
```
Layer 1 check (build/test/lint/tsc)
  → PASS → proceed to Layer 2
  → FAIL → REFLECTION STEP (new):
             1. Pause: "What failed and why?"
             2. Produce structured diagnosis
             3. Write reflexion_diagnosis trace event
             4. Use diagnosis to guide fix approach
           → fix based on diagnosis → retry
             → same error 3 times → circuit breaker with reflection history → escalate
```

### 2.3 Research Basis
- **Reflexion (Verbal RL)**: forces agent to evaluate failed output, self-reflect on why, then formulate revised plan. Works with in-context learning, no fine-tuning. Minimum data: raw error message from current session.
- **Key insight**: Reflexion is a prompt inserted between failure and retry. It's not a new system — it's a structured pause.

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 (Reflection Step)**: After any Layer 1 check fails, before Blake attempts a fix, insert a reflection prompt that produces a structured diagnosis with 4 fields:
  - `what_failed`: which check failed and the error output (e.g., "tsc: 3 type errors in src/auth.ts")
  - `root_cause_hypothesis`: Blake's analysis of why it failed (e.g., "missing interface for new UserProfile field")
  - `revised_approach`: what to try differently this time (e.g., "add UserProfile.avatar field to types/user.ts before fixing auth.ts")
  - `confidence`: low/medium/high — how confident Blake is in the hypothesis

- **FR2 (Trace Integration)**: Each reflection writes a `reflexion_diagnosis` event to trace via Phase 1's `trace-writer.sh`. Since trace-writer.sh doesn't have a `trace_reflexion_diagnosis` helper yet (intentionally omitted in Phase 1 — it's a Phase 2 event), Blake must add this helper to trace-writer.sh.

- **FR3 (Retry Context)**: The diagnosis is appended to Blake's context for the next retry attempt. If multiple retries occur, Blake has the full reflection history (reflection 1 + reflection 2 + ...) available, enabling each retry to learn from all previous failures.

- **FR4 (Enhanced Circuit Breaker)**: When circuit breaker fires (same error 3 times), the escalation message to human includes:
  - All accumulated reflection diagnoses (not just "same error 3 times")
  - The last `revised_approach` that was tried
  - Blake's assessment of whether this is a design issue (→ Alex) or environment issue (→ human)

- **FR5 (Zero Overhead on Success)**: When Layer 1 passes on first try, no reflection step runs. Reflection only triggers on FAIL. No additional cost for happy path.

- **FR6 (Reflection Prompt Template)**: Create `.tad/templates/reflexion-prompt.md` — a reusable template Blake fills in after each failure. Generic enough for all failure types (tsc, test, lint, build).

### 3.2 Non-Functional Requirements
- **NFR1**: Reflection adds ~5-10 seconds per retry (LLM self-analysis). Acceptable trade-off.
- **NFR2**: No new hooks in settings.json. Reflection is SKILL protocol text, not mechanical enforcement.
- **NFR3**: Reflection history is in-context (conversation memory), not persisted to a file between sessions. Trace events provide cross-session persistence.

---

## 4. Technical Design

### 4.1 Blake SKILL.md Changes

**Location**: `layer1_self_check:` section (line ~1270)

Current text:
```yaml
    layer1_self_check:
      - "按 task_type_branching 执行对应检查"
      - "全部 PASS 才进 Layer 2 — 一项 FAIL 就修复重跑"
```

Replace with:
```yaml
    layer1_self_check:
      - "按 task_type_branching 执行对应检查"
      - "全部 PASS 才进 Layer 2"
      - "一项 FAIL → 执行 reflexion_step（见下方），不直接修复"

    reflexion_step:
      trigger: "Layer 1 整轮迭代 FAIL（收集所有失败后触发一次，不是每个检查项单独触发）"
      action: |
        BEFORE attempting any fix, pause and produce a structured diagnosis:

        1. Read the error output carefully
        2. Fill the reflection template (.tad/templates/reflexion-prompt.md):
           - what_failed: "{check_name}: {error_summary}"
           - root_cause_hypothesis: "{why this happened — not the error message, the CAUSE}"
           - revised_approach: "{what to do differently — not just 'fix the error'}"
           - confidence: "low | medium | high"
        3. Write reflexion_diagnosis trace event:
           source .tad/hooks/lib/trace-writer.sh
           trace_reflexion_diagnosis "{what_failed}" "{root_cause_hypothesis}" \
             "{revised_approach}" "{confidence}" "{slug}"
        4. Append diagnosis to conversation context (reflection_history accumulates)
        5. NOW proceed with fix, guided by revised_approach
      
      on_success_path: "Skip entirely — no reflection when Layer 1 passes"
      
      circuit_breaker_enhancement: |
        When circuit breaker fires (consecutive_same_error >= 3):
        Instead of generic "same error 3 times" message, include:
        
        ────────────────────────────
        ⚡ Circuit Breaker — Reflexion History
        
        Attempt 1: {what_failed}
          Hypothesis: {root_cause_hypothesis_1}
          Tried: {revised_approach_1}
          Result: Still failing
        
        Attempt 2: {what_failed}
          Hypothesis: {root_cause_hypothesis_2}
          Tried: {revised_approach_2}
          Result: Still failing
        
        Attempt 3: {what_failed}
          Hypothesis: {root_cause_hypothesis_3}
          Tried: {revised_approach_3}
          Result: Still failing
        
        Blake assessment: {design_issue | environment_issue | unknown}
        Recommendation: {escalate to Alex for redesign | human fix environment | need more context}
        ────────────────────────────
```

### 4.2 trace_reflexion_diagnosis Helper (trace-writer.sh)

Add to `.tad/hooks/lib/trace-writer.sh`:

```bash
trace_reflexion_diagnosis() {
  local what_failed="$1" hypothesis="$2" approach="${3:-}" confidence="${4:-medium}" slug="${5:-}"
  local ctx
  if [ "$HAS_JQ" = true ]; then
    ctx=$(jq -nc --arg w "$what_failed" --arg h "$hypothesis" --arg a "$approach" --arg c "$confidence" \
      '{what_failed:$w,root_cause_hypothesis:$h,revised_approach:$a,confidence:$c}')
  else
    ctx="what_failed=${what_failed}|root_cause_hypothesis=${hypothesis}|revised_approach=${approach}|confidence=${confidence}"
  fi
  TRACE_CONTEXT="$ctx" TRACE_OUTCOME="fail" TRACE_ACTOR="agent_inferred" \
    TRACE_SLUG="$slug" TRACE_AGENT="blake" \
    record_trace "reflexion_diagnosis"
}
```

### 4.3 Reflection Prompt Template

`.tad/templates/reflexion-prompt.md`:
```markdown
# Reflexion Diagnosis

## What Failed
{check_name}: {error_output_summary}
(Copy the actual error, don't paraphrase)

## Root Cause Hypothesis
Why did this happen? Not the error message — the CAUSE.
Think: what assumption was wrong? What dependency was missing? What state was unexpected?

## Revised Approach
What will you do differently this time?
Not "fix the error" — HOW will you fix it? What specific files, what specific changes?

## Confidence
- **high**: I've seen this pattern before and know the fix
- **medium**: My hypothesis is reasonable but I'm not 100% sure
- **low**: I'm guessing — this might need a completely different approach
```

### 4.4 State Persistence Enhancement

In `state_schema:` (Blake SKILL.md line ~122-128), add:
```yaml
  reflection_count: 0         # total reflections this task
  last_reflection_summary: "" # 1-line summary of last reflection
  escalation_assessment: ""   # design_issue | environment_issue | unknown (CR-P2-7)
```

These fields are for crash recovery. Additionally, add to `recovery:` section:
```yaml
recovery:
  on_resume: |
    continue_from_last_checkpoint
    If reflection_count > 0:
      Reload reflection history from trace JSONL:
        grep 'reflexion_diagnosis' .tad/evidence/traces/*.jsonl | \
          jq -r 'select(.slug == "{current_slug}") | .context' 
      Inject recovered reflections as conversation context before resuming retry.
```

This ensures crash recovery restores the full reflection history that guides retries (ARCH-P0-3 fix).

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] Searched Blake SKILL.md for ralph_loop, layer1_self_check, circuit_breaker, state_schema

### MQ2: 函数存在性验证
- [x] `record_trace()` — .tad/hooks/lib/common.sh (Phase 1 output, verified)
- [x] `trace-writer.sh` — .tad/hooks/lib/trace-writer.sh (Phase 1 output, verified)
- [x] `layer1_self_check` — Blake SKILL.md line 1270, verified

---

## 6. Implementation Steps

### Step 1: Add trace_reflexion_diagnosis to trace-writer.sh
Add the helper function per §4.2 at the end of `.tad/hooks/lib/trace-writer.sh`, after the existing 5 helpers.

### Step 2: Create reflexion-prompt.md template
Write `.tad/templates/reflexion-prompt.md` per §4.3.

### Step 3: Modify Blake SKILL.md — layer1_self_check + reflexion_step
Replace the 2-line `layer1_self_check:` block (line ~1270-1274) with the expanded version per §4.1. Insert `reflexion_step:` block immediately after. Keep the anti-rationalization comment about lint warnings.

### Step 4: Modify Blake SKILL.md — circuit_breaker_enhancement
Find the circuit breaker escalation block. ⚠️ There are TWO `circuit_breaker` references in Blake SKILL.md — the one to modify is the Ralph Loop execution logic section (search for `escalate_to_human` or `consecutive_same_error`). Do NOT modify the overview diagram (lines 74/90-91 are just ASCII art). Enhance the escalation message format per §4.1 `circuit_breaker_enhancement`.

### Step 5: Modify Blake SKILL.md — state_schema
Add `reflection_count` and `last_reflection_summary` fields to `state_schema:` (line ~122-128) per §4.4.

### Step 6: Verify trace integration
Source trace-writer.sh and test: `trace_reflexion_diagnosis "tsc: 3 errors" "missing interface" "add types" "medium" "test-slug"` produces valid JSONL.

### Grounded Against (Alex step1c):
- .claude/skills/blake/SKILL.md lines 61-141 (Ralph Loop overview, read at 2026-05-19)
- .claude/skills/blake/SKILL.md lines 1260-1340 (layer1_self_check + layer2, read at 2026-05-19)
- .tad/hooks/lib/trace-writer.sh lines 1-30 (Phase 1 output, read at 2026-05-19)
- .tad/schemas/trace-schema.yaml (Phase 1 output, reflexion_diagnosis event type defined)

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/blake/SKILL.md       # layer1_self_check, circuit_breaker, state_schema
.tad/hooks/lib/trace-writer.sh      # Add trace_reflexion_diagnosis helper
```

### 7.2 Files to Create
```
.tad/templates/reflexion-prompt.md   # Reflection template
```

---

## 8. Testing Requirements

### 8.1 Trace Helper Test
- `bash -n .tad/hooks/lib/trace-writer.sh` exits 0 (syntax check after adding new function)
- `grep -c '^trace_' .tad/hooks/lib/trace-writer.sh` = 6 (5 existing + 1 new)

### 8.2 Protocol Text Verification
- `grep -c 'reflexion_step:' .claude/skills/blake/SKILL.md` = 1
- `grep -c 'reflection_count' .claude/skills/blake/SKILL.md` ≥ 1
- `grep -c 'Reflexion History' .claude/skills/blake/SKILL.md` = 1

---

## 9. Acceptance Criteria

- [ ] AC1: Blake SKILL.md `layer1_self_check` section references `reflexion_step` on failure
- [ ] AC2: `reflexion_step:` block exists with trigger, action (4-step), on_success_path, circuit_breaker_enhancement
- [ ] AC3: `trace_reflexion_diagnosis` helper exists in trace-writer.sh with 5 params (what_failed, hypothesis, approach, confidence, slug)
- [ ] AC4: `reflexion-prompt.md` template exists in `.tad/templates/` with 4 sections (What Failed, Root Cause, Revised Approach, Confidence)
- [ ] AC5: Circuit breaker escalation message includes reflection history (not just "same error 3 times")
- [ ] AC6: `state_schema` has `reflection_count` and `last_reflection_summary` fields
- [ ] AC7: No reflection overhead on success path (explicit skip when Layer 1 passes)
- [ ] AC8: `bash -n .tad/hooks/lib/trace-writer.sh` exits 0
- [ ] AC9: `grep -c '^trace_reflexion_diagnosis' .tad/hooks/lib/trace-writer.sh` = 1 (specific function exists)
- [ ] AC10: No changes to settings.json, no new hooks
- [ ] AC11: Reflexion triggers per Layer 1 iteration (after all checks run), not per individual check failure
- [ ] AC12: Crash recovery section includes grep-based reload of reflexion_diagnosis events from trace JSONL
- [ ] AC13: Pipe-delimited fallback keys match jq keys (root_cause_hypothesis, revised_approach — not shortened)

## 9.1 Spec Compliance Checklist

| # | Verification Type | Verification Method | Expected | Verified |
|---|-------------------|--------------------|---------:|----------|
| 1 | post-impl | `grep -c 'reflexion_step:' .claude/skills/blake/SKILL.md` | 1 | (post-impl) |
| 2 | post-impl | `grep -c '^trace_reflexion' .tad/hooks/lib/trace-writer.sh` | 1 | (post-impl) |
| 3 | post-impl | `grep -c '^trace_reflexion_diagnosis' .tad/hooks/lib/trace-writer.sh` | 1 | (post-impl) |
| 4 | post-impl | `bash -n .tad/hooks/lib/trace-writer.sh` | exit 0 | (post-impl) |
| 5 | post-impl | `test -f .tad/templates/reflexion-prompt.md` | exit 0 | (post-impl) |
| 6 | pre-impl | `git diff --name-only .claude/settings.json` | empty | ✅ empty |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Blake SKILL.md is ~2000+ lines. Use precise Edit with exact old_string match. Do NOT read/rewrite the whole file.
- ⚠️ `reflexion_step` is PROTOCOL TEXT — it tells Blake what to do, not code that executes. Blake reads this at activation and follows it during implementation.
- ⚠️ The reflection prompt is intentionally generic (works for tsc, test, lint, build failures). Do NOT create separate templates per failure type.
- ⚠️ `trace_reflexion_diagnosis` uses the same env-var convention as Phase 1 helpers. Do NOT use positional params beyond 5.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: TRACE_OUTCOME="$confidence" violates schema enum (pass/fail/error/skip/partial) | §4.2 changed to TRACE_OUTCOME="fail", confidence stays in TRACE_CONTEXT JSON | Resolved |
| backend-architect | P0-1: Same TRACE_OUTCOME issue (independently flagged) | §4.2 same fix | Resolved |
| code-reviewer | P0-2: Circuit breaker line references wrong (said ~74/90-91, actual is elsewhere) | §6 Step 4 rewritten with search guidance, explicit "do NOT modify ASCII art" warning | Resolved |
| backend-architect | P0-2: Crash recovery loses reflection history on resume | §4.4 recovery section enhanced: grep trace JSONL for reflexion_diagnosis events, inject as context | Resolved |
| backend-architect | P1-1: Lint warning overhead — 15 warnings = 15 reflexion cycles | §4.1 trigger changed to per-iteration (collect all failures, one reflection), AC11 added | Resolved |
| backend-architect | P1-2: Pipe-delimited key name mismatch (hypothesis vs root_cause_hypothesis) | §4.2 fallback keys aligned to match jq keys, AC13 added | Resolved |
| code-reviewer | P1-1: FR3 (retry context) has no AC | AC12 added for crash recovery reload | Resolved |
| code-reviewer | P1-2: AC9 grep count fragile (exact = 6) | AC9 changed to specific function name check | Resolved |
| code-reviewer | P1-3: YAML nesting guidance | §6 Step 3 already has indent note | Resolved |
| code-reviewer | P2-1: Add escalation_assessment to state_schema | §4.4 state_schema updated | Resolved |
| backend-architect | P2-1: Add retry_number to trace context | Noted — Blake can include in context JSON if useful | Deferred |

### Experts Selected

1. **code-reviewer** — YAML structure, trace function signature, AC coverage
2. **backend-architect** — data architecture, crash recovery, cross-phase contract, overhead analysis

### Overall Assessment (post-integration)

- code-reviewer: CONDITIONAL PASS → PASS (2 P0, 3 P1 resolved, 1 P2 resolved)
- backend-architect: CONDITIONAL PASS → PASS (2 P0, 2 P1 resolved, 1 P2 deferred)

---

### 10.2 Sub-Agent 使用建议
- [ ] **code-reviewer** — verify YAML indentation, trace function signature, backward compat

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Reflection trigger level | Gate 3 only vs Layer 1 every fail vs Circuit breaker only | Layer 1 every fail | User specified; catches errors early, builds reflection history |
| 2 | Reflection storage | File-based vs In-context | In-context + trace | In-context for retry guidance, trace for cross-session persistence |
| 3 | Template approach | Per-failure-type templates vs Single generic | Single generic | Simpler; failure-specific context comes from error output, not template |
| 4 | State schema change | New file vs Extend existing | Extend existing state_schema | Minimal change; crash recovery needs reflection_count |

---

**Required Evidence Manifest**:
```yaml
evidence:
  expert_reviews:
    - .tad/evidence/reviews/alex/auto-evolve-phase2-reflexion/code-reviewer.md
    - .tad/evidence/reviews/alex/auto-evolve-phase2-reflexion/backend-architect.md
  gate_verdicts:
    - Gate 2 in this document
  completion:
    - .tad/active/handoffs/COMPLETION-20260519-auto-evolve-phase2-reflexion.md
  blake_reviews:
    - .tad/evidence/reviews/blake/auto-evolve-phase2-reflexion/
```

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-19
**Version**: 3.1.0
