Model: harness=opencode | model=opencode-go/gpt-5.6-luna | route=host

# Independent TAD Layer-2 Group-0 Spec-Compliance Re-Review

Task: `TASK-20260825-YOLO2-P2`
Review target: `HEAD 1bd70f2e72085974732b359336cdd459779c1732`
Frozen implementation base: `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7`
Enforcement commit under assessment: `6eaef1fb` (fix(TAD): enforce explicit degraded-approval binding for assertion shell reads)
Review scope: `git diff 96bbfada..HEAD` for the Phase-2 files; Handoff sections 6–13; persisted final Phase-1 and Phase-2 suite logs; current `pair-results.json` + `runs/5ef23944dc06bedc/run-manifest.json` + all 40 raw records in that run namespace; current engine/runner/driver source (`validateNativeEventBinding`, `validateRoundReport`, `cmdRoundAuthorize`, `cmdRoundClose`, quality-policy init validation); the degradation approval file; and both full suites re-executed at this HEAD.

## Verdict

**FAIL**

Acceptance counts:

| Status | Count |
|---|---:|
| `NOT_SATISFIED` | 5 |
| `PARTIALLY_SATISFIED` | 6 |
| `SATISFIED` | 1 |

The Handoff pass rule is `NOT_SATISFIED=0` and `PARTIALLY_SATISFIED<=3`. Both are violated. The prior P0 is resolved: the enforcement change converts the silent assertion shell-read bypass into a disclosed, hash-bound, machine-verified degraded path. What remains are the strict-capability, dogfood-design, evidence-manifest, and fixture-coverage gaps that the frozen Handoff still requires for a full pass. This is a review only; no product code, Handoff, `NEXT.md`, session-state, or evidence other than this requested report was modified.

## Review Basis

- Current `HEAD` is `1bd70f2e`; the worktree is clean.
- Timeline verified from commit timestamps and file mtimes: `6eaef1fb` (Aug 26 23:15 -04:00) precedes the dogfood revalidation (run manifest generated `2026-08-27T13:34:26Z`, pair results `13:50:53Z`) and the persisted suite logs (Aug 27 09:52 local). The dogfood and suite logs were produced on the current mechanism; only the later `1bd70f2e` is a docs commit.
- Both exact AC suites were re-executed from repository root at this HEAD: `node .tad/scripts/yolo-recovery.test.mjs` → 10/10 named cases + `RESULT=PASS`, exit 0; `node .tad/scripts/yolo-round.test.mjs` → all 12 named cases (11 required + `resume-continuation`) + `RESULT=PASS`, exit 0. The persisted `phase1-suite-final.log` and `phase2-suite-final.log` match these results.
- `node --check` on all three Phase-2 files exits 0.

## Hash And Metric Recompute

The `runs/5ef23944dc06bedc` manifest was recomputed against current files. Every value matched:

| Field | Recomputed value | Result |
|---|---|---|
| `mechanism_sha256` | `5ef23944dc06bedcab8f041dd22fa71eb275ccc92f72bbadfcce773efb8795a1` | MATCH |
| `runner_sha256` | `69ec681616345215696054e61a0e24ccbaa2a3e46a8318cf0e89a0d1fdf3a974` | MATCH |
| `recovery_sha256` | `c3985be1faa6516eeec304cb7813d4aae38e4a8065e88e43bc54076a8403ff88` | MATCH |
| `driver_sha256` | `f1079c9f414e4f08a913a6436d6aaceed6e638726010f9f9e6031691a466a82e` | MATCH |
| `dataset_sha256` | `3f80d269dec74e793d895e4f3974d7a5ec4b2621410675860d400fe553439f4e` | MATCH |

Approval binding recomputed across all 40 current records (`.tad/evidence/yolo/yolo2-verified-orchestration/phase2/runs/5ef23944dc06bedc/pairs/`):

