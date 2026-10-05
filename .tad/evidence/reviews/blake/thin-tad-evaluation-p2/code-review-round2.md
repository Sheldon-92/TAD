# Code Review Round 2 — thin-tad-pilot runner (Gate 3 Layer 2)

- Scope: code safety + test integrity ONLY (no judgment on experimental design or statistics).
- Files: `experiments/thin-tad-pilot/runner.mjs` (~931 lines), `experiments/thin-tad-pilot/runner.test.mjs` (293 lines).
- Mode: read-only review. No code was modified.
- Reviewer: independent, no prior context.

## Verdict: PASS

All in-scope safety properties hold with file:line evidence below. Zero P0, zero P1. Four OBS-grade notes (non-blocking).

## Layer-1 command outputs (executed by reviewer from /home/box/云同步/TAD)

- `node --check experiments/thin-tad-pilot/runner.mjs` → OK (`RUNNER_CHECK_OK`)
- `node --check experiments/thin-tad-pilot/runner.test.mjs` → OK (`TEST_CHECK_OK`)
- `node --test experiments/thin-tad-pilot/runner.test.mjs` → 23 pass / 0 fail, 7 suites (node v20.19.2, ~332 ms)
- Import scan: runner imports are `node:fs`, `node:path`, `node:os`, `node:crypto`, `node:url`, `node:child_process` (`spawn` only). No `fetch(`, no `eval(`, no `execSync`, no bare `execFile(`, no `shell: true`.

## PASS checks (with evidence)

(a) Subprocess safety — PASS
- argv-array spawn, no shell: `spawn(ocBin(), argv, {...})` with no `shell` option — runner.mjs:270-275.
- Binary via `TAD_OPENCODE_BIN` fallback: `ocBin()` returns `process.env.TAD_OPENCODE_BIN || 'oc-run'` — runner.mjs:75-77.
- Detached process-group kill, SIGTERM grace then SIGKILL: `detached: process.platform !== 'win32'`, `process.kill(-child.pid, 'SIGTERM')`, inner `setTimeout(..., KILL_GRACE_MS)` then `process.kill(-child.pid, 'SIGKILL')` — runner.mjs:273,301-312 (`KILL_GRACE_MS = 5000`, runner.mjs:63).
- 300 s timeout: `TIMEOUT_MS = 300000` (runner.mjs:62), enforced by `setTimeout(..., TIMEOUT_MS)` (runner.mjs:313).
- 50 MB buffer cap with trace streaming: `MAX_BUFFER = 50 * 1024 * 1024` (runner.mjs:64); `onData` stops accumulating past the cap, writes `[truncated: buffer cap]` marker to the trace stream (runner.mjs:283-292).
- error/close double-finish guard: `settled` flag in `finish()` (runner.mjs:282,295-300); both `error` and `close` handlers clear the timer and go through `finish` (runner.mjs:314-321).

(b) Env sanitation — PASS
- Allowlist approach: `ENV_ALLOW` (PATH, HOME, USER, LOGNAME, SHELL, LANG, LC_*, TZ, TMP*, TAD_OPENCODE_BIN) — runner.mjs:117-120; `sanitizeEnv` copies only allowlisted keys, defaults PATH — runner.mjs:122-130.
- Stripping covers `PILOT_*`, `KEY|TOKEN|SECRET|PRIVATE`, `TAD_*` (except `TAD_OPENCODE_BIN`) — runner.mjs:132-140.
- Applied inside the spawn path: `env: sanitizeEnv(env)` in `spawnOc` (runner.mjs:271); `executeArm` passes raw `process.env` and relies on that inner sanitation (runner.mjs:566) — single centralized gate, no bypass.

(c) Fail-closed probe — PASS
- Missing binary → ineligible/ABORT, never pass: `harnessNote` + `violation = adapter-ineligible` (runner.mjs:450-451,493); `probePassed` requires `reader.available` (runner.mjs:486-487); `action: ABORT` (runner.mjs:501); `cmdRunPair`/`cmdRunAll` throw `E1('ADAPTER_INELIGIBLE', ...)` (runner.mjs:779,814); `cmdProbe` exits 1 (runner.mjs:768-771).
- Negative-control breach → fail: `negativeBlocked = false` on forbidden-content match (runner.mjs:468-471) → violation `Negative control breached` (runner.mjs:494).
- Positive-control failure → fail: canary round-trip (runner.mjs:475-483) → violation `Positive control failed` (runner.mjs:495).
- Baseline truncation → ineligible: `ADAPTER_INELIGIBLE: BASELINE_TRUNCATED` with found/expected counts (runner.mjs:492).

