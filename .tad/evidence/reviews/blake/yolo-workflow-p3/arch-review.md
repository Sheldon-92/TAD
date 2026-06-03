# Architecture Review: YOLO Epic Workflow (P3)

**Reviewer:** Backend Architecture Expert
**Date:** 2026-06-03
**Primary file:** `.claude/workflows/yolo-epic.workflow.js` (394 lines)
**Reference workflows:** `gate-review.workflow.js`, `tournament-design.workflow.js`, `epic-audit.workflow.js`
**Handoff:** HANDOFF-20260603-yolo-workflow-p3.md
**Context:** Existing code-review.md and spec-compliance.md already cover AC-level verification. This review focuses on architectural coherence, error handling patterns, schema design, prompt quality, and API usage.

---

## 1. Architectural Coherence: Hybrid Conductor + Workflow Boundary

### Assessment: Well-Designed

The Conductor/Workflow split is clean and follows a defensible principle: **judgment stays in the Conductor, execution moves to the Workflow**. Specifically:

- **Conductor retains:** Y1 (phase activation), Y2 (grounding -- requires reading codebase with full context), Y3b (handoff validation -- requires judgment about quality), Y7 (gate judgment -- reads evidence files from disk, makes pass/fail decision), Y8 (knowledge assessment + human checkpoint).
- **Workflow owns:** Y3 (design agent), Y4 (parallel review agents), Y5 (Blake implementation agent), Y6 (parallel impl-review agents), plus budget reporting.

This boundary is correct because the Workflow API spawns sub-agents with fresh context windows -- exactly what you want for the "execute a focused task" steps -- while the Conductor maintains the long-running context needed for judgment decisions that require understanding the full Epic state.

The two-call invocation pattern (Call 1: `['design']`, Call 2: `['review', 'implement', 'impl_review']`) is architecturally sound. It exists because Y3b is a Conductor judgment step that must occur between Y3 and Y4. This is not a workaround; it is the correct design. The alternative (putting Y3b inside the workflow) would violate the "judgment stays in Conductor" principle and require the workflow to make a pass/fail decision about its own output -- exactly the self-preferential bias the Thariq article warns about.

**No findings.**

---

## 2. Error Handling: Circuit Breakers, Fallback Paths, honest_partial Signals

### P0-1: Review phase has no circuit breaker -- silent failure if all reviewers return null

**Location:** Lines 236-248 (Y4) and Lines 351-363 (Y6)

**Issue:** The design phase (Y3) has a well-implemented circuit breaker: if the first attempt fails, retry once; if the second attempt fails, return an error object for the Conductor to handle as honest_partial. But the review phases (Y4, Y6) have NO equivalent circuit breaker. If both `parallel()` reviewers return null (agent crash, timeout, etc.), the code proceeds with:

```javascript
var validReviews = reviewResults.filter(Boolean)  // = []
var totalP0 = 0  // 0 because no reviews
```

The workflow then sets `result.design_reviews = []` and `result.design_review_p0_count = 0` and continues to the next step. The Conductor receives a result that says "0 P0s found" -- indistinguishable from "all reviews passed with no issues." This is a **false-negative that looks like success**.

The SKILL.md judgment rule says ">=2 distinct reviewers at Y4 and Y6" -- but the workflow returns a result that lets the Conductor believe the requirement was met when zero reviewers actually ran.

**Impact:** A completely unreviewed handoff or implementation passes through as if it were reviewed and clean.

**Fix:** After filtering, check `validReviews.length < 1` (or `< reviewerCount` for strict mode) and either:
- Return an error object (like the design circuit breaker does), or
- Set a `review_incomplete: true` flag that the Conductor can check

Example:
```javascript
if (validReviews.length === 0) {
  log('Y4: Circuit breaker — all reviewers failed')
  return {
    error: 'review_circuit_breaker',
    phase: 'review',
    reviewers_attempted: reviewPrompts.length,
    reviewers_succeeded: 0,
    message: 'No reviewers returned results. Conductor should handle honest_partial.'
  }
}
```

### P0-2: Implementation phase failure is swallowed -- workflow continues to impl_review of non-existent code

**Location:** Lines 252-293 (Y5) and Lines 298-363 (Y6)

**Issue:** When the implementation agent fails (`implResult` is null or `completion_written` is false), the workflow logs the failure and sets `result.implementation = { error: 'no completion report', raw: implResult }` -- but then **continues to the impl_review phase**. The impl_review agents are told to "Read the completion report at {completionPath}" and "Check the git diff for recent changes." Both will find nothing meaningful because no implementation occurred.

This means the impl_review agents will either:
- Report CANNOT_VERIFY for all ACs (best case, waste of tokens)
- Hallucinate findings based on whatever happens to be in the git diff (worst case, misleading results)

