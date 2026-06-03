---
task_type: e2e
e2e_required: yes
research_required: no
git_tracked_dirs: [".claude/workflows", ".tad/evidence"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-006
**Handoff Version:** 3.1.0

---

## Gate 2: Design Completeness

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | 7 concrete experiments, each with pass/fail criteria |
| Components Specified | OK | Test scripts + evidence report |
| Functions Verified | OK | Experiments test existing workflows, no new features |
| Data Flow Mapped | OK | Run experiment → capture output → compare against expected → verdict |

**Gate 2 Result**: PASS

---

## 1. Task Overview

Codex cross-model review (2026-06-03) rated the Dynamic Workflow Integration Epic 12/25 (Safety 2/5, Sustainability 2/5). Core finding: "Promising architecture, unsafe landing." The workflows were structurally validated (AC grep checks) but never tested for **failure modes**.

This handoff runs 7 concrete experiments to determine whether the workflows are production-ready or need safety fixes. Each experiment targets a specific failure mode identified by Codex. Results are recorded as evidence; no code changes unless a critical bug is discovered.

**This is an AUDIT, not an implementation.** Blake reads code, runs experiments, reports findings. Fix only if a P0 safety issue is confirmed live.

---

## 2. The 7 Experiments

### Experiment 1: YOLO — Does Call 2 stop on design-review P0?

**What Codex said:** "yolo-epic.workflow.js lets implementation continue after design review even when reviewers find P0s."

**How to test:**
1. Read `.claude/workflows/yolo-epic.workflow.js`
2. Trace the code path from the `review` step to the `implement` step
3. Answer: Is there a deterministic check between Y4 (design review result) and Y5 (Blake implement) that stops execution if p0_count > 0?
4. If YES: document the exact line numbers where the gate fires
5. If NO: this is a **P0 SAFETY BUG** — implement proceeds despite review P0s
6. If the gate EXISTS: craft a minimal dry-run that feeds p0_count=1 into the gate logic and confirm it actually halts (code trace is necessary but not sufficient — the review step might return a different shape than the gate expects)

**Expected evidence:** Code trace showing the conditional + runtime proof (dry-run or structural argument for why the shape matches).

**Pass criterion:** There exists a deterministic `if (p0_count > 0) { return/throw/stop }` between the review and implement phases inside Call 2, AND evidence that the review step's return shape matches the gate's expected input.

---

### Experiment 2: YOLO — Budget enforcement vs observation

**What Codex said:** "Budget observation is not budget enforcement."

**How to test:**
1. Read `yolo-epic.workflow.js`
2. Find all `budget.remaining()` references
3. Classify each as:
   - ENFORCEMENT: code that stops/returns/throws when budget is low
   - OBSERVATION: code that logs budget but continues regardless
4. Check: what happens when `budget.total` is null (no user budget set)?

**Expected evidence:** Line-by-line classification table.

**Pass criterion:** At least one ENFORCEMENT check exists before each agent spawn. Budget guard handles null gracefully (doesn't crash, falls back to max_rounds).

---

### Experiment 3: Tournament — `judgePairs` undeclared assignment bug

**What Codex said:** "judgePairs = deepPairs is assigned without declaration inside an ES module, which can throw."

**How to test:**
1. Read `.claude/workflows/tournament-design.workflow.js`
2. Search for `judgePairs`
3. Check: is it declared with `let`/`const`/`var` before first assignment?
4. If undeclared: run `node -c tournament-design.workflow.js` — does it parse? (It may parse but throw at runtime)
5. Try to invoke the workflow in deep mode with a minimal test to trigger the code path

**Expected evidence:** grep output + node -c result + runtime test if applicable.

**Pass criterion:** `judgePairs` is properly declared OR the code path works correctly despite the concern.

---

### Experiment 4: Loop-Discover — Dedup with missing key

**What Codex said:** "If findings lack the dedup_key field, the dedup will malfunction."

**How to test:**
1. Read `.claude/workflows/loop-discover.workflow.js`
2. Find the `getKey()` function and the dedup filter
3. Trace: what happens when a finding object has `dedup_key` field as undefined/null?
4. Does `seen.has(undefined)` or `seen.has('')` cause false dedup (collapsing unrelated items)?

**Expected evidence:** Code trace showing the null/undefined handling path.

**Pass criterion:** Findings with missing dedup_key are either filtered out with a warning OR treated as unique (not collapsed).

---

### Experiment 5: Platform detection — Wrong result when Claude Code files exist in Codex session

**What Codex said:** "A project with .workflow.js files running on Codex would get 'workflow' instead of 'codex'."

**How to test:**
1. Read `.tad/hooks/lib/detect-platform.sh`
2. Check: does it check env vars (CLAUDE_CODE_SESSION, parent process) BEFORE checking files?
3. Run: `bash .tad/hooks/lib/detect-platform.sh` in THIS terminal (Claude Code) — should return "workflow"
4. Simulate non-Claude-Code context: `CLAUDE_CODE_SESSION="" bash .tad/hooks/lib/detect-platform.sh` — what does it return?
5. Read detect-platform.sh and enumerate ALL env vars / process checks it uses. Then simulate the exact Codex detection: set any Codex-specific env var the script checks while workflow files exist on disk. Verify it returns "codex" not "workflow".
6. If the script has no Codex-specific env var check (only `command -v codex`): document this as a detection gap.

**Expected evidence:** Actual run output from scenarios 3-5 + enumeration of all detection conditions.

**Pass criterion:** Detection uses env/process checks FIRST, file-system check is NOT the primary detection mechanism. Or: the file-system check is explicitly documented as a known limitation.

---

### Experiment 6: Gate-Review — Skeptic effectiveness on PASS items

**What Codex said:** "gate-review claims per-AC verification but uses pipeline, likely serial."

**How to test:**
1. Read `.claude/workflows/gate-review.workflow.js`
2. Check: does it use `pipeline()` or `parallel()` for the verifier agents?
3. Check: does the skeptic phase run on ALL items or only on FAIL/PARTIAL items?
4. If skeptic only runs on flagged items: a verifier that wrongly PASSes an AC (false negative) is never caught

**Expected evidence:** Code path trace showing pipeline vs parallel + skeptic trigger condition.

**Pass criterion:** Verifiers use `pipeline()` (acceptable — serial is fine for correctness). Skeptic only runs on flagged items (acceptable — false negatives require a different mechanism, documented as limitation).

---

### Experiment 7: Shared infrastructure audit — DRY violations

**What Codex said:** "Repeated hand-written arg parsing in every workflow."

**How to test:**
1. Count `Object.keys` patterns across all 5 workflows:
   `grep -c 'Object.keys' .claude/workflows/*.workflow.js`
2. Count repeated schema definitions:
   `grep -c 'type.*object.*properties' .claude/workflows/*.workflow.js`
3. List all args-parsing code blocks — are they copy-pasted or structurally different?

**Expected evidence:** Counts + diff of args-parsing blocks across files.

**Pass criterion:** N/A — this is a measurement, not a pass/fail. Output is a maintenance burden score.

---

## 3. Files to Read (DO NOT MODIFY unless P0 safety bug found)

| File | Read for |
|------|----------|
| `.claude/workflows/yolo-epic.workflow.js` | Experiments 1, 2 |
| `.claude/workflows/tournament-design.workflow.js` | Experiment 3 |
| `.claude/workflows/loop-discover.workflow.js` | Experiment 4 |
| `.tad/hooks/lib/detect-platform.sh` | Experiment 5 |
| `.claude/workflows/gate-review.workflow.js` | Experiment 6 |
| `.claude/workflows/*.workflow.js` (all) | Experiment 7 |

---

## 4. Acceptance Criteria

| AC | Requirement | Verification |
|----|------------|-------------|
| AC1 | All 7 experiments executed | Evidence file contains 7 sections with results |
| AC2 | Each experiment has pass/fail verdict | Every section ends with PASS / FAIL / LIMITATION |
| AC3 | P0 bugs (if found) are fixed with test | Any confirmed P0 has a code fix + before/after evidence |
| AC4 | Summary verdict | Overall: PRODUCTION-READY / NEEDS-FIXES / EXPERIMENTAL |
| AC5 | Evidence file written | `.tad/evidence/research/2026-06-03-workflow-safety-validation.md` exists |

---

## 5. Important Notes

### 5.1 Rules of engagement
- **READ first, RUN second.** Code trace before live test.
- **Fix ONLY confirmed P0 safety bugs** (Experiment 1 stop-on-P0 is the most likely). Everything else: report as finding, don't fix.
- **Be adversarial.** Codex rated Safety 2/5. Prove Codex wrong with evidence, or confirm Codex right with evidence. "It looks fine" is not evidence.

### 5.2 If Experiment 1 finds a P0
If YOLO workflow does NOT stop on design-review P0: this is a safety regression. Fix it in `yolo-epic.workflow.js` by adding a deterministic gate between the review and implement steps. This is the ONLY authorized fix in this handoff.

### 5.3 What NOT to do
- DO NOT refactor workflows for DRY (Experiment 7 is measurement only)
- DO NOT add a test harness (that's a separate handoff if needed)
- DO NOT change workflow behavior unless a P0 safety bug is confirmed
- DO NOT modify SKILL.md
