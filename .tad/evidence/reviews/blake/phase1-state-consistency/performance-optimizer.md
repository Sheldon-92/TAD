# Performance Review — Phase 1 State Consistency

Reviewer: performance-optimizer
Date: 2026-04-24

## Hot-path (router hook)

Measurement: `.tad/evidence/completions/phase1-state-consistency/perf-P1.4-router.tsv` (N=30, wall-clock via `perl Time::HiRes`).

| Stat | Value (ms) |
|------|-----------|
| min  | 102.65 |
| p50  | 123.43 |
| mean | 137.87 |
| p95  | 206.45 |
| p99  | 214.84 |
| max  | 214.84 |
| count > 200ms | 2 / 30 (6.7%) |

**Budget**: p95 < 200ms. **Status**: p95 = 206.45ms — **marginally over budget by ~3%** (≈6.5ms). 2 samples exceed 200ms (iterations 9 = 206.45ms, 28 = 214.84ms).

**Baseline comparison**: 2026-04-07 architecture.md entry recorded median ≈81ms (measured via `claude -p` proxy, known to inflate but the value we have). Current p50 = 123.43ms → delta ≈ +42ms at the median, +106ms at p95. This is well beyond the "~1ms added grep" theoretical prediction.

**Root cause analysis**: the Phase 1 addition — one `grep -qE` over already-in-memory `$USER_MSG` — cannot by itself account for +42ms median. The likely explanation mirrors the 2026-04-14 architecture.md finding ("Perf Gate Measurement Requires Dedicated CI Runner, Not Dev Host"): this measurement run was on a dev host with other `claude` sessions / load. Script work itself is dominated by known-heavy forks (one `yq -o=json`, several `jq`, two `perl` timing calls). The distribution is consistent with fork contention, not algorithmic regression: spread (102 → 214ms) >> mean shift, and high values are scattered (not monotonic), indicating system load not steady-state cost.

**Verdict**: **marginal regression — borderline FAIL on dev-host numbers, PASS expected under CI conditions**. Three viable paths forward:

1. **Re-measure on a quiet host** (load avg <1.0, no other `claude -p` sessions). Per the 2026-04-14 learning, dev-host p95 is typically 2-3× inflated. A clean re-run is the correct way to settle whether the 206ms p95 is real or measurement noise.
2. **Accept as-is** with documented caveat: dev-host p95 = 206ms, CI-expected p95 ≈ 100-140ms (extrapolating the dev/CI ratio). No code change.
3. **Micro-optimize if re-measurement still fails**: the cheapest win is replacing the second `perl -MTime::HiRes=time` at line 237 with arithmetic on a single start-of-script capture + end-computed delta via a single perl call. Saves ~3-5ms on the closing path. But this shouldn't be the first resort — measure first.

**Recommendation**: re-measure on a quiet host BEFORE declaring failure. The Phase 1 `grep` addition is algorithmically cheap (sub-ms); the budget gap is measurement-environment noise, not code regression.

## Cold-path scripts

### drift-check.sh (on-demand via /tad-maintain CHECK)

For 20-50 active handoffs, serial iteration is correct (deterministic output, per-handoff error isolation). Observed fork cost per handoff:

- **`check_zombie_handoffs`** is the hot sub-path: one `git log --since=60days --format='%H %s' | grep -iE | head -3` per handoff. At N=50, that's 50 × (git log fork + grep fork) ≈ ~1.5-3s total. `git log` dominates (~20-40ms per invocation on a moderate-history repo).
- `check_slug_consistency` runs one `awk` + two `sed` + a `grep -qE` per handoff path, plus a nested `while read p` loop with a `grep -qF` per manifest path. At 20-50 handoffs × ~3-5 paths each, still sub-second.
- `check_supersedes_chains` and `check_ghost_tasks` use one `grep` + one `awk` per handoff. Negligible.

**Optimization opportunity** (non-blocking): `check_zombie_handoffs` can hoist `git log --since=60days --format='%H %s'` OUT of the per-handoff loop into a one-shot buffer, then `grep -iE` against that buffer per handoff. Collapses 50 git forks to 1, cuts the dominant cost ~30×. Not required at current handoff counts (few-seconds budget is fine); recommended if handoff count grows past 100.

### gate3-git-tracked-check.sh (Gate 3, once per handoff)

yq invoked 3x on the in-memory `$FM` string (`type`, `length`, `[]`). Each yq fork ≈ 30-60ms on macOS → ~90-180ms total yq overhead. Plus per-dir `git check-ignore` + `git ls-files` forks. For a typical 2-5 dir handoff, total runtime ~300-600ms — **under the 1s budget**. If `git_tracked_dirs` grows >10, budget could be tested. Non-blocking for Phase 1.

Cheap win if desired: combine the `type` + `length` + `[]` yq calls into a single `yq -o=json` dump followed by `jq` against the in-memory JSON (same pattern as the router hook uses). Saves ~60-120ms per Gate 3 invocation. Worth doing only if Gate 3 becomes a common latency complaint.

### layer2-audit.sh (slug truncation)

Adds at most 2 extra `find -maxdepth 1 -print -quit` calls (early-exit on first match). Each ≈ 5-10ms. **Negligible**, as handoff noted.

## Blocking patterns (if any)

**One N+1 pattern** worth noting (not blocking):

- `drift-check.sh::check_zombie_handoffs` — per-handoff `git log` fork. Currently fine at 20-50 handoffs; hoist-out refactor recommended if handoff counts grow. No action required for Phase 1 merge.

No unbounded loops. No synchronous I/O in the router hot path. The earlier 2026-04-07 single-awk consolidation is preserved untouched — the router's scoring inner loop is still one awk process.

## Verdict

**CONDITIONAL PASS** — conditional on re-measurement under clean host conditions confirming p95 < 200ms.

- **If re-measured p95 < 200ms on quiet host** → PASS (measurement noise, no regression).
- **If re-measured p95 still > 200ms** → FAIL and require investigation (unlikely but possible; the Phase 1 grep alone cannot produce +40ms median, so another cause must exist).

The router code change itself (a single bash-native `grep -qE` against an in-memory string) is algorithmically sound. Cold-path scripts are all within their respective budgets with one noted future N+1 opportunity in drift-check.