- Independently computed SHA-256 of `harness-degradation-approval.md` = `e488be7a495d218219cb8a77ee8c72f4039454a27376522240031271e1e109e5`.
- 20/20 assertion records carry `degraded_approval_sha256` exactly equal to that hash; 20/20 also retain `native_policy_violation: true`, so the degradation is disclosed in every record rather than suppressed.
- 0/80 raw carrier hash failures across all 40 records.
- Event inventories recomputed from the raw output carrier for all 40 records: 0 declared-vs-actual mismatches; output-vs-trace carrier event kinds equal in 40/40 records.
- Assertion turns still contain native `command_execution` reads (4 or 8 per record) — this is the degraded behavior itself, now approval-bound. Execution turns contain native `file_change`/`command_execution` events consistent with the declared workspace-write mode.
- Session continuity recomputed: 20/20 execution turns have `resumed_from_session` equal to the pinned assertion-session id AND their recorded native `invocation.cmd` contains `exec resume <pinned-id>` — the resume chain is verifiable from the raw record, not merely self-asserted in a bare field.
- Aggregate `pair-results.json` points at `runs/5ef23944dc06bedc/run-manifest.json`, records mechanism `5ef23944…`, and reports 5/5 control + 5/5 treatment hidden acceptance, `repeated_or_unauthorized_nonzero: 0`.
- Arm token totals remain execution-only. Recomputed P1 all-role usage: control assertion 132,667 + execution 177,406 + deterministic review 30 = 310,133 vs reported 177,406; treatment 256,861 vs reported 139,159. Reviewer/alignment usage is still outside the reported totals.

## Degraded-Path Conversion Assessment (prior P0-1)

The prior P0-1 read: "The live native tool boundary is not enforced" — assertion turns shell-read arbitrary files under a read-only declaration while the verifier's rejection condition checked an unset `strict_tool_policy` field, silently recording `native_policy_violation` and continuing.

At `6eaef1fb` this is converted into a properly disclosed, verified degraded path:

1. **Disclosed.** The runner records `degraded_approval_sha256` from the Conductor flag (`yolo-reference-runner.mjs:228-230`) and keeps `native_policy_violation: true` on every affected record. The approval file (`harness-degradation-approval.md:1-14`) is an explicit human decision, scoped to this Phase-2 dogfood only, naming the exact failed capability and the compensating controls.
2. **Frozen.** The goal `quality_policy` carries `degraded_assertion_shell_reads: true` + `degraded_approval_sha256`, shape-validated at init and immutable thereafter (`yolo-recovery.mjs:1886-1897`). The driver computes the approval hash from the actual file (`phase2-pair-driver.mjs:29-30,119-124`).
3. **Verified.** `validateNativeEventBinding` now (a) binds declared `native_event_kinds` to the parsed contents of the output carrier, (b) requires the output and trace carriers to have equal event inventories (`native_carrier_event_mismatch`), (c) refuses `file_change` on assertion turns unconditionally, and (d) tolerates assertion shell reads only when `quality_policy.degraded_assertion_shell_reads === true` AND the record's `degraded_approval_sha256` equals the goal's frozen hash (`yolo-recovery.mjs:2453-2484`), enforced in `cmdRoundAuthorize` (`:2899-2903`) and `cmdRoundClose` (`:3165-3169`). Two new red fixtures prove both refusal errors (`yolo-round.test.mjs:557-572`).
4. **Replayed.** All 20/20 assertion records in the current run recompute against the approval file hash (table above). Silence is no longer acceptance: an unapproved assertion shell read now fails authorization.

This closes the *silent* part of P0-1. What remains is honestly degraded, not strict: assertion turns still shell-read (the sandbox does not block host reads), capability 9 is still unproven, and under the frozen Handoff §7 only strict may satisfy the dogfood — the correct outcome remains an honest partial, not a pass. The execution-side residue (native stream calls not reconciled one-to-one with `action_started` events) is retained as a P1 below, not a P0: the carriers are now hash- and inventory-bound, the final effect delta is bound against the live worktree manifest (`yolo-recovery.mjs:3237-3241`), and the policy boundary that was silently bypassable is now approval-gated.

## AC Assessment

