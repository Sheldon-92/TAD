---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/workflows", ".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260603-dynamic-workflow-integration.md (Phase 3/5)

---

## Gate 2: Design Completeness

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | Hybrid model: workflow orchestrates sub-agent steps, Conductor keeps judgment steps |
| Components Specified | OK | 1 workflow file + 1 SKILL.md modification |
| Functions Verified | OK | Workflow API proven in P0-P2 (3 workflows, 30+ agents) |
| Data Flow Mapped | OK | Conductor → workflow (sub-agent steps) → Conductor (judgment) → workflow → ... |

**Gate 2 Result**: PASS

---

## 1. Task Overview

Convert the YOLO execution protocol from ~240 lines of SKILL.md prose into a deterministic JS workflow script + a slim SKILL.md invocation stub. The workflow orchestrates sub-agent steps (design, review, implement) while the Conductor (main Alex loop) retains judgment steps (grounding, validation, gate decisions). Add `budget.remaining()` observation at phase boundaries.

**Why now:** YOLO is TAD's highest-token-cost workflow (multi-phase Epics consuming unbounded tokens). Current implementation is prose that the LLM follows step-by-step — susceptible to goal drift and agentic laziness (the exact failure modes the Thariq article identifies). Zero token cost data exists (measurement confirmed blind spot). Converting to a workflow makes execution deterministic and adds cost visibility.

---

## 2. Requirements

### Functional
- FR1: Create `.claude/workflows/yolo-epic.workflow.js` — YOLO Epic execution workflow
- FR2: Workflow handles sub-agent steps: Y3 (design), Y4 (design review), Y5 (implement), Y6 (impl review)
- FR3: Conductor retains judgment steps: Y1 (activate), Y2 (grounding), Y3b (validation), Y7 (gate), Y8 (KA)
- FR4: `budget.remaining()` checked at each phase boundary; cost report shown to human at pause
- FR5: Human checkpoint at each phase: continue full / continue lean (1 reviewer) / pause / honest_partial
- FR6: Evidence files written to same paths as current protocol (`.tad/evidence/yolo/{epic-slug}/`)
- FR7: alex/SKILL.md `yolo_execution_protocol` section reduced to ~30 lines: invocation + judgment rules + constraints
- FR8: Backward compat: if Workflow tool unavailable, link to current prose protocol as fallback

### Non-Functional
- NFR1: Object.keys workaround for args (same as P1/P2)
- NFR2: File-as-source-of-truth: workflow prompts pass file PATHS, never business content
- NFR3: ≥2 distinct reviewers at Y4 and Y6 (code-reviewer mandatory + domain expert)
- NFR4: Circuit breaker: max 2 retry rounds per step, then honest_partial
- NFR5: Constraint rules from current YOLO protocol MUST survive in SKILL.md stub (not deleted during slimming — v2.7 lesson)

---

## 3. Technical Design

### Architecture: Hybrid Conductor + Workflow

```
Conductor (main Alex loop)              Workflow (deterministic JS)
─────────────────────────               ──────────────────────────
Y1: Activate phase                      
Y2: Read code + grounding file          
                                        Y3: agent() → design sub-agent
                                            → writes HANDOFF.md
Y3b: Validate handoff (frontmatter,     
     grounding, AC dry-run)             
                                        Y4: parallel() → 2 reviewer agents
                                            → writes review files
     Fix P0s if found                   
                                        Y5: agent(isolation:'worktree') → Blake
                                            → writes COMPLETION.md + commit
                                        Y6: parallel() → 2 reviewer agents
                                            → writes impl-review files
     Fix P0s if found                   
Y7: Gate judgment (read all files)      
Y8: Knowledge Assessment                
─── budget report + human checkpoint ───
     Loop to Y1 for next phase          
```

### Workflow args interface

