# Spec-Compliance Review: HANDOFF-20260601-codex-parity-phase1-spike

**Reviewer:** code-reviewer (spec-compliance, independent re-verification)
**Date:** 2026-06-01
**Handoff:** HANDOFF-20260601-codex-parity-phase1-spike.md
**Verdict:** CONDITIONAL PASS (2 P1, 2 P2 — no P0)

---

## AC Verification Matrix

All verification commands re-run independently. `<regen>` = `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md`.

| AC | Status | Evidence | Notes |
|----|--------|----------|-------|
| AC1-guard | PASS | `grep -c AskUserQuestion <regen>` = **0** (expected 0) | Verified. |
| AC1-constraint | PASS | `grep -coE 'MUST\|MANDATORY\|VIOLATION' <regen>` = **59** (expected >=10; source=136, floor=13) | 4.5x above floor. `-coE` counts occurrences, not lines -- correct for this use. |
| AC1-size | PASS | `wc -c < <regen>` = **49596** (range 25600-102400) | 49KB. Not truncated (>>25KB), not oversized (<<100KB). |
| AC2-deliverable | PASS | `grep -c 'deliverable' <regen>` = **7** (expected >=5) | Drift closed. Baseline live = 0. |
| AC2-routing | PASS | `grep -c 'task_type: deliverable' <regen>` = **1** (expected >=1) | Routing anchor present at step0_6_deliverable_classification. |
| AC2-research | PASS | `grep -c 'research_complexity' <regen>` = **3** (expected >=1) | Research-engine wiring present (tier persistence at line 412). |
| AC2-step45 | PASS | `grep -ci 'step4_5\|Pack Awareness' <regen>` = **3** (expected >=1) | Pack-collision wiring present. |
| AC3 | PASS | `parity-criterion.md` exists (3395 bytes). Content confirms: (a) 3-layer check defined (Section/Constraint/Capability-Marker), (b) must-cover vs expected-absent split documented with 9 allowlisted protocols, (c) mechanical marker-extraction rule stated for Layer 3, (d) pinned exit-code contract (0/1/2) + parse-error path (P1 fail-open, P3 fail-closed). | All sub-requirements met. See P1-1 below re: feature_markers partial hardcoding. |
| AC4-drift | PASS | `bash parity-check.sh <source> <live>` = **exit 1**. Layer 1 FAIL: 8 missing must-cover sections (idea_list, idea_promote, research_decision, research_plan, research_review, status_panoramic, test_review, update_roadmap). Layer 2 PASS. Layer 3 FAIL: 4 absent markers (task_type 'deliverable', feature 'deliverable', 'research_complexity', 'step4_5'). | Per-layer reporting names specific missing items. Anti-theater proven. |
| AC4-parity | PASS | `bash parity-check.sh <source> <regen>` = **exit 0**. Layer 1: 22 covered, 9 expected-absent, 0 missing. Layer 2: AskUser=0, constraints=57 (floor=13), AR+FI present. Layer 3: all task_types + feature markers covered. | All 3 layers independently report PASS. |
| AC5 | PASS | spike-report.md records: B-viability "VIABLE -- Proceed to P2". Time separation: Step 3 authoring ~40min (one-time) vs Step 3b recurring "NOT MEASURED" (UNPROVEN) vs <=5min threshold. Boolean pivot: "PASS -- proceed to Phase 2" with "supervised regen ~15 min; headless target <=5 min (UNPROVEN)". DR-20260601 appended at line 75 with "Phase 1 Spike Finalized (2026-06-01)" + verdict + residual. | All AC5 sub-requirements met. |
| AC6 | PASS | `git status --porcelain .tad/codex/` = **empty**. `git diff --name-only .tad/codex/` = empty. | Live edition byte-unchanged. Scratch isolation confirmed. |
| AC7 | PASS | `grep -ci 'expected-absent\|expected absent' .tad/portable-rules.md` = **1**. Content: Strip-Whole-Protocol row at line 58, Expected-Absent-in-Codex Allowlist table (9 protocols with rationale) at line 64, Nested/inline ignore list (5 keys) at line 82. | CR P0-2 fully resolved. |
| AC8 | PASS (honest fallback) | `codex-alex-skill.regen2.md` does NOT exist. Spike report: "Status: Headless reliability UNPROVEN -- P2 residual risk." (line 28). Explicit: "This is an honest 'UNPROVEN', not a fake 'PASS'." (line 35). | Honest-fallback path exercised correctly per AC8 alternative. |

