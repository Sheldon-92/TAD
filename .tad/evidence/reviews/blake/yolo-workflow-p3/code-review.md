# Code Review: YOLO Epic Workflow (P3)

**Reviewer:** Code Review Agent (Blake Layer 2)
**Date:** 2026-06-03
**Files reviewed:**
- `.claude/workflows/yolo-epic.workflow.js` (NEW, 384 lines)
- `.claude/skills/alex/SKILL.md` lines 3584-3629 (MODIFIED, ~46 lines)
- `.tad/archive/protocols/yolo-execution-v1-prose.md` (NEW, 269 lines)

**Reference workflows consulted:**
- `.claude/workflows/gate-review.workflow.js`
- `.claude/workflows/tournament-design.workflow.js`

---

## Summary

The workflow correctly extracts 4 sub-agent steps (Y3/Y4/Y5/Y6) from the YOLO prose protocol into a deterministic JS workflow. The hybrid model is sound: Conductor keeps judgment steps, workflow handles spawnable agents. The SKILL.md stub preserves all 4 constraint strings and the SAFETY count is unchanged (global=20, yolo-section=0). The archived prose protocol is complete (269 lines, full Y1-Y8 + epic_completion).

Overall quality is good and consistent with the P0-P2 reference workflows. Below are the findings organized by severity.

---

## P0 Findings (Blocking)

### P0-1: `sections_present` in DESIGN_RESULT_SCHEMA is not `required` but is never used downstream

**Location:** `yolo-epic.workflow.js` lines 21-23

**Issue:** `sections_present` is defined in the schema but not in the `required` array, and more critically, no code ever reads `designResult.sections_present`. This is not a bug per se, but the REAL P0 is below:

### P0-2: Design retry prompt has no context about what files to read

**Location:** `yolo-epic.workflow.js` lines 148-154

**Issue:** The retry prompt tells the agent "Re-read {epicPath} Phase {phaseNumber}" but does NOT re-pass the grounding file path or the handoff template path. The first attempt prompt (lines 122-136) includes 3 file paths: Epic, grounding, and handoff template. The retry only passes 2 (Epic and handoff output path). If the first attempt failed because the agent couldn't find the grounding file, the retry will fail for the same reason.

```javascript
// Current retry prompt (incomplete):
'Re-read ' + epicPath + ' Phase ' + phaseNumber +
' and produce a COMPLETE handoff to ' + handoffPath + '.'

// Should also include:
'Read the grounding file: ' + (groundingPath || evidenceBase + phasePrefix + '-grounding.md') + '\n' +
'Read the handoff template: .tad/templates/handoff-a-to-b.md\n' +
```

**Fix:** Add grounding path and template path to the retry prompt.

### P0-3: No `mkdir -p` for evidence directory in workflow

**Location:** `yolo-epic.workflow.js` (missing)

**Issue:** The workflow tells reviewer agents to write files to `evidenceBase` (e.g., `.tad/evidence/yolo/{epic-slug}/phase1-design-review-cr.md`). If this directory doesn't exist, the sub-agent's file write will fail. The original prose protocol (Y1 step 1) explicitly includes `mkdir -p .tad/evidence/yolo/{epic-slug}`. The current workflow assumes the Conductor did this in Y1, but:
1. The SKILL.md stub's `workflow_invocation` section doesn't mention mkdir
2. If someone calls the workflow with `steps: ['review', 'implement', 'impl_review']` without having run Y1 first, the directory may not exist

**Risk:** Sub-agent fails silently because it can't write the evidence file. The review appears to succeed but no evidence lands on disk.

**Fix:** Either (a) add a Bash call at the start of the workflow to ensure the directory exists, or (b) document in the SKILL.md `workflow_invocation` that Y1 must `mkdir -p` before Call 1.

---

## P1 Findings (Should Fix)

### P1-1: `parallel()` receives an array of functions, not an array of function-wrappers in the reference pattern

**Location:** `yolo-epic.workflow.js` lines 184-227, 296-339

**Issue:** The code builds `reviewPrompts` as an array of functions (`.push(function() { return agent(...) })`), then calls `await parallel(reviewPrompts)`. This matches the `tournament-design.workflow.js` pattern (line 135: `parallel(competitorPrompts.map(function(c) { return function() { ... } }))`). However, `gate-review.workflow.js` uses a different pattern: `parallel(flagged.map(function(flag) { return function() { ... } }))` — same thing.

