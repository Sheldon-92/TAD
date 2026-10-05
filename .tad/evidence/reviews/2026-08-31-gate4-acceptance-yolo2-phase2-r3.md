# Gate 4 Acceptance — YOLO2 Phase 2, Round 3

**Task:** `TASK-20260827-YOLO2-P2-COMPLETION`  
**Base:** `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7`  
**Candidate:** `b47b5b2fed13d6f1c26e42a877ae9f235820f121`  
**Pinned main:** `c992769204f0072b982d66393d9588467fd3699d`  
**Alex verdict:** **FAIL — Gate 3 prerequisite is not an immutable, self-contained proof**  
**Date:** 2026-08-31

## Executive decision

Gate 4 does not accept this tuple. The exact pinned command exits 0 and prints `RESULT=PASS`,
but it does so after Git reports that the candidate has no `gate3-verdict.md` blob. It then reads
mutable working-tree evidence. The supplied R3 carriers and Blake reports are also working-tree
modifications whose Git blobs contain an older tuple.

This is an evidence-integrity failure, not a finding that the Phase-2 product behavior is broken.
Do not archive Phase 2 and do not promote YOLO2 Phase 2 to accepted/default-on status.

## Gate-3 prerequisite

| Check | Result | Independent evidence |
|---|---|---|
| Candidate Git authority | FAIL | `b47b5b2f...` has no Git blob for `phase2/gate3-verdict.md`. |
| Main Git authority | FAIL | `c9927692...` Gate-3 blob names main `d48d2dd7...` and candidate `9ad3cd80...`. |
| Completion authority | FAIL | Candidate/main Git blob SHA-256 is `9f586283...`; the submitted R3 Completion is only a modified worktree file (`33e13960...`). |
| Five scope carriers | FAIL | Committed scope manifest/main-equivalence/log are `5c9c84b7...` / `a5d5d17f...` / `07292272...`, not submitted `eb773a75...` / `2fef865e...` / `88e7ed5c...`. |
| Blake Group-0/Layer-2 binding | FAIL | Submitted report digests exist only in modified worktree files; candidate/main Git blobs have older digests and tuples. |
| Exact pinned verifier | FALSE PASS | Emits Git fatal for the missing candidate verdict, then falls back to filesystem content and returns PASS/0. |

The five working carrier digests were unchanged before/after the replay, but pre/post equality does
not make a mutable, unpinned input authoritative. The verifier must also bind every input to an
external immutable trust root and reject missing, stale, dirty, or substituted authority.

## Independent Gate-4 reviews

| Review | Result | Material findings |
|---|---|---|
| Code | FAIL — P0=0, P1=3 | Mutable/stale Gate-3 binding; incomplete dogfood identity validation; R2 fixtures do not invoke the production verifier. |
| Security/evidence integrity | FAIL — P0=0, P1=4 | False-PASS authority fallback; mutable carriers and verification-time generation; incomplete dogfood binding; invalid R2 negative fixtures. |
| Performance/budget | FAIL — P0=0, P1=3 | Mutable Gate-3 carrier; incomplete reuse identity; R2 selector mismatch. Budget value and bounded runtime controls themselves are valid. |
| UX | N/A | No user-interface surface in this phase. |

Detailed reports:

- `.tad/evidence/reviews/2026-08-31-code-review-yolo2-phase2-r3.md`
- `.tad/evidence/reviews/2026-08-31-security-review-yolo2-phase2-r3.md`
- `.tad/evidence/reviews/2026-08-31-performance-review-yolo2-phase2-r3.md`

## P1 blockers

1. **The verifier trusts mutable evidence instead of the frozen Git objects.**
   `verifyEquivalence()` falls back to `fs.readFileSync` when the candidate Gate-3 blob is missing,
   and its marker check only proves that a title/token exists. The carrier loop explicitly permits
   untracked/dirty evidence. This directly contradicts the submitted claim “dirty → ERROR”.
2. **Dogfood reuse is not verified against the complete signed identity.**
   The implementation checks three mechanism blobs and dataset/task blobs, but not the signed
   approval, exact `3000000 / 600000 / 600000` policy, generator/judge/CLI/model/settings,
   canonicalization, raw `a6fe746c...` run identity, or durable evidence tree.
3. **The R2 fixtures are not production-verifier tests.**
   `runScopeFixtures()` defines `invoke()` but never calls it. The tests compare local predicates
   or constants; the main-drift fixture is a no-op. They do not establish the R2 required
   tamper/unknown-exclusion/anti-hardcode failure behavior.
4. **The R2 authority selector is internally inconsistent.**
   The Handoff contains `scope_proof_amendment_r2`, but the verifier still validates the old
   `scope_proof_amendment` selector and DR-20260830 value. The working `main-equivalence.json`
   declares R2 as expected while recording the old value as candidate/main values.

## Verified repairs and positives

- All four R2 exclusions independently recompute to the signed parent, binary-diff SHA-256 and
  stable patch-id values. The corrected `f967276f...` digest is `3abdcc69...`.
- The generic unrelated-path allowances rejected in R2 have been removed.
- Candidate parent is the frozen base and its tree is
  `87d21bd4d8e403b29d3bfd879e867f81e9a6d68a`; the Phase-2 scope topology is correct.
- The `3000000 / 600000 / 600000` Phase-2 budget is human-authorized, and bounded runtime controls
  are present. This Gate-4 failure does not revoke that amendment.
- The exact verifier replay took only seconds and did not modify the five working carriers.

## Required recovery

1. Separate **product refs** from a **post-freeze attestation** to avoid an impossible self-hash
   loop. Freeze candidate and product-main first; then create an immutable detached attestation
   that names those refs and the carrier digests. The verifier must receive the attestation ref or
   expected SHA values explicitly. It must not discover its trust root from the same mutable files
   it is validating.
2. Remove all filesystem fallback and all generation/write branches from pinned verification.
   Missing Git/attestation authority, missing carrier, dirty tracked carrier, digest mismatch, or
   pre/post change must return `RESULT=ERROR`/2.
3. Bind and recompute every dogfood reuse field against an immutable raw-run manifest and durable
   evidence tree. Reuse `a6fe746c...` only if the full canonical identity is equal; otherwise use a
   new namespace. Do not rerun dogfood merely because this Gate 4 failed.
4. Replace the nine simplified fixtures with real temporary repositories that invoke the same
   production verifier and assert the R2 positive and negative cases, including constant
   substitution and an unknown fifth exclusion.
5. Validate `frontmatter.scope_proof_amendment_r2` against the signed R2 decision. Regenerate the
   attestation, Completion/Gate-3 authority, Group-0, code-reviewer and test-runner bindings only
   after the final refs and full reuse identity are frozen. Stop at a new Gate-3 PASS.

## Knowledge Assessment

| Question | Answer | Evidence |
|---|---|---|
| Blake Gate-3 journal verified? | Yes | `.tad/evidence/journal/yolo2-phase2-completion-2026-08-29.md` exists. |
| New reusable discovery? | No new principle | R3 confirms the already-signed R2 requirement that evidence must be immutable and independently recomputed. |
| Project-knowledge update required now? | No | Gate 4 failed; no tuple or knowledge authority was changed. |

**Archive decision:** prohibited until a later Alex Gate 4 returns PASS and the human accepts it.
