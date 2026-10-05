# YOLO2 Phase-2 — Gate 4 R4 Independent Code Review

**Reviewer:** independent code-reviewer  
**Date:** 2026-08-31  
**Verdict:** **FAIL**  
**Severity summary:** P0=0, P1=3, P2=0, LOW=0

## Reviewed tuple

| Field | Value |
|---|---|
| Frozen base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` |
| Candidate | `7de87feae02e0362e7fc405b9642def4cc145211` |
| Pinned main | `7365a636b983ec55346c29eab266f8a8ab535206` |
| Expected attestation SHA-256 | `7e55ac67762d1b12933b6ed7945df9ea262215b0efaa05ce9c488da3bfc7eaf4` |
| Claimed evidence-bundle tree | `7f1e1d0361f67ab5a1f856f05ca0cd503a482299` |

## Findings

### P1-1 — The attestation does not verify its declared reports or evidence bundle

The external expected SHA correctly pins `attestation.json`, and the verifier
checks its base/candidate/main tuple, five scope carriers, and `gate3` at
`.tad/scripts/yolo-recovery.test.mjs:2077-2149`. It never reads or validates
`attDoc.reports`, `attDoc.evidence_bundle_tree_sha`,
`attDoc.evidence_bundle_path`, or `attDoc.product_tree_sha`.

This is observable in the reviewed worktrees. The attestation's report hashes
match the main-worktree reports, but the candidate-worktree reports differ:

| Report | Attested SHA-256 | Candidate-worktree SHA-256 |
|---|---|---|
| `spec-compliance-final.md` | `e2a27e...` | `328171...` |
| `code-reviewer.md` | `64ba93...` | `ea9347...` |
| `test-runner.md` | `719bb3...` | `668b21...` |

Despite that mismatch, the exact pinned R4 verifier command returns
`RESULT=PASS`. Thus an attested report may be modified, replaced, or absent
without invalidating the acceptance proof.

The claimed bundle tree is a currently present but Git-unreachable tree object.
It correctly excludes `attestation.json`, so the artifact as
assembled is acyclic; however, the verifier never calls `git cat-file`, walks
the tree, or compares its members to the five carriers, Gate-3 verdict, and
three reports. A missing or substituted bundle therefore also passes. Further,
the Gate-3 document cites stale attestation SHA `c83b6a...`, not the external
trust root `7e55ac...`. The claimed single-direction evidence graph is neither
fully bound nor enforced.

### P1-2 — R2 fixtures still do not run the production verifier against their temporary repositories

`runScopeFixtures()` copies a verifier into each temporary repository, but its
`invoke()` runs the outer-repository script instead
(`.tad/scripts/yolo-recovery.test.mjs:1813-1832`). That script derives
`REPO_ROOT` from its own file location (`:29-31`), so it examines the real
repository rather than the temporary Git history and manifests.

The required exclusion-pass fixture creates data but explicitly does not invoke
the verifier (`:1838-1867`). Fixtures 2–4 merely assert that the external
command is not `RESULT=PASS` (`:1912-1915`, `:1939-1940`, `:1997-1998`), so an
unrelated `ERROR` such as missing attestation satisfies them. They do not assert
the prescribed failure mode or prove tampered exclusions, paths, and candidate
history are rejected by the production verifier. This remains short of the R2
real-Git/same-verifier fixture contract.

### P1-3 — Dogfood reuse identity remains only partially verified

The R4 verifier correctly rechecks the three mechanism blobs, committed dataset
inputs, and approval blob. But its policy validation computes an unused value
and performs no comparison (`.tad/scripts/yolo-recovery.test.mjs:1756-1772`).
Harness validation is only a presence check (`:1773-1774`); it does not bind a
judge binary/model/family/version, model settings, or raw run
`a6fe746c...`/durable-tree identity. The code then returns without validating
the advertised raw-run fields (`:1775-1779`).

Consequently, a changed authorized budget, judge, harness setting, or raw-run
carrier can reuse dogfood under the same dataset/mechanism hashes. This is not
the complete exact-reuse identity required by DR-20260830 §2.6 and
DR-20260831.

## Confirmed improvements

- The candidate and main use the same verifier blob, and the exact verifier
  invocation requires an attestation plus its externally supplied expected SHA.
- The current attestation SHA-256 and its five carrier/Gate-3 hashes match the
  corresponding candidate-worktree files.
- The evidence bundle currently excludes the attestation, avoiding direct
  self-reference in the assembled artifact.
- The exact R4 verifier command returned `RESULT=PASS` and did not change the
  attestation, five carriers, Gate-3 document, or the three reports.

Those improvements do not close the findings above because report/bundle
integrity and full dogfood identity are not checked by the verifier itself.

## Reproduction

From the candidate worktree, the following command returned `RESULT=PASS`:

```text
node .tad/scripts/yolo-recovery.test.mjs --case phase2-scope-proof \
  --base 96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7 \
  --main 7365a636b983ec55346c29eab266f8a8ab535206 \
  --candidate 7de87feae02e0362e7fc405b9642def4cc145211 \
  --manifest .tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/phase2-commit-manifest.json \
  --evidence-dir .tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof \
  --attestation .tad/evidence/yolo/yolo2-verified-orchestration/phase2/attestation.json \
  --expected-attestation-sha256 7e55ac67762d1b12933b6ed7945df9ea262215b0efaa05ce9c488da3bfc7eaf4
```

It passes even though the candidate-worktree report hashes differ from those
declared by the attestation. P0/P1 is not zero; therefore the R4 Gate-4
code-review result is **FAIL**.
