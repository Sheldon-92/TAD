# YOLO2 Phase-2 — Gate 4 R4 Security / Evidence-Integrity Review

**Reviewer:** Independent security auditor  
**Date:** 2026-08-31  
**Verdict:** **FAIL** — P0=0, P1=4, P2=0, LOW=0. P0/P1=0 is required for Gate 4 PASS.

## Frozen inputs independently checked

| Input | Result |
|---|---|
| Base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` exists as a commit. |
| Candidate | `7de87feae02e0362e7fc405b9642def4cc145211` exists; direct parent is the frozen base; product tree is `8885640cbc96ee915de358e06f14a714585b00e8`. |
| Main | `7365a636b983ec55346c29eab266f8a8ab535206` exists and was the observed `main` ref. |
| External attestation | Working file SHA-256 is exactly `7e55ac67762d1b12933b6ed7945df9ea262215b0efaa05ce9c488da3bfc7eaf4`. Its declared bundle tree is `7f1e1d0361f67ab5a1f856f05ca0cd503a482299`. |
| Scope verifier execution | Executed in `.worktrees/tad-yolo2-candidate` with the supplied full tuple, attestation path, and expected SHA. It returned `CASE=phase2-scope-proof RESULT=PASS` / exit 0. The findings below demonstrate why that PASS is not sufficient. |

## Findings

### P1-1 — The attestation binds neither the declared bundle tree nor Layer-2 reports, so a false PASS can survive changed acceptance evidence

The supplied attestation lists `evidence_bundle_tree_sha` and three report digests. But the pinned verifier never reads or validates either field: the only attestation consumers are `attDoc.carriers` and optional `attDoc.gate3` in `.tad/scripts/yolo-recovery.test.mjs:2121–2150`. Searching the candidate verifier finds no use of `attDoc.reports` or `evidence_bundle_tree_sha`.

This leaves a direct integrity gap: after the initial expected-attestation check, any report may be replaced, removed, or made inconsistent without affecting the scope-verifier result. The verifier also never recomputes whether the listed paths form the declared tree `7f1e…`. That violates the R4 requirement that bundle, carriers, reports, and Gate-3 digest form one bound object.

**Required remediation:** require a schema with all five carriers, Gate-3, all required reports, and bundle-tree fields; recompute every listed digest and construct/compare the exact bundle tree during verification. Missing, duplicate, extra, or mismatched entries must emit `RESULT=ERROR`/2.

### P1-2 — Gate-3 content is only digest-checked and is internally inconsistent with the externally pinned attestation

The current Gate-3 file hashes to the attestation's `gate3.sha256`, so the verifier accepts it. However its own text declares a different attestation SHA (`c83b6aa…`, not the externally pinned `7e55ac…`) and a different bundle tree (`f2af5b3…`, not the attestation's `7f1e1d…`). The file also claims that it binds reports and the bundle tree, while the verifier does not perform those checks.

The main Git Gate-3 blob is not the R4 verdict: `git show 7365…:.../gate3-verdict.md` names the older `c992…/b47…` tuple. In `verifyEquivalence`, the Gate-3 check reads that main blob (with filesystem fallback) and only looks for the word PASS (`.tad/scripts/yolo-recovery.test.mjs:1653–1666`); it never parses and matches the R4 candidate/main tuple. The post-freeze working Gate-3 is digest-bound but not semantically checked.

Thus an externally signed hash can authenticate a self-contradictory or stale PASS document, and the verifier still returns PASS—as reproduced above.

**Required remediation:** make the external attestation the sole Gate-3 authority or parse the post-freeze Gate-3 file strictly. In either design, require exact equality among its candidate/main/base, attestation digest, bundle-tree SHA, report digests, and verdict `PASS`; remove the main-Git stale-PASS/fallback branch.

### P1-3 — Carrier checks are vulnerable to TOCTOU and do not reject the observed dirty carriers

At start the verifier hashes carriers against the external attestation (`.tad/scripts/yolo-recovery.test.mjs:2121–2134`), then later reopens the manifest and other carriers (`2224`, `2325`, `2374`) without a post-read/full post-verification digest check. A carrier can therefore be swapped after its initial hash check and before its later use.

Further, the actual candidate worktree has all five scope-proof carriers marked modified by Git, yet the supplied command returned PASS. The only dirty-path checks are the five product files (`2207–2215`); the carrier loop explicitly performs only existence/size validation (`2296–2321`). This fails the requested dirty/missing/tamper `ERROR` behavior even though initial content tampering is detected.

**Required remediation:** snapshot the attestation and all carrier bytes/digests before parsing; verify the same digests again after all consumers finish (and before emitting PASS). Reject dirty tracked carriers and unapproved untracked carriers, or use a dedicated immutable evidence worktree/content store whose full identity is externally pinned.

### P1-4 — R2 production fixtures still do not test the intended production cases; dogfood reuse identity remains incomplete

`runScopeFixtures()` says it invokes the same production verifier, but its `invoke()` executes the parent-repository script while setting a temporary directory only as `cwd` (`.tad/scripts/yolo-recovery.test.mjs:1830–1832`). The production script's repository root remains the parent candidate worktree, so temporary-repository SHAs do not exercise the claimed temporary Git authority. Moreover, its four "exact R2 exclusion" cases explicitly say "Not actually invoking verifier" (`1838–1867`), and the source/parent/diff/patch/drift fixtures remain local-string/no-op checks (`2000–2037`). These cannot prove the required `RESULT=ERROR` behavior or catch replacement of recomputation with a constant.

The dogfood check is also incomplete: it verifies candidate mechanisms, dataset files, and approval, but `policy_sha256` is merely required and never compared (`1765–1772`); harness fields are only required to be nonempty (`1773–1774`); raw-run/durable-tree fields are not required or validated (`1778–1779`). Therefore a policy, harness identity, canonicalization, raw run, or durable-tree substitution can pass with unchanged mechanisms/tasks, contrary to the required complete reuse identity.

**Required remediation:** run the verifier copied/committed into each temporary repository with its own strict external attestation and assert exact PASS/FAIL/ERROR exit contracts for every R2 case. For reuse, require and recompute the policy, complete harness/model settings, canonicalization, raw-run ID/input manifest, durable-tree digest, and the equality relation to the reused final run.

## Positive checks and scope limits

- The candidate is correctly isolated from the frozen base at its first parent, and its stated product tree was independently verified.
- The external SHA prevents a simple before-start attestation edit, and all five current carrier digests plus the current Gate-3 digest match the supplied attestation.
- The invoked top-level verifier did not mutate the project worktree; its fixture machinery creates temporary repositories only. This does not cure the fixture-validity or carrier TOCTOU failures.
- No material application-facing secret, injection, auth, transport, or dependency regression is supported by this bounded evidence-integrity review.

## Reproduction anchors

```text
shasum -a 256 .tad/evidence/.../phase2/attestation.json
# 7e55ac67762d1b12933b6ed7945df9ea262215b0efaa05ce9c488da3bfc7eaf4

git -C .worktrees/tad-yolo2-candidate status --short
# M on all five scope-proof carriers, yet the pinned verifier returns PASS

rg 'attDoc\.reports|evidence_bundle_tree_sha' \
  <candidate>.tad/scripts/yolo-recovery.test.mjs
# no verification use

shasum -a 256 .tad/evidence/.../phase2/gate3-verdict.md
# 8246f444... (matches attestation gate3), while its text declares c83b6aa.../f2af5b3...
```

Only this R4 report was written. No frozen tuple object, carrier, implementation file, or prior report was modified.