**Verdict:** The pattern is consistent. Not a bug. Withdrawn.

### P1-2: Domain reviewer `agentType` is hardcoded to `'backend-architect'` even when auto-detect prompt says frontend

**Location:** `yolo-epic.workflow.js` lines 224 and 337

**Issue:** The prompt tells the domain reviewer to auto-detect (">50% frontend files -> focus on frontend architecture"), but the `agentType` metadata is hardcoded to `'backend-architect'`. If the Workflow runtime uses `agentType` for any routing or logging, it will report incorrect type. More importantly, the evidence file path is hardcoded to `-arch.md` (line 206, line 322), so a frontend-detected review still writes to `*-arch.md` instead of `*-fe.md`.

This contradicts the SKILL.md `evidence_file_naming` convention:
```
cr=code-reviewer, arch=backend-architect, fe=frontend-specialist,
sec=security-auditor, ux=ux-expert-reviewer, perf=performance-optimizer
```

The original prose protocol (Y4 step 3) says "auto-detect your domain" and the evidence naming convention maps each domain to a specific suffix. But the workflow hardcodes `arch` for all domains.

**Impact:** Evidence file naming is wrong when the handoff is frontend/security-heavy. Future audit scripts or cross-reference tools that look for `-fe.md` or `-sec.md` will not find the reviews.

**Fix:** Either (a) accept `arch` as the default-only suffix and document that the auto-detect is prompt-level only, or (b) have the reviewer agent return the detected domain type in the schema and use it for the file path (more complex but more correct).

### P1-3: Missing `whenToUse` in meta export

**Location:** `yolo-epic.workflow.js` line 1-11

**Issue:** Both reference workflows (`gate-review` line 4, `tournament-design` line 4) include a `whenToUse` field in their `meta` export. This field is used by the skill registration system to determine when to suggest the workflow. The yolo-epic workflow omits it.

**Fix:** Add `whenToUse` to meta:
```javascript
whenToUse: 'When executing an Epic phase in YOLO or semi-auto mode. Conductor calls this workflow twice per phase: once for design, once for review+implement+impl_review.',
```

### P1-4: `budget` global accessed without defensive check on `.spent()` and `.remaining()` being functions

**Location:** `yolo-epic.workflow.js` lines 371-378

**Issue:** The code checks `budget && budget.total` before calling `budget.spent()` and `budget.remaining()`. Per the SKILL.md api_notes: "If budget.total is null (no user budget set): remaining() returns Infinity." But the code doesn't guard against `budget.spent` or `budget.remaining` not being functions. If the Workflow runtime provides `budget` as a plain object without methods, calling `.spent()` will throw a TypeError.

The reference workflows don't use `budget` at all, so there's no precedent to follow. The SKILL.md api_notes say these are "confirmed in Workflow tool docs" but this is the first use in TAD.

**Fix:** Add a typeof guard:
```javascript
if (budget && budget.total && typeof budget.spent === 'function') {
  budgetReport.budget_spent = budget.spent()
  budgetReport.budget_remaining = budget.remaining()
  // ...
}
```

### P1-5: `phaseNumber` validation allows `0` as valid but `phaseNumber === null` is the check

**Location:** `yolo-epic.workflow.js` line 82

**Issue:** The validation `phaseNumber === null` will pass for `phaseNumber = 0` (which is falsy but not null). However, `phaseNumber = 0` is not a valid phase number in TAD Epics (phases are 1-indexed). The check is technically correct but fragile. If someone passes `phase_number: 0`, it will produce paths like `phase0-grounding.md` which don't match the convention.

**Fix:** Change to `phaseNumber == null || phaseNumber < 1` or add explicit range validation.

### P1-6: No step-order validation

**Location:** `yolo-epic.workflow.js` lines 90-101

**Issue:** The step validation checks that each step is in VALID_STEPS, but doesn't validate the ORDER. The handoff explicitly states two valid call patterns:
- Call 1: `['design']`
- Call 2: `['review', 'implement', 'impl_review']`

But the workflow will happily accept `['impl_review', 'design']` or `['implement']` alone. Running `implement` without `review` first means no design review happened. Running `impl_review` before `implement` means reviewing code that doesn't exist yet.

The Conductor should enforce ordering, but the workflow could at least warn or validate the common patterns.

**Impact:** Low in practice (Conductor controls invocation), but defensive validation prevents misuse.

**Fix:** Add a warning log if steps don't match one of the two expected patterns.

