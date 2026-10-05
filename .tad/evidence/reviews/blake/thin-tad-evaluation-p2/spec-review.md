# Spec review — P2 runner vs HANDOFF §6/§9.1 (Layer 2, narrow scope)

Verdict: **CONDITIONAL** (no P0; 2 P1, fix before live matrix). Offline code passes; live AC2/3/5/7 honestly BLOCKED (no `oc-run` binary — not a defect).

## §6.1 Phase 2.1–2.4 coverage
- 2.1 Probe+fidelity: `sanitizeEnv`/`envLeakCheck` (runner.mjs:122-140), symlink walk (194-222), neg/pos canary + `BASELINE_TRUNCATED` (422-513), exit 1 (758-767); tests: breach/pos-fail/clean/missing-binary (test:106-157). DONE.
- 2.2 Single-run drive: `makeWorkspace`/`populateWorkspace` (186-243), `buildOcArgv --model … --temperature 0 --seed 42 --dir` (247-257), `ocBin=TAD_OPENCODE_BIN||oc-run` (75-77), `detached`+SIGTERM/SIGKILL+300s+50MB (262-320). DONE.
- 2.3 Matrix+hard-stop: `interleavedSchedule` 24 steps baseline-first (593-600), `Budget.reserve→BUDGET_EXCEEDED`@26 (386-400), per-arm 1 / total 2 / 3-consec fuse (401-414), BROKEN+delta null (676-677). Tests 22/22 incl. 26/27th, fuse, retry-once, no-retry-model (159-221). DONE (minus P1-1).
- 2.4 Scoring+summary: dynamic `scoreArtifact`/`judgeStatus` from `pilot.mjs`, never reimplemented (613-616); null-not-0 + `partial:true` (345-361,583-589); `tokensPerAccepted→null` on 0 (602-606); top keys exactly H/V/metadata (687-710). DONE.

## AC0–AC8
| AC | Result | Evidence |
|---|---|---|
| AC0 probe+fidelity | SATISFIED | live `probe`→exit 1, `adapter-ineligible: binary missing`, fail-closed correct (runner.mjs:490,763-766); fidelity 13/13 in same report; mocks cover breach/pos/clean |
| AC1 syntax+tests | SATISFIED | `node --check` OK; `node --test` 22/22 pass |
| AC2 model/harness lock | CODE-SAT / LIVE-BLOCKED | `MODEL_ID` pinned (58), argv locks (250-253), `MODEL_LEAKAGE_DETECTED` (363-367); manifest assert needs live runs (no binary) |
| AC3 24 runs/budget | CODE-SAT / LIVE-BLOCKED | 24/26/`BUDGET_EXCEEDED`/fuse/interleave in code+tests; `manifest.json` needs live runs |
| AC4 arm fidelity | SATISFIED | probe `baseline_file_count:13, arms_verified:true, candidate_present:true` live; unit asserts 13 (test:87-93) |
| AC5 P1 scoring | CODE-SAT / LIVE-BLOCKED | reuse, no rewrite; `scored+unscorable=24` logic+tests (257-285); `pair-summary.json` needs live runs |
| AC6 raw tokens, no USD | SATISFIED(code) | null-not-0/partial + null-on-0 in code+tests (223-247); forbidden grep clean (see below); live ledger BLOCKED |
| AC7 H/V split | CODE-SAT / LIVE-BLOCKED | exact 3 top keys, no merged field, 6+6, BROKEN intact (test:257-285) |
| AC8 scope/privacy | SATISFIED | only `experiments/thin-tad-pilot/` touched (2 new untracked + README M); `.agents/.claude/.tad/hooks` diffs are mode-only 755→644, zero content lines |

## Forbidden scan (`grep -rniE 'gpt-|claude-3|usd|dollar'` on the two new files)
- Hits: only `runner.test.mjs:54` (`!src.includes('gpt-')…`, negative guard) — NOT a violation. No `usd|dollar` hits. No second model, no currency, no production-TAD content edits, no `pooled_summary`/`overall_combined_win_rate` in `runner.mjs` (test asserts absence, :262-263).

## P0/P1
- P0: none.
- P1-1 `runner.mjs:568`: `RETRY_BACKOFF_MS=10000` defined (70) but `executeArm` waits `setTimeout 0`; §4.4 requires 10s backoff. Wire the constant (keep 0 injectable for tests).
- P1-2 `runner.mjs:144-153,443`: `siblingProbePath()` exported but `probeIsolation` never probes the §4.2 sibling external-repo path (only oracles+SOURCE-MAP). Add sibling path to forbidden list.
- Note (not rated): with binary present, default reader delegates (`readPath` always throws, :541) so `probe` still ABORTs until run-pair sandbox — conservative fail-closed, acceptable; live AC0 PASS only via sandbox path.

## Fix round (Blake, 2026-09-08)
- P1-1 RESOLVED: `executeArm` takes `retryDelayMs ?? RETRY_BACKOFF_MS`; live path waits 10s, tests inject 0. New test pins `RETRY_BACKOFF_MS === 10000`.
- P1-2 RESOLVED: `siblingProbePath()` now resolves the real peer file `../agent-workshop/.tad/evidence/reviews/alex-acceptance.md`; `canonicalForbiddenPaths()` returns 3 legs; new test asserts membership + outside-repo.
- Re-verify: `node --check` OK, `node --test` 23/23 pass, live `probe` still fail-closed (`adapter-ineligible: binary missing`, exit 1), runs/ currency grep clean.
- Verdict after fix: PASS (conditional items closed; live-run ACs remain harness-BLOCKED, not code defects).
