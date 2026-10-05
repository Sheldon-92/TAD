# Gate 4 Acceptance — YOLO2 Phase 2, Round 2

**Task:** `TASK-20260827-YOLO2-P2-COMPLETION`  
**Candidate:** `a199030bd44d1a62a2b8b43ce629b02af5217095`  
**Pinned main:** `28c0f9af83c23945038475ec4723a7c43a8acfbf`  
**Alex verdict:** **FAIL — return to Alex/Blake contract repair**  
**Date:** 2026-08-31

## Prerequisite

| Check | Status | Evidence |
|---|---|---|
| Gate-3 reports | Partial | Blake Group-0/code/test reports bind the submitted tuple and claim PASS. |
| Completion authority | FAIL | Candidate and main bodies still state `HONEST_PARTIAL`, 10/11, and Layer 2 blocked. |
| Gate-3 verdict authority | FAIL | Candidate and main still declare old HEAD `e78f0360...` and the prior AC-B failure. |
| Pinned verifier | FALSE PASS | Returns PASS and is now read-only, but does not recompute the authority claims it accepts. |

Gate 3 is not accepted as a valid Gate-4 prerequisite.

## Quality evidence

| Evidence | Required | Result | File |
|---|---:|---|---|
| Code review | Yes | FAIL — P0=0, P1=3 | `.tad/evidence/reviews/2026-08-31-code-review-yolo2-phase2-r2.md` |
| Security review | Yes | FAIL — P0=0, P1=3 | `.tad/evidence/reviews/2026-08-31-security-review-yolo2-phase2-r2.md` |
| Performance review | Yes | FAIL — P0=0, P1=2, P2=1 | `.tad/evidence/reviews/2026-08-31-performance-review-yolo2-phase2-r2.md` |
| UX review | No | N/A — no UI surface | — |

## Verified repairs from Round 1

- Dataset index and all five task inputs are candidate/main Git blobs; mutable dataset fallback
  is removed.
- Pinned verifier is read-only: the exact command returns without changing any of the five
  carrier hashes, and the candidate worktree remains clean.
- The implemented `3000000 / 600000 / 600000` budget exactly matches the human-signed
  DR-20260831 and is accepted for Phase 2.
- Five product blobs are candidate/main equivalent; the submitted scope-manifest and
  main-equivalence file hashes match the user's tuple.

## Remaining blockers

1. **Stale authority accepted as PASS.** Completion and Gate-3 verdict contradict the submitted
   tuple. The verifier checks a title/token and trusts self-reported equivalence fields instead of
   extracting candidate SHA, PASS disposition, AC-B status, and canonical content from both Git
   objects.
2. **Dogfood reuse proof is incomplete.** The canonical manifest/verifier binds mechanism and
   dataset blobs but not the exact signed budget, approval semantics, CLI/judge/model/settings,
   final raw run namespace, or durable evidence tree required by DR-20260831.
3. **Unauthorized candidate scope.** Generic archive/brain-index/judge/context/Framework Health
   paths were added to the implementation allowlist even though they are not in Handoff §3 or an
   exact signed exclusion. The candidate therefore contains unrelated work.
4. **Fixed exclusion is hard-coded, not recomputed.** Real `git diff --binary` SHA-256 for
   `f967276f...` is `3abdcc69...`, while the signed DR says `70de6e...`; the verifier bypasses the
   mismatch by returning the constant.
5. **Scope-proof carriers are ignored mutable files.** Read-only behavior in one replay is an
   improvement, but `git status` cannot protect ignored carriers. They must be committed or bound
   as immutable content-addressed inputs with pre/post digest enforcement.

## Acceptance checks

| Item | Status | Note |
|---|---|---|
| Functional acceptance | FAIL | Scope and reuse integrity ACs are not established. |
| Quality evidence complete | FAIL | All three mandatory Gate-4 reviewers found P1 blockers. |
| Subagent issues resolved | FAIL | Round-2 P1 findings remain open. |
| Decision compliance | FAIL | DR-20260830 recomputation and DR-20260831 reuse conditions are not implemented. |

## Knowledge Assessment

| Question | Answer | Evidence |
|---|---|---|
| Blake Gate-3 journal verified? | Yes | `.tad/evidence/journal/yolo2-phase2-completion-2026-08-29.md` exists. |
| New Gate-4 discovery? | Yes | A self-consistent equivalence JSON can still be a false proof when the verifier does not recompute its claims from the authority Git objects. |
| Distilled to project knowledge? | Deferred | Gate 4 failed and the tuple must remain frozen; distill after the corrected candidate is accepted. |

## Required recovery

This round cannot return solely to Blake: two contract-level issues require Alex/human authority.

1. Alex must correct the signed fixed-exclusion provenance hash and explicitly authorize exact
   exclusions for legitimate non-YOLO commits (`c5f0114b`, `896f63df`, `5dac5ed0`) instead of
   widening the path allowlist.
2. Blake then rebuilds a Phase-2-only candidate, makes scope carriers immutable, implements exact
   authority-carrier recomputation, and implements the complete DR-20260831 reuse manifest.
3. Regenerate Completion/Gate-3 verdict first, then regenerate the tuple and all Group-0/Layer-2
   reports. Stop at a new Gate-3 PASS for another Alex Gate 4.

Do not archive Phase 2.