---

## P2 Findings (Nice to Have)

### P2-1: Mixed `var`/`let`/`const` declaration style

**Location:** Throughout the file

**Issue:** The file uses `const` for schemas and phase flags, `let` for args variables, and `var` for loop variables and mutable state inside phase blocks. The reference workflows also mix `var` and `const` (tournament-design uses `var` for loop variables too), so this is a project-wide pattern rather than a regression.

**Verdict:** Consistent with existing codebase. No action needed.

### P2-2: Design prompt doesn't mention `git_tracked_dirs` frontmatter field

**Location:** `yolo-epic.workflow.js` line 129

**Issue:** The design prompt says "Include YAML frontmatter (task_type, e2e_required, research_required, git_tracked_dirs)." The current handoff also includes `skip_knowledge_assessment` and `gate4_delta` in its frontmatter. Consider making the frontmatter field list more complete or saying "Include all standard YAML frontmatter fields per the template."

### P2-3: Inconsistent comment style for phase markers

**Location:** Lines 116, 174, 244, 289, 357

**Issue:** Phase comments use inconsistent Unicode box-drawing:
- `// -- Phase: Design (Y3) ---` uses ASCII dashes
- But the section headers use the same pattern consistently

Actually on re-inspection, all phase comments use the same `// -- ... ---` pattern. Consistent. Withdrawn.

### P2-4: `agentsSpawned` counter doesn't account for failed agents

**Location:** Lines 143, 155, 230, 277, 343

**Issue:** `agentsSpawned` increments even when an agent returns null/fails. This means the budget report's `agents_spawned` count reflects attempted spawns, not successful ones. The budget report says "agents spawned" but it's really "agents attempted."

**Fix:** Either rename to `agents_attempted` or only increment on success.

---

## AC Verification (Cross-check)

| AC | Status | Note |
|----|--------|------|
| AC1 | PASS | `node -c` exits 0, valid JS syntax |
| AC2 | PASS | `steps` parameter parsed and validated (lines 90-106) |
| AC3 | PASS | Y3 uses single `agent()` call (line 138) |
| AC4 | PASS | Y4/Y6 use `parallel()` with function arrays (lines 229, 342) |
| AC5 | PASS | `isolation: 'worktree'` on line 275 |
| AC6 | PASS | Budget report schema includes agents_spawned, budget_spent, budget_remaining (lines 361-378) |
| AC7 | PASS | YOLO section is 46 lines (3584-3629), under 50 threshold |
| AC8 | PASS | All 4 constraint strings present at lines 3588-3591 |
| AC9 | PASS | Archive file exists, 269 lines, contains full prose protocol |
| AC10 | PASS | YOLO section has 0 SAFETY hits; global count = 20 (unchanged) |
| AC11 | PASS | `Object.keys` workaround at line 66 |

---

## Positive Observations

1. **Hybrid split is well-executed.** The judgment steps (Y1/Y2/Y3b/Y7/Y8) correctly stay in the Conductor; only spawnable steps move to the workflow. This matches the architecture from the handoff exactly.

2. **Circuit breaker pattern is correct.** Design phase has max 2 attempts (lines 145-166), matching the prose protocol's "circuit breaker: if second attempt also fails verify -> honest_partial."

3. **File-as-source-of-truth constraint is honored.** All agent prompts pass file paths, not business content. The design prompt passes `epicPath`, `groundingPath`, `handoffPath` as paths to read from disk.

4. **Evidence paths match convention.** The `evidenceBase + phasePrefix + '-design-review-cr.md'` pattern correctly produces paths like `.tad/evidence/yolo/{slug}/phase1-design-review-cr.md`, matching the existing convention (modulo P1-2 for domain suffix).

5. **SKILL.md stub is well-crafted.** The 46-line stub retains constraints, workflow invocation instructions, evidence naming, fallback, and judgment rules. The `epic_completion` section is correctly preserved (it's Conductor-level, not workflow-level).

---

## Recommended Action

- **Must fix before Gate 3:** P0-2 (retry prompt incomplete), P0-3 (mkdir -p for evidence dir)
- **Should fix:** P1-2 (domain suffix hardcoded), P1-3 (whenToUse), P1-4 (budget type guard)
- **Can defer:** P1-5, P1-6, P2-*

P0-1 was reclassified during review -- `sections_present` being optional and unused is cosmetic, not blocking. The real P0s are P0-2 and P0-3.
