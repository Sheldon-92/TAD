# YOLO2 Phase-2 — Gate 4 R3 Independent Code Review

**Reviewer:** independent code-reviewer  
**Date:** 2026-08-31  
**Verdict:** **FAIL**  
**Severity summary:** P0=0, P1=3, P2=0, LOW=0

## Reviewed frozen tuple

| Field | Value |
|---|---|
| Frozen base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` |
| Candidate | `b47b5b2fed13d6f1c26e42a877ae9f235820f121` |
| Pinned main | `c992769204f0072b982d66393d9588467fd3699d` |
| Scope manifest SHA-256 | `eb773a75c2f119cd791c05d34e2b3270d6448e1c681cb47b3cfc8384b38061fb` |
| Main-equivalence SHA-256 | `2fef865e2787d865107724690f620f521331fbbfbbc5055704fb069d40a0b0e7` |
| Product tree | `87d21bd4d8e403b29d3bfd879e867f81e9a6d68a` |
| Immutable evidence tree | `32baef299ac99e3a8ba957a0623142b49686973447a7b7b78a1c5162f6f6e6cd` |
| Verifier log SHA-256 | `88e7ed5c13fe91f7ef066c1c318698d4732e76befff2f7c65141ff1005807a4f` |

## Findings

### P1-1 — Exact Gate-3 authority is not bound to the frozen tuple

`b47b5b2...` has no Git object for
`.tad/evidence/yolo/yolo2-verified-orchestration/phase2/gate3-verdict.md`:
`git show` reports that the path exists only on disk. The corresponding pinned-main
Git blob at `c992769...` is also stale: it declares candidate `9ad3cd...` and main
`d48d2d...`, rather than the reviewed `b47b5b...` / `c992769...` tuple.

The requested R3 carrier files are present only as modified worktree files. In
contrast, the candidate's committed scope-proof objects bind an earlier tuple
(for example, its committed manifest SHA-256 is `5c9c84...`, its committed
main-equivalence SHA-256 is `a5d5d1...`, and its committed log SHA-256 is
`072922...`). This is not an immutable, self-contained replay.

The verifier conceals the failure: `verifyEquivalence()` falls back from the
candidate Git object to filesystem content for `gate3-verdict.md`
(`.tad/scripts/yolo-recovery.test.mjs:1653-1667`) and reduces the check to a
substring/title check (`:1677-1689`). Its carrier loop explicitly allows
untracked or dirty carriers (`:2107-2109`). Running the exact R3 command emitted
the missing-candidate-blob fatal diagnostic yet returned `RESULT=PASS`.

This violates the exact candidate HEAD + PASS binding and immutable-carrier
requirements of DR-20260830 §2.4 and DR-20260831 R2 §§2 and 5. Gate 4 must not
accept a PASS based on mutable worktree content when the frozen objects disagree.

### P1-2 — Dogfood reuse verification does not check the complete identity

`verifyDogfoodInputManifest()` at
`.tad/scripts/yolo-recovery.test.mjs:1694-1746` recomputes only the three
mechanism blobs and the dataset index/task blobs. It does not recompute or
compare the manifest's approval, policy, generator/harness CLI identity, judge
binary/model/family/version, model settings, canonicalization version, or
equality with raw run `a6fe...`.

Consequently, a changed approval, budget policy, judge, or harness could still
reuse the dogfood and pass the verifier. This fails DR-20260830 §2.6 and
DR-20260831's exact-reuse conditions.

### P1-3 — R2 negative fixtures do not execute the production verifier

`runScopeFixtures()` at
`.tad/scripts/yolo-recovery.test.mjs:1780-1897` defines an `invoke()` helper but
never calls it. The listed fixtures are predicate/constant checks, not real
temporary-repository executions of the same verifier. They therefore cannot
demonstrate that tampered exclusion fields, a candidate containing an excluded
commit, or a generic unrelated path returns the prescribed failure.

This does not satisfy the real-Git, same-production-verifier fixture requirement
in DR-20260831 R2 §4.

## Confirmed improvements

- The inclusive scope allowlist no longer contains the Round-2 generic Local
  Wiki/archive allowances (`yolo-recovery.test.mjs:1344-1353`), and the candidate
  net diff contains none of those generic paths.
- All four R2 exclusion binary-diff SHA-256 values recompute from the stated Git
  parent/source objects to their recorded values:
  `3abdcc...`, `7ec134...`, `931d11...`, and `86a557...`.
- The exact verifier invocation left the five on-disk carrier hashes unchanged.
  That read-only property does not remedy its reliance on mutable, non-object
  evidence described in P1-1.

## Verification performed

- Inspected candidate and pinned-main Git objects, including product blob
  equivalence, completion/Gate-3 carriers, and all five scope-proof carriers.
- Recomputed all four exclusion binary-diff SHA-256 values directly with
  `git diff --binary <parent> <commit>`.
- Ran the pinned R3 scope verifier from the candidate worktree with pre/post
  carrier SHA-256 checks. It returned `RESULT=PASS`, despite the missing
  candidate Git blob diagnostic above.

P0/P1 is not zero; therefore the R3 Gate-4 code-review result is **FAIL**.