**Summary: 8/8 ACs SATISFIED** (AC8 via the honest-fallback branch).

---

## Section 10 Important Notes Compliance

| Note | Status | Evidence |
|------|--------|----------|
| 10.1 Anti-theater | PASS | AC4-drift exit 1, two independent layer failures with named specifics. The check discriminates. |
| 10.2 Single-user-CLI | PASS | `grep -c 'settings.json\|PreToolUse\|SessionStart' parity-check.sh` = 0. No hook wiring. |
| 10.3 Preserve-list safety | PARTIAL | `anti_rationalization_registry` (3 refs), `forbidden_implementations` (6 refs) confirmed. However, see P1-2: `honest_partial_protocol` (0 refs, source has 4) and `Ralph Loop` (0 refs, source has 3) are missing from regen. |
| 10.4 Shell portability | PASS | No `grep -P`. `LC_ALL=C` on all sort operations (3 instances). `|| true` on grep commands. `set -euo pipefail`. BSD/macOS clean. |
| 10.5 Scratch isolation | PASS | Output at `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md`. `.tad/codex/` untouched (verified via git status + git diff). |

---

## Findings

### P1-1: Feature markers in parity-check.sh Layer 3 are hardcoded, not mechanically extracted (ARCH P1-1 partial violation)

**File:** `.tad/evidence/spikes/codex-parity/parity-check.sh`, line 164
**Severity:** P1 (must fix in P3)

The handoff (AC3, ARCH P1-1) mandates: "marker list is extracted from the source argument at run time, never a hardcoded list." The parity-criterion.md (Layer 3) also states: "Mechanically extracted from the CURRENT source at gate time."

In the implementation, `task_type` values ARE partially extracted from the source at runtime (lines 148-149, correct direction). However, `feature_markers` on line 164 is a hardcoded string:

```bash
feature_markers="deliverable research_complexity step4_5"
```

This is NOT extracted from the source. If a future protocol addition introduces a new feature marker (e.g., `agent_teams`, `vector_retrieval`), the parity-check will not know to require it in the Codex edition -- the exact "future drift passes silently" failure mode ARCH P1-1 exists to prevent.

Additionally, line 149's task_type extraction uses a hardcoded enum filter (`code|yaml|research|e2e|mixed|deliverable`) that would drop new values not in this list.

**Mitigation:** The handoff says "Phase 1 needs a working, discriminating first cut" and "Phase 3 hardens." The current hardcoded list IS correct for v2.20.0 and the check DOES discriminate on today's content. Acceptable for P1 prototype.

**Action for P3:** Replace `feature_markers` with mechanical extraction from the source SKILL or from a maintained list in `portable-rules.md`. Remove the hardcoded enum filter from line 149 or derive it from source validation blocks.

---

### P1-2: Regen drops `honest_partial_protocol` references (Preserve-NEVER-Delete gap, undetected by parity-check)

**File:** `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md`
**Severity:** P1 (regen quality gap + parity-check blind spot)