The reference workflows handle this correctly: `gate-review.workflow.js` aborts if the extract phase finds no ACs (line 140-143). `tournament-design.workflow.js` aborts if fewer than 2 competitors succeed (line 155-158). The yolo-epic workflow does not follow this pattern for the implement-to-impl_review transition.

**Fix:** Add a guard between Y5 and Y6:
```javascript
if (runImplReview) {
  if (!result.implementation || result.implementation.error) {
    log('Y6: Skipping impl review — implementation failed')
    result.impl_reviews = []
    result.impl_review_skipped = true
    result.impl_review_skip_reason = 'implementation failed or incomplete'
  } else {
    // ... existing Y6 code
  }
}
```

### P1-1: Design circuit breaker does not propagate the first attempt's partial result

**Location:** Lines 146-171

**Issue:** When the first design attempt fails and the retry also fails, the circuit breaker returns `last_line_count` from the second attempt. But it discards any partial work from the first attempt. If the first attempt wrote 40 lines (below threshold) and the second wrote 30 lines, the Conductor only sees "30 lines." More importantly, the first attempt may have written a partial HANDOFF.md to disk that the Conductor could use for honest_partial recovery. The error return should note this.

**Impact:** Minor -- the Conductor can always read the disk to find partial work. But the error return should signal that a partial file may exist at `handoffPath`.

**Fix:** Add `partial_file_may_exist_at: handoffPath` to the error return object.

### P1-2: No timeout or max-agent budget guard in the workflow itself

**Location:** Entire file

**Issue:** The workflow can spawn up to 7 agents per invocation (1 design + 1 retry + 2 reviewers = 4 for Call 1; or 2 reviewers + 1 Blake + 2 impl-reviewers = 5 for Call 2). If budget is exhausted mid-execution, the workflow has no mechanism to detect this and abort gracefully. The budget check only happens AFTER all steps complete (lines 368-389).

The Thariq article recommends checking budget at phase boundaries: "You can set explicit token usage budgets for dynamic workflows to limit how many tokens a task uses." But the workflow only reports budget at the end, never checks it between steps.

**Impact:** Medium. If the budget runs out during Y5 (implementation), the Y6 impl-review agents will still attempt to spawn, consuming more tokens on a doomed review. However, the Workflow runtime itself may enforce budget limits externally, making this a defense-in-depth concern rather than a critical gap.

**Fix:** Add budget check between Y5 and Y6:
```javascript
if (typeof budget !== 'undefined' && budget && typeof budget.remaining === 'function') {
  var remaining = budget.remaining()
  if (remaining !== null && remaining < 0) {
    log('Budget exhausted after implementation. Skipping impl review.')
    result.budget_exhausted = true
    // skip Y6
  }
}
```

---

## 3. Schema Design

### Assessment: Adequate with one structural gap

The three schemas (DESIGN_RESULT_SCHEMA, REVIEW_RESULT_SCHEMA, IMPL_RESULT_SCHEMA) are well-structured and follow the patterns established by the reference workflows. Required fields are correctly chosen -- only the fields the workflow logic actually reads are `required`.

### P1-3: REVIEW_RESULT_SCHEMA lacks `verdict` field

**Location:** Lines 28-39

**Issue:** The review schema requires `reviewer_type`, `evidence_path`, `p0_count`, `p1_count`, `p2_count`, and `summary`. But it has no `verdict` field (e.g., "PASS", "FAIL", "CONDITIONAL_PASS"). The `gate-review.workflow.js` VERIFY_SCHEMA includes a `verdict` enum. Without a verdict field, the Conductor has to infer the review outcome from `p0_count > 0` -- which works but is indirect. More importantly, a reviewer might find zero P0s but still have concerns that don't fit the P0/P1/P2 taxonomy (e.g., "the design approach is fundamentally wrong but I can't point to a specific spec violation"). Without a verdict field, this concern has nowhere to go except `summary`, which the workflow never reads.

**Impact:** Low for the workflow itself (it only checks `p0_count`), but reduces the quality of information available to the Conductor for judgment.

**Fix:** Add an optional verdict field:
```javascript
verdict: { type: 'string', enum: ['PASS', 'CONCERNS', 'FAIL'] }
```

### P2-1: DESIGN_RESULT_SCHEMA `sections_present` field is dead weight

**Location:** Lines 21-23

**Issue:** `sections_present` is defined in the schema but never read by any downstream code. Already noted in code-review.md P0-1. This is cosmetic -- the schema is consumed by the agent to guide its output structure, so having an unreferenced field is merely confusing, not broken.

---

## 4. Agent Prompt Quality: File-as-Source-of-Truth

### Assessment: Good with one structural violation

The prompts correctly follow the file-as-source-of-truth principle. All agent prompts pass file paths rather than business content. The design prompt (lines 123-137) tells the agent to read the Epic, grounding file, and handoff template from disk. The review prompts point to the handoff and evidence paths. The implementation prompt points to the handoff for requirements.