```
args: {
  epic_path: string,          // Path to Epic file (required)
  epic_slug: string,          // Epic slug for evidence paths (required)
  phase_number: number,       // Which phase to execute (required)
  phase_name: string,         // Phase name (required)
  handoff_path: string,       // Where to write handoff (required)
  completion_path: string,    // Where to write completion (required)
  grounding_path: string,     // Grounding file (written by Conductor before workflow)
  pause_between_phases: boolean,  // Semi-auto mode
  reviewer_count: number,     // 2 (default) or 1 (lean mode, human-authorized exception to ≥2 rule)
  steps: string[]             // Which phases to run: subset of ['design', 'review', 'implement', 'impl_review']
                              // Call 1: ['design'] → return handoff for Conductor Y3b validation
                              // Call 2: ['review', 'implement', 'impl_review'] → full execution
                              // Invalid step names → abort with error listing valid steps
}
```

### Workflow phases

**Phase: Design (Y3)**
- Spawn 1 Alex design agent
- Prompt: file paths only (epic, grounding, handoff template)
- Output: HANDOFF.md on disk
- Verify: file exists + > 50 lines
- On verify fail: re-spawn once, then return error for Conductor to handle

**Phase: Design Review (Y4)**
- Spawn 2 reviewer agents in parallel (or 1 in lean mode)
- code-reviewer: mandatory
- domain-expert: auto-detect from handoff Files to Modify
- Write reviews to evidence dir
- Return: { reviews: [...], p0_count: N }

**Phase: Implement (Y5)**
- Spawn 1 Blake agent with `isolation: 'worktree'`
- Standard Blake prompt (same as current Y5)
- Output: COMPLETION.md + git commit
- Verify: completion file exists

**Phase: Impl Review (Y6)**
- Same as Y4 but reads COMPLETION.md + git diff
- Spawn 2 reviewer agents in parallel (or 1 in lean mode)
- Return: { reviews: [...], p0_count: N }

**Phase: Budget Report**
- After all 4 sub-agent phases complete, report:
  - Agents spawned this phase: N
  - `budget.spent()` if available
  - `budget.remaining()` if available
- Return report to Conductor for human checkpoint

### What stays in SKILL.md (~30 lines)

```yaml
yolo_execution_protocol:
  description: "Hybrid Conductor + Workflow YOLO execution"
  trigger: "step7_execution_mode user chose YOLO or semi-auto"
  
  constraints:  # THESE MUST SURVIVE (NFR5)
    - "File is source of truth — prompt only passes paths"
    - "Review must be Conductor-spawned sub-agent — don't trust sub-agent claimed review"
    - "Every step persists — write to disk before next step"
    - "Blake sub-agent does implementation + Layer 1 only"

  workflow_invocation: |
    For each ⬚ Planned Phase (TWO workflow calls per phase):
    1. Y1: Activate phase (Conductor)
    2. Y2: Grounding (Conductor reads code, writes grounding file)
    3. Call 1: Workflow({name: 'yolo-epic', args: {steps: ['design'], ...}})
       → Y3: design sub-agent writes HANDOFF.md
       → Returns: { handoff_path }
    4. Y3b: Validate handoff (Conductor — frontmatter, grounding, AC dry-run)
    5. Call 2: Workflow({name: 'yolo-epic', args: {steps: ['review','implement','impl_review'], ...}})
       → Y4: 2 design reviewers → Y5: Blake implements → Y6: 2 impl reviewers
       → Returns: { design_reviews, impl_reviews, budget_report }
       Precondition: {handoff_path} must exist and be > 50 lines (validated by workflow)
    6. Y7: Gate judgment (Conductor reads all evidence files from disk)
    7. Y8: Knowledge Assessment (Conductor)
    8. Budget report + human checkpoint

  evidence_file_naming: |
    Reviewer type → filename suffix mapping:
      code-reviewer → cr, backend-architect → arch, frontend-specialist → fe,
      security-auditor → sec, ux-expert-reviewer → ux, performance-optimizer → perf
    Evidence files: .tad/evidence/yolo/{epic-slug}/phase{N}-{step}-{suffix}.md
    Example: phase1-design-review-cr.md, phase1-impl-review-arch.md

  fallback: |
    If Workflow tool unavailable:
    Archive the full prose protocol to .tad/archive/protocols/yolo-execution-v1-prose.md
    before first use of workflow version. Conductor follows archived prose verbatim.

  api_notes: |
    budget: {total, spent(), remaining()} — confirmed in Workflow tool docs.
    agent(prompt, {isolation: 'worktree'}) — confirmed in Workflow tool docs.
    Both are real APIs but unused in P0-P2 workflows. First use in TAD.
    If budget.total is null (no user budget set): remaining() returns Infinity.
    Worktree cleanup: automatic if agent makes no changes; otherwise path returned.

  judgment_rules: |
    - Conductor MUST re-read review files from disk before gate judgment (not from memory)
    - ≥2 distinct reviewers at Y4 and Y6
    - Circuit breaker: max 2 retry rounds per step
    - honest_partial if circuit breaker triggers
```

