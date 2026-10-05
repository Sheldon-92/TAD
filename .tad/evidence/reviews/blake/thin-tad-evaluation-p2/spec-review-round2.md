# Spec-Compliance Review — Round 2 (TAD Gate 3 Layer 2)

**Task:** TASK-20260908-thin-tad-evaluation-p2 (Phase 2.1–2.4, AC0–AC8, CODE level)
**Reviewer role:** Independent spec-compliance reviewer (read-only; no code modified)
**Date:** 2026-09-08
**Sources read (no summaries trusted):**
- `.tad/active/handoffs/HANDOFF-20260908-thin-tad-evaluation-p2.md` (§3.1, §4, §6.1, §9.1)
- `experiments/thin-tad-pilot/runner.mjs` (931 lines)
- `experiments/thin-tad-pilot/runner.test.mjs` (293 lines, 23 tests)
- Live evidence bundle: `.tad/evidence/experiments/thin-tad-pilot/arms/baseline.json` (13 files),
  `arms/candidate.md` (present), `oracles/approved.json` (12 cases)

## Verdict: PASS (code-level; live-run portions CODE-SAT / LIVE-BLOCKED)

No P0 findings. 2 × P1 + 4 × OBS below. All AC0–AC8 are satisfied at the code +
offline-test level; live-run-dependent assertions (manifest.json, pair-summary.json)
are honestly unproducible here because the subject binary `oc-run` is absent and
fabricating those artifacts would be dishonest (both files confirmed absent).

## Per-AC table (CODE level only)

| AC | Criterion (§9.1) | Rating | File:line evidence |
|---|---|---|---|
| AC0 | Probe + baseline fidelity | CODE-SAT / LIVE-BLOCKED (pass-path) | `runner.mjs:425-516` probeIsolation (Tier1 env+symlink, Tier2 neg/pos, fidelity gate, fail-closed `adapter_eligible:false/ACTION:ABORT/exit 1`); `runner.mjs:168-185` fidelity (13-file count+sha); live `probe` here correctly returns `probe_passed:false, adapter_eligible:false, ABORT, exit 1` (binary absent = EXPECTED, not a defect); offline pass-path covered by `runner.test.mjs:139-150` clean-double test |
| AC1 | Syntax + offline tests | CODE-SAT | `node --check` clean on both files (Layer-1 cross-check below); `node --test`: 23/23 pass; stdlib-only + no-shell enforced by `runner.test.mjs:39-50` |
| AC2 | Model/harness lock + runtime assertion | CODE-SAT / LIVE-BLOCKED (manifest leg) | Single lock `MODEL_ID` `runner.mjs:58`, `HARNESS_ID` `runner.mjs:59`, argv pin `runner.mjs:250-260` (`--model/--temperature 0/--seed 42/--dir`), `TAD_OPENCODE_BIN` override `runner.mjs:75-77`; runtime `assertModelIdentity` `runner.mjs:366-370` throws `MODEL_LEAKAGE_DETECTED`, enforced in `executeArm` `runner.mjs:580` + `cmdRunPair/cmdRunAll` `runner.mjs:802,839`; no second model string in source (`runner.test.mjs:54`); manifest-identity leg un-runnable (no manifest — EXPECTED) |
| AC3 | 24 runs, budget 26, fuse, BROKEN | CODE-SAT / LIVE-BLOCKED (manifest leg) | `PLANNED_RUNS=24` `runner.mjs:65`, `MAX_INVOCATIONS=26` `runner.mjs:66`, `reserve()` throws `BUDGET_EXCEEDED` `runner.mjs:397-403`; per-arm1 (`runner.mjs:68,570`) + total2 (`runner.mjs:67,404-406`) retries; interleaved 24-step schedule `runner.mjs:598-605` tested `runner.test.mjs:94-103`; 27th-call + fuse-counter unit tests `runner.test.mjs:160-182`; BROKEN/`pair_delta:null`/ledger-kept `runner.mjs:657-660,681-682` tested `runner.test.mjs:275-284`; executed-manifest leg un-runnable (no manifest — EXPECTED). One P1: cross-arm fuse reset (P1-1) |
| AC4 | 13-file arm fidelity + candidate | CODE-SAT / LIVE-BLOCKED (manifest leg) | `EXPECTED_BASELINE_FILES=13` `runner.mjs:71`; `checkBaselineFidelity` `runner.mjs:168-180` (count + sha presence, `arms_verified`); verified live against frozen bundle: `baseline.json` = 13 files, `candidate.md` present; offline test `runner.test.mjs:88-93`; probe hard-gates on `!arms_verified` → `ADAPTER_INELIGIBLE: BASELINE_TRUNCATED` `runner.mjs:492`; manifest `arms_verified/baseline_file_count` leg un-runnable (EXPECTED) |
| AC5 | P1 scorer reuse, scored+unscorable=24 | CODE-SAT (offline) / LIVE-BLOCKED (real-oracle leg) | `buildSummary` imports, never reimplements: `scoreArtifact`+`judgeStatus` from `./pilot.mjs` `runner.mjs:620-621` (comment lock `runner.mjs:34-35`); both exist in `pilot.mjs:271,404`; BROKEN-aware `scored_count+unscorable_infra_arms` `runner.mjs:624-625,705-714` tested with doubles `runner.test.mjs:264-273`; FAILED_INFRA-without-artifact counted unscorable, never scored `runner.mjs:657-660`; full 24-artifact-vs-oracle leg un-runnable without live runs (EXPECTED) |
| AC6 | Raw tokens, null-not-0, partial, no USD | CODE-SAT | `parseTelemetry` null-preserving `runner.mjs:348-364` (tested `runner.test.mjs:248-253`); `writeRunJson` `partial:true`-on-null `runner.mjs:586-594` (tested `runner.test.mjs:231-242`); `tokensPerAccepted` null-on-0 `runner.mjs:607-611` (tested `runner.test.mjs:243-247`); precise grep `usd\|dollar\|cents` over both source files = 0 hits (only `$` hits are JS template-literal interpolations; only `cost` hit is a code comment); `human_seconds:0` `runner.mjs:590`; retry spend kept in ledger `runner.mjs:650-656` |
| AC7 | H/V split, exactly 3 top keys, no pooled field | CODE-SAT (offline) | Doc builds exactly `{H_calibration, V_holdout, metadata}` `runner.mjs:692-715` with `metadata.disclaimer` = spec string `runner.mjs:72-73,707`; allowlist-tested `runner.test.mjs:264-273` (`deepStrictEqual` keys + `!overall_combined_win_rate` + `!pooled_summary` + 6/6 case split + scored+unscorable=24); zero-accepted→null tested `runner.test.mjs:285-292` |
| AC8 | Scope, privacy, production zero-intrusion | CODE-SAT | All writes confined to tmp workspaces / run dirs / `RUNS_ROOT` (gitignored evidence): `runner.mjs:193,230,237,241,283,478,587,592,765-766,854-855,885-886,895-896` — zero references to `.agents/`, `.claude/`, `.tad/hooks`, `.tad/config.yaml` as write targets; only in-scope paths touched: `runner.mjs`+`runner.test.mjs` (new, untracked) + `README.md` (+42 lines); env allowlist strips `PILOT_*`/keys/session vars `runner.mjs:117-140` (tested `runner.test.mjs:67-84`); pre-existing working-tree dirt outside the pilot dir is mode-only changes + unrelated doc deletions, 0 added production lines attributable to this task |

