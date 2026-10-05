# Performance & Budget Review — YOLO2 Phase 2, Gate 4 R3

**Reviewer:** independent performance / budget review  
**Date:** 2026-08-31  
**Verdict:** **FAIL** — P0=0, P1=3, P2=0, LOW=0.  Per Gate-4 policy, P1=0 is required for PASS.

## Frozen review tuple

| Field | Value |
|---|---|
| Base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` |
| Candidate | `b47b5b2fed13d6f1c26e42a877ae9f235820f121` |
| Pinned main | `c992769204f0072b982d66393d9588467fd3699d` |
| Scope manifest SHA-256 | `eb773a75c2f119cd791c05d34e2b3270d6448e1c681cb47b3cfc8384b38061fb` |
| Main-equivalence SHA-256 | `2fef865e2787d865107724690f620f521331fbbfbbc5055704fb069d40a0b0e7` |
| Product-tree | `87d21bd4d8e403b29d3bfd879e867f81e9a6d68a` |
| Immutable-evidence SHA-256 | `32baef299ac99e3a8ba957a0623142b49686973447a7b7b78a1c5162f6f6e6cd` |
| Verifier-log SHA-256 | `88e7ed5c13fe91f7ef066c1c318698d4732e76befff2f7c65141ff1005807a4f` |

The reviewed product scripts are identical between candidate and pinned main. The bounded policy in the driver is the human-authorized Phase-2-only `3000000 / 600000 / 600000` policy.

## Findings

### P1-1 — Gate-3 evidence is not self-contained or immutable for the candidate tuple

`b47b5b2...` does not contain `phase2/gate3-verdict.md`. During the pinned command's actual replay from the candidate worktree, Git therefore reports the missing object, but the verifier still returns PASS by falling back to the mutable filesystem. The fallback file is ignored by Git, so it can change independently of the candidate SHA. The candidate worktree's current file SHA-256 was `821f36a92ec4deca181d2dd44c93ca523eeef0c2642d69207881484c11c546d7`, while `main-equivalence.json` asserts canonical SHA-256 `2f9acb02...`.

Evidence:

- `git cat-file -e b47b5b2...:.tad/evidence/yolo/yolo2-verified-orchestration/phase2/gate3-verdict.md` fails: the path exists only on disk, not in the candidate object.
- `.gitignore` ignores `.tad/evidence/`, including that Gate-3 carrier.
- `.tad/scripts/yolo-recovery.test.mjs:1653-1667` explicitly catches the Git-object failure and uses `fs.readFileSync`.
- `.tad/scripts/yolo-recovery.test.mjs:2140-2153` validates only internal fields of the worktree carrier; it does not bind the carrier to an immutable externally supplied digest.

This violates DR-20260831's self-contained, immutable replay requirement and makes the reported PASS dependent on mutable worktree state rather than the frozen tuple.

### P1-2 — `a6fe...` dogfood reuse identity is incomplete, allowing budget/environment drift to be reused as if identical

DR-20260831 permits reuse only after exact equality of the mechanism, exact authorized policy, inputs, approval/policy, generator/judge/harness/CLI/model/family/version/settings/canonicalization, and final raw-run/durable-evidence tree. The current manifest contains the three mechanism hashes and dataset Git blobs, but it does not contain or recompute the exact numeric policy; judge, CLI, model version/settings; complete harness identity; or raw-run/durable-evidence tree identity. The verifier stops after checking mechanism and dataset fields.

Evidence:

- `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/dogfood-input-manifest.json` has only `approval_sha256` / `policy_sha256` and a minimal harness object (`generator`, `model_family`, `canonicalization_version`).
- `.tad/scripts/yolo-recovery.test.mjs:1694-1746` validates only the three mechanism blobs, dataset index, and per-task blobs before returning.
- `.tad/decisions/DR-20260831-yolo2-phase2-budget-amendment.md` §3 requires all of the omitted bindings and forbids mutable-fallback reconstruction.

Consequently, the accepted Phase-2 budget cannot be proven to be the budget that governed `a6fe...`, and a changed model, CLI, settings, judge, raw run, or durable tree can be incorrectly reused.

### P1-3 — The R3 scope carrier and verifier validate the superseded DR-20260830 marker, not the required R2 marker

The frozen `main-equivalence.json` claims that its expected handoff marker is the R2 amendment, but records the DR-20260830 value for both candidate and main. The verifier hard-codes the same old value, so it accepts that contradiction instead of testing the R2 contract.

Evidence:

- `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/main-equivalence.json:50-56` has R2 as `expected_value`, but DR-20260830 as both observed values.
- `.tad/scripts/yolo-recovery.test.mjs:1634-1639` hard-codes `frontmatter.scope_proof_amendment` and DR-20260830.
- The handoff correctly carries R2 in the separate `scope_proof_amendment_r2` field, whereas DR-20260831 R2 §5 requires the new candidate and corrected authority binding.

This makes the scope proof internally contradictory and fails to establish the R2 acceptance boundary.

## Positive observations / performance disposition

- The Phase-2 numeric budget itself is authorized by DR-20260831 and the driver sets `max_tokens: 3000000`, `audit_reserve_tokens: 600000`, and `max_executor_tokens_per_round: 600000` in `.tad/scripts/phase2-pair-driver.mjs:21`.
- `.tad/scripts/yolo-recovery.mjs:747-865` and `:1007-1039` enforce finite round, retry, action, reservation, token, and audit-reserve bounds. No runaway-loop defect was supported by this review.
- The read-only scope command completed locally in about seven seconds and left the candidate worktree unchanged; its local execution cost is not a Gate-4 blocker. Its ability to pass using mutable evidence is the blocker.
- DR-20260831 deliberately prohibits inheriting this loose Phase-2 budget into Phase 3. A Phase-3 calibration remains a separate follow-up, not a defect in the authorized Phase-2 ceiling.

## Required remediation before another Gate-4 review

1. Bind Gate-3 verdict and all five scope carriers to Git objects or a content-addressed immutable archive, and pass/verify their expected digests as part of the command; remove the Gate-3 filesystem fallback.
2. Expand the dogfood manifest and verifier to recompute and compare every DR-20260831 §3 input, including exact numeric policy, complete execution identity, and raw/durable evidence-tree identities for `a6fe...`.
3. Verify `scope_proof_amendment_r2` against the R2 path, regenerate a consistent tuple, and rebind all Gate-3 reports before rerunning Gate 4.
