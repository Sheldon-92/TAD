# Code Review — HANDOFF-20260702-trajectory-eval-p2 (Judge Harness Spike + Calibration)

**Reviewer:** code-reviewer (narrow-scope, Gate 2 pre-handoff)
**Date:** 2026-07-02
**Scope read:** §2, §4 (esp §4.2/§4.4), §6 + §6.7, §7, §8, §9.1, §10
**Blast-radius checks:** `.tad/eval/judge/` absent (PASS, Blake creates) · golden-set = 12 GS + INDEX + BLIND-PACK (PASS)

Overall this is a well-constructed handoff: the metrics contract (§4.4) is explicit and pre-computed against golden ground truth, the freeze/anchoring hazards are called out, and the pivot path is a legitimate exit. The problems below are concentrated in the **verification layer** (AC3 schema check) and the **EVAL_ERROR ↔ gate-critical-trajectory interaction**, both of which can produce a false PASS or an uncomputable gate.

---

## 1. Critical Issues (P0)

### P0-1 — AC3's jq schema check cannot detect a missing/null score in D1–D4 (false PASS)
`jq -e '[.D1,.D2,.D3,.D4,.D5][] | .score'`

`jq -e` sets its exit status from the **last emitted value only** (0 if the last value is non-null/non-false; 1 if last is null/false; 4 if nothing emitted). The pipeline emits one value per dimension, so the exit code reflects **D5 only**.

Traced against the §4.2A.4 schema `{"D1": {"score": ..., "rationale": ...}}`:
- Missing `.D4` (or `.D4.score` null) but valid `.D5` → `null | .score` = `null`, stream continues, last value = D5's number → **exit 0 → no BAD → false PASS.** A dropped middle dimension is invisible.
- Non-object dim (e.g. `"D2": 5`) → `5 | .score` errors mid-stream → exit non-zero → BAD (this case *is* caught).
- `"UNRECOVERABLE"` string → truthy → passes (intended).

Net: the AC only truly validates D5. Since AC3 is the sole schema gate and the downstream §4.4 pooling silently trusts these files, a judge that omits a dimension corrupts within-1 with no signal. It also does **not** validate the score domain (a `"score": 6` or `"score": "high"` passes) nor rationale presence (FR1 requires per-dim rationale).

**Fix (copy-paste ready):**
```bash
for f in .tad/eval/judge/results/round1/*.json; do
  jq -e '[.D1,.D2,.D3,.D4,.D5]
         | all(type=="object"
               and (.rationale | type=="string")
               and ((.score | type=="number" and . >= 1 and . <= 5 and (floor==.))
                    or .score=="UNRECOVERABLE"))' "$f" >/dev/null \
    || echo "BAD $f"
done
```
`all(cond)` iterates the 5-element array; a missing dim → element `null` → `null|type=="object"` = false → whole thing false → exit 1 → BAD. This closes presence, object-shape, integer-domain, and rationale in one check.

### P0-2 — EVAL_ERROR on a gate-critical trajectory (GS-11 / GS-03 / GS-06) leaves a stop-loss gate uncomputable, with no rule
§8.1 tolerates a **single** EVAL_ERROR (excluded from pairing); only **≥2** triggers a full-round rerun. That rule treats all 12 trajectories as fungible — but three of them are load-bearing operands for the non-within-1 gates:
- Contrast pair (AC5) = `judge(GS-11) − judge(GS-03)`
- Anti-anchor (AC6) = `judge(GS-06) ≥ 3.5`

If exactly one trajectory is EVAL_ERROR **and it is GS-11, GS-03, or GS-06**, no full rerun fires, yet the affected gate has a missing operand and cannot be computed. There is no defined verdict for "gate operand missing." At Gate 4 this forces exactly the on-the-spot interpretation §10.1 forbids ("口径含糊处回 Alex，不现场发明"), or worse, a silent skip.

**Fix:** add a rule that an EVAL_ERROR on any of {GS-11, GS-03, GS-06} forces a single-trajectory fresh re-spawn regardless of the ≥2 threshold; if that trajectory still EVAL_ERRORs, the dependent gate is declared **inconclusive → PIVOT** (never silently skipped). State this in §8.1 and reference it from AC5/AC6.

---

## 2. Recommendations (P1)

### P1-1 — EVAL_ERROR file handling collides with AC3's "12 files + no BAD"
AC3 asserts `ls results/round1/*.json | wc -l == 12` **and** every file passes the jq schema. But §8.1 says an EVAL_ERROR trajectory is "标 EVAL_ERROR" without specifying where. Two failure modes:
- If no JSON is written for the errored trajectory → count = 11 → AC3 FAIL.
- If a sentinel JSON (e.g. `{"eval_error": true}`) is written in the same dir → it has no `.D*.score` → jq → BAD → AC3 FAIL.

Either way the sanctioned EVAL_ERROR path trips the very AC that is supposed to pass. **Fix:** define EVAL_ERROR results to live in a sibling location (e.g. `results/round1/errors/{slug}.json`) or carry an explicit `{"eval_error": true, ...}` sentinel that AC3 pre-filters (`jq -e 'has("eval_error")' "$f" >/dev/null && continue`), and adjust the `wc -l == 12` expectation to "12 minus recorded EVAL_ERRORs, each with an errors/ file."

