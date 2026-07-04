---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex/references"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-03
**Project:** TAD Framework
**Task ID:** TASK-20260703-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260703-claude-science-skill-architecture.md (Phase 3/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-07-03

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Extends existing workflow completion trigger Q2/Q3 with auto-generation |
| Components Specified | ✅ | SCAND auto-gen logic + Anthropic-standard frontmatter template |
| Functions Verified | ✅ | skillify-candidate-template.md exists, workflow_completion_trigger exists |
| Data Flow Mapped | ✅ | Workflow result → Q2/Q3 "yes" → auto-gen SCAND → .tad/active/skillify-candidates/ |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Extend the workflow completion trigger (triple-question KA) so that when Q2 ("reusable judgment pattern?") or Q3 ("workflow improvement?") is answered "yes", a SCAND file is auto-generated with Anthropic-standard name/description and extracted workflow steps — instead of requiring manual writing.

### 1.2 Why We're Building It
**业务价值**：Lowers the barrier from "recognize a pattern AND manually write a SCAND" to "recognize a pattern and confirm, SCAND auto-generated." This is how Claude Science saves pipelines as reusable skills — one confirmation, not a writing exercise.
**成功的样子**：After a successful Workflow run (≥3 agents), user says "yes this is reusable" → SCAND file appears at `.tad/active/skillify-candidates/` with proper frontmatter and steps, ready for *harvest review.

### 1.3 Intent Statement

**真正要解决的问题**：The current Q2/Q3 path says "If yes: write SCAND candidate" but doesn't specify HOW. In practice, the agent writes a minimal stub or the user has to describe the pattern. Auto-generation extracts the pattern from the workflow context (what agents did, in what order, what each produced) and fills the SCAND template automatically.

**不是要做的**：
- ❌ 不是改 T1/T2/T3 routing logic (*harvest still decides tier)
- ❌ 不是改 Blake's T1 ceremony (skillify_evaluation step 5)
- ❌ 不是 auto-deploying skills (SCAND stays draft until human confirms)
- ❌ 不是改 Q1 (knowledge) path — only Q2 (skill) and Q3 (workflow)

---

## 2. Technical Design

### 2.1 Current State

In `.claude/skills/alex/references/workflow-completion-trigger.md`, lines 11-17:

```yaml
action: |
  After a Workflow tool call completes with agent_count >= 3:
  1. Q1 (knowledge): "Did this workflow execution reveal something new?"
     → If yes: record to .tad/project-knowledge/ (same as Gate 4 C)
  2. Q2 (skill): "Did the workflow expose a reusable judgment pattern?"
     → If yes: Skillify 4-gate + Step 5 (same path)
  3. Q3 (workflow): "Should this workflow be improved based on what just happened?"
     → If yes (defect): record for future bugfix handoff
     → If yes (new pattern): write SCAND candidate with type: orchestration
```

### 2.2 New Behavior

Replace Q2 and Q3 "yes" branches with auto-generation logic:

```yaml
action: |
  After a Workflow tool call completes with agent_count >= 3:
  1. Q1 (knowledge): "Did this workflow execution reveal something new?"
     → If yes: record to .tad/project-knowledge/ (same as Gate 4 C)
  2. Q2 (skill): "Did the workflow expose a reusable judgment pattern?"
     → If yes: auto-generate SCAND (see auto_gen_scand below)
       with type: judgment
  3. Q3 (workflow): "Should this workflow be improved based on what just happened?"
     → If yes (defect): record for future bugfix handoff
     → If yes (new pattern): auto-generate SCAND (see auto_gen_scand below)
       with type: orchestration

  auto_gen_scand:
    trigger: "Q2 or Q3 answered 'yes' for reusable pattern"
    steps:
      1. Extract pattern from workflow context:
         - What agents were spawned and in what order
         - What each agent's prompt/task was (abstract to pattern, not literal text)
         - What the overall pipeline achieved
      2. Variabilize: replace episode-specific values with placeholders
         (per Knowledge Recording principle: "reusability is a mechanical test —
          can you variabilize the episode-specific values?")
         Examples: specific file paths → {target_file}, specific pack names → {pack_name}
      3. Generate SCAND using template .tad/templates/skillify-candidate-template.md.
         Complete frontmatter field mapping:
         
         | Field | Value | Source |
         |-------|-------|--------|
         | name | derive kebab-case slug from pattern | auto |
         | date | current date YYYY-MM-DD | auto |
         | status | draft | CONSTRAINT: discoverer MUST NOT set beyond draft |
         | type | judgment (Q2) or orchestration (Q3) | from question path |
         | tier | ~ | CONSTRAINT: set ONLY by *harvest, NEVER by discoverer |
         | materialized_at | ~ | T1 ceremony only |
         | reference_at | ~ | T2 harvest only |
         | source | "workflow-completion:{workflow-name}" | new convention for auto-gen |
         | trigger_conditions | derived from pattern — when would this apply? | extracted from workflow context |
         | reusable | ~ | # auto-gen skips 4-gate; *harvest evaluates |
         | non_trivial | ~ | # auto-gen skips 4-gate; *harvest evaluates |
         | verified | ~ | # auto-gen skips 4-gate; *harvest evaluates |
         | not_already_captured | ~ | # auto-gen skips 4-gate; *harvest evaluates |
         
         Body sections:
         - ## Pattern: {pattern name} — from workflow pattern
         - ### When to Use — from trigger_conditions
         - ### Steps — extracted + variabilized workflow pattern
         - ### Quality Criteria — from workflow success criteria
         - ### Anti-Patterns — from workflow failure modes (if observed)
         - ## Evidence — link to the workflow run
         - ## Proposed Skill Outline — name + description (Anthropic-standard ≤1024, third-person, "what + when")

      4. Write to .tad/active/skillify-candidates/SCAND-{date}-{slug}-{type}.md
         (type suffix prevents collision when both Q2 and Q3 generate SCANDs)
      5. Report: "📋 SCAND auto-generated: {slug}-{type}. Review via *harvest."
    
    skip_option: "User can say 'skip' at the Q2/Q3 AskUserQuestion to skip auto-gen"
    
    variabilize_test: |
      Before writing the SCAND, apply the variabilize test:
      "Can I replace every episode-specific value with a placeholder and
       the pattern still makes sense for a DIFFERENT task?"
      If NO → don't write SCAND, report: "Pattern is too episode-specific to reuse."
    
    dual_yes_handling: |
      When both Q2 AND Q3 are "yes": generate two SCANDs with different type suffixes.
      Each SCAND's Evidence section cross-references the other:
      "See also SCAND-{date}-{slug}-{other-type}.md from same workflow run."
```

### 2.3 What stays the same

- Q1 (knowledge) path — unchanged
- Trigger threshold (agent_count >= 3) — unchanged
- Skip rule for TAD management tasks (*publish, *sync) — unchanged
- T1/T2/T3 routing — unchanged (SCAND stays draft, *harvest decides tier)
- AskUserQuestion format — unchanged (lightweight 3-question interaction)
- SCAND template file — unchanged (auto-gen fills it, doesn't modify the template itself)

### 2.6 What changes (honest accounting)

- Q2 "yes" path: was "Skillify 4-gate + Step 5", now auto_gen_scand (4-gate SKIPPED — see D5)
- Q3 "new pattern" path: was "write SCAND candidate", now auto_gen_scand
- 4 quality-gate booleans: set to `~` (null) instead of `true` — signals *harvest must evaluate
- SCAND filename: adds `-{type}` suffix for dual-yes collision avoidance

### 2.4 Also update: .agents/skills/ parity

Apply same changes to `.agents/skills/alex/references/workflow-completion-trigger.md`.

---

## 8. Implementation Steps

**Layer 1:**
1. Read current workflow-completion-trigger.md
2. Replace Q2 and Q3 "yes" branches with auto_gen_scand logic
3. Add auto_gen_scand section with 5-step generation flow
4. Update .agents/skills/ parity copy
5. Verify skillify-candidate-template.md still used as base

**Layer 2:**
Standard code-reviewer on the protocol changes.

### 8.2 Key Constraints
- SCAND status MUST be "draft" — auto-gen does NOT bypass human review
- The variabilize test is MANDATORY — episode-specific patterns should NOT become SCANDs
- Q1 path is untouched
- Template at .tad/templates/skillify-candidate-template.md is the source of truth for SCAND format

### 8.4 Friction Preflight
No special dependencies. Standard text editing.

---

## 9. Acceptance Criteria

- [ ] **AC1**: Q2 "yes" → auto-generates SCAND at .tad/active/skillify-candidates/SCAND-{date}-{slug}-judgment.md
- [ ] **AC2**: Q3 "yes (new pattern)" → auto-generates SCAND with `-orchestration` suffix
- [ ] **AC3**: Generated SCAND has all 14 frontmatter fields per §2.2 field-mapping table. 4 gate booleans = `~` (null). Proposed Skill Outline has Anthropic-standard description (≤1024, third-person, "what + when")
- [ ] **AC4**: Generated SCAND includes variabilized Steps section (episode-specific values replaced with {placeholders})
- [ ] **AC5**: "Skip" option available — user can decline auto-gen at Q2/Q3
- [ ] **AC6**: .agents/skills/ parity maintained for workflow-completion-trigger.md
- [ ] **AC7**: When both Q2 and Q3 are "yes", two distinct SCAND files are generated (different type suffix) without overwriting
- [ ] **AC8**: When variabilize test fails, no SCAND is generated and report shows "Pattern is too episode-specific to reuse"

---

## 10. File Manifest

| File | Action | Purpose |
|------|--------|---------|
| .claude/skills/alex/references/workflow-completion-trigger.md | MODIFY | Add auto_gen_scand logic |
| .agents/skills/alex/references/workflow-completion-trigger.md | MODIFY | Parity copy |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Knowledge Is Forged at Distill, Not Captured** (principles.md) — The discoverer writes raw journal; a stranger distills. For auto-gen SCAND, the "auto" part does the pattern extraction, but human still confirms via *harvest — preserving the capture/distill separation.
- **Deny-List Must Be Applied at EVERY Copy Granularity** (principles.md) — .agents/skills/ parity must be maintained.

---

## 11. Decision Summary

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Auto-gen SCAND on Q2/Q3 "yes" | Lowers barrier from manual writing to confirm + auto-generate (Claude Science pattern) |
| D2 | Mandatory variabilize test | Per Knowledge Recording principle — episode-specific patterns should not become reusable skills |
| D3 | SCAND stays draft | discoverer MUST NOT set status beyond draft — existing CONSTRAINT preserved |
| D4 | Anthropic-standard frontmatter | name/description in Proposed Skill Outline comply with Phase 1's standardization |
| D5 | 4-gate intentionally skipped in auto-gen | Auto-gen lowers barrier to capture; 4-gate booleans set to `~` (null) to signal *harvest must evaluate. Rationale: discoverer confirming "yes this is reusable" at Q2/Q3 is a lightweight gate; full 4-gate evaluation is *harvest's job as the distiller. This is an honest tradeoff — lower capture friction vs deferred quality gate. |
| D6 | source convention for workflow SCANDs | `source: "workflow-completion:{workflow-name}"` distinguishes auto-gen from manual SCANDs |
| D7 | Type suffix in filename | `-judgment` / `-orchestration` suffix prevents collision on dual-yes |

### Expert Review Audit Trail

| Reviewer | Findings | P0 | P1 | P2 | Resolution |
|----------|----------|----|----|-----|------------|
| code-reviewer | 12 findings | 2 | 5 | 5 | P0-1: Added complete 14-field frontmatter mapping table. P0-2: 4 gate booleans set to `~` + D5 rationale. P1s: source convention (D6), dual-yes handling + type suffix (D7, AC7), section 2.3→2.6 honest accounting, variabilize failure AC8. |
| spec-compliance | 7 findings | 2 | 4 | 1 | P0-1: same as above (field mapping). P0-2: same (4-gate skip). P1s: dual-yes collision (same fix), Blake not_already_captured gap (deferred — *harvest is dedup checkpoint), description field location clarified (Proposed Skill Outline body). |
