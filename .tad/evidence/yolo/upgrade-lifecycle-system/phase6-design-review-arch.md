# Phase 6 Design Review — Architecture

**Reviewer**: architecture (backend systems, verification pipeline design)
**Date**: 2026-06-10
**Handoff**: HANDOFF-20260610-acceptance-phase6.md
**Focus**: Does the verification tooling prove E2E correctness? Is the gate exercise genuine? Does evidence support future audits?

---

## Verdict: PASS with 0 P0, 3 P1, 4 P2

The design is sound. The two-script approach (acceptance + gate-exercise) is architecturally correct: it separates post-deployment verification from gate-capability proof, both operating as stateless read-only verifiers. The gate exercise in a temp dir is a genuine falsification test (not theater). However, three P1 issues reduce the real-world confidence the system can actually deliver on its E2E claim.

---

## P0 Issues (blocking)

None.

---

## P1 Issues (must fix before implementation)

### P1-1: Epic SC-3 "chain upgrade fixture" dropped without trace

**Evidence**: Phase 6 grounding (L17) explicitly requires: "旧 tag (v2.19.0) → current 链式升级 fixture PASS". The grounding (L25) also proposes "Chain upgrade fixture: extend run-fixtures.sh with a v2.19.0→current chain test". The handoff design drops this entirely — neither upgrade-acceptance.sh nor gate-exercise.sh verifies multi-hop chain correctness on the REAL 12-manifest chain. The existing F5 fixture tests a synthetic 2-hop chain (v0.1.0→v0.3.0), which is insufficient to prove the 12 historical manifests actually compose correctly.

**Risk**: The 12 historical manifests (v2.19.0 through v2.27.0) were batch-generated in Phase 5. If any manifest references a file that was already deleted by an earlier manifest in the chain, the engine could fail mid-chain on real projects. F5 proves 2-hop logic works; nothing proves the 12-manifest chain is internally consistent.

**Fix**: Add FR6 or extend FR3: run `migration-engine.sh --from 2.19.0 --to 2.27.0 --target <synthetic-old-install> --dry-run` in the acceptance evidence collection (Phase 3). This is the single highest-value verification missing — it tests the real artifact chain, not a synthetic 2-hop toy.

### P1-2: gate-exercise.sh tests only DELETE detection, not RENAME detection

**Evidence**: Section 4.3 step 5 says "Remove the file, bump to v0.2.0, commit and tag -- NO manifest." This exercises only the UNMANIFESTED DELETE path (release-verify.sh L445). The migration gate also checks UNMANIFESTED RENAME (L461-466). There is a POSSIBLE RENAME heuristic (L428-442) that fires on basename-match — that logic path is completely unexercised by this design.

**Risk**: If the rename detection has a regression (e.g., the basename-match grep in a pipe/subshell context on macOS), the gate would silently pass on unmanifested renames. This violates the "gate must be able to FAIL to prove it is not theater" principle for ALL gate paths, not just one.

**Fix**: Add a second scenario in gate-exercise.sh: rename a file (git mv) without manifest coverage, assert the output contains "POSSIBLE RENAME" or "UNMANIFESTED RENAME". This is ~10 additional lines and exercises the second branch.

### P1-3: upgrade-acceptance.sh deprecation.yaml parsing assumes stable indentation

**Evidence**: Section 4.4 proposes parsing with `^      - ` (6-space indent). The actual deprecation.yaml (read at L5-50) uses exactly this format TODAY, but YAML permits 2/4/6/8 space indent equivalently. If a future editor reformats the file (e.g., `yamllint --fix`), the parser silently returns zero paths and the check vacuously passes (PASS with nothing checked = validation theater).

**Risk**: A vacuous pass on zero extracted paths is indistinguishable from "no deprecated files remain" — the check becomes dead weight without anyone noticing.

**Fix**: After the awk extraction, assert the path count is > 0 (or at minimum >= the known current count, e.g., >= 6 unique paths). If zero paths extracted, exit 2 (wiring error: "deprecation.yaml parsing returned zero paths — check format"). This transforms a silent false-negative into a loud wiring failure.

---

## P2 Issues (improve before or after implementation)

### P2-1: ZERO_TOUCH diff requires human pre-sync snapshot — no automation path

The design correctly SKIPs the ZERO_TOUCH check when `--snapshot` is not provided. But the entire value proposition of Phase 6 is "show me, not trust me." Without automation to take the snapshot before *sync runs, the most critical check (byte-identity of user dirs) depends entirely on human discipline. Consider adding a one-liner to the *sync protocol documentation: `cp -a project/.tad/active project-pre-sync/active` etc., or better, have upgrade-acceptance.sh accept `--auto-snapshot` which snapshots, calls *sync, then verifies.

