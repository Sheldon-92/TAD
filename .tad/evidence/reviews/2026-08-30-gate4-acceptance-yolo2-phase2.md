# Gate 4 Acceptance — YOLO2 Phase 2

**Task:** `TASK-20260827-YOLO2-P2-COMPLETION`  
**Candidate:** `e78f0360dbcb2a71a0161ac9adc08480488c73fe`  
**Pinned main:** `06a535320b98f6469b4afbb87914fd9092d36872`  
**Alex verdict:** **FAIL — return to Blake**  
**Date:** 2026-08-30

## Prerequisite

| Check | Status | Evidence |
|---|---|---|
| Gate 3 marker | Partial | Completion frontmatter says `pass`, but its body still says `HONEST_PARTIAL`, Phase-1 `10/11`, and Layer 2 blocked. |
| Gate 3 verdict carrier | Fail | `gate3-verdict.md` names candidate `e78f0360...` but still records Phase-1 failure and blocked Group-0/Layer 2. |
| Pinned verifier | Fail closedness | The command returns `RESULT=PASS`, but first reports that `pairs/dataset-index.json` is absent from the candidate Git object and then falls back to mutable filesystem evidence. |

The Gate-3 summary is therefore not accepted as a valid Gate-4 prerequisite.

## Quality evidence

| Evidence | Required | Result | File |
|---|---:|---|---|
| Code review | Yes | FAIL — P0=0, P1=3 | `.tad/evidence/reviews/2026-08-30-code-review-yolo2-phase2.md` |
| Security review | Yes | FAIL — P0=0, P1=3 | `.tad/evidence/reviews/2026-08-30-security-review-yolo2-phase2.md` |
| Performance review | Yes | FAIL — P0=0, P1=2, P2=1 | `.tad/evidence/reviews/2026-08-30-performance-review-yolo2-phase2.md` |
| UX review | No | N/A — no UI surface | — |

## Blocking findings

1. **Mutable dogfood evidence is accepted.** The candidate and pinned main Git objects do not contain `phase2/pairs/dataset-index.json`. The verifier catches that failure, reads the mutable worktree copy, and still returns PASS. This violates DR-20260830 §2.6.
2. **Main equivalence is incomplete.** `main-equivalence.json` emits `immutable_evidence: []` and only two shared-control-plane entries. It does not bind the required exact `gate3-verdict.md` candidate SHA plus PASS result; the checker only tests that the file contains the title `Gate 3 Verdict`.
3. **Candidate replay is not self-contained.** The required final suites cannot be replayed from the candidate validation worktree because dogfood/pairs/review evidence is not candidate-bound.
4. **The verifier broadens scope authority.** Its inclusive allowlist accepts unrelated archive/brain-index/eval/context paths beyond the single human-approved fixed exclusion model.
5. **Frozen budget changed without approval.** The original handoff fixes `240000 / 48000 / 24000`; the driver and raw pair configs use `3000000 / 600000 / 600000`. Neither signed amendment authorizes that design change.
6. **Completion carriers contradict the claimed final state.** The frontmatter says PASS while the report body and friction table retain unresolved blockers.

## Acceptance checks

| Item | Status | Note |
|---|---|---|
| Functional acceptance | FAIL | The evidence-integrity and frozen-budget ACs are not satisfied. |
| Quality evidence complete | FAIL | All three mandatory Gate-4 reviewers found blocking P1 issues. |
| Subagent issues resolved | FAIL | Eight P1 findings remain open; overlapping findings are intentionally not double-counted as separate root causes. |
| Decision compliance | FAIL | Mutable evidence fallback and budget expansion deviate from signed handoff/DR authority. |

## Knowledge Assessment

| Question | Answer | Evidence |
|---|---|---|
| Blake Gate-3 journal verified? | Yes | `.tad/evidence/journal/yolo2-phase2-completion-2026-08-29.md` exists. |
| New Gate-4 discovery? | Yes | An object-pinned verifier that falls back to mutable worktree inputs can produce a false PASS; a tuple cannot compensate for an untrusted derivation path. |
| Distilled to project knowledge? | Deferred | Gate 4 is failing and `main` is pinned. Do not mutate shared project knowledge until Blake produces the corrected candidate and tuple. |

## Minimum return-to-Blake scope

1. Remove all mutable-filesystem fallback from dogfood input reconstruction. Bind every reused input to candidate/main Git blobs or immutable content-addressed raw carriers; otherwise invalidate reuse and rerun dogfood.
2. Make the pinned verifier read-only and fail if any required carrier is absent. It must not rewrite the candidate worktree during Gate 4.
3. Emit and validate non-empty immutable evidence binding plus exact `gate3-verdict.md` candidate SHA and PASS semantics, including `source_commit` fields required by DR-20260830.
4. Restore the frozen budget or obtain a new human-signed amendment that explicitly accepts the larger budget and consequences.
5. Update Completion, Friction Status, Gate-3 verdict, Group-0, and Layer-2 reports to one non-contradictory final tuple; rerun both suites and the pinned verifier from the self-contained candidate worktree.

Gate 4 must be rerun after these items are complete. Do not archive Phase 2 yet.
