# Code-Reviewer Expert Review — HANDOFF-20260613-pack-quality-phase1-bar-baseline

**Reviewer lens:** code-reviewer (AC command runnability, shell/grep traps, self-leak, product structure self-consistency)
**Scope read:** §6, §9 + §9.1, §10, files in §7 (pack-eval-runner.sh, capability-upgrade SKILL, Epic, 24 packs presence)
**Verdict:** CONDITIONAL PASS

Note: this handoff is already in `.tad/archive/handoffs/` (retrospective Gate-2). Findings are framed as they would have applied at authoring time. Empirical grep/shell tests run against synthetic fixtures in /tmp.

---

## Critical Issues (P0)
None. The two prior P0s (Layer B discriminability, no-fixture blind spot) are structurally resolved with backing ACs (AC7/AC8). No new P0-class defect in the AC command set or execution order.

---

## Recommendations (P1)

### P1-A — AC3 self-leaks on template boilerplate (the #1 named risk)
`AC3` = `grep -iE 'negative control' QB.md && grep -iE 'FAIL|≤ ?2|低分|0/[0-9]' QB.md`.
Tested: a QUALITY-BAR.md containing ONLY the §4.1/§4.2 *instruction* text
("...对劣质结构样例打分 → 必须 FAIL", "...→ 必须 ≤2") **PASSES AC3** with zero
actual negative-control run. The grep cannot distinguish an instruction that
*says* "must FAIL" from a real scored verdict that *produced* FAIL. The §4.1
template itself contains the literal strings "必须 FAIL" and "≤2", so a Blake who
copies the template skeleton and never runs the control still passes. This is
exactly the validation-theater failure §10.1 names as head risk, and the AC was
explicitly tightened for it (S1/arch S1 "不只查字样,要有实际低分/FAIL verdict") —
but the verifier as written does not enforce that tightening.
Fix: scope the FAIL/≤2 match to a dedicated results block that cannot be the
template, e.g. require a fenced verdict line like `NEG-CONTROL-A: FAIL (score=N)`
emitted by an actual run, and grep for that anchor token, not free prose. Or run
pack-eval-runner.sh against the deliberately-bad sample and capture exit/score.

### P1-B — AC8 verifies only half its own criterion
AC8 criterion text: "无 fixture 的包被标 LOW 置信度 **且进 Batch 1**".
Command only does `grep -iE 'LOW|低置信|无 ?fixture|missing fixture'` ≥1. The
"进 Batch 1" (the actual P0-2 rank-rule fix) is **unverified**; a single LOW
sentence anywhere passes. Tested: the §4.2 template sentence alone satisfies it.
Fix: add a row-scoped check that the no-fixture pack appears on a Batch-1 line,
e.g. `grep -E '批次 ?1|Batch 1' BASELINE-AUDIT.md` co-located with the LOW pack
name, or assert the pack name + "Batch 1" + "LOW" on the same scored row.

---

## Suggestions (P2)

### P2-A — AC2 "scored row" predicate is loose
`...[^\|]*\|.*[0-9]` counts a row as scored if ANY digit follows a pipe. A row
carrying a date (e.g. `| ml-training | N/A | ... | 2026-06-13 |`) or a footnote
index would register as "scored" without a real Layer A/B number. Verified AC2
dedup logic itself works (returns 2 on a 2-pack fixture). Tighten to require a
digit in a known score column if you want it airtight; current form is adequate
to block the §2.2-namelist paste it was designed against.

### P2-B — AC4 minor over-count on `批次10`
`批次 ?[1-4]` matches the `1` in `批次10`. Verified: `| 批次10 |` → count 1.
Harmless (only inflates a `>=3` floor, never causes a false FAIL) and the §6
token guidance ("批次 N" with leading space) steers authors away from it. Note,
not blocker.

### P2-C — §6 mkdir warning now moot / §7.2 path drift
`.tad/evidence/pack-quality/` already exists, so the §6 "首次写入失败" warning is
belt-and-suspenders (fine to keep). §7.2 points the Epic at
`.tad/active/epics/EPIC-20260613-...md`; that file is now under
`.tad/archive/epics/`. Path was correct at authoring time (Epic was active);
flagged only so a re-runner of Gate 3 knows the file relocated on archive.

---

## Positive Confirmations
- AC2 / AC3-part1 / AC4 / AC5 / AC6 grep forms run cleanly with bare `|` (ERE),
  matching the pipe-escape note at the bottom of §9.1. Verified empirically.
- AC6 (`grep -c http`) correctly requires a real URL — template text has no
  literal `http`, so it cannot self-leak. Good design.
- Grounding in §7.3 verified: pack-eval-runner.sh (12613 bytes), capability-
  upgrade SKILL.md, and all 24 target packs exist. CONSUMES/PRODUCES single-layer
  attribution rule (§4.1 arch P1-3) is sound and prevents double-counting.
- Execution order (Step1 research → Step2 gold-standard → Step3 audit+backfill)
  is correct: Layer A/B definitions precede the audit that consumes them.

---

## Overall Assessment: CONDITIONAL PASS
Implementable as written. Two P1s (AC3 template self-leak, AC8 half-verified
criterion) let validation theater pass the very gate built to stop it — fix the
verifier anchors before Blake runs Gate 3, or Gate 3 must manually confirm the
negative-control verdicts and Batch-1 placement were *produced*, not *quoted*.
