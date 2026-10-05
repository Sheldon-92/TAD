Model: harness=opencode | model=muse-spark-1.3-contributor | route=opencode-go
Reviewer: gate2-code-reviewer (independent session)
Verdict: CONDITIONAL PASS
Target: HANDOFF-20260908-thin-tad-evaluation-p2.md v1.1 (design pre-handoff Gate 2, code/execution-safety lens)
Date: 2026-09-08
Carrier: .tad/evidence/reviews/alex/thin-tad-evaluation-p2/round1-code-review.md

## Findings

**P0-1 (§9.1 AC0 — unbound `assert`, verification one-liner throws ReferenceError):** AC0's Verification Method is `node ... probe | node -e 'const fs = require("node:fs"); const r = JSON.parse(fs.readFileSync(0)); assert.strictEqual(...); assert.strictEqual(...);'` — it calls `assert.strictEqual` but never requires `node:assert`. Post-impl execution fails with `ReferenceError: assert is not defined`, so the start-probe gate (the single most safety-critical AC) is unverifiable as specified. §6.7's dry-run claim ("command syntax verified with node -e") is therefore false for AC0. Required fix: add `const assert = require("node:assert");` to the `node -e` snippet, exactly as was done for AC3/AC5/AC7 per the §9.2 audit trail.

**P0-2 (§9.1 AC2 — unbound `assert`, model-lock verification throws ReferenceError):** AC2's second conjunct is `node -e 'const fs = require("node:fs"); const m = JSON.parse(...); assert(m.runs.every(...))'` — bare `assert(...)` with no `require("node:assert")`. Same ReferenceError; the runtime model-identity lock (no second model / no silent downgrade) cannot be verified as specified, and §6.7's "verified model string and runtime assertion" claim is overstated. Required fix: add `const assert = require("node:assert");` to the snippet.

**P1-1 (§4.1 — no explicit `shell:false` / execFile-only mandate):** §4.1 says "严格参数化数组" with an `execFile`-shaped example but never explicitly forbids `child_process.exec`/`execSync` with a shell string or `shell:true`. An implementer can satisfy the letter (array-looking args joined into a string) while reintroducing shell injection via `tempDir`/`case_id`. Required fix: state "MUST use `execFile`/`spawn` with `shell:false` (default); MUST NOT use `exec`/`execSync`/any `shell:true`".

**P1-2 (§4.1/§3.1 — vague "必要模型凭证" exception contradicts env scrub):** §4.1 Tier-1 scrub strips `PILOT_PRIVATE_ROOT`, `PILOT_SOURCE_ROOT`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, "TAD session 变量" but permits "仅保留…必要模型凭证" — an unbounded exception through which a private key can leak back in. Required fix: replace with a closed allowlist (e.g. `PATH`, `HOME`, `USER`/`LOGNAME`, plus one explicitly named credential var required by `oc-run`, nothing else).

**P1-3 (§4.2 — negative control canonicalization inconsistent with claimed fix):** §9.2 claims P0-4 resolved via "`fs.realpathSync` 绝对路径", and §3.1 says paths are "解析为绝对路径 (`fs.realpathSync`)", but §4.2's operative sketch defines `CANON_* = path.join(REPO_ROOT, ...)` and `path.resolve(REPO_ROOT, '../买卖/README.md')` with no `realpathSync`. Symlinked checkout → non-canonical probe path → false pass. Required fix: canonicalize with `fs.realpathSync` on both probe paths and the workspace check, in §4.2 text.

**P1-4 (§4.2 — compliance-prompt probe vs mechanism probe gap):** "让受测 harness 尝试读取" is unspecified as to mechanism: if the read attempt is an LLM dialogue request ("please try to read X"), a refusal proves obedience, not filesystem isolation. Required fix: specify the read is attempted through the same tool/filesystem channel the harness grants the model, with pass/fail decided on exit-code/content-match (exact canary-uuid equality for positive; byte-match against oracle content for negative), not on refusal language.

**P1-5 (§4.2/AC4 — arm-fidelity check is self-attested, method under-specified):** §4.2 cites "依据 scope-approval.json 条件 1" but gives no concrete harness-side check (e.g. harness echoes loaded file list + hashes/lengths compared against `baseline.json` manifest). AC4 only asserts manifest fields (`arms_verified==true`, `baseline_file_count==13`) — the runner attesting to itself. A truncated baseline with a lying manifest passes. Required fix: specify the harness-loading evidence (loaded-file inventory with SHA/char-count vs frozen manifest) and point AC4 at that evidence, not just the manifest flag.

**P1-6 (§9.1 AC0/AC2/AC5 — brittle or weak assertions):** (a) AC0 pipes probe stdout into `JSON.parse(fs.readFileSync(0))` but §4.2 never imposes exactly-one-JSON-document stdout discipline on `probe` — any log line breaks verification; require it. (b) AC2's `grep -F` proves the authorized model string is present, not that no second model is present; add a negative assertion (e.g. fail on any second `--model` value / second known model id). (c) AC5 asserts `scored_count==24` strictly, which fails on legitimate BROKEN pairs (§4.4 allows them); allow `scored + broken == 24` or document full-matrix expectation.