| AC | Status | Exact verification and current evidence |
|---|---|---|
| AC1 | `PARTIALLY_SATISFIED` | Syntax checks exit 0; Phase-1 suite re-run 10/10 + `RESULT=PASS`, exit 0, matching the persisted final log. The Phase-1 scope checker that runs inside that suite now documents its window as closed at the Phase-1 Gate-4 archive commit by design (`yolo-recovery.test.mjs:1367-1382`), so it deliberately does not certify `96bbfada..HEAD`. The Handoff requires a separately persisted scope checker comparing `96bbfada..HEAD` against §9 plus `scope-fixtures.txt`; neither exists. The final-head scope proof is still missing. |
| AC2 | `SATISFIED` | `node .tad/scripts/yolo-round.test.mjs` re-run: every required named case PASS, `RESULT=PASS`, exit 0; persisted `phase2-suite-final.log` matches. The extra green `resume-continuation` case does not invalidate the listed results. |
| AC3 | `PARTIALLY_SATISFIED` | `--case round-state` proves authorize-before-prepare, double-prepare, verify-before-candidate, the happy path, sequence-gap refusal, and byte-identical journal restore (`yolo-round.test.mjs:403-449`). Close-before-authorize, double-close, unknown-event, action-budget ordering, legacy verify, and the 3-verified cadence reds are still not in this case (append-after-candidate lives in completion-gate via `stop`). |
| AC4 | `PARTIALLY_SATISFIED` | Both exact commands pass. `slice-contract` carries the mapping/phrasing/non-goal-hash/path/traversal/symlink reds; `replan-boundary` proves replan-reason refusal plus goal and verified-history immutability. Necessary evidence is persisted in `round_prepared` and revalidated at load/authorize (`yolo-recovery.mjs:1548-1557,2839-2841`); the packet budget is enforced with composition (`:2784-2792`). Still missing: post-bind evidence-mutation reds, the full contract/replan drift matrix, and the `contract-fixtures.txt` carrier. |
| AC5 | `PARTIALLY_SATISFIED` | `--case reentry-gate` now proves: hard 7/8, soft 0.89, self-review, verdict-FAIL, accepted write attempt, missing provenance, estimated usage, write-capable sandbox, tampered raw-output SHA, wrong round, mutation hidden by empty observations, `native_event_binding_mismatch`, `assertion_native_tool_policy_violation` (shell reads without the frozen approval), and single-round authorization (`yolo-round.test.mjs:496-578`). The engine additionally hard-refuses assertion `file_change` and packet-over-budget with composition. Still absent: wrong-packet-hash, stale-journal-sequence, wrong-next-action, prose-only record, session-ID mismatch native negatives, and the audit-reserve reservation red. The codex resume-chain continuation is accepted as a disclosed model adaptation (see P1-4). |
| AC6 | `PARTIALLY_SATISFIED` | `--case round-close-and-verify` proves: session mismatch, reservation overrun, non-native usage, usage-artifact/turn mismatch, wrong round, empty trace, tampered execution trace, untracked-call `unauthorized_mutation`, direct unreceipted mutation, policy-tool mismatch, duplicate nonce, stale-round nonce, and renamed-label effect replay (`yolo-round.test.mjs:581-710`); verify binds the closed candidate's report/usage/turn hashes and success mapping (`yolo-recovery.mjs:3088-3104` region). Still unproven: the raw native stream's per-call one-to-one reconciliation with `action_started`, stale-pre-state replay and command-spelling reds, contract-path drift at verify, and the required fixture carrier. |
| AC7 | `NOT_SATISFIED` | `--case alignment-gate` drives one verified round, refuses stale digest and bad coverage, and passes a valid align (`yolo-round.test.mjs:738-826`). It still does not reach the three-verified cadence, does not prove the four §4.6 counterexamples, has no executor-authored-alignment red, and `cmdAlign` still has no hidden-acceptance input or result binding — the hidden-business chain is only cross-referenced to completion-gate. |
| AC8 | `PARTIALLY_SATISFIED` | `--case completion-gate` proves no-alignment refusal, incomplete-slice refusal, full closure, terminal status, and append-after-candidate byte preservation (`yolo-round.test.mjs:829-875`). The remaining one-at-a-time negatives (single reviewer absent, one failed check, hidden failure, Handoff drift, open action, repeated/unauthorized >0) are guarded in the engine but not individually fixture-proven. |
| AC9 | `NOT_SATISFIED` | `--case budget-exhaustion` executes only the round and wall-clock fixtures; the actions and audit-reserve blocks are setup without assertions and retry/total-token fixtures do not exist (`yolo-round.test.mjs:878-930`). Blind retry is now removed from both turn types (driver `:171-172,191-194`), and the audit-reserve guard is real in `cmdRoundAuthorize:2926-2935` — but four of six required exhaustion fixtures remain unproven and reported token totals are still execution-only (recompute table above). |
| AC10 | `NOT_SATISFIED` | `--case phase2-policy` validates init-policy rejection and legacy-checkpoint refusal; it does not execute the §7 capability probe. The persisted probe verdict is `degraded` with capability 9 failing (`reference-harness-capability.json:43-61`). The Handoff is frozen text: only strict may satisfy Phase-2 dogfood. The new human approval + enforced binding make the degraded run legitimate and auditable, and its correct disposition is the Handoff's own honest-partial branch — but they do not convert the probe to strict, so AC10's expected evidence ("the persisted real probe is strict") is not met. |
| AC11 | `NOT_SATISFIED` | The dogfood is real and revalidated on the current mechanism: 5/5 control + 5/5 treatment hidden acceptance, safety counters 0, approval binding on 20/20 assertion records, all manifest hashes matching. But the checker still validates only format and `pairs.length >= 5` (`yolo-round.test.mjs:933-948`); review records are driver-written `deterministic-rubric` carriers (`phase2-pair-driver.mjs:325-342`), not independent native judge turns; there are no three blinded passes, no label commitment, and no tamper/swap reds; arm inputs are not frozen-equivalent (P1-5); the safety metric remains journal-derived and cannot count refused attempts. |
| AC12 | `NOT_SATISFIED` | `gate3-verdict.md`, `knowledge-assessment.md`, and the matching COMPLETION now exist — a real improvement — but the §12 manifest is still missing `base-commit.txt`, `reference-harness-probe.txt`, `reference-runner-record-schema.json`, `contract-fixtures.txt`, `budget-fixtures.txt`, `scope-fixtures.txt`, and the entire `dogfood/` tree (the `pairs/`+`runs/` layout is not the required structure). The `required-evidence` case still checks only four paths (`yolo-round.test.mjs:951-960`), and the persisted `gate3-verdict.md` is pinned to `c3c2673c`, i.e. stale relative to this HEAD. |

