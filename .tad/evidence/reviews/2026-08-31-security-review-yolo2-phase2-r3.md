# YOLO2 Phase-2 — Gate 4 R3 Security / Evidence-Integrity Review

**Reviewer:** independent security auditor  
**Date:** 2026-08-31  
**Verdict:** **FAIL** — P0=0, P1=4, P2=0, LOW=0. Gate 4 cannot pass while a P1 remains.

## Frozen review tuple

| Field | Verified value |
|---|---|
| Base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` |
| Candidate | `b47b5b2fed13d6f1c26e42a877ae9f235820f121` (parent is the frozen base; tree `87d21bd4d8e403b29d3bfd879e867f81e9a6d68a`) |
| Pinned main | `c992769204f0072b982d66393d9588467fd3699d` |
| Working-carrier SHA-256s | scope manifest `eb773a75c2f119cd791c05d34e2b3270d6448e1c681cb47b3cfc8384b38061fb`; main-equivalence `2fef865e2787d865107724690f620f521331fbbfbbc5055704fb069d40a0b0e7`; immutable-pairs content `32baef299ac99e3a8ba957a0623142b49686973447a7b7b78a1c5162f6f6e6cd`; verifier log `88e7ed5c13fe91f7ef066c1c318698d4732e76befff2f7c65141ff1005807a4f` |

The SHA values above describe the supplied *working-tree* carriers. They are not a substitute for an authority object, and that distinction is material to the findings below.

## Findings

### P1-1 — Scope verifier can issue PASS from self-reported, non-authoritative Gate-3 data

`b47…` has no Git blob for `phase2/gate3-verdict.md` (`git cat-file -e b47…:.tad/evidence/yolo/yolo2-verified-orchestration/phase2/gate3-verdict.md` fails). The same path in pinned main is a stale authority: it names main `d48d2dd…`, candidate `9ad3cd…`, and an older tuple, rather than this R3 tuple. Candidate `COMPLETION…` is likewise stale: its R2 addendum names candidate `e0ae358…` and main `f517cfa…`; its retained body still records `HONEST_PARTIAL`, 10/11, and BLOCKED states.

Despite this, the R3 working-tree `main-equivalence.json` asserts `PASS`/`b47…`. The verifier accepts that self-report: its only Gate-3 validation is `expected_value === 'PASS'` and equality among values already in that JSON. Its `source_commit` check rejects a missing value but does not reject a nonempty wrong value (`.tad/scripts/yolo-recovery.test.mjs:2146`). The lower-level equivalence code also permits a missing candidate Gate-3 Git blob to fall back to `fs.readFileSync` (`.tad/scripts/yolo-recovery.test.mjs:1654`).

This is a reachable false-PASS path: changing a filesystem carrier (or retaining a stale authority carrier) can manufacture the result the verifier later checks. It violates DR-20260830 §2.4/§3 and R2 §5's required exact Git-authority binding.

**Required remediation:** make the final Completion and Gate-3 verdict immutable Git blobs for the exact tuple; extract candidate SHA and PASS directly from both candidate/main blobs, compare their content digest to the carrier, and fail `RESULT=ERROR` if any blob is missing, stale, or disagreeing. Do not use a filesystem fallback for authority.

### P1-2 — Carrier tampering and missing manifests are not fail-closed; the verifier writes evidence during verification

All five scope-proof files are currently modified in the shared working tree. The candidate and main Git blobs for `main-equivalence.json` instead hash to `a5d5d17ff848529b92c80c1de0f4739ddc15ca079c95ff9727ac028edd8311bf` and contain the older `644b24…/6f1403…` tuple; their scope-manifest blobs hash to `5c9c84b763199db12ffa66322345cdfb1143ebc684297c917b02b22762b53972`. The R3 carrier SHA values are therefore not pinned content from either reviewed Git object.

The verifier merely checks carrier existence and nonzero size (`.tad/scripts/yolo-recovery.test.mjs:2085`); it does not require clean Git status or compare every carrier byte digest against a Git blob/content-addressed immutable store. Worse, when the manifest is absent it creates its directory and writes a new manifest (`.tad/scripts/yolo-recovery.test.mjs:1997`). A verification invocation can thus mutate the evidence it is supposed to audit.

This violates the requested dirty/missing/tamper fail-closed and read-only properties, and creates a TOCTOU window between evidence generation and trust.

**Required remediation:** require every carrier before start, record and verify a complete pre/post SHA-256 set, reject any dirty/untracked/changed carrier, and remove the manifest-generation branch from the Gate-4 verifier. Generation belongs in a distinct producer command/worktree, not the verifier.

### P1-3 — Dogfood reuse integrity is only partially checked and is not tied to the final raw run

The dogfood carrier provides policy/approval and harness fields, but `verifyDogfoodInputManifest()` verifies only the three mechanism blobs, dataset index, and task blobs (`.tad/scripts/yolo-recovery.test.mjs:1694–1746`). It does not recompute or compare the policy, approval, generator/harness/model settings, canonicalization value, raw-run identifier, or raw input manifest. Nor does it establish that those inputs equal the run being reused.

Consequently an altered approval, policy, model/harness identity, or raw-run association can retain the same mechanisms/tasks and still be treated as reusable. This conflicts with DR-20260830 §2.6, which makes *all* canonical inputs and equality with the final run preconditions for reuse.

**Required remediation:** consume an immutable, content-addressed raw-run manifest; recompute every required identity field from candidate Git blobs and raw inputs; bind its digest and run ID into the scope tuple; reject any missing/changed field and require a new namespace/full run.

### P1-4 — R2 exclusion fixtures do not exercise the production verifier or prove the anti-hardcode control

The four live Git objects do independently recompute to the R2 values (parents, binary diff SHA, sorted-path SHA, and patch-id); that part of the R3 inventory is correct. However the approved exclusion table remains duplicated as `FIXED_EXCLUSIONS` in code (`.tad/scripts/yolo-recovery.test.mjs:1365`), rather than bound to an immutable signed decision object.

More importantly, `runScopeFixtures()` declares an `invoke()` helper to run the production verifier (`.tad/scripts/yolo-recovery.test.mjs:1794`) but never calls it. Its nine fixtures only perform simplified in-memory/string checks; for example, the purported tamper fixture changes a local string (`.tad/scripts/yolo-recovery.test.mjs:1864`), and the main-drift fixture is explicitly a no-op (`.tad/scripts/yolo-recovery.test.mjs:1871`). Thus they do not show that source/parent/diff/path/patch/reason/exemption mutations produce `ERROR`, nor that replacing recomputation with a constant is caught.

This fails DR-20260831 R2 §§2 and 4: each exact exclusion must be recomputed from Git objects and the *same production verifier* must run real temporary-repository negative controls, including the constant-substitution control.

**Required remediation:** load the signed R2 record by immutable blob/digest, retain Git recomputation, and create real temporary repositories which invoke the production verifier for every required positive/negative case. Assert exit 2 and `RESULT=ERROR` for every provenance-field drift, a fifth exclusion, an undeclared overlap, and a deliberately constant-only implementation.

## Positive checks / scope notes

- Candidate is Phase-2-only in topology: its direct parent is the frozen base, and its tree equals the supplied product-tree SHA.
- The generic unrelated path allowances named in R2 §3 are absent from the Phase-2 inclusive allowlist; an off-allowlist candidate path is rejected by `.tad/scripts/yolo-recovery.test.mjs:1575`.
- I independently recomputed all four R2 exclusion Git-object values; each matches the R2 table. This does **not** cure the fixture and signed-authority defects above.
- No material application-facing secret, injection, authentication, transport, or dependency regression is supported by this targeted scope-verifier review. No active DAST target is in scope.

## Reproduction evidence

```text
git rev-parse b47…^                         # 96bbfada…
git rev-parse b47…^{tree}                   # 87d21bd…
git cat-file -e b47…:.../phase2/gate3-verdict.md
# fatal: path exists on disk, but not in b47…
git show c992…:.../phase2/gate3-verdict.md  # names d48d2dd… / 9ad3cd…
git show b47…:.../COMPLETION-...md          # names e0ae358… / f517cfa… and retains HONEST_PARTIAL
git show b47…:.../scope-proof/main-equivalence.json | shasum -a 256
# a5d5d17… (not supplied 2fef865e…)
```

No project files were changed by this review other than this report. The scope verifier itself was not run because the provided workspace has concurrent dirty carrier changes; the findings above are derived from the frozen Git objects and direct source inspection.
