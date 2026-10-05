# Performance Review — YOLO2 Phase 2

**Reviewer:** independent performance-optimizer (Gate 4)  
**Date:** 2026-08-30  
**Review boundary:** candidate `e78f0360dbcb2a71a0161ac9adc08480488c73fe`; pinned main `06a535320b98f6469b4afbb87914fd9092d36872`  
**Required tuple:** `{candidate_sha: e78f0360dbcb2a71a0161ac9adc08480488c73fe, main_sha: 06a535320b98f6469b4afbb87914fd9092d36872, scope_manifest_sha256: 2c48f936381c54859d52599aa12058b5b864bea1868d1c9ef930fea4f8378afc, main_equivalence_sha256: 5ec952669303492d127cb7e7673c26ae151be6b56917241b12a155c44af496b6, product_tree_sha256: 53c9761ff8d4ac03eaa21c57e841ae238083d9fbac3f4aa033f0ec28d941f90c, immutable_evidence_tree_sha256: no-tree, verifier_output_sha256: 946cb3ca9377a0c1e27f53f0ce988ef83ec71bfa1c0bcbca60f1ae0a10dbfd13}`

## Verdict

**FAIL — P0=0, P1=2, P2=1, LOW=0.**

The engine has finite per-run counters and the raw five-pair result records no unauthorized/repeated actions. However, the submitted scope replay is not a read-only, object-pinned operation, and the dogfood budget is materially larger than the frozen design budget without a corresponding human amendment. Either P1 blocks Gate 4.

## Performance Audit Report

| Metric | Target / contract | Actual evidence | Status |
|---|---|---|---|
| Browser bundle / FCP / LCP / TTI / CLS | N/A — CLI orchestration, no browser surface | N/A | N/A |
| Run-level maximum | `max_rounds=8`, `max_actions=40`, `max_wall_seconds=14400` | Driver sets those finite values | Pass |
| Frozen total token budget | `240000` tokens, reserve `48000`, executor-round max `24000` | Driver and durable pair configs use `3000000` / `600000` / `600000` | **Fail (P1-2)** |
| Observed five-pair token use | Must remain within the frozen policy governing each dogfood | `1,673,705` total across the ten arms; largest arm `232,090`; largest reported round `149,654` | **Fail (P1-2)** |
| Pinned scope replay | Must recompute from pinned Git objects / immutable inputs and be replayable without changing the candidate | Falls back to mutable worktree data and rewrites candidate carriers | **Fail (P1-1)** |

## Findings

### P1-1 — Scope-proof replay reads mutable worktree inputs and rewrites its candidate evidence

The pinned verifier first attempts to read the dataset index from the candidate Git object, but on failure explicitly falls back to the candidate worktree ([`yolo-recovery.test.mjs:1690`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:1690)-1717). The candidate Git object does not contain the ignored dataset task/index files, while its worktree does. That makes a PASS depend on mutable filesystem state rather than just `{candidate_sha, main_sha}` plus content-addressed input.

In the same pinned path, a successful verifier unconditionally writes `candidate-tree.json`, `main-equivalence.json`, and `scope-proof.log`, and can write the remaining scope carriers ([`yolo-recovery.test.mjs:2044`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/yolo-recovery.test.mjs:2044)-2131). The candidate worktree is currently dirty in all five scope-proof carriers (38 additions, 17 deletions), even though its product paths are clean. The emitted hashes now match the main-worktree copies, demonstrating that a Gate 4 replay has changed its own evidence input/output boundary.

This conflicts with DR-20260830's requirement to recompute dogfood inputs from candidate Git blobs and content-addressed raw inputs, run from the candidate validation worktree, and keep Phase-2 owned paths clean. It also makes replay cost non-deterministic: each revalidation writes state that the next validation then consumes.

Required remediation: make the verifier read an explicit immutable input bundle (or Git/CAS blobs) whose hashes are supplied to the invocation; write replay output only to a fresh temporary/output directory; compare that output with the submitted carriers without overwriting them; reject any dirty Phase-2 evidence carrier before execution. Regenerate the tuple and rerun Group-0/Layer-2 after that boundary is fixed.

### P1-2 — The real dogfood increases the frozen token budgets by 12.5×/25× without an accepted amendment

The design authority fixes `max_tokens=240000`, `audit_reserve_tokens=48000`, and `max_executor_tokens_per_round=24000`, and states that increasing a frozen policy requires a new human-authorized run ([`HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md:213`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/active/handoffs/HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md:213)-243). The final driver instead hard-codes `3000000`, `600000`, and `600000` ([`phase2-pair-driver.mjs:21`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/phase2-pair-driver.mjs:21)); every durable `dogfood/cases/P*/pair-config.json` records the same changed policy.

The raw paired results report a `149,654`-token round and `232,090`-token arm, which would exceed the frozen `24,000` executor-round maximum. The 2026-08-27 human amendment accepts specified harness degradations only; it explicitly retains all other original handoff semantics and contains no budget change ([`DR-20260827-yolo2-phase2-amended-acceptance.md:8`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/decisions/DR-20260827-yolo2-phase2-amended-acceptance.md:8)-10, 36-43).

This is a material cost/performance and bounded-loop regression, not merely a test-fixture choice: the raw dogfood validates a different budget contract than the one accepted in the handoff. Required remediation is either to restore the frozen policy and rerun the dogfood, or obtain a precise human-signed budget amendment before rerunning it. Existing evidence cannot be relabelled in place.

### P2-1 — Full dogfood campaign has no outer wall-time ceiling or progress checkpoint

The driver serializes five pairs, each serializing control then treatment ([`phase2-pair-driver.mjs:916`](/Users/sheldonzhao/01-on%20progress%20programs/TAD/.tad/scripts/phase2-pair-driver.mjs:916)-946). Each two-slice arm synchronously spawns assertion/reviewer/execution calls with 10/10/15-minute timeouts, and then the driver runs three synchronous 15-minute final judges. The worst-case serial campaign is about 925 minutes (75 native/judge calls), with no campaign-level timeout, checkpoint, or resumable pair cursor.

This does not invalidate the per-run finite-loop enforcement, but it creates a high operational replay cost after a transient failure. Before Phase 3, add a durable pair-level resume/checkpoint and a declared campaign ceiling; retain serial execution unless concurrency can preserve the existing isolation rules.

## Evidence reviewed

- `.tad/active/handoffs/HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md`
- `.tad/active/handoffs/HANDOFF-20260827-yolo2-phase2-completion.md`
- `.tad/decisions/DR-20260827-yolo2-phase2-amended-acceptance.md`
- `.tad/decisions/DR-20260830-yolo2-phase2-scope-proof-amendment.md`
- `.tad/active/handoffs/COMPLETION-20260825-yolo2-phase2-bounded-quality-loop.md`
- `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/gate3-verdict.md`
- Candidate and main Git objects named above; the five scope-proof carriers; raw `dogfood/` tree and `runs/a6fe746c2ff351df/` paired results.

The supplied Group-0, code-reviewer, and test-runner reports use the same declared tuple, but this review does not accept the tuple as sufficient because P1-1 shows that the verifier can derive it from mutable worktree evidence.
