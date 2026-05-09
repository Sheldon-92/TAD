# SPIKE REPORT — Phase 1c: Perf Hardening + AC17 fail-OPEN Fix

**Date:** 2026-04-14
**Spike Dir:** `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/`
**Handoff:** `.tad/active/handoffs/HANDOFF-20260414-phase1c-perf-ac17-fix.md`
**Epic:** EPIC-20260413-symmetric-quality-enforcement (Phase 1c/5)
**Budget:** 4-6h Light TAD spike
**Actual effort:** ~3h

---

## Overall: PARTIAL-GO

**Rationale:** The primary Phase 1c goal — closing the AC17 missing-dep fail-OPEN security hole — is fully achieved (AC1-4 PASS). The exit-code contract is empirically re-verified under Claude Code 2.1.107 (AC9 PASS). Apples-to-apples provenance + CI anti-pattern guards hold (AC12-13 PASS). **However, AC6 perf budget (p95 < 100ms) fails on 2 of 4 hooks on the benchmark host, and AC8 Scenario B timeout-self-abort fails because AC12's byte-preservation constraint explicitly prohibits the `read -t` timeout wrapping that would be needed.** Both failures have clear Phase 3 remediation paths but require Alex's design decision.

Phase 3 production deployment: **CONDITIONAL-GO** — can proceed for AC17/contract/guard guarantees, but perf budget and internal timeout must be addressed in Phase 3 production hook code (explicitly out-of-scope for this spike's apples-to-apples constraint).

---

## AC-by-AC Verdict Table

| AC | Criterion | Verdict | Evidence |
|----|-----------|---------|----------|
| AC1 | `lib/dep-guard.sh` with `require_dep` + PATH pin + whitelist regex + SECURITY comment | **PASS** | `hooks-v2/lib/dep-guard.sh` lines 1-26 |
| AC2 | 4 hooks source dep-guard via `${BASH_SOURCE[0]%/*}`, per-hook `require_dep` | **PASS** | All 4 hooks lines 22-26 (evidence-validator also has `require_dep awk` at line 22) |
| AC3 | `results/ac17-retest.tsv` shows missing_dep PASS, deny triggered, exit 0, no `$dep` interpolation | **PASS** | `results/ac17-retest.tsv` — 4/4 PASS |
| AC4 | AC17 deny output valid JSON per `jq -e .` | **PASS** | `jq_valid=yes` all 4 rows |
| AC5 | `bench-n100.tsv` = 400 rows, per-hook hot-path fixture | **PASS** | `wc -l results/bench-n100.tsv` = 401 (400 data + 1 header); fixtures per-hook in `bench-n100.sh:23-45` |
| AC6 | **All 4 hooks p95 < 100ms (strict, blocking)** | **FAIL (2/4)** | `stats-summary.tsv`: pretool=67.44 ✓, override=52.48 ✓, evidence-validator=156.51 ✗, bash-watcher=130.57 ✗ |
| AC7 | ≥3/4 median < 50ms (non-blocking sanity) | **FAIL (1/4)** | Only override-detector (31.98) under 50. Non-blocking. |
| AC8 | Scenario A + B both PASS (hook self-aborts <3s, deny, valid JSON) | **PARTIAL (A pass, B fail)** | `results/timeout-trigger.tsv`: A elapsed=0.032s, deny, JSON (PASS via EOF-close fail-closed path, NOT explicit timeout); B elapsed=5.023s, killed by outer wrapper (hook did NOT self-timeout) |
| AC9 | Empirical: exit 0 + stdout deny JSON blocks Write under CC 2.1.107 | **PASS** | `results/exit-code-contract.tsv`: file_created=no, claude-output: "The Write was blocked by a PreToolUse hook (`deny-hook.sh`) with message: 'TAD test: exit-0-stdout-deny contract verification'. File not created." |
| AC10 | SPIKE-REPORT.md with Overall + per-AC table | **PASS** | this file |
| AC11 | COMPLETION-REPORT.md exists with Evidence Checklist + Gate 3 attestation + Knowledge Assessment | **PASS** | `COMPLETION-REPORT.md` |
| AC12 | hooks-v2 vs 1b diff ONLY dep-guard lines | **PASS** | `results/apples-to-apples.txt` shows +5 lines per hook (+6 for evidence-validator), all dep-guard; `results/apples-to-apples-verdict.txt`: AC12 PASS |
| AC13 | `grep -rn 'require_dep "\$' hooks-v2/` returns empty | **PASS** | `apples-to-apples-verdict.txt`: AC13 PASS |
| AC14 | Message to Alex quotes p95 from stats-summary.tsv | **PASS** (see Completion Message below) | quoted raw numbers: pretool 67.44 / override 52.48 / validator 156.51 / bash-watcher 130.57 |
| AC15 | Conditional — optimization delta, triggered by AC6 FAIL | **NOT-EXECUTED (design conflict)** | See §Perf Notes below — §4.4 optimization would modify hook code, violating AC12's byte-preservation. Deferred to Phase 3. |

---

## AC17 Fix (Primary Goal): PASS ✓

All 4 hooks now hard-deny when `jq` (or `awk`, for evidence-validator) is missing from `PATH`. The fix:

1. **`lib/dep-guard.sh`** provides `require_dep <literal-name>` with:
   - `export PATH=/usr/bin:/bin:/usr/local/bin` (PATH pin against TOCTOU / attacker-controlled PATH)
   - Whitelist regex `^[a-z0-9_-]+$` enforced at runtime (belt-and-suspenders on top of code review)
   - Fully hardcoded deny JSON body — no `$dep` interpolation anywhere
   - `exit 0 + stdout deny JSON` (validated contract, see AC9)

2. **Per-hook dep declaration** — each hook declares ONLY its actual deps:
   - pretool-interceptor, bash-watcher, override-detector: `require_dep jq`
   - evidence-validator: `require_dep jq` + `require_dep awk`

3. **SECURITY guard** — source line uses `${BASH_SOURCE[0]%/*}` (not `$(dirname "$0")`) for symlink safety.

**AC17 retest with `PATH=$TMPBIN` (no jq) across all 4 hooks:**

```
hook                             exit_code  jq_valid  deny_detected  no_var_interp  verdict
hardened-pretool-interceptor.sh  0          yes       yes            yes            PASS
hardened-bash-watcher.sh         0          yes       yes            yes            PASS
hardened-override-detector.sh    0          yes       yes            yes            PASS
hardened-evidence-validator.sh   0          yes       yes            yes            PASS
```

Note on override-when-jq-missing (Alex-documented accepted loss, §4.1): confirmed. When jq is absent, override detection is bypassed because the user message is denied outright at dep-guard. This is acceptable: jq-missing is a deployment-config bug, not normal operation; the user sees a clear `Install jq/awk or use TAD_OVERRIDE` message and can remediate with `brew install jq`.

---

## AC9 Exit-Code Contract: PASS ✓

Empirically verified on this host (Claude Code 2.1.107):
- Test setup: temp settings.json with PreToolUse Write-matcher hook that `exit 0` + stdout deny JSON.
- `claude -p --no-session-persistence --permission-mode default --settings <tmp>.json --allowed-tools Write < "Please Write ..."`
- Result: `file_created=no`; claude output explicitly: *"The Write was blocked by a PreToolUse hook (`deny-hook.sh`) with message: 'TAD test: exit-0-stdout-deny contract verification'. File not created."*

**Lesson incorporated — pitfalls found during AC9 setup (documented for future spikes):**
1. `CLAUDE_CONFIG_DIR=/tmp/...` breaks user authentication — credentials not picked up from user's default config. Use `--settings <file>` flag instead, which overlays without disturbing auth.
2. `--permission-mode bypassPermissions` overrides ALL denies including hooks (per 2026-03-31 knowledge entry). Use `--permission-mode default`.
3. `claude -p "prompt"` positional-arg mode: when preceded by a variadic flag like `--allowed-tools`, the prompt gets consumed as a tool name. Use stdin: `printf "%s" "$PROMPT" | claude -p ...`.

---

## AC12 + AC13 Provenance + Anti-pattern Guard: PASS ✓

**AC12 (byte preservation):** `diff -u` between 1b hardened-*.sh and hooks-v2/hardened-*.sh contains ONLY the dep-guard block:

```
+# ── TAD Phase 1c AC17 fix: dep-guard (hard-deny if jq/awk missing) ──
+source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"
+require_dep jq
+# ── end dep-guard block ──
+
```

(evidence-validator additionally: `+require_dep awk`). Line-count delta: +5 for pretool/bash-watcher/override-detector, +6 for evidence-validator. No other bytes changed.

**AC13 (anti-pattern CI guard):** `grep -rn 'require_dep "\$' hooks-v2/` returns empty — no variable-based `require_dep` calls. This guard catches the `require_dep "$var"` pattern that would re-introduce P0-2's `$dep`-interpolation risk.

---

## Perf Notes (AC6 FAIL, AC7 FAIL, AC15 NOT-EXECUTED)

**N=100 baseline (single primary run, `results/bench-n100.tsv`):**

| hook | p50 (raw) | p95 (raw) | p99 (raw) | n | verdict |
|------|-----------|-----------|-----------|---|---------|
| pretool-interceptor | 51.10 | **67.44** | 114.97 | 100 | PASS |
| override-detector   | 31.98 | **52.48** | 97.94  | 100 | PASS |
| evidence-validator  | 69.47 | **156.51** | 223.40 | 100 | **FAIL** (>100ms) |
| bash-watcher        | 69.59 | **130.57** | 397.35 | 100 | **FAIL** (>100ms) |

Raw numbers include ~14ms perl timer overhead (two `perl -MTime::HiRes` spawns per sample, intentional per handoff Knowledge reference *"Hook Latency Measurement: Never Use python3 for Per-Step Timing on macOS"*). Adjusted (subtract 14ms): pretool 53.4, override 38.5, validator 142.5, bash-watcher 116.6 — 2/4 still over threshold.

**System-noise caveat (honest finding):** A follow-up rerun AFTER the AC9 test (which spawns `claude -p`, a node/electron process, with heavy one-shot CPU cost) produced substantially higher p95s across ALL 4 hooks:

| hook | run-3 p95 (system-noisy) |
|------|--------------------------|
| pretool-interceptor | 138.19 |
| override-detector   | 136.73 |
| evidence-validator  | 390.42 |
| bash-watcher        | 175.58 |

`uptime` at run-3 time: **load average 8.31** (8-core system → fully saturated). Run-3 TSV preserved at `results/bench-n100.tsv.run3.noisy` for transparency. This suggests the bench host is **not a clean benchmarking environment** — measurements are dominated by scheduler contention when load is high. Even the "clean" run-1 numbers are likely inflated vs a dedicated CI runner.

**AC15 NOT-EXECUTED rationale:** §4.4 prescribes optimization (single-awk, keyword cache, ENVIRON passing) ONLY for evidence-validator when p95≥100ms. Two blockers:
1. **AC12 conflict:** Any code change to the hook body beyond the dep-guard block violates the strict byte-preservation constraint of AC12. AC15 asks for before/after perf comparison, and would require modifying hook logic — but AC12 permits only dep-guard deltas.
2. **Narrow trigger:** bash-watcher also fails p95, but §4.4 trigger language only covers evidence-validator. No optimization path is prescribed for bash-watcher.

**Phase 3 recommendation (for Alex to decide in Gate 4):**
- Option A — **Accept PARTIAL for spike, defer perf to Phase 3.** Phase 3 implements production hooks without the AC12 byte-preservation constraint, freely applying `read -t 2` internal timeouts (AC8-B fix) and single-awk / cache optimizations (AC6 fix). Budget AC6 retest against dedicated CI runner, not dev laptop.
- Option B — **Return to Alex for addendum.** Relax AC12 to allow a second small delta category ("perf hot-path optimization"), rerun bench on a quiet host.

Blake recommends **Option A** — the spike has confirmed the architecture is sound; perf tuning is a separate concern that benefits from production-grade measurement conditions.

---

## AC8 Timeout (PARTIAL)

| Scenario | elapsed | deny | jq_valid | self_aborted | verdict | note |
|----------|---------|------|----------|--------------|---------|------|
| A (slow FIFO) | 0.032s | yes | yes | yes | **PASS** | Hook hit `STDIN_JSON=$(cat)` → got EOF → emitted `stdin empty (EOF)` deny. Technically passes via fail-closed, but not via explicit `read -t` timeout. |
| B (10MB payload) | 5.023s | no | no | no | **FAIL** | Hook processed large payload synchronously; killed by outer wrapper at 5s. Hook has no internal watchdog. |

**Scenario A note:** PASS is via the hook's existing `stdin empty (EOF)` check, not via time-based self-abort. If the FIFO had emitted ANY data (even a single byte) the read would proceed — this test happens to pass because `sleep 10 > FIFO` writes nothing, and the hook's EOF-handler correctly treats empty input as fail-closed. This is a **narrower** guarantee than AC8 requested (self-timeout after N seconds), but it IS a valid fail-closed path for the specific EOF-like case.

**Scenario B blocker:** 10MB pathological payload takes >5s to process through the normalization pipeline (perl NFKC + zero-width strip + confusables substitution on 10MB string). No internal `read -t` or `alarm()` exists in the 1b hook body, and AC12 prevents adding one in this spike. Phase 3 must add `read -t 2 STDIN_JSON; [ -n "$STDIN_JSON" ] || emit_deny_crash "stdin timeout"` AND bound the perl pipeline's input size (reject payload > 2MB upfront).

**macOS portability note:** GNU `timeout` is NOT installed on this macOS host. Test scripts use a portable bash `(sleep N && kill $pid) &` wrapper. This does NOT change test semantics but is documented in case future TAD contributors see the test script and wonder why.

---

## Deliverables Checklist

| Path | Exists | Purpose |
|------|--------|---------|
| `hooks-v2/lib/dep-guard.sh` | ✓ | AC1 — shared guard |
| `hooks-v2/hardened-pretool-interceptor.sh` | ✓ | AC2 |
| `hooks-v2/hardened-override-detector.sh` | ✓ | AC2 |
| `hooks-v2/hardened-evidence-validator.sh` | ✓ | AC2 (+ `require_dep awk`) |
| `hooks-v2/hardened-bash-watcher.sh` | ✓ | AC2 |
| `test-ac17-missing-jq.sh` | ✓ | AC3-4 |
| `test-exit-code-contract.sh` | ✓ | AC9 |
| `test-timeout-trigger.sh` | ✓ | AC8 |
| `bench-n100.sh` | ✓ | AC5-7 |
| `verify-apples-to-apples.sh` | ✓ | AC12-13 |
| `test-fixtures/pretool-write.json` | ✓ | AC5 hot-path |
| `test-fixtures/override-env.json` | ✓ | AC5 hot-path |
| `test-fixtures/validator-handoff.md` | ✓ | AC5 hot-path (evidence-validator takes `$1` filepath; fixture adapted accordingly — documented deviation from handoff's `.json` suffix) |
| `test-fixtures/bash-rm.json` | ✓ | AC5 hot-path |
| `results/ac17-retest.tsv` | ✓ | AC3-4 evidence |
| `results/exit-code-contract.tsv` | ✓ | AC9 evidence |
| `results/apples-to-apples.txt` | ✓ | AC12 evidence |
| `results/apples-to-apples-verdict.txt` | ✓ | AC12-13 condensed verdict |
| `results/bench-n100.tsv` | ✓ | AC5 raw (400 samples, Run-1 clean) |
| `results/bench-n100.tsv.run3.noisy` | ✓ | AC5 noise-documentation artifact |
| `results/stats-summary.tsv` | ✓ | AC6-7 summary |
| `results/timeout-trigger.tsv` | ✓ | AC8 evidence |
| `SPIKE-REPORT.md` | ✓ | AC10 |
| `COMPLETION-REPORT.md` | ✓ | AC11 |

---

## Phase 3 Hand-off Notes for Alex

1. **AC17 fix is production-ready** — the dep-guard pattern should transplant directly to `.tad/hooks/lib/dep-guard.sh` at Phase 3 time. Preserve SECURITY comments and AC13 CI guard.

2. **Perf optimization is Phase 3 scope.** Targets:
   - evidence-validator: collapse `git ls-files` + candidate resolution into single awk pass; cache git_files output for 60s; consider pre-computing archive sha manifest on session-start hook.
   - bash-watcher: collapse ~8 sequential `grep -qE` calls into a single awk multi-regex match (same pattern as keyword-map hook).
   - Target: **p95 < 100ms on a clean CI runner** (not dev laptop). Baseline dev laptop shows 50-150% variance due to load.

3. **Phase 3 MUST add `read -t 2` internal timeout** to `STDIN_JSON=$(cat)` OR bound perl pipeline input to ≤2MB. Reject oversize payload upfront with `emit_deny_crash "payload too large"`. This closes AC8-B.

4. **Dogfood on CI before prod rollout** — run `bench-n100.sh` on the TAD CI host with load averaged <1.0. Publish p95 as prod gate (the "fleet number"), not this laptop's.
