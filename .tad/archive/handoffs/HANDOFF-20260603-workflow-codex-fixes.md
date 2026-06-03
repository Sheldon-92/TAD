---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/workflows", ".tad/hooks/lib", ".tad/codex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-007
**Handoff Version:** 3.1.0

---

## Gate 2: Design Completeness

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | 5 targeted fixes from Codex re-review, no architectural changes |
| Components Specified | OK | 3 workflow files + 1 shell script + 1 doc annotation |
| Functions Verified | OK | Each fix is a few lines, clearly scoped |
| Data Flow Mapped | OK | N/A — bug fixes, not data flow changes |

**Gate 2 Result**: PASS

---

## 1. Task Overview

Codex cross-model re-review (2026-06-03) rated the Dynamic Workflow Epic 16/25 (NEEDS-FIXES). 5 remaining items prevent PRODUCTION-READY status. All are small, targeted fixes — no architectural changes.

**Goal:** Fix all 5 items so Codex re-re-review rates PRODUCTION-READY (20+/25).

---

## 2. The 5 Fixes

### Fix 1: `judgePairs` undeclared in tournament deep mode (P1)

**File:** `.claude/workflows/tournament-design.workflow.js`
**Problem:** `judgePairs = deepPairs` is an undeclared assignment. In ES module mode (`export const meta` makes it a module), this throws `ReferenceError: judgePairs is not defined` at runtime. Deep mode tournament is broken.
**Fix:** Add `let` declaration before the assignment. Find the line where `judgePairs` is first assigned and add `let judgePairs` before it. Or if there's an earlier `let judgePairs = ...` for standard mode, ensure deep mode uses the same variable.
**Verification:** `node --input-type=module -e "$(cat .claude/workflows/tournament-design.workflow.js)" 2>&1 | grep -c ReferenceError` should be 0.

### Fix 2: Y6 all-reviewer failure is fail-open (P1)

**File:** `.claude/workflows/yolo-epic.workflow.js`
**Problem:** If ALL Y6 implementation reviewers fail (return null), the workflow sets `impl_review_p0_count = 0` plus an error flag. This is fail-OPEN: zero P0s reported when actually we don't know (reviewers crashed). Should be fail-CLOSED.
**Fix:** After the Y6 reviewer parallel() call, check if ALL results are null. If so, set `impl_review_p0_count = -1` (or a sentinel) and `stop_reason = 'all_reviewers_failed'`, then return early (same pattern as the Y4 P0 gate at line 261).
**Verification:** Read the code path: when `validReviews.length === 0`, does the workflow stop or continue to the next step?

### Fix 3: Budget label clarification (P2)

**File:** `.claude/workflows/yolo-epic.workflow.js`
**Problem:** The workflow calls itself "budget-aware" but budget is observation-only (logs remaining, human decides). Codex says this is misleading.
**Fix:** In the `export const meta` block, change description from any mention of "budget-aware" to "budget-reporting". Add a comment at the budget check: `// Budget REPORTING only — human decides at checkpoint. NOT enforcement.`
**Verification:** `grep -i 'budget-aware' .claude/workflows/yolo-epic.workflow.js` should return 0.

### Fix 4: Platform detection env var gap (P1)