### P0-3: Retry prompt (already in code-review P0-2) breaks file-as-source-of-truth

**Location:** Lines 148-158

**Issue:** Already covered in code-review.md P0-2. The retry prompt drops the grounding file path and the template path. This is a file-as-source-of-truth violation because the retry agent cannot ground itself in the same source material as the first attempt. Confirmed as P0 from the architecture perspective as well -- the grounding file is the Conductor's primary mechanism for ensuring the design agent has accurate knowledge of the current codebase state.

### P1-4: Implementation prompt hardcodes Layer 1 check commands that may not exist in all projects

**Location:** Lines 263-266

**Issue:** The Blake implementation prompt includes:
```
3. Run these checks (Layer 1):
   - npx tsc --noEmit (must pass)
   - npm test (must pass)
   - npm run lint (if available)
```

These commands assume a TypeScript + npm project. TAD itself is a shell-based framework (`tad.sh`, `*.sh` scripts). The `npx tsc --noEmit` command will fail in the TAD project context because there is no `tsconfig.json`. This prompt should either:
- Read the Layer 1 check commands from the handoff (which should specify project-appropriate checks), or
- Use conditional checks ("if tsconfig.json exists, run tsc")

**Impact:** In practice, the Blake agent will likely handle this gracefully (skip tsc if no tsconfig), but the prompt is misleading. For a general-purpose YOLO workflow that may be used across different project types, hardcoded commands are fragile.

**Fix:** Change to: "Run the Layer 1 checks specified in the handoff. If no specific checks are listed, try: tsc (if tsconfig.json exists), test suite (npm test or equivalent), and linter (if configured)."

### P1-5: Impl-review prompt says "Check the git diff for recent changes" without specifying scope

**Location:** Lines 310, 336

**Issue:** The prompt tells impl-review agents to "Check the git diff for recent changes" but does not specify which diff. Should it be `git diff HEAD~1`? `git diff main`? `git diff --cached`? The agent will guess, and different agents in the parallel review may check different diffs, leading to inconsistent review coverage.

The implementation prompt (Y5) tells Blake to commit with a specific message, so the impl-review agents should check the diff of that specific commit. But they have no way to know the commit SHA.

**Fix:** Either (a) have the IMPL_RESULT_SCHEMA include a `commit_sha` field, then pass it to the impl-review prompt, or (b) specify `git log --oneline -1 && git diff HEAD~1` in the prompt.

---

## 5. Budget API Usage

### Assessment: Defensive but potentially incorrect

### P1-6: `budget.spent` and `budget.remaining` are guarded as functions but the API may provide them as properties

**Location:** Lines 380-387

**Issue:** The code uses `typeof budget.spent === 'function' ? budget.spent() : null`. The Thariq article's API reference (Diagram 1) does not show `budget` as part of the Workflow API surface. The SKILL.md `api_notes` says "budget: {total, spent(), remaining()} -- confirmed in Workflow tool docs" but this is the first use in TAD.

There is ambiguity about whether `spent` and `remaining` are methods (requiring `()`) or getters/properties (accessed without `()`). The `typeof === 'function'` guard handles the case where they are properties (would return the value directly via `budget.spent` without calling it). But if they ARE functions and return a Promise, the code would store a Promise object instead of a number.

Since no reference workflow uses the budget API, there is no empirical precedent.

**Impact:** If the API returns properties instead of functions, `budget.spent()` would throw TypeError without the guard. The guard handles this. But the `null` fallback means the Conductor gets no budget data in that case, which is a silent degradation.

**Fix:** The current implementation is the best available defensive code given the API uncertainty. Add a log line when the fallback triggers so the Conductor knows budget data was unavailable:
```javascript
if (typeof budget.spent !== 'function') {
  log('Budget: spent/remaining are not functions — API shape unexpected')
}
```

### P2-2: Budget report always runs even when no steps executed

**Location:** Lines 368-393

**Issue:** If validation fails early (e.g., invalid steps array), the code returns before reaching the budget report. This is correct. But if all steps are skipped due to conditional flags (e.g., `steps: ['design']` means `runReview`, `runImplement`, `runImplReview` are all false), the budget report still runs and reports `agents_spawned: 1` (or whatever count). This is correct behavior -- just noting it for completeness.

---

## 6. Cross-Cutting Concerns

### P1-7: No structured result envelope for the Conductor to distinguish success from partial success

**Location:** Lines 114-115 (result object)

**Issue:** The `result` object is built incrementally (`result.handoff_path = ...`, `result.design_reviews = ...`, etc.) but has no top-level `status` field. The Conductor must inspect individual fields to determine the outcome:
- Did design succeed? Check `result.handoff_path` exists
- Did reviews complete? Check `result.design_reviews.length > 0`
- Did implementation succeed? Check `result.implementation && !result.implementation.error`