### P1-2 — within-1 denominator has no minimum-N floor
within-1 (AC4) is a proportion over paired (traj,dim) cells. Pairwise UNRECOVERABLE exclusions (§4.4) plus one tolerated EVAL_ERROR can shrink the 12×4 = 48-cell denominator materially, and a small denominator makes the ≥80% gate statistically hollow (and Goodhart-able). **Fix:** add a floor — e.g. "if paired-cell N < 36, the within-1 gate is inconclusive → return to Alex / PIVOT, not auto-PASS." This also protects against a degenerate round where mass UNRECOVERABLE inflates the ratio on a handful of easy cells.

### P1-3 — "池化均分" dim-set is ambiguous for the contrast-pair and anti-anchor gates
within-1 explicitly pools **D1,D2,D3,D5 (excludes D4)**. But the contrast-pair and anti-anchor rows in §4.4 say only "judge(GS-xx 池化均分)" without stating whether D4 is in or out. This matters because the ≥1.5 and ≥3.5 thresholds were calibrated from the golden means in §2.1 (GS-11 5.00 / GS-03 2.80 / GS-06 4.20) — the judge's pooled mean **must be computed over the identical dim set** the golden baseline used, or the comparison is apples-to-oranges. Compounding: if the judge marks a dim UNRECOVERABLE for GS-11/03/06, is that dim dropped from the mean (shifting it relative to golden)? **Fix:** state explicitly (a) which dims enter "池化均分" for these two gates, (b) that it must equal the dim set golden used in §2.1, and (c) how a judge-side UNRECOVERABLE dim is handled in the mean.

### P1-4 — AC7 subagent_tokens gate is likely permanently DEGRADED
§4.2C / NFR1 rely on "Blake records subagent_tokens from the Agent tool return." In practice the Task/Agent tool result does not reliably surface a structured subagent token count to the caller. §8.4 already provides a duration+line-count proxy fallback marked DEGRADED — good — but §4.4 still lists token ≤80K as a **门 (gate)**. If the primary signal is unavailable in this runtime (not merely flaky), the token half of AC7 can never actually enforce 80K; it will always fall to proxy. **Fix:** confirm the runtime exposes usage on a throwaway spawn *before* Round 1; if it does not, downgrade the token component to advisory and keep only wall-clock (≤5min, which *is* observable) as the enforceable gate — otherwise AC7 is validation theater.

---

## 3. Suggestions (P2)

- **AC8 anchoring fragility.** `^calibration_verdict: (PASS|PIVOT)$` requires the line to start at column 0 with no adornment. If Blake writes it inside a ```yaml fence (indented) or as a markdown list item (`- calibration_verdict:`), grep returns 0. Also, the glob `calibration-report-*.md` with `grep -c` over multiple files prints per-file counts, breaking the "expected 1". Mandate a single bare top-level line and note the single-report assumption.
- **AC1 token language mismatch.** The greps hunt English tokens (`swap`, `rationale`, `score`). If judge-prompt.md is authored in Chinese ("反转测试", "理由"), these silently return 0. Mandate the English tokens appear literally in the prompt, or align the greps to the authored language. (`'"score"'` itself parses fine — literal `"score"` — no bug there.)
- **No AC verifies the ≤1500-line bundle cap** (§4.2B), which is the actual cost-control mechanism behind NFR1. Add a cheap check: `awk 'END{exit !(NR<=1500)}'` per bundle, or fold into AC7.
- **Round-count log must distinguish counting vs non-counting reruns.** §4.4 (bundle-optimization reruns) and §8.1 (≥2 EVAL_ERROR full rerun) both "不消耗迭代轮次," yet AC8 verifies "迭代日志 ≤3 轮" by human read. Define a log schema that tags each run as `calibration_round` vs `operational_rerun` so ≤3 is unambiguous.
- **AC11 residual gap (marginal).** `.tad/evidence/research/open-notebook-vs-notebooklm/` (concurrent, currently untracked) is not in the exclusion allowlist. Baseline-snapshot + `comm -13` covers the existing dir line, and new files inside an existing untracked dir keep the same porcelain line, so this only bites if concurrent work creates a *new* top-level untracked path under `evidence/research/`. Consider adding `\.tad/evidence/research/` to the allowlist for safety.

---

## 4. Overall Assessment

**CONDITIONAL PASS** — resolve both P0s before handoff.

- **P0-1** (AC3 jq only validates D5) and **P0-2** (EVAL_ERROR on GS-11/03/06 leaves a gate uncomputable) are blocking: the first can yield a false PASS on a malformed judge output, the second can silently break a stop-loss gate or force forbidden on-the-spot interpretation. Both have concrete, low-cost fixes above.
- P1-1/P1-2/P1-3 tighten the calibration contract so the numbers mean what §4.4 claims; P1-4 prevents AC7 from being a gate it cannot enforce.
- P2s are polish and self-consistency.

The design intent, freeze discipline, and pivot-as-legitimate-exit are sound; the fixes are all in the verification and edge-case layers, not the architecture.