### P2-2: Evidence README recommendation section is manually written — not machine-verifiable

FR5 asks for a "structured recommendation" about warn-to-hard-block. This is valuable for human decision-making but cannot be revisited automatically. Consider adding a machine-readable footer (e.g., `RECOMMENDATION_STATUS: pending | accepted | rejected`) so future automation can track whether the flip happened.

### P2-3: No negative test for upgrade-acceptance.sh ZERO_TOUCH violation

The design tests version FAIL (AC4) but never demonstrates ZERO_TOUCH FAIL (a ZERO_TOUCH dir modified during sync). Without this, the ZERO_TOUCH check could have a bug that always reports PASS, and the evidence would never reveal it. Add a test: copy the TAD repo, modify one file in `active/`, run with --snapshot pointing to the original.

### P2-4: gate-exercise.sh copies derive-sync-set.sh but not migration-engine.sh

Section 4.3 step 6 copies derive-sync-set.sh and release-verify.sh. The migration gate in release-verify.sh (L365) calls `bash "$DERIVE" --zero-touch "$REPO"`. This works. But if release-verify.sh's migration mode ever adds a secondary call to migration-engine.sh (plausible future), the gate exercise would break silently. Documenting the exact dependency set and asserting `[ -f "$DERIVE" ]` in the gate exercise (already done by release-verify.sh L108) is sufficient — but note it for maintenance.

---

## Strengths

1. **Genuine falsification**: gate-exercise.sh creates a REAL git state with an unmanifested delete and asserts exit 1. This is not a mock — it exercises the actual release-verify.sh code path including tag detection, ZERO_TOUCH filtering, and manifest cross-reference. The gate CAN fail, which proves it CAN block.

2. **Stateless verifiers**: Both scripts are pure functions of their inputs (target dir + reference data). No persistent state, no side effects on the real repo. This means they can be re-run indefinitely as regression checks.

3. **Evidence chain completeness**: The evidence directory captures raw output (not summarized), so a future auditor can verify the actual assertions that fired, not just a PASS/FAIL badge.

4. **Separation of concerns**: The handoff correctly refuses to include the 14-project *sync in Blake's scope (that requires Alex + human), while still providing the verification SCRIPT that makes the sync auditable.

5. **Exit code discipline**: 0/1/2 semantics match the existing release-verify.sh contract. Consumers of these scripts can trust the same convention.

---

## Architectural Assessment: Is This Validation Theater?

**No — but it is narrower than the grounding promises.**

The gate exercise is genuine: it creates a real git state, runs the real gate code, and asserts a real exit 1. This is falsifiable (if someone breaks the gate, the exercise fails). The acceptance script verifies 4 orthogonal properties of a synced project.

However, the grounding document (phase6-grounding.md) lists 5 verification requirements:
1. Fixture suite all PASS -- covered (FR3, AC14)
2. 14/14 project diff -rq -- correctly deferred to human (script provided)
3. Old tag chain upgrade -- DROPPED (P1-1)
4. Gate interception exercise -- covered (FR2, AC11-12)
5. Knowledge Assessment -- out of Blake's scope (Gate 4)

Item 3 is the gap. Without proving the real 12-manifest chain composes correctly, the system's claim of "any supported old version can upgrade to current" rests on the F5 synthetic 2-hop fixture alone. This is the difference between "the mechanism works in principle" and "the mechanism works on OUR data."

---

## Summary Table

| ID | Severity | Category | One-line |
|----|----------|----------|----------|
| P1-1 | P1 | Coverage gap | Epic SC-3 chain-upgrade fixture dropped from design |
| P1-2 | P1 | Coverage gap | Gate exercise tests DELETE only, not RENAME |
| P1-3 | P1 | Silent failure | deprecation.yaml parser can vacuously pass on zero paths |
| P2-1 | P2 | Automation | ZERO_TOUCH snapshot requires human discipline |
| P2-2 | P2 | Auditability | Recommendation section not machine-verifiable |
| P2-3 | P2 | Coverage gap | No negative test for ZERO_TOUCH violation detection |
| P2-4 | P2 | Maintainability | gate-exercise dependency set may drift |

---

## Recommendation

Address P1-1 through P1-3 before Blake starts implementation. P1-1 is the most impactful — it adds ~15 lines to the evidence collection phase but closes the biggest confidence gap in the Epic. P1-2 is ~10 lines of additional gate exercise. P1-3 is a 3-line guard (count check + exit 2).

After these fixes, the Phase 6 design delivers genuine end-to-end verification evidence that supports both immediate human confidence and future audit traceability.