**Evidence:**
- `grep -c 'honest_partial' <regen>` = **0**. Source has 4 occurrences (lines 3390, 3432, 3496, 3521 -- circuit-breaker fallback instructions in expert-review protocols: "if second attempt also fails verify -> honest_partial, pause for human").
- `grep -c 'Ralph' <regen>` = **0**. Source has 3 occurrences (lines 58, 5678, 5745 -- cross-references to Blake's Ralph Loop).

`portable-rules.md` Preserve-NEVER-Delete list explicitly names:
- "honest_partial_protocol reference"
- "Ralph Loop protocol logic references (Layer 1 + Layer 2)"

**Why the parity-check misses this:** `honest_partial_protocol` is in the NESTED_IGNORE list (parity-check.sh line 41), meaning Layer 1 skips it. Neither `honest_partial` nor `Ralph Loop` is a Layer 3 feature marker. There is no Layer 2 named-marker guard for `honest_partial` (unlike `anti_rationalization_registry` and `forbidden_implementations` which are explicitly checked).

**Impact:** The regen's expert-review error-handling protocols lack the `honest_partial` escalation path. The circuit-breaker pattern ("if re-spawn also fails P0 -> honest_partial, pause for human") is missing, meaning the Codex edition's expert-review flow has no documented fallback for repeated failures.

The Ralph Loop cross-references are lower severity (line 58 says "config-execution (Ralph Loop, failure learning) is Blake-specific"), but their absence removes context that helps a Codex user understand the Alex-Blake protocol relationship.

**Action for P3:**
1. Add `honest_partial` as a Layer 2 named-marker guard in parity-check.sh (alongside `anti_rationalization_registry` and `forbidden_implementations`).
2. Re-run the regen procedure with explicit instruction to preserve honest_partial circuit-breaker references.
3. Consider adding Ralph Loop cross-references to the Layer 2 guards if they are deemed load-bearing for Alex (lower priority -- they are explanatory, not operational in Alex context).

---

### P2-1: parity-check.sh Layer 1 regex may over-match nested protocol keys

**File:** `.tad/evidence/spikes/codex-parity/parity-check.sh`, line 54
**Severity:** P2 (suggestion)

The extraction `grep -oE '[a-z_]+_protocol:' "$CLAUDE_SKILL"` matches ALL `*_protocol:` patterns including nested/inline ones. The NESTED_IGNORE list (lines 37-41) correctly filters these in the loop. However, if a future source adds a new nested `*_protocol:` key not in the list, it would be treated as must-cover.

For P3, consider extracting only unindented (column-0) keys:
```bash
source_protocols=$(grep -oE '^[a-z_]+_protocol:' "$CLAUDE_SKILL" | sed 's/:$//' | LC_ALL=C sort -u)
```
This would eliminate the NESTED_IGNORE list entirely.

---

### P2-2: Constraint count cosmetic inconsistency in spike report

**Observation:** The spike report "Regen Guard Checks" table says `MUST/MANDATORY/VIOLATION = 59`, but the parity-check run pasted in the same report says `constraints=57`. Direct verification gives 59. Likely caused by the parity-check being run before a minor regen edit. Cosmetic only -- both values exceed the floor (13) by >4x.

---

## Positive Observations

1. **Anti-theater discrimination is genuine and strong.** The parity-check correctly fails the live drifted edition on 2 of 3 layers with specific named failures (8 missing sections + 4 absent markers). This is not a rubber-stamp gate.

2. **The regen successfully closes the drift.** All 3 missing feature tracks (deliverable, research_complexity, step4_5) are present with substantive protocol content -- verified by spot-checking `step0_6_deliverable_classification` (line 862), `research_complexity` tier persistence (line 412), and `step4_5` block content (line 210).

3. **AC8 handled with integrity.** Honest UNPROVEN, not a fake PASS. Clear documentation of why + explicit P2 carry-forward.

4. **Shell portability is clean.** No `grep -P`, `LC_ALL=C` on sort, `|| true` guards, proper `set -euo pipefail`.

5. **Portable-rules.md update is well-structured.** Expected-Absent-in-Codex Allowlist with per-protocol rationale. Exact match between portable-rules.md and parity-check.sh allowlists.

6. **Exit-code contract verified end-to-end.** exit 0 (parity), exit 1 (drift), exit 2 (no args + file not found) all tested.

7. **Regen content quality.** The 49KB regen is substantive (not keyword-stuffed). Protocol steps, numbered instructions, YAML keys all preserved with only tool-reference replacements. AskUserQuestion sites correctly replaced with "List options as numbered text" alternatives.

---

## Verdict

**CONDITIONAL PASS** -- all 8 ACs are satisfied. Two P1 findings for P3 hardening:

- **P1-1:** Layer 3 feature markers are hardcoded, not mechanically extracted from source (ARCH P1-1 partial violation). Acceptable for P1 prototype; MUST be fixed in P3 release gate.
- **P1-2:** Regen drops `honest_partial_protocol` circuit-breaker references (4 source occurrences -> 0), which the parity-check cannot detect because `honest_partial_protocol` is in the nested-ignore list and has no Layer 2 named-marker guard. Should be fixed in P3 by adding a Layer 2 guard.

Neither P1 blocks the spike's primary deliverable (B-viability verdict + discrimination proof + reusable procedure).
