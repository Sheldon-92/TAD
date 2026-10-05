Model: harness=opencode | model=muse-spark-1.3-contributor | route=opencode-go
Reviewer: gate2-ai-evaluation-reviewer (independent session)
Verdict: CONDITIONAL PASS
Target: HANDOFF-20260908-thin-tad-evaluation-p2.md v1.1 (design pre-handoff Gate 2, AI-evaluation-methodology lens)
Date: 2026-09-08
Carrier: .tad/evidence/reviews/alex/thin-tad-evaluation-p2/round1-ai-evaluation.md

## Findings

**P0-1 (§4.6 + AC7 — merged-win-rate loophole via denylist check).** Defect: §4.6 prose bans "any merged win-rate field," but the machine-enforceable AC7 check (§9.1) only asserts two specific negations: `!s.overall_combined_win_rate && !s.pooled_summary`. A renamed merged field (`total_win_rate`, `combined_summary`, `overall_delta`, `win_rate_diff`) would pass AC7 literally while violating the segregation intent. Required fix: replace AC7's denylist with an exact top-level key allowlist, e.g. `assert.deepStrictEqual(Object.keys(s).sort(), ["H_calibration","V_holdout","metadata"])`, keeping the two negations as defense-in-depth.

**P0-2 (AC5 vs §4.6 schema lock vs BROKEN policy — unsatisfiable conjunction).** Defect: AC5 asserts `s.scored_count === 24` on `pair-summary.json`, but (a) §4.6 locks top-level schema to exactly three keys (metadata/H/V) with no `scored_count` defined anywhere — a literal Blake implementation cannot place it without violating the lock; (b) under the §4.4 BROKEN policy, a case with an irrecoverable `FAILED_INFRA` arm has no artifact to score, so `scored_count` would legitimately be < 24 and the AC5 check would fail on correct behavior. Required fix: define `metadata.scored_count` (or equivalent nested path) in §4.6 AND make AC5 BROKEN-aware, e.g. `scored_count + unscorable_infra_arms == 24` with `unscorable_infra_arms` counting only `FAILED_INFRA` arms, or `scored_count === 24 iff zero BROKEN pairs`.

**P1-1 (AC6 verification overbreadth — `$` false-positive on legitimate artifacts).** Defect: AC6 runs `grep -riE 'usd|\$|dollar|cents'` recursively over all of `runs/`, which per §7.2 includes `trace.log` and `artifact/` directories. Any legitimate `$` in model output (shell scripts, JS template literals, `$HOME`, Makefile `$@`) triggers a false failure of an otherwise honest run. Direction is fail-safe (false alarm, not silent USD reinjection — no USD reinjection path in the accounting design itself, §4.5 is clean), but it makes AC6 unsatisfiable in practice. Required fix: scope the grep to JSON key names and/or exclude `trace.log`/`artifact/` from the currency scan.

**P1-2 (§4.4 fault-classification gap — nonzero exit WITH structured output).** Defect: infra failure is defined as "非零退出且无结构化输出" (conjunction), model failure as "正常完成并产出文件但断言不符". A nonzero exit that still emits structured output matches neither definition literally, leaving retry permission ambiguous. Required fix: add one explicit default-deny sentence, e.g. "any case not positively meeting ALL infra criteria is a model failure with no retry."

**P1-3 (AC3 does not bind the retry budget it claims).** Defect: AC3 checks `executed_runs.length in [24,26]` and `cases_covered == 12` but never asserts `total infra_retries <= 2` or per-arm `infra_retries <= 1`. Required fix: add `sum(infra_retries) <= 2 && every(r => r.infra_retries <= 1)` to the AC3 assertion over `manifest.json`/`run.json`.

**P1-4 (Probe invocations vs the 26-budget — unaccounted).** Defect: §4.4 counts "模型调用" toward 26, but `probe` also drives the harness (`oc-run`) for negative/positive controls. The design never states whether probe harness invocations are inside or outside the budget. Required fix: one sentence stating probe file-op invocations are non-model harness calls excluded from the 26-count (or counted, with the ceiling adjusted).

**P1-5 (Cross-run `/tmp` snooping path — predictable prefix, no cleanup).** Defect: §4.1 creates `/tmp/thin-tad-p2-{case_id}-{arm}-{timestamp}` per run with no cleanup requirement. Runs execute sequentially and interleaved, so a candidate-arm run could glob a prior baseline-arm leftover and read its artifact. Required fix: unguessable random suffix (not just timestamp), post-run workspace archival/removal, and optionally a cross-run negative control.