### Workflow invocation split (important detail)

The Conductor calls the workflow TWICE per phase:
1. **Call 1:** `Workflow({..., args: {steps: ['design']}})` → returns handoff path
2. Conductor runs Y3b (validation) on the handoff
3. **Call 2:** `Workflow({..., args: {steps: ['review', 'implement', 'impl_review']}})` → returns reviews + completion

This is because Y3b is a Conductor judgment step that must run BETWEEN Y3 and Y4. The workflow script accepts a `steps` array in args to control which phases run.

---

## 4. Files to Create / Modify

| File | Action | Scope |
|------|--------|-------|
| `.claude/workflows/yolo-epic.workflow.js` | CREATE | ~300-400 lines: 4 sub-agent phases + budget report |
| `.claude/skills/alex/SKILL.md` | MODIFY | Replace lines 3584-3822 (~240 lines) with ~30-line stub |

**Grounded Against** (Alex step1c, read 2026-06-03):
- .claude/skills/alex/SKILL.md lines 3584-3822 (full YOLO protocol — 240 lines, 8 steps)
- .claude/workflows/gate-review.workflow.js (reference for args workaround + pipeline pattern)
- .claude/workflows/tournament-design.workflow.js (reference for parallel reviewer pattern)

---

## 5. Acceptance Criteria

| AC | Requirement | Verification Method | Expected Evidence |
|----|------------|--------------------|--------------------|
| AC1 | Workflow exists and parses | `node -c .claude/workflows/yolo-epic.workflow.js` | Exit 0 |
| AC2 | Steps parameter works | grep for `steps` handling in workflow | Conditional phase execution |
| AC3 | Design phase spawns 1 agent | Source inspection: Y3 uses single `agent()` call | 1 agent call |
| AC4 | Review phases spawn 2 agents | Source inspection: Y4/Y6 use `parallel([...])` with 2 entries | 2 parallel calls |
| AC5 | Blake uses worktree isolation | `grep 'isolation.*worktree' .claude/workflows/yolo-epic.workflow.js` | >= 1 match |
| AC6 | Budget report returned | Schema includes budget fields (agents_spawned, budget_spent, budget_remaining) | Fields present |
| AC7 | SKILL.md reduced | `awk '/^yolo_execution_protocol:/,/^[a-z_]+:/{print}' .claude/skills/alex/SKILL.md \| wc -l` | <= 50 lines (was ~264; includes epic_completion ~20 lines which stays) |
| AC8 | Constraints survived (exact match) | For each: `grep -Fq 'File is source of truth' .claude/skills/alex/SKILL.md` (repeat for all 4 constraint strings) | All 4 exit 0 |
| AC9 | Fallback archived | `test -f .tad/archive/protocols/yolo-execution-v1-prose.md` | File exists with full prose protocol |
| AC10 | SAFETY unchanged (YOLO section has 0 hits) | `awk '/^yolo_execution_protocol:/,/^[a-z_]+:/' .claude/skills/alex/SKILL.md \| grep -c 'NOT_via_alex_auto\|forbidden_implementations'` | == 0 (YOLO section contains none; global count stays 20) |
| AC11 | NFR1 args workaround | `grep 'Object.keys' .claude/workflows/yolo-epic.workflow.js` | >= 1 match |