(d) Budget enforcement — PASS
- 27th invocation throws: `MAX_INVOCATIONS = 26` (runner.mjs:66); `reserve()` throws `BUDGET_EXCEEDED` at ceiling (runner.mjs:397-403). Per-call fresh `Budget` (no cross-CLI resume) is deliberate and documented (runner.mjs:874-879).
- Per-arm ≤1 and total ≤2 infra retries: `MAX_INFRA_RETRY_PER_ARM = 1` + `MAX_TOTAL_INFRA_RETRIES = 2` (runner.mjs:67-68); enforced jointly at runner.mjs:570 (`infraRetries < MAX_INFRA_RETRY_PER_ARM && budget.canRetryInfra()`).
- 10 s backoff wired on live path: `RETRY_BACKOFF_MS = 10000` (runner.mjs:70); live default via `retryDelayMs ?? RETRY_BACKOFF_MS` (runner.mjs:573) — CLI callers omit `retryDelayMs` (runner.mjs:785,822); `retryDelayMs: 0` appears only in test doubles.
- Model-logic failures never retried: `COMPLETED` returns immediately with no retry branch (runner.mjs:579-582); scoring verdicts happen later in `buildSummary`, outside the retry loop.
- Consecutive-infra fuse: `CONSECUTIVE_INFRA_ABORT = 3` (runner.mjs:69); third consecutive `noteInfraRetry` throws `INFRA_CIRCUIT_OPEN` (runner.mjs:407-413); reset only on success/model outcome (runner.mjs:414-416,576,581).

(e) Accounting honesty — PASS
- Missing token fields stay null, never 0-filled: `pick()` returns null unless a finite number (runner.mjs:350-357); `parseTelemetry` yields nulls on unparseable stdout (runner.mjs:348-364).
- `partial:true` flag: set in `writeRunJson` when any token/elapsed field is null (runner.mjs:588-591) and in summary metadata when any bucket has nulls (runner.mjs:716).
- `tokens_per_accepted` null on zero success: early `if (accepted === 0) return null` (runner.mjs:607-611); null-propagating division + `sumPart` null barrier (runner.mjs:686-690).
- No USD/currency/second-model strings: only occurrence of "currency" is the comment "No currency conversion is performed anywhere in this file" (runner.mjs:18); no USD/dollar/price tokens; pinned single model only (runner.mjs:58), second-model names absent.

(f) Test integrity — PASS
- Injected doubles only: `harnessReader` doubles for probe (runner.test.mjs:107-157), `fakeExec` executors (runner.test.mjs:186-220), `readRun`/`scorer` doubles for summary (runner.test.mjs:257-292). No `oc-run` binary, network, or model calls.
- No writes to frozen bundle: all test writes go to `os.tmpdir()` mkdtemp dirs (`runner-arm-`, `runner-run-`, runner.test.mjs:190,203,215,232) or `makeWorkspace` tmpdir; frozen-bundle access is read-only (`readFileSync` of oracles/baseline/exports). Only CLI invocation is `--help` (exit 2, no writes; runner.test.mjs:61-63).
- Negative/positive/budget/fuse paths asserted: breach (runner.test.mjs:107-126), positive-fail (127-138), clean-pass (139-150), missing-binary (151-156), 26+1 budget (160-170), circuit (171-182), infra-retry-once (183-195), no-model-retry (196-207), model-leakage (208-220), backoff default + sibling leg (221-227).
- Stdlib-only imports in runner verified by reviewer directly (see Layer-1 outputs). Test file adds only stdlib (`node:test`, `node:assert/strict`, `node:child_process` `execFileSync` used with argv array for the `--help` gate — no shell).

## Findings

P0: none. P1: none.

- OBS-1 — Header comment (runner.mjs:7) claims "no dynamic import", but `buildSummary` uses `await import('./pilot.mjs')` (runner.mjs:620-621). Benign (static literal, frozen P1 scorer delegation) but the comment is inaccurate; reword to "no dynamic import except the static P1 scorer delegation".
- OBS-2 — `classifyOutcome` (runner.mjs:372-385): the last two branches both return `'FAILED_INFRA'`, making the `if (!telemetry.raw)` check dead code. Fail-safe direction (bounded single retry), but collapse or differentiate to avoid implying a model-failure path exists here.
- OBS-3 — `writeRunJson` stamps constant `human_seconds: 0` (runner.mjs:590). Not currency and out of the token-ledger scope, but a hardcoded zero elapsed field could mislead; prefer omitting it or recording a real measurement.
- OBS-4 — `countInvocations` falls back to `PLANNED_RUNS` when no manifest exists (runner.mjs:742-749), so `metadata.total_executed_invocations` can report 24 before anything ran. Labeled best-effort in-code; consider `null` + partial flag instead of the planned count.

## Layer-1 raw tail (`node --test`)

`# tests 23, # suites 7, # pass 23, # fail 0, # cancelled 0, # skipped 0` (full TAP log in shell history; head shows static-gates and env-hygiene suites passing, tail shows token-accounting and segregated-summary suites passing).
