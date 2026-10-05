# Fix-verification addendum Round 2 (Gate 3 Layer 2 delta)
Scope: 2 P1s in runner.mjs; read-only review, no code modified.
P1-a terminal-infra fuse: RESOLVED — runner.mjs:419 noteTerminalInfra defined; :587 terminal FAILED_INFRA path calls noteTerminalInfra (not noteSuccessOrModel); :412/:421 throw INFRA_CIRCUIT_OPEN at 3 consecutive.
P1-b FAILED_MODEL no-retry: RESOLVED — runner.mjs:378 classifyOutcome returns FAILED_MODEL on nonzero exit WITH telemetry.raw and no infra signal; :590-595 executeArm surfaces FAILED_MODEL terminally with :593 assertModelIdentity and :594 streak reset.
Regression tests: runner.test.mjs:228 FAILED_MODEL-no-retry (1 call, infra_retries 0, streak 0); :242 3-terminal-fuse (r1/r2 FAILED_INFRA, 3rd rejects INFRA_CIRCUIT_OPEN). Both present.
Observed: `node --check` runner.mjs OK; `node --check` runner.test.mjs OK; `node --test` 25 pass / 0 fail (7 suites).
Invariants hold: :66 MAX_INVOCATIONS 26 + :401 BUDGET_EXCEEDED; :68 per-arm-1 + :581 gate, :67 total-2 + :407 gate; :710-733 3-key H_calibration/V_holdout/metadata; no USD/currency strings (only prohibitive comment :18); single model opencode-go/muse-spark-1.3-contributor (:58, test :51-58).
FINAL: PASS