---

## 6. Important Notes

### 6.1 Critical constraint: v2.7 quality chain failure precedent
The biggest risk of this task is removing constraint rules during SKILL.md slimming. The 2026-04-04 principle says: "Constraint rules (MUST/MANDATORY/VIOLATION) cannot be removed. Only truly mechanical logic (step-by-step prose) is safe to extract." Blake MUST verify AC8 (all 4 constraints survive) AND AC10 (SAFETY count unchanged) before declaring complete.

### 6.2 Two-call workflow invocation pattern
The workflow is invoked TWICE per phase because Y3b (Conductor validation) sits between Y3 (design) and Y4 (review). This is intentional — it preserves the Conductor's judgment authority. Blake should implement a `steps` parameter in args that accepts an array like `['design']` or `['review', 'implement', 'impl_review']`.

### 6.3 What NOT to do
- DO NOT move Y2 (grounding) or Y7 (gate judgment) into the workflow — these are Conductor judgment steps
- DO NOT delete the 4 constraint lines from SKILL.md (NFR5 + v2.7 precedent)
- DO NOT auto-reduce reviewer count based on budget — human decides via checkpoint
- DO NOT use `forbidden_implementations` or `NOT_via_alex_auto` literal strings in workflow file
- DO NOT change evidence file paths (must match existing `.tad/evidence/yolo/{slug}/phase{N}-*` pattern)

### 6.4 Reference: existing workflows
- `gate-review.workflow.js` — args workaround, pipeline pattern, parallel reviewers
- `tournament-design.workflow.js` — parallel competitors, pairwise judging, Object.keys pattern
- Both are proven patterns Blake can reference for implementation

---

## 7. Project Knowledge

### Blake must note:
- **Conductor Architecture principle** (project_conductor-architecture memory): sub-agent nesting limits, file-as-source-of-truth, 5 critical constraints from 2 spikes
- **YOLO Audit Findings** (project_yolo-audit-findings memory): validation theater risk — structural checks prove files exist, NOT that quality improved. Budget report should show real numbers, not "estimated" ones.
- **v2.7 quality chain failure** (principles.md): removing constraint rules during slimming → quality drift for months. The 4 constraints in the YOLO stub are load-bearing.

---

## 8. Expert Review Status

| Expert | Findings | Status |
|--------|----------|--------|
| (pending — Blake side Gate 3 Layer 2) | — | — |

---

## 9. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Hybrid vs full workflow | Full workflow / Hybrid / Observe only | Hybrid | Conductor keeps judgment (Y2/Y3b/Y7/Y8), workflow gets sub-agents (Y3/Y4/Y5/Y6) |
| 2 | Two-call invocation | Single call / Two calls | Two calls | Y3b must run between Y3 and Y4; can't do that inside a single workflow execution |
| 3 | Budget control | Auto-degrade / Human checkpoint / None | Human checkpoint | "Alex SUGGESTS, human DECIDES" — don't auto-reduce reviewers |
| 4 | SKILL.md reduction target | ~20 / ~30 / ~40 lines | ~30-40 lines | Must keep constraints + fallback + judgment rules |

---

## 10. Required Evidence Manifest

```yaml
expert_reviews:
  - path: .tad/evidence/reviews/blake/yolo-workflow-p3/code-review.md
    required: true
  - path: .tad/evidence/reviews/blake/yolo-workflow-p3/spec-compliance.md
    required: true
gate_verdicts:
  - path: .tad/evidence/reviews/blake/yolo-workflow-p3/gate3-verdict.md
    required: true
completion:
  - path: .tad/active/handoffs/COMPLETION-20260603-yolo-workflow-p3.md
    required: true
```
