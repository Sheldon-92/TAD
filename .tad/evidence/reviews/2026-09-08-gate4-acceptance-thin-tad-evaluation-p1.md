# Gate 4 Acceptance — TAD 精简实验 P1 (thin-tad-evaluation-p1)

**Date:** 2026-09-08  
**Owner:** Alex (Solution Lead)  
**Task ID:** TASK-20260907-thin-tad-evaluation-p1  
**Epic:** `.tad/active/epics/EPIC-20260907-thin-tad-evaluation.md` (Phase 1/3)  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260907-thin-tad-evaluation-p1.md`  
**Completion:** `.tad/active/handoffs/COMPLETION-20260907-thin-tad-evaluation-p1.md`  
**Implementation Commit:** `fc2c07ce99d5255f5e5e0378f19f375565e302d7` (5 files under `experiments/thin-tad-pilot/`)  
**Task Type:** mixed (offline experiment package + tools) · **e2e_required:** no · **research_required:** no  
**Verdict:** **PASS** (Accepted at Phase 1 boundary)

---

## 1. Prerequisite Checks

| Check | Status | Evidence / Notes |
|---|---|---|
| Gate 3 Passed | ✅ PASS | Completion report frontmatter `gate3_verdict: PASS` & body §Gate 3 表全绿 |
| Gate 3 Evidence | ✅ Exists | `.tad/evidence/reviews/blake/thin-tad-evaluation-p1/{spec-review.md,code-review.md}` |
| Implementation committed | ✅ Yes | Commit `fc2c07ce` (5 files staged from empty index with explicit allowlist: `README.md`, `pilot.mjs`, `pilot.test.mjs`, `testdata/mini-date.json`, `testdata/mini-filter-error.json`) |
| Private bundle excluded | ✅ Yes | `.tad/evidence/experiments/thin-tad-pilot/` git-ignored, no force-add, no sensitive source content in git |

---

## 2. Functional Acceptance — AC Verification Recheck

All AC evidence from `.tad/evidence/acceptance-tests/thin-tad-evaluation-p1/` reviewed against handoff §9.1:

| AC# | Description | Expected | Actual | Status |
|---|---|---|---|---|
| AC0 | Node & Git runtime base | Node runnable, 40-char SHA | `v20.19.2`, `7c1eb5a8d4324f30cb4d3e20d0d659bc727a3533` | ✅ PASS |
| AC1 | Syntax & unit tests | `node --check` + `node --test` pass | Exit 0; 32/32 tests pass (syntax check clean, CLI negatives included) | ✅ PASS |
| AC2 | 6 sources verified | 6 explicit sources verified, no symlink | Exit 0; 6/6 path/mode/SHA256 match frozen baseline | ✅ PASS |
| AC3 | 12 case packages | 12 cases (6 H / 6 V), no empty/placeholder | Exit 0; 12 instances valid, H/V paired, schemas intact | ✅ PASS |
| AC4 | Baseline/candidate freeze | Fixed SHA blob/mode match; closure approved | Exit 0; 13 files at fixed SHA verified; applicable closure approved | ✅ PASS |
| AC5 | Export package leak check | Allowlist match; no answer/oracle leak | Exit 0; 32 paths match allowlist; leak/path traversal negatives reject | ✅ PASS |
| AC6 | Bidirectional controls | Correct accepted (UNSCORED+rubric for evidence), error rejected | Exit 0; 12 correct accept, 12 error reject with critical failures | ✅ PASS |
| AC7 | Offline pipeline rehearsal | 12×2 offline dry-run stable across 2 passes | Exit 0; 12×2×2 stable projection; H/V split; no side-effects | ✅ PASS |
| AC8 | Cost & accounting logic | Independent manual match; null for 0-success | Exit 0; known sample recomputed, no zero-fill, partial flag set | ✅ PASS |
| AC9 | Scope & privacy | Only §7 tool staged/committed; untracked attributed | Exit 0; staged ⊆ tool allowlist; private data untracked/git-ignored | ✅ PASS |

---

## 3. Layer 2 Independent Reviews

| Review | Initial Verdict | Delta Recheck (2026-09-08) | Final Verdict |
|---|---|---|---|
| Spec / Experiment Semantics (`spec-review.md`) | CONDITIONAL (missing CLI negative tests in suite + latent binding `&&` bug) | Fixed: binding `if (art.case_id !== id \|\| art.family !== c.family)` + suite negative tests for sources/arms/scope in `pilot.test.mjs` (32/32 pass) | ✅ PASS |
| Code / Execution Safety (`code-review.md`) | CONDITIONAL PASS (binding `&&`, git prefix boundary, vacuous execSync regex) | Fixed: binding `\|\|`, exact/prefix boundary enforcement in `GIT_PATH_PREFIXES`, occurrence-scoped regex for execSync. Unconditional PASS | ✅ PASS |

---

## 4. Friction Status Review (Gate 4)

| # | Friction Point | Status | Disposition & Alex Review |
|---|---|---|---|
| 1 | 4 external sources harness read-refused | DEGRADED_WITH_APPROVAL | Approved in handoff §6.1/§8; reconstruction ratio 6/6, assumptions explicit, no fabricated text |
| 2 | Working tree dirty from other terminals | NOT_APPLICABLE_WITH_REASON | Attributed by actor via `verify-scope`; tool commit `fc2c07ce` exactly 5 files |
| 3 | Node v20.19.2 vs design v24.7.0 | EQUIVALENT_SUBSTITUTE | Tool uses Node stdlib built-in test runner supported on both; 32/32 tests pass |
| 4 | Live review human absent | EQUIVALENT_SUBSTITUTE | 6 independent fresh subagent sessions (V author, re-derivation, adjudication, scope, L2 dual review); no self-review |
| 5 | /tmp script usage in early step | READY | Remediated, all evidence written directly to declared evidence directories |

Zero unresolved `BLOCKED` rows. All degradations/substitutions substantiated with appropriate evidence.

---

## 5. Scope Boundary & Honest Readiness

Per `readiness.md`:
- **Validated**: 12 offline task packages, frozen baseline/candidate text, independent oracles, bidirectional controls, offline pipeline dry-run, accounting logic, scope confinement.
- **Explicitly NOT claimed**:
  1. Real task-solving ability (no LLM run).
  2. Arm loading fidelity (no agent harness loaded the rules).
  3. OS/container sandbox isolation (same-shell blind test not proven).
  4. Model behavior, real costs, token counts, latency (synthetic/null only).
  5. Statistical win/lose conclusions (12 cases cannot establish general superiority).

---

## 6. Knowledge Assessment (Gate 4)

| Question | Answer | Evidence / Rationale |
|---|---|---|
| Blake Gate 3 journal verified? | N/A | Blake reported No new discoveries (instantiated existing AC-Verification and negative control patterns, format drift caught and normalized). Verified reasonable. |
| New Gate 4 discoveries? | ❌ No | P1 verification confirms existing architectural disciplines: independent oracle re-derivation, bidirectional control validation, and fail-closed harness boundaries. No new global principles required. |
| Summary | — | P1 offline validation complete; existing principles held without drift. |

---

## 7. Acceptance Decision & Phase 2 Stop Boundary

- **Gate 4 Verdict:** **PASS**
- **Action:** Phase 1 (offline task package and validation chain) is formally accepted.
- **Phase 2 Boundary:** **HARD STOP.** Phase 2 involves model selection, live harness execution, real token spend, and isolation verification. It requires a separate Human Authorization decision and MUST NOT be started autonomously.
