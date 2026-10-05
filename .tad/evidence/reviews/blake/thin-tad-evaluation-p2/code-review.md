# Code Review: thin-tad-evaluation-p2 (runner.mjs + runner.test.mjs)

Scope: code safety + test integrity only. No files modified.
Verdict: **CONDITIONAL** (0×P0, 2×P1, 1 observation). Tests: 22/22 pass offline.
Verified: `node --check runner.mjs` ok; `node --test runner.test.mjs` → 22 pass, 0 fail.

## PASS checks
- Subprocess: `spawn(ocBin(), argv, …)` argv-only, no `shell` (runner.mjs:267);
  `detached` PGID + SIGTERM→5s→SIGKILL (298-309); TIMEOUT_MS 300000 (62,310);
  MAX_BUFFER 50MB + trace streaming w/ cap (64,280-289); `close`/`error`
  double-finish guarded by `settled` (292-297).
- Binary via `TAD_OPENCODE_BIN` (75-77); env allowlist + strip PILOT_*/keys/TAD_*
  (117-140), applied inside `spawnOc` (268); static test asserts
  detached + override + no fetch/eval/execSync (test:39-50).
- Fail-closed: missing binary → BLOCKED adapter-ineligible (447-448,490);
  breach → `Negative control breached` (459-470,491); canary fail →
  `Positive control failed` (472-480,492); truncation →
  `ADAPTER_INELIGIBLE: BASELINE_TRUNCATED` (489); all require
  `probe_passed` + exit 1 / throw ADAPTER_INELIGIBLE (484,765,774,809).
- Budget: 27th `reserve()` throws BUDGET_EXCEEDED (394-400, test 160-170);
  per-arm ≤1 + total ≤2 infra retries (565,401-403, test 183-195);
  COMPLETED never retried (574-577, test 196-207); 3-consecutive circuit
  (405-410, test 171-182); MODEL_LEAKAGE assertion (363-367,575, test 208-220).
- Tests: 22 tests doubles-only (injected harnessReader/fakeExec/readRun/scorer);
  only real spawn is local `node --help` (test:61); negative/positive controls
  assert real failure branches (107-157); frozen bundle read-only (writes → tmpdir).
- Stdlib-only imports (`node:` ×6, runner.mjs:37-42); scoring delegated to
  pilot.mjs `scoreArtifact`/`judgeStatus` (615-616); no USD strings (grep NO_USD).

## Findings
- P1 runner.mjs:151 — `siblingProbePath()` defined but never called; probe loop
  (443) checks only 2 canonical paths, handoff §4.2 also requires sibling-repo
  negative control (`../买卖/README.md`-class). Fix: include sibling path in
  `forbidden` list or delete dead helper + waive in handoff.
- P1 runner.mjs:568 vs :70 — live infra-retry waits `setTimeout 0`, mandated
  10s backoff (`RETRY_BACKOFF_MS=10000` defined, never used). Fix: use the
  constant (keep 0/override under test doubles).
- OBS — `classifyOutcome` (369-377) maps every `!ok` spawn to FAILED_INFRA and
  circuit counts retries not runs; consistent with handoff §4.4 here (infra =
  nonzero/timeout/429/5xx), but terminal FAILED_INFRA resets consecutive count
  (571) so "3 consecutive runs" fuse is narrower than worded. Accept or reword.

## Gate recommendation
CONDITIONAL → fix/waive the 2 P1s before Gate 3 sign-off. No P0 blocks probe,
budget, isolation, or scoring integrity.

## Fix round (Blake, 2026-09-08)
- P1 (dead sibling helper) RESOLVED: sibling path wired into the forbidden list (3 legs), covered by unit test.
- P1 (0ms backoff) RESOLVED: default `RETRY_BACKOFF_MS` (10s) with injectable override for tests.
- OBS (fuse scope) accepted as designed: handoff §4.4 defines the fuse over infra events; terminal FAILED_INFRA resetting the streak matches "consecutive infra failures" wording.
- Re-verify: 23/23 tests pass, probe fail-closed intact. Verdict after fix: PASS.
