# Performance Review — YOLO2 Phase 2, Gate 4 Round 2

**Reviewer:** independent performance-optimizer  
**Date:** 2026-08-31  
**Review boundary:** base `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7`; candidate `a199030bd44d1a62a2b8b43ce629b02af5217095`; pinned main `28c0f9af83c23945038475ec4723a7c43a8acfbf`  
**Scope-manifest SHA-256:** `06086e32998b584af603ff70fe920299c6b800a558802044fdde77b961e65e67`  
**Main-equivalence SHA-256:** `4ac353c83aaf68c09d7805b2fffc21c58aa9fe214f1fafdbab33a52fb6b24433`

## Verdict

**FAIL — P0=0, P1=2, P2=1, LOW=0.**

Round 2 fixes the previous mutable-dataset fallback and mutating-replay defect: the standard pinned verifier ran from the clean candidate worktree with `RESULT=PASS`, and the five carrier SHA-256 values were unchanged before and after the run. The Phase-2 budget is also now authorized by the human-signed 2026-08-31 amendment. These fixes are accepted in this review.

Gate 4 remains blocked because the new verifier accepts a stale Gate-3 carrier for a different candidate, and because the reuse manifest/checker does not enforce the complete, exact input set that DR-20260831 requires for reuse.

## Performance Audit Report

| Metric | Target / contract | Actual evidence | Status |
|---|---|---|---|
| Browser bundle / FCP / LCP / TTI / CLS | N/A — CLI orchestration, no browser surface | N/A | N/A |
| Pinned replay mutation | Read-only; no candidate carrier rewrite | Standard command passed; five carrier hashes unchanged; candidate worktree stayed clean | Pass |
| Dataset/task inputs | Git blobs or immutable content-addressed inputs; no filesystem fallback | Dataset index and all five task JSON files are tracked in candidate; verifier rejects missing candidate blobs | Pass |
| Phase-2 dogfood budget | DR-20260831: `3000000 / 600000 / 600000` | Driver uses exactly `max_tokens=3000000`, `audit_reserve_tokens=600000`, `max_executor_tokens_per_round=600000` | Pass for Phase 2 only |
| Gate-3 candidate binding | Gate-3 verdict must name this candidate and pass, in both candidate/main | Carrier still names `e78f036…`, reports AC-B 10/11 FAIL and Group-0 blocked; verifier nevertheless passes | **Fail (P1-1)** |
| Dogfood reuse equality | Exact policy, approval, generator/judge/harness CLI/model/settings, raw run and durable-tree identity | Canonical manifest/checker cover only a subset | **Fail (P1-2)** |

## Findings

### P1-1 — Read-only scope verifier accepts a stale Gate-3 report for the prior candidate

Both `a199…` and pinned main retain `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/gate3-verdict.md` whose `HEAD` is `e78f0360…`, whose Phase-1 result is `FAIL, 10/11`, and whose prose says Group-0/Layer 2 remain blocked. It is therefore not a Gate-3 carrier for the Round-2 candidate.

`main-equivalence.json` instead self-reports `expected_sha: a199…` for that carrier. The verifier only requires a `PASS` token and equal self-reported candidate/canonical hashes ([`yolo-recovery.test.mjs:2091`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:2091)-2118); it never extracts and compares the carrier's declared `HEAD` to `candidateFull` or verifies the final AC-B/Layer-2 disposition. Consequently, the exact pinned command returns PASS for an internally contradictory tuple.

DR-20260830 requires the actual `gate3-verdict.md` candidate HEAD and PASS verdict to be extracted from both Git objects, not inferred from marker text ([`DR-20260830-yolo2-phase2-scope-proof-amendment.md:69`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/decisions/DR-20260830-yolo2-phase2-scope-proof-amendment.md:69)-73). Regenerate the Gate-3 report for `a199…`, bind its canonical relevant subdocument hash, and make the verifier reject a different declared HEAD or any residual AC-B/Group-0 blocking language. Then regenerate the tuple and rebind the required reviews.

### P1-2 — Dogfood reuse manifest does not enforce all DR-20260831 identity conditions

The new DR authorizes reuse only after exact equality of the specified budget, approval/policy carriers, generator/judge/harness CLI/model/family/version/settings, and final raw run namespace plus durable evidence tree ([`DR-20260831-yolo2-phase2-budget-amendment.md:44`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/decisions/DR-20260831-yolo2-phase2-budget-amendment.md:44)-65).

The submitted `dogfood-input-manifest.json` contains mechanism hashes and Git dataset inputs, but its `policy` has only an approval hash and `policy_sha256=c97be…`. That value is the SHA-256 of only `{max_rounds:8,max_retries_per_slice:2,max_actions:40}`; it does not bind the authorized `3000000 / 600000 / 600000` values. Its `harness` contains only `generator`, `model_family`, and `canonicalization_version`; it has no judge, CLI version, model settings, raw-run, or durable-evidence-tree binding.

Correspondingly, `verifyDogfoodInputManifest` validates only the three mechanism blobs and dataset/task Git blobs, then returns ([`yolo-recovery.test.mjs:1663`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1663)-1715). It does not recompute or compare the DR-required policy, approval semantics, judge/harness identity/settings, final run namespace, or durable tree. The candidate Git tree contains the committed dataset inputs but not the raw `runs/` or `dogfood/` evidence roots.

This is a reuse-integrity and replayability blocker, not a request to rerun by default. Extend the canonical manifest and read-only verifier to bind and recompute every DR-20260831 input; reuse remains valid if and only if that comparison and the durable checker both pass. Any mismatch must invalidate reuse and require a fresh namespace, exactly as the DR specifies.

### P2-1 — Campaign-level cost calibration remains a Phase 3 follow-up, not a Phase 2 acceptance failure

The driver still serializes five pairs, then control/treatment arms, and uses synchronous 10/10/15-minute assertion/reviewer/executor timeouts plus three 15-minute judges per pair ([`phase2-pair-driver.mjs:181`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/phase2-pair-driver.mjs:181)-236 and 898-946). Its theoretical full-campaign ceiling is about 925 minutes across 75 native/judge calls.

The new DR deliberately accepts a loose but finite Phase-2 ceiling and says it is not evidence of cost efficiency. It expressly requires a separate Phase-3 calibration based on full-role usage, cached-input visibility, observed distribution, and safety margin ([`DR-20260831-yolo2-phase2-budget-amendment.md:67`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/decisions/DR-20260831-yolo2-phase2-budget-amendment.md:67)-80). Keep this as a Phase-3 design requirement; it is not a reason to reject the authorized Phase-2 numeric policy.

## Verified improvements from Round 1

- Dataset index and task inputs are now candidate Git blobs; the mutable filesystem fallback is removed ([`yolo-recovery.test.mjs:1687`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1687)-1713).
- Pinned mode verifies existing carriers and does not write them ([`yolo-recovery.test.mjs:2039`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:2039)-2133). Independent replay confirmed unchanged carrier SHA-256 values and a clean candidate worktree.
- The implemented `3000000 / 600000 / 600000` policy exactly matches the scoped human authorization in DR-20260831. No finding is raised for the budget amount itself.

## Evidence reviewed

- `HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md`
- `HANDOFF-20260827-yolo2-phase2-completion.md`
- `DR-20260827-yolo2-phase2-amended-acceptance.md`
- `DR-20260830-yolo2-phase2-scope-proof-amendment.md`
- `DR-20260831-yolo2-phase2-budget-amendment.md`
- Final completion report, Gate-3 verdict, both pinned Git objects, five scope-proof carriers, committed dataset inputs, and raw `runs/a6fe746c2ff351df/` evidence.