## Prior Findings: CLOSED vs STILL OPEN

**P0-1 (silent native tool boundary bypass) — CLOSED as a silent bypass; converted to a disclosed, verified degraded path** (assertion side, evidence in the dedicated section above) with a residual execution-side attribution gap retained at P1 (P1-10 below).

| Prior | Status | Evidence |
|---|---|---|
| P1-1 strict capability unavailable | STILL OPEN | `reference-harness-capability.json:59-61` verdict `degraded`, capability 9 fails; approval exists and is enforced; Handoff §7 still reserves dogfood satisfaction for strict. |
| P1-2 Phase-2 scope proof absent | STILL OPEN (reframed) | The Phase-1 checker's closed window is now documented as intentional (`yolo-recovery.test.mjs:1367-1382`), so it is no longer an unnoticed defect — but the separately persisted `96bbfada..HEAD` checker and `scope-fixtures.txt` required by AC1 remain absent. |
| P1-3 deterministic producer-side review | STILL OPEN | `phase2-pair-driver.mjs:325-342` writes `review-output`/`review-trace`/PASS review JSON with `harness: deterministic-rubric`; confirmed in current run evidence (`review-R-01.json`, `review-R-02.json`). |
| P1-4 exact-session contract relaxed | STILL OPEN (disclosed) | `yolo-recovery.mjs:3180-3182` accepts `resumed_from_session`; the `resume-continuation` case labels the resume chain positive with fresh/wrong-chain reds. Raw evidence: 20/20 execution turns carry the pinned id in both the binding field and the native `invocation.cmd`. Deviation from frozen §4.4 wording remains. |
| P1-5 arms not frozen-equivalent | STILL OPEN | `setupRepo` embeds arm-specific `run_id`, handoff bytes, timestamps, and per-arm base commits before init (`phase2-pair-driver.mjs:90-133`); task hashes match but arm equivalence is not established. |
| P1-6 dogfood evidence not independently checked | STILL OPEN | `dogfood-evidence` checker still shape+count only (`yolo-round.test.mjs:933-948`); `deriveSafetyMetrics` still journal-derived (`phase2-pair-driver.mjs:462-485`). |
| P1-7 budget accounting and blind retry | PARTIALLY CLOSED | Blind retry removed from both turn types (diff `6eaef1fb`; driver `:171-172,191-194`). Still open: 4 of 6 exhaustion fixtures, reviewer/alignment usage uncharged (P1 all-role 310,133 vs reported 177,406), totals execution-only. |
| P1-8 alignment hidden-acceptance chain unproven | STILL OPEN | `caseAlignmentGate` unchanged in scope; `cmdAlign` still has no hidden-acceptance binding. |
| P1-9 required evidence/lifecycle carriers absent | PARTIALLY OPEN | `gate3-verdict.md`, `knowledge-assessment.md`, COMPLETION now exist; the §12 manifest carriers and `dogfood/` tree are still absent, the checker still lists four paths, and the persisted Gate 3 verdict is pinned to the pre-enforcement HEAD `c3c2673c`. |
| P1-10 runner provenance not bound to manifest/native effects | STILL OPEN | `validateRunnerBoundArtifact` is shape-only (`yolo-recovery.mjs:2486-2515`); `runner_sha256` is not compared with the current run manifest, and native stream events are not reconciled one-to-one with `action_started` (`:3190-3232` reconciles the runner-synthesized `tool_calls`). |
| P2-1 packet omits necessary-evidence section | PARTIALLY CLOSED | BUDGETS section and enforced packet budget with composition added (`:2775-2792`); necessary-evidence paths/hashes still not in the packet body. |
| P2-2 fingerprint not general for multi-path effects | STILL OPEN | `yolo-reference-runner.mjs:162-169` unchanged (single target + full path list). |
| P2-3 raw trace carrier not parsed | CLOSED | `native_carrier_event_mismatch` now cross-checks the trace carrier (`yolo-recovery.mjs:2459-2468`); 40/40 current records verify. |
| P2-4 exit defaulting to expected | CLOSED | Observed integer exit required (`:2987-2993`). |

