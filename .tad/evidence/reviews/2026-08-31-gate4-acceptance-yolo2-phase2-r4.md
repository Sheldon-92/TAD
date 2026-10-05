# Gate 4 Acceptance — YOLO2 Phase 2, Round 4

**Task:** `TASK-20260827-YOLO2-P2-COMPLETION`  
**Candidate:** `7de87feae02e0362e7fc405b9642def4cc145211`  
**Pinned main:** `7365a636b983ec55346c29eab266f8a8ab535206`  
**External attestation SHA-256:** `7e55ac67762d1b12933b6ed7945df9ea262215b0efaa05ce9c488da3bfc7eaf4`  
**Alex verdict:** **FAIL — R4 topology accepted, enforcement incomplete**  
**Date:** 2026-08-31

## Decision

The R4 one-way attestation design resolves the prior self-reference defect. The exact pinned
command verifies the external attestation digest and returns `RESULT=PASS`/0 without rewriting the
five scope carriers. Gate 4 nevertheless cannot accept the tuple because material fields declared
by the attestation and dogfood manifest are not consumed by the verifier.

This is a bounded finalization defect. No new architecture amendment, budget decision, or dogfood
run is required if the existing raw evidence proves the declared identity.

## Independent reviews

| Review | Result | Report |
|---|---|---|
| Code | FAIL — P0=0, P1=3 | `.tad/evidence/reviews/2026-08-31-code-review-yolo2-phase2-r4.md` |
| Security/evidence integrity | FAIL — P0=0, P1=4 | `.tad/evidence/reviews/2026-08-31-security-review-yolo2-phase2-r4.md` |
| Performance/budget | FAIL — P0=0, P1=2 | `.tad/evidence/reviews/2026-08-31-performance-review-yolo2-phase2-r4.md` |
| UX | N/A | No UI surface. |

## Remaining P1 blockers

1. **Attestation enforcement is incomplete.** The verifier validates base/candidate/main, the five
   `carriers`, and Gate3, but never reads `reports`, `evidence_bundle_tree_sha`, or
   `product_tree_sha`. The candidate worktree report digests differ from the attested values and
   the exact command still passes. Gate3 also embeds stale attestation `c83b6aa9...` and bundle
   `f2af5b3b...` values although the external roots are `7e55ac67...` and `7f1e1d03...`.
2. **Dogfood exact reuse is declared but not proved.** The manifest has no numeric budget tuple,
   judge/model/settings, raw-run identity, or durable-tree identity. The verifier computes an
   unused policy hash, checks only harness field presence, and does not compare a raw/durable run.
3. **R2 fixtures do not exercise the intended temporary repository.** `invoke()` launches the
   parent repository script, whose `REPO_ROOT` remains the parent repository. The exact-exclusion
   loop never invokes the verifier, and other fixtures accept any non-PASS result rather than the
   required targeted `ERROR` behavior.

## Verified positives

- Candidate/main and the externally supplied attestation SHA form an acyclic trust topology.
- The attestation file digest exactly equals `7e55ac67...`; all five carrier digests and Gate3
  digest match the values it records.
- Candidate parent/base and product tree are correct.
- All four R2 exclusion provenance values independently recompute correctly; generic unrelated
  scope allowances are removed.
- The Phase-2 `3000000 / 600000 / 600000` authorization remains valid.
- The exact pinned verifier run completed successfully and did not mutate the inspected carriers.

## One bounded recovery pass

1. Remove the redundant bundle-tree claim, or actually verify a durable reachable bundle. The
   simplest accepted R4 form is the explicit attestation digest maps: validate every carrier,
   Gate3, and all three reports, plus compare `product_tree_sha` to the candidate Git tree.
2. Remove the `Attestation` and `Evidence Bundle Tree` lines from Gate3. Gate3 must contain only the
   stable tuple/candidate/PASS facts; update its attested digest once.
3. Add the exact policy numbers, generator/judge CLI and model/settings, canonicalization, raw
   `a6fe746c...` identity, raw input/tree digest, and durable evidence-tree digest to the dogfood
   manifest. Recompute and compare every field. Reuse the run if equal; rerun only on mismatch.
4. Make fixture invocation run the copied verifier against the temporary repository and assert
   the specific exit/result for every signed R2 case. Do not count missing-attestation or wrong
   repository errors as an exclusion-test pass.
5. Produce one final candidate/main, then generate Gate3, reports, and attestation exactly once.
   Stop at Gate 3 PASS. No further binding layer is requested.

## Knowledge Assessment

R4 adds no new project principle: it applies the already recorded rule that an external trust root
must be independently consumed, not merely described. No project-knowledge update is made while
Gate 4 is red.

**Archive decision:** prohibited until a later Alex Gate 4 returns PASS.