**P1-6 (Sibling-coverage narrowing).** Defect: §3.1 negative control lists sibling repos as "如 `../买卖/`、`../agent-workshop/`" (two examples) but §4.2 canonicalizes only `path.resolve(REPO_ROOT, '../买卖/README.md')` — `agent-workshop` dropped from the enforceable spec. Required fix: enumerate all in-scope sibling top-level entries (or "every sibling top-level directory of REPO_ROOT") in §4.2.

**P1-7 (Missing V-retirement clause — H-contamination guardrail).** Defect: `readiness.md` P2-entry checklist requires "any candidate change after V freeze retires all V to seen," but the handoff never carries this rule. Required fix: import the retirement sentence verbatim into §3.2 or §4.3.

**P2-1 (§4.4 vs §8.4 "指数退避" wording).** Single fixed 10s wait with max 1 retry per arm is not exponential backoff. Fix wording to "固定 10s 等待".

**P2-2 (Directory-listing exfiltration unprobed).** Negative control tests file-content reads only; `readdir` listing of private/sibling directories is untested. Hardening note.

**P2-3 (`INVALID` records-layer semantics unstated).** MQ4 lists `INVALID` alongside scorer statuses without stating the scorer never emits it. Fix: one sentence clarifying `INVALID`/`FAILED_*`/`ADAPTER_INELIGIBLE` are runner records-layer only.

**P2-4 (§7.4 `pilot.mjs` grounded on head-50 only).** `scoreArtifact(family, artifact, key)` signature assumed from a partial read. Blake must confirm full signature before wiring the scorer call.

Adversarial sweep summary (attempted, outcome): leakage via workspace answers — blocked; silent model substitution — blocked (`reported_model_id` assertion + `MODEL_LEAKAGE_DETECTED`); USD reinjection — no path found; retry gaming — narrowed to the P1-2 classification seam; merged win-rate — bypassable as specified (P0-1); H-contamination — no active path, tripwire missing (P1-7); cross-run snooping — open path (P1-5).

## AC check

- **AC0 (probe + fidelity): PASS.** Two-tier probe with `realpathSync` canonical paths, canary positive control, `ADAPTER_INELIGIBLE` fail-closed exit 1, plus 13-file `BASELINE_TRUNCATED` abort.
- **AC1 (runner syntax + offline tests): PASS.**
- **AC2 (model/harness lock): PASS.** Single-model string locked, runtime `reported_model_id` assertion with abort, no second-model path.
- **AC3 (24 runs + budget): PASS** (core). Hardening gaps P1-2/P1-3/P1-4 do not fail the AC's core.
- **AC4 (arm fidelity): PASS.** 13-file no-truncation verification with abort.
- **AC5 (scoring execution): FAIL** (P0-2: `scored_count` undefined in locked schema and contradicts BROKEN policy).
- **AC6 (token purity, no USD): FAIL as specified** (P1-1: bare-`\$` grep over `trace.log`/`artifact/` false-fails legitimate `$`; accounting design itself is pure).
- **AC7 (H/V segregation): FAIL as specified** (P0-1: denylist check permits renamed merged fields; prose + disclaimer + 3-key lock are correct, the machine check is not).
- **AC8 (scope/privacy/zero-intrusion): PASS.**

## Verdict justification

The methodology core is sound — blind frozen-export consumption with a genuine two-tier attacker-model probe, single-model lock with runtime identity assertion, honest 24/26 budget with BROKEN-pair null-diff plus gross token ledger, pure raw-token accounting, reuse (not rewrite) of the P1 scorer, and H/V strict-split reporting with an explicit V=6 exploratory-only disclaimer — but Gate 3's machine gates are not literally satisfiable as written: AC7's denylist permits a renamed merged win-rate and AC5's `scored_count === 24` contradicts both the §4.6 three-key schema lock and the BROKEN policy's unscorable-arm case, so Blake cannot implement the handoff verbatim. CONDITIONAL PASS with two P0 verification-binding fixes plus seven P1 hardening items; no fundamental redesign needed once the P0s are closed.

Resolution note (Alex, v1.2): P0-1/P0-2 fixed in handoff v1.2 (§4.6 `metadata` gains `scored_count` + `unscorable_infra_arms` with sum-to-24 definition; AC5 BROKEN-aware; AC7 top-level-key allowlist added, denylist kept as defense-in-depth). P1-1–P1-7 / P2-1–P2-4 recorded as Blake-advisory for Gate 3 Layer 1 / implementation hardening.