## New Gaps Introduced by 6eaef1fb

- **P2 (new): records omitting `native_event_kinds` skip the inventory and shell-read checks.** `validateNativeEventBinding` early-returns when the field is absent (`yolo-recovery.mjs:2456`). The prior code required codex-harness records to declare an inventory (missing kinds → `native_event_binding_mismatch`); the new code applies to all harnesses but only when the field is an array. A fabricated assertion record omitting the field would bypass both the inventory binding and the approval check. The real runner always emits the field, so the dogfood path is unaffected; this is a defensive-completeness regression for hostile producers, narrower than the old harness-string bypass it replaces.

No other new gaps were found. Blind-retry removal and the observed-exit requirement are strict improvements.

## Findings

### P0

None. The prior P0-1 is resolved into the disclosed, hash-bound, machine-verified degraded path described above, with its execution-side residue carried at P1.

### P1

- **P1-A: Strict capability 9 remains unavailable; the frozen Handoff reserves dogfood satisfaction for strict.** The probe is `degraded`; the approval makes the degraded run legitimate but its Gate-3 disposition is the honest-partial branch, not a pass (`reference-harness-capability.json:59-61`; Handoff §7).
- **P1-B: The `96bbfada..HEAD` scope proof and `scope-fixtures.txt` are absent**; AC1's final-head scope requirement is unmet (`yolo-recovery.test.mjs:1367-1382`; Handoff AC1).
- **P1-C: Re-entry review is driver-synthesized `deterministic-rubric` output, not an independent native reviewer turn** (`phase2-pair-driver.mjs:325-342`; Handoff §4.4).
- **P1-D: Exact-session continuation is implemented as a runner-asserted resume chain**, deviating from frozen §4.4 wording, though disclosed, negative-controlled, and verified 20/20 in raw evidence (`yolo-recovery.mjs:3180-3182`; `yolo-round.test.mjs:962-985`).
- **P1-E: Control and treatment inputs are not frozen-equivalent** (arm-specific run ids, handoff bytes, timestamps, base commits; `phase2-pair-driver.mjs:90-133`).
- **P1-F: The AC11 checker does not recompute raw metrics, does not require blinded independent judges, label commitment, or tamper reds; the safety metric is journal-derived** and cannot count refused attempts (`yolo-round.test.mjs:933-948`; `phase2-pair-driver.mjs:462-485`).
- **P1-G: Budget coverage and accounting are incomplete**: 4 of 6 exhaustion fixtures unproven; reviewer/alignment usage uncharged; reported totals execution-only (P1 recompute: 310,133 vs 177,406).
- **P1-H: The alignment hidden-business chain and cadence reds are unproven** (`yolo-round.test.mjs:738-826`; `cmdAlign` `yolo-recovery.mjs:3263-3305`).
- **P1-I: The §12 Required Evidence Manifest is incomplete and the persisted Gate 3 verdict is stale** (pinned to `c3c2673c`; missing manifest carriers and `dogfood/` tree; four-path checker).
- **P1-J: Runner provenance and per-native-call attribution are not bound to the current run manifest or one-to-one with `action_started` events**; reconciliation consumes the runner-synthesized `tool_calls` list (`yolo-recovery.mjs:2486-2515,3190-3232`).

