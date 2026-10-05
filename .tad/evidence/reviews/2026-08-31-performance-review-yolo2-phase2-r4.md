# Performance & Budget Review — YOLO2 Phase 2, Gate 4 R4

**Reviewer:** independent performance / budget review  
**Date:** 2026-08-31  
**Verdict:** **FAIL** — P0=0, P1=2, P2=0, LOW=0. Gate 4 requires P0/P1=0 for PASS.

## Frozen tuple

| Field | Value |
|---|---|
| Base | `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7` |
| Candidate | `7de87feae02e0362e7fc405b9642def4cc145211` |
| Pinned main | `7365a636b983ec55346c29eab266f8a8ab535206` |
| Attestation SHA-256 | `7e55ac67762d1b12933b6ed7945df9ea262215b0efaa05ce9c488da3bfc7eaf4` |
| Evidence-bundle tree | `7f1e1d0361f67ab5a1f856f05ca0cd503a482299` |

## Findings

### P1-1 — Reuse of `a6fe...` still does not prove the complete DR-20260831 identity

The R4 dogfood manifest continues to omit the exact authorized policy values, judge, CLI, model version/settings, complete harness identity, final raw-run namespace, and durable-evidence tree. Its `policy_sha256` is the SHA-256 of only `{max_rounds:8,max_retries_per_slice:2,max_actions:40}` (`c97be9...`), not the frozen `3000000 / 600000 / 600000` policy. The verifier recognizes the gap in comments and returns without validating it.

Evidence:

- `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/dogfood-input-manifest.json` contains only mechanism hashes, input hashes, approval/policy hashes, and the minimal `{generator, model_family, canonicalization_version}` harness object. It has no raw/durable, CLI, judge, model-version/settings, or three numeric-budget fields.
- `.tad/scripts/yolo-recovery.test.mjs:1765-1779` calculates no comparison for `policy_sha256`, only checks three minimal harness fields, and contains an unimplemented raw/durable check.
- `c97be9...` recomputes exactly from the three small loop limits above; it does not encode the human-approved token ceiling, reserve, or per-round ceiling.
- DR-20260831 budget amendment §3 requires exact equality for all of these inputs before `a6fe...` may be reused.

This permits a raw run produced under a different budget or execution environment to be labeled identical. It is a correctness and budget-governance blocker, not merely a reporting omission.

### P1-2 — The R4 attestation does not verify its claimed durable evidence-bundle root, which is currently unreachable and excludes the raw/durable evidence it must bind

The attestation's expected SHA does protect the attestation file itself, and the verifier checks the five scope-carrier hashes plus the Gate-3 file hash. However, it never reads or verifies `evidence_bundle_tree_sha`, and it never checks the attestation `reports` entries. The named bundle tree is an unreachable Git object, therefore subject to ordinary pruning; its listed members exclude `runs/` and the durable dogfood tree entirely.

Evidence:

- `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/attestation.json` names bundle tree `7f1e1d...`.
- `git fsck --no-reflogs --unreachable` reports that exact tree as `unreachable tree 7f1e1d...`.
- `git ls-tree -r 7f1e1d...` contains only three Layer-2 reports, the Gate-3 verdict, and five scope carriers; it contains no `runs/` or dogfood durable-evidence paths.
- `.tad/scripts/yolo-recovery.test.mjs:2121-2150` verifies carrier/Gate-3 filesystem hashes only. There is no verification of `evidence_bundle_tree_sha` or `reports` afterwards.

Thus an R4 replay can PASS after checking only mutable filesystem material whose names happen to match an attestation, without proving that the promised content-addressed root exists, is retained, or contains the raw and durable reuse evidence. This fails DR-20260831 §3's immutable/self-contained replay condition.

## Verified positive properties

- The driver in the candidate sets the authorized Phase-2-only policy exactly: `max_tokens:3000000`, `audit_reserve_tokens:600000`, and `max_executor_tokens_per_round:600000` (`.tad/scripts/phase2-pair-driver.mjs:21`). This is consistent with DR-20260831 and must not be treated as authorization for Phase 3.
- Candidate and pinned main have identical product scripts.
- The R4 attestation SHA matches the supplied frozen digest. The pinned command with `--attestation` and `--expected-attestation-sha256` returned `RESULT=PASS` from the candidate worktree in approximately 12 seconds, and a pre/post status comparison showed `WORKTREE_UNCHANGED=1`.
- The attestation improves protection of the five scope carriers and Gate-3 verdict against post-attestation edits, but it does not close the two findings above.
- The recovery mechanism retains finite round/retry/action/token/reservation checks. No independent runaway-loop defect is supported by this review.

## Required remediation

1. Make the manifest and verifier recompute and compare every DR-20260831 §3 reuse input, including the exact three budget values, approval/policy source, generator/judge/harness/CLI/model/family/version/settings/canonicalization, final `a6fe...` raw-run identity, and durable-evidence tree identity.
2. Make the attestation verifier resolve `evidence_bundle_tree_sha` as a retained, reachable immutable tree and compare its full contents against the attested files. Include the raw-run and durable-evidence tree in that root, verify the report entries, and fail when any required member is absent.
3. Generate a new tuple and rerun Gate 3/4 after both bindings are enforced. Phase-3 calibration remains a separate DR-required follow-up.