**P1-7 (§4.4/AC3 — budget counters under-asserted, manifest schema unlocked):** AC3 checks `planned_runs==24`, `executed in [24,26]`, 12 cases, no breach — but never verifies per-arm retry ≤1, total infra retries ≤2, the 27th-attempt `BUDGET_EXCEEDED` throw, or the consecutive-3-infra breaker. `manifest.json` field names (`executed_runs`, `budget_exceeded`, `cases_covered`, `infra_retries`) exist only implicitly inside AC snippets, unlike the locked `pair-summary.json` top-level schema in §4.6. Required fix: lock the manifest schema in §4.4 and extend AC3 (or a new AC) with retry-counter and breaker assertions; unit-test the 27th-attempt throw offline per §8.1.

**P2-1 (§9.1 AC6 — `$` alternative makes the gate flaky, direction is safe):** `! grep -riE 'usd|\$|dollar|cents'` is correctly fail-closed in form (negated grep), but bare `\$` matches any literal `$` (shell vars, template literals in `trace.log`), so legitimate runs can fail AC6. Fail-closed direction means no bypass — P2 only. Consider scoping to token/currency key names (e.g. `usd|cost_usd|price|dollar|cents`) or scanning only `run.json`/`pair-summary.json`.

**P2-2 (§4.1 — `process.kill(-pid)` is POSIX-only, no platform guard):** Negative-PID group kill throws on Windows; §4.1 already scopes to POSIX but gives no fallback/guard. Add `process.platform` guard or documented POSIX-only precondition in §8.4.

**P2-3 (§7.4 — grounding depth understates MQ2 evidence):** Grounded-against lists `pilot.mjs` as "head 50 lines read", yet `scoreArtifact` (line 271), `judgeStatus` (line 404) live far beyond line 50 — a 50-line read cannot support MQ2. I independently verified all three exports exist (`privateRoot` L42, `scoreArtifact` L271, `judgeStatus` L404; signature `scoreArtifact(family, artifact, key)` matches §4.6). Fix the grounded line to reflect actual verification depth.

**P2-4 (§4.2 — ambiguous OR-violation string; §8.4 — missing budget row):** The probe-failure `violation` message merges negative-breach and positive-failure with "OR" — require distinct codes for audit. §8.4 should gain an explicit BLOCKED row for `BUDGET_EXCEEDED` / consecutive-3-infra breaker (currently only implied by §4.4).

## AC check

- **AC0:** FAIL — unbound `assert` (P0-1). Otherwise syntactically plausible (`fs.readFileSync(0)` reads piped stdin; `JSON.parse(Buffer)` coerces).
- **AC1:** PASS — `node --check` + `node --test` is valid and executable post-impl.
- **AC2:** FAIL — unbound `assert` (P0-2); `grep -F` also only proves presence, not absence of a second model (P1-6b).
- **AC3:** PASS (weak) — syntactically valid, both requires present, range check correct; under-asserts retry/breaker counters (P1-7).
- **AC4:** PASS (weak) — syntactically valid with both requires; verifies self-attested manifest fields rather than harness-side loading (P1-5).
- **AC5:** PASS (brittle) — syntactically valid; strict `==24` conflicts with legal BROKEN pairs (P1-6c).
- **AC6:** PASS — fail-closed `! grep -riE ...` form is correct and executable; flakiness risk from bare `$` noted (P2-1). No inversion (prior P0-2 genuinely fixed).
- **AC7:** PASS — syntactically valid, both requires present; correctly asserts absence of `overall_combined_win_rate`/`pooled_summary`.
- **AC8:** PASS — `git diff --stat HEAD -- .agents/ .claude/ .tad/hooks/ .tad/config.yaml` is valid; all four paths exist in repo (verified `.claude/` present); matches §3.2 scope ban.

Grounded-file verification (my independent checks): `scoreArtifact`/`judgeStatus`/`privateRoot` all exist in `experiments/thin-tad-pilot/pilot.mjs` with matching call signature — MQ2 reuse claim TRUE. `scope-approval.json` exists with the 13-file condition and the P2-must-verify-loading condition — fidelity requirement is real and cited. Oracle files (`oracles/approved.json`), `SOURCE-MAP.md`, and sibling `../买卖/` all exist, so negative-control targets are non-vacuous.

## Verdict justification

The safety architecture is substantive and almost entirely sound: TAD_OPENCODE_BIN resolution, parameterized argv, detached process-group SIGTERM→SIGKILL, 300s/50MB bounds, two-tier fail-closed probes exiting 1 with `ADAPTER_INELIGIBLE`, 24+2/26 hard-stop with `BUDGET_EXCEEDED`, infra-vs-model retry distinction, fail-closed AC6 regex, BLOCKED-with-no-substitute friction rows, and locked H/V-split schema are all correctly specified and consistent with the Epic's Phase 2 scope. What blocks a clean PASS is narrow but load-bearing: the two verification one-liners that Gate 3 must execute to prove isolation (AC0) and model-lock (AC2) both reference an unrequired `assert` and will throw `ReferenceError` exactly when used — the same defect class the §9.2 trail already treated as P0 for AC3/AC5/AC7 but missed in AC0/AC2, invalidating §6.7's dry-run claims for those two. CONDITIONAL PASS because both P0s are one-line fixes with the exact remedy specified; Blake must apply P0-1/P0-2 (closed in handoff v1.2; re-execute at Gate 3 Layer 1) before Gate 3 Layer 1.

Resolution note (Alex, v1.2): P0-1/P0-2 fixed in handoff v1.2 (§9.1 AC0/AC2 now require `node:assert`). Re-execution of both one-liners is a Blake Gate 3 Layer 1 duty.