## Findings

**P1-1 — Cross-arm consecutive-infra fuse never fires in `run-all`** (`runner.mjs:576,581,414-416`):
terminal `FAILED_INFRA` calls `noteSuccessOrModel()`, resetting `consecutiveInfra` to 0, so
three consecutive failed *runs* across arms can never reach `CONSECUTIVE_INFRA_ABORT=3`
(demonstrated: fail→reset→fail→reset→fail leaves `consecutiveInfra=1`, no `INFRA_CIRCUIT_OPEN`).
§4.4 requires abort after 3 consecutive infra-failed runs. Impact is bounded and fail-safe
(26-call ceiling still hard-stops; aftermath honestly marked BROKEN) — hence P1, not P0.
Fix: in `executeArm`'s terminal-`FAILED_INFRA` path, increment (not reset) the consecutive
counter and throw `INFRA_CIRCUIT_OPEN` at 3; reset only on COMPLETED/model-verdict runs.
Note the existing fuse unit test (`runner.test.mjs:171-182`) drives the counter directly and
does not catch this path-level reset.

**P1-2 — `classifyOutcome` maps every non-ok spawn to `FAILED_INFRA`, even with structured
model-failure output** (`runner.mjs:372-385`): a nonzero exit accompanied by parseable
telemetry indicating a model-logic failure is retried once as infra, against §4.4's
"model failure → never retry". Bounded (1/arm, 2 total) and fail-safe in direction
(extra evidence, never a skipped retry that hides success), but the retry ledger will
attribute one model-shaped failure as infra. Fix: if `telemetry.raw` exists and exit is a
clean model-level non-zero (no infra signature), return a non-retriable model outcome.

**OBS-1 — Sibling negative-control leg differs from the §4.2 example path**
(`runner.mjs:152-156` uses `../agent-workshop/.tad/evidence/reviews/alex-acceptance.md`;
handoff example cites `../买卖/README.md`). Both files exist; the coded leg is a real
external-repo file outside `REPO_ROOT` (test asserts this, `runner.test.mjs:221-227`),
so isolation intent is preserved. Suggest aligning the spec example or accepting the
coded path as the canonical leg.

**OBS-2 — Forbidden-path canonicalization is a no-op map** (`runner.mjs:446`:
`.map((p) => fs.realpathSync(REPO_ROOT) && p)` resolves the repo root but returns `p`
unresolved). Paths are already absolute via `path.join/resolve`, and the content-match
check (`runner.mjs:462-472`, 64-char slice) prevents false-pass on error echoes, so risk
is low; resolving each leg with `fs.realpathSync` would close the symlink-alias gap
§9.2 (ai-evaluation P0-4) intended.

**OBS-3 — `countInvocations()` falls back to `PLANNED_RUNS` with no manifest**
(`runner.mjs:742-749`): a `summary` run before any matrix would stamp
`total_executed_invocations: 24` without evidence. Best-effort labeled, but suggest
`null` + `partial:true` when no manifest exists.

**OBS-4 — Budget is per-CLI-invocation, not cross-invocation** (`runner.mjs:874-879`):
twelve `run-pair` calls plus a `run-all` could cumulatively exceed 26 harness calls;
only an audit note is persisted (`budget-audit.json`). Acceptable for the authorized
flow (one `run-all` = one matrix), but the ceiling is not enforced across CLI calls.

## Layer-1 cross-check (as run by this reviewer)

- `node --check experiments/thin-tad-pilot/runner.mjs` → OK
- `node --check experiments/thin-tad-pilot/runner.test.mjs` → OK
- `node --test experiments/thin-tad-pilot/runner.test.mjs` → 23 pass / 0 fail (7 suites)
- Live `node experiments/thin-tad-pilot/runner.mjs probe` → `probe_passed:false,
  adapter_eligible:false, action:ABORT, exit 1` (fail-closed on missing `oc-run`; EXPECTED)