**File:** `.tad/hooks/lib/detect-platform.sh`
**Problem:** Safety validation Experiment 5 found detect-platform.sh returns "codex" even inside Claude Code (because `CLAUDE_CODE_SESSION` env var is not set in real Claude Code sessions — it was a speculative check). The parent-process heuristic also doesn't reliably detect Claude Code.
**Fix:** Reverse the detection priority: check for Codex FIRST (it's more reliably detectable via `command -v codex`), then default to "workflow" if inside any interactive session with .workflow.js files. Add a comment documenting the limitation.

Revised logic:
```bash
#!/bin/bash
# Returns: "workflow" | "codex" | "none"
# Known limitation: cannot reliably distinguish Claude Code from Codex
# when BOTH are available. Defaults to "workflow" (higher quality).
# User can override by setting TAD_PLATFORM=codex.

# Override: user explicitly sets platform
if [ -n "${TAD_PLATFORM:-}" ]; then
  echo "$TAD_PLATFORM"
  exit 0
fi

# Check Codex CLI availability
CODEX_AVAILABLE=0
if command -v codex >/dev/null 2>&1; then
  CODEX_AVAILABLE=1
fi

# Check workflow files exist
WORKFLOW_AVAILABLE=0
if ls .claude/workflows/*.workflow.js >/dev/null 2>&1; then
  WORKFLOW_AVAILABLE=1
fi

# Priority: workflow > codex > none
# (workflow = Claude Code Workflow tool, higher quality than sequential codex exec)
if [ "$WORKFLOW_AVAILABLE" -eq 1 ]; then
  echo "workflow"
elif [ "$CODEX_AVAILABLE" -eq 1 ]; then
  echo "codex"
else
  echo "none"
fi
```

**Verification:** `bash .tad/hooks/lib/detect-platform.sh` in Claude Code should return "workflow". `TAD_PLATFORM=codex bash .tad/hooks/lib/detect-platform.sh` should return "codex".

### Fix 5: Document test harness need (P2)

**File:** `.tad/evidence/research/2026-06-03-workflow-safety-validation.md` (append)
**Problem:** Codex wants a deterministic test harness but building one is out of scope for a fix batch. Document it as a tracked follow-up.
**Fix:** Append a "## Follow-Up: Test Harness" section to the validation report with the 5 test cases Codex specified:
1. Review P0 stops implement
2. Reviewer-null fails closed
3. Implementation failure skips review
4. Budget-low stops
5. Deep tournament mode runs without ReferenceError

**Verification:** `grep 'Test Harness' .tad/evidence/research/2026-06-03-workflow-safety-validation.md` returns a match.

---

## 3. Files to Modify

| File | Action | Fix # |
|------|--------|-------|
| `.claude/workflows/tournament-design.workflow.js` | MODIFY | Fix 1 (judgePairs declaration) |
| `.claude/workflows/yolo-epic.workflow.js` | MODIFY | Fix 2 (Y6 fail-closed) + Fix 3 (budget label) |
| `.tad/hooks/lib/detect-platform.sh` | MODIFY | Fix 4 (detection logic rewrite) |
| `.tad/evidence/research/2026-06-03-workflow-safety-validation.md` | MODIFY | Fix 5 (append test harness section) |

---

## 4. Acceptance Criteria

| AC | Requirement | Verification |
|----|------------|-------------|
| AC1 | judgePairs declared | `grep 'let judgePairs\|var judgePairs\|const judgePairs' .claude/workflows/tournament-design.workflow.js` >= 1 |
| AC2 | Y6 fail-closed | Read yolo-epic.workflow.js: when all reviewers return null, workflow returns/stops (not continues with p0_count=0) |
| AC3 | Budget label fixed | `grep -ci 'budget-aware' .claude/workflows/yolo-epic.workflow.js` == 0 |
| AC4 | Platform detection has override | `grep 'TAD_PLATFORM' .tad/hooks/lib/detect-platform.sh` >= 1 |
| AC5 | Platform returns "workflow" here | `bash .tad/hooks/lib/detect-platform.sh` output is "workflow" |
| AC6 | Test harness documented | `grep 'Test Harness' .tad/evidence/research/2026-06-03-workflow-safety-validation.md` >= 1 |
| AC7 | SAFETY unchanged | `grep -c 'NOT_via_alex_auto\|forbidden_implementations' .claude/skills/alex/SKILL.md` == 20 |

---

## 5. Important Notes

- These are TARGETED FIXES, not refactors. Don't reorganize, extract shared modules, or add features.
- After these fixes, we will re-run Codex for a third review to aim for PRODUCTION-READY.
- Fix 4 (platform detection) is a REWRITE of detect-platform.sh — simpler logic, explicit user override via TAD_PLATFORM env var.