Compare to the `gate-review.workflow.js` which returns a single `GATE_REPORT_SCHEMA` with an `overall_verdict` enum. The yolo-epic workflow has no equivalent summary.

**Impact:** The Conductor must implement its own logic to interpret the result object. If a new step is added in the future, the Conductor's interpretation logic must be updated in lockstep.

**Fix:** Add a top-level status to the result before returning:
```javascript
result.status = 'complete'  // or 'partial' if any step failed
result.steps_succeeded = steps.filter(function(s) {
  if (s === 'design') return result.handoff_path
  if (s === 'review') return result.design_reviews && result.design_reviews.length > 0
  if (s === 'implement') return result.implementation && !result.implementation.error
  if (s === 'impl_review') return result.impl_reviews && result.impl_reviews.length > 0
  return false
})
```

### P2-3: Workflow does not validate that handoff exists before running Call 2 steps

**Location:** Lines 181-248 (review phase start)

**Issue:** The SKILL.md says "Precondition: handoff must exist and be > 50 lines." The workflow checks this for the design phase (line 146: `designResult.line_count < 50`) but does NOT check it when running review/implement/impl_review steps in Call 2. If the Conductor accidentally calls the workflow with `steps: ['review', 'implement', 'impl_review']` before the handoff exists (e.g., Y3b validation failed but Conductor proceeded anyway), the review agents will try to read a non-existent file.

The Conductor SHOULD enforce this, but defense-in-depth says the workflow should also validate its preconditions.

**Fix:** At the start of the review phase, add:
```javascript
if (runReview) {
  // Precondition: handoff must exist (written by Call 1 design step)
  // Workflow trusts Conductor validated this, but log a warning for debugging
  log('Y4: Expects handoff at ' + handoffPath + ' (Conductor must validate existence)')
}
```

---

## Findings Summary

| ID | Severity | Title | Category |
|----|----------|-------|----------|
| P0-1 | P0 | Review phase has no circuit breaker -- 0 reviewers looks like "all passed" | Error Handling |
| P0-2 | P0 | Implementation failure does not stop impl_review from running | Error Handling |
| P0-3 | P0 | Retry prompt drops grounding + template paths (confirms code-review P0-2) | Prompt Quality |
| P1-1 | P1 | Design circuit breaker does not signal partial file on disk | Error Handling |
| P1-2 | P1 | No mid-execution budget guard between Y5 and Y6 | Budget API |
| P1-3 | P1 | REVIEW_RESULT_SCHEMA lacks verdict field | Schema Design |
| P1-4 | P1 | Blake prompt hardcodes tsc/npm commands for all project types | Prompt Quality |
| P1-5 | P1 | Impl-review prompt does not specify which git diff to check | Prompt Quality |
| P1-6 | P1 | Budget API shape uncertainty -- add log when fallback triggers | Budget API |
| P1-7 | P1 | No top-level status/verdict in result envelope | Architecture |
| P2-1 | P2 | DESIGN_RESULT_SCHEMA `sections_present` is unused | Schema Design |
| P2-2 | P2 | Budget report runs even when no sub-agent steps executed | Budget API |
| P2-3 | P2 | No precondition validation for handoff existence in Call 2 | Architecture |

---

## Overlap with Existing Reviews

- **P0-3** confirms code-review.md P0-2 (retry prompt incomplete). Same finding, different angle (file-as-source-of-truth violation vs missing file paths).
- **P2-1** confirms code-review.md P0-1 (reclassified to cosmetic). Both reviews agree this is not blocking.
- Code-review.md P0-3 (mkdir -p for evidence dir) is NOT duplicated here because it is a file-system concern, not an architecture concern. It remains valid and should be fixed.
- Code-review.md P1-2 (domain suffix hardcoded to `-arch`) is also NOT duplicated. It is a naming-convention concern that this review acknowledges but does not re-file.

**Net-new P0s from this review:** P0-1 (review circuit breaker) and P0-2 (impl failure not stopping impl_review).

---

## Architectural Verdict

The hybrid Conductor + Workflow pattern is **architecturally sound**. The boundary between judgment steps and execution steps is clean, well-motivated, and consistent with the Thariq article's recommendations. The two-call invocation pattern correctly preserves the Conductor's authority over validation.

The primary weakness is in **error propagation**: the happy path is well-designed, but failure paths allow silent degradation (zero reviewers reading as "clean", failed implementation flowing into impl_review). These are the two net-new P0s that must be fixed before the workflow can be trusted in production YOLO execution.

The budget API usage is the best available given the API uncertainty. The schema design is adequate. The agent prompts correctly follow file-as-source-of-truth with one confirmed violation in the retry path.

**Recommendation:** Fix P0-1 and P0-2 (error propagation), then this workflow is ready for Gate 3.