### P2

- **P2-A (new): assertion records omitting `native_event_kinds` bypass inventory and shell-read checks** (`yolo-recovery.mjs:2456`).
- **P2-B: The execution packet still omits the necessary-evidence path/hash section** (`yolo-recovery.mjs:2745-2792`).
- **P2-C: Effect fingerprints are not independently observed per affected/deleted/untracked path** (`yolo-reference-runner.mjs:162-169`).

### P3

- **P3-A: The informational `native_policy_violation` field is not consumed by the engine**; after this change the authoritative check is the approval binding, and the retained flag could drift from the engine's own carrier parse without detection. Cosmetic dual bookkeeping; auditors should read the engine check as authoritative.

## Gate 3 Determination

Gate 3 cannot be `PASS` under this Handoff.

- Group 0 has 5 `NOT_SATISFIED` ACs and 6 `PARTIALLY_SATISFIED` ACs; the pass rule (`NOT_SATISFIED=0`, `PARTIALLY<=3`) fails on both counts (`HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md:717-737,970-979`).
- The remaining P1 findings block per Handoff §13.
- The enforcement change honestly resolves the prior P0: the degraded assertion-shell path is now disclosed, human-approved, hash-frozen, and machine-verified on every authorization. Under frozen §7 the correct overall disposition remains **HONEST_PARTIAL** — which is what the existing (but stale, pre-`6eaef1fb`) `gate3-verdict.md` and COMPLETION record; the Gate 3 carrier will need re-issuance at the current HEAD once Group 0 re-runs.

The correct current disposition is Group-0 `FAIL`, with the run remaining in the honest-partial state rather than predicting that a future completion/archive state will pass.

## Provenance

The prior FAIL report previously stored at this path (written against `b8faef6e`, and itself superseding an earlier `fc902e0a`-state FAIL) was read in full as provenance and is superseded by this re-review; its findings were individually re-assessed against `1bd70f2e` evidence rather than trusted. The independent Alex FAIL reports remain untouched under `.tad/evidence/reviews/alex/yolo2-phase2/`. This overwrite changed only `.tad/evidence/reviews/blake/yolo2-phase2/spec-compliance.md`. Verification commands executed read-only from repository root; both suites and all recomputations were run at `HEAD 1bd70f2e` with a clean worktree.
