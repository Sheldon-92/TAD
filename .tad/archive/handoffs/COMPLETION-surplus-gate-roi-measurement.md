---
handoff: HANDOFF-surplus-gate-roi-measurement.md (v3.3.0)
epic: EPHEMERAL-surplus-gate-roi-measurement
phase: measure-and-verdict (1/1)
task_type: research
agent: Blake
date: 2026-07-12
gate3_verdict: pass  # §9.1 all green + AC13 independent spot-check 4/5 (see Gate 3 section)
---

# COMPLETION — Gate ROI Measurement (surplus-gate-roi-measurement)

**Status**: COMPLETE (all §9.1 ACs green on first run; AC13 independent spot-check executed at Gate 3: 4/5 agreement, PASS)
**Deliverable**: `.tad/evidence/research/gate-roi-measurement-2026-07.md` (417 lines, git-staged, NOT committed)
**Handoff**: `.tad/active/handoffs/HANDOFF-surplus-gate-roi-measurement.md` v3.3.0

---

## Verdict + Recommendation (quoted verbatim from the report)

```
**Verdict**: net-positive
**Recommendation**: GO
```

FR7 inputs (verbatim ASCII lines from ## Verdict):

```
NC% = 63.0% (17/27)
P0+P1 total = 91
zero-catch ratio = 22.2% (6/27)
```

Rule branch: NC% (63.0%) >= 25% AND P01 (91) >= 10 → net-positive. GO = proceed to revisit the 2026-04-15 mechanical-enforcement decision, next step cost-side measurement (cost explicitly unmeasured; the smoke-alarm posture stays until then).

## Aggregates

| Metric | Value |
|--------|-------|
| S (sample size) | 27 (census 189, every-7th, 0 epic-bookkeeping exclusions matched) |
| Total defects counted | 139 (P0=26, P1=65, P2=48) |
| NC (rows with >=1 broken-ship/silent-degradation catch) | 17 |
| NC% | 63.0% |
| P01 | 91 |
| Z (zero-catch ratio) | 6/27 = 22.2% (0.222) |
| Counterfactual per defect | broken-ship 3 / silent-degradation 48 / cosmetic 88 |
| Stage per defect | Gate2 review 18 / Gate3 L2 113 / Gate3 L1-dogfood 8 / Gate4 0 |
| Low-confidence rows | 13 of 27 contain >=1 low-confidence classification (49/139 defects); only 3 rows (GR-03, GR-08, GR-21) have a ROW-level counterfactual resting on low-confidence evidence, and none of those is in the NC set — the verdict does not depend on any low-confidence classification |

## Per-AC Table (raw command outputs, run 2026-07-12 from repo root, RPT=.tad/evidence/research/gate-roi-measurement-2026-07.md)

| AC | Verification (un-escaped) | Expected | RAW output | Status |
|----|--------------------------|----------|------------|--------|
| AC1 | `test -s "$RPT" && wc -l < "$RPT"` | exit 0, >=150 | `417` / `exit=0` | ✅ PASS |
| AC2 | `grep -cE '^\| GR-[0-9]{2} ' "$RPT"` | >=20 | `27` | ✅ PASS |
| AC3 | GR rows lacking traces/archive path; then per-row `test -f` on col 8 | 0; empty MISSING | `0` ; no `MISSING` lines emitted (`(end MISSING check)` only) | ✅ PASS |
| AC4 | `grep -cE '^## (Method\|Sample Table\|Defect Detail\|Aggregate Metrics\|Verdict\|Limitations)$' "$RPT"` | 6 | `6` | ✅ PASS |
| AC5 | `grep -cE '^\*\*Verdict\*\*: (net-(positive\|neutral\|negative)\|unmeasurable-with-current-evidence)$' "$RPT"` | 1 | `1` | ✅ PASS |
| AC6 | Recommendation-line count; Verdict-section grep -ci '2026-04-15'; grep -ciE 'cost\|overhead\|recovery\|成本\|恢复' | 1 ; >=1 ; >=1 | `1` ; `1` ; `1` | ✅ PASS |
| AC7 | baseline-diff via `comm -13 /tmp/gate-roi-baseline.txt -` filtered to protected paths | 0 | `0` | ✅ PASS |
| AC8 | GR rows without a counterfactual enum value | 0 | `0` | ✅ PASS |
| AC9 | Limitations grep -ciE 'false.negative\|missed' ; grep -ciE 'bias' | >=1 each | `1` ; `4` | ✅ PASS |
| AC10 | Verdict-section distinct labels via `grep -oiE 'NC% =\|P0\+P1 total =\|zero-catch ratio =' \| sort -uf \| wc -l`; plus P01 recompute from Defect Detail tags | 3 ; recomputed == 91 | `3` ; `grep -c '^- (P0)'`=26, `'^- (P1)'`=65 → 26+65=**91** == Verdict `P0+P1 total = 91` (also `'^- (P2)'`=48, matching the Aggregate table) | ✅ PASS |
| AC11 | Method-section `grep -c 'net-positive iff NC% >= 25% AND P01 >= 10; net-negative iff NC% <= 5%; net-neutral otherwise'` | 1 | `1` | ✅ PASS |
| AC12 | GR rows where counterfactual COLUMN ($7, space-stripped) == none | >=1 | `6` | ✅ PASS |
| AC13 | FR8 5-row independent counterfactual spot-check (executed at Gate 3 via fresh independent agent, blind, paths-only) | table + >=4/5 agree | 4/5 agree (see Gate 3 section below) | ✅ PASS |

AC7 raw command: `git status --porcelain | sort | comm -13 /tmp/gate-roi-baseline.txt - | grep -v 'gate-roi-measurement\|EPHEMERAL-surplus-gate-roi' | grep -cE '\.claude/skills/|\.tad/hooks/|\.tad/archive/|\.tad/evidence/traces/|\.tad/project-knowledge/|\.tad/active/'` → `0`. The only new tracked path vs baseline is the deliverable itself (`A .tad/evidence/research/gate-roi-measurement-2026-07.md`) plus this COMPLETION file (both name-excluded per the AC).

## Gate 3 Execution Record

**Layer 1**: all §9.1 post-impl commands executed (raw outputs in the AC table above); all green on first run, zero content weakening (no rows deleted, no numbers adjusted).

**AC13 / FR8 independent counterfactual spot-check** — executed per hook mandate at Gate 3 time:

- Row selection: 5 rows drawn randomly with recorded seed — `awk 'BEGIN{srand(20260712); ...}'` → GR-03, GR-09, GR-20, GR-24, GR-27.
- Reviewer: fresh independent general-purpose agent (agentId acd361cef66ba6eee), BLIND: paths-only prompt (handoff §4.3 rubric + the 5 cited evidence files), explicitly forbidden from reading the report or this COMPLETION; analyst enums were NOT in the prompt.

| GR-id | analyst enum | reviewer enum | agree? |
|-------|--------------|---------------|--------|
| GR-03 | cosmetic | cosmetic | ✅ |
| GR-09 | broken-ship | broken-ship | ✅ |
| GR-20 | silent-degradation | silent-degradation | ✅ |
| GR-24 | none | none | ✅ |
| GR-27 | silent-degradation | none | ❌ |

**Agreement = 4/5 → meets the FR8 >=4/5 threshold → classification pass stands (no rubric-tightening re-run required).**

Disagreement analysis (GR-27, documented per FR8): the reviewer classified `none` on stage-eligibility grounds — the D2 judge-prompt gap and §4.4 metric ambiguity "were found by the deliverable's own calibration rounds (self), not recorded gate catches." The analyst counted them as Gate 3 Layer 1/self-verification catches (the handoff FR3 stage enum includes "self", and Method §5 states the Layer-1/AC-run/dogfood counting rule). The disagreement is about WHICH catches are stage-eligible, not about the counterfactual nature of the defects (both parties treat them as verification-instrument issues). Sensitivity: if GR-27 were reclassified `none`, NC drops 17→16, NC% = 59.3%, Z = 7/27 = 25.9% — the FR7 branch and the verdict (net-positive) are UNCHANGED.

**Knowledge Assessment (MANDATORY — journaled here, NOT written to .tad/project-knowledge/)**: this handoff's NFR1 + AC7 place `.tad/project-knowledge/` on the protected write list (read-only analysis; the report is the only deliverable), so per the Capture/Distill model the raw journal lives here for Alex-side distillation:

**是否有新发现？** ✅ Yes (journal entries below; distillation → Alex)

1. **Aggregate-count-only fix logs are the bottleneck for archival ROI measurement** (candidate: patterns/gate-design.md or memory-and-learning.md). 49 of 139 counted defects (35%) existed in the record only as per-reviewer severity COUNTS ("P1=3") with no content — forcing classify-DOWN/low-confidence handling. If COMPLETION reports enumerated every finding in one line each (as GR-18/GR-22-via-review-file do), archival measurement would need no low-confidence machinery. Cheap fix with compounding measurement value.
2. **Trace-emission gap**: 7 of 16 post-2026-05-19 sampled rows carry `gate3_verdict: pass` frontmatter but NO `gate_result` trace event (dual-platform-parity-fix, publish-gate-phase5, research-input-quality, ...). The trace channel under-reports gate activity vs frontmatter — anyone using traces as the gate ledger will undercount. Maintenance candidate.
3. **Rubric edge found by the FR8 spot-check itself**: the "self/Layer-1 catch vs formal gate catch" stage boundary is where independent raters diverge (the GR-27 disagreement). Future gate-measurement rubrics should define stage-eligibility of self-caught/dogfood defects as explicitly as the counterfactual enum — the counterfactual axis itself showed 4/4 agreement where both raters counted the same defects.

**Skillify candidate?** ❌ No — one-off archival measurement; the reusable part (rubric + frame) already lives in the handoff.

**Gate 3 verdict: PASS** (Layer 1 green, AC13 4/5, KA recorded, scope check AC7 = 0).

## Friction Status

| Friction Point | Status | Notes |
|----------------|--------|-------|
| Grounding file missing | READY | Used §7.3 measured values; census re-measured live (189) matched handoff AC-P2 |
| jq availability | READY | jq present; trace annotation command ran as specified |
| Census below 140 | READY | Census 189 → 27 samples (frozen list at /tmp/gate-roi-sample.txt used verbatim, byte-identical to re-derived FR1 output) |
| CJK grep byte-matching | READY | No LC_ALL workaround needed; full-file Reads used for extraction, grep only as locator |

## Files Changed

- `.tad/evidence/research/gate-roi-measurement-2026-07.md` — NEW (the single deliverable; git-staged, not committed)
- `.tad/active/handoffs/COMPLETION-surplus-gate-roi-measurement.md` — NEW (this report)
- No other writes. AC7 baseline-diff = 0 protected-path hits.

## Sub-Agent Usage

| Sub-Agent | 是否调用 | 说明 |
|-----------|---------|------|
| general-purpose reader | ❌ | All 27 COMPLETION files read fully in-context (sizes 33–234 lines; no context pressure) |
| Others | ❌ | Single sequential pipeline per handoff §10.3 |

## Honest Notes — ambiguities hit during classification

1. **Aggregate-count-only findings**: several COMPLETIONs record per-reviewer severity COUNTS without restating content (GR-03, GR-09, GR-11, GR-14, GR-21, GR-23). Decision (documented in Method §5): count each individually with a generic description, classify counterfactual DOWN to cosmetic (tie-break 3), flag low-confidence. This biases NC% against the gates. Excluding them entirely would not change the verdict (they are all cosmetic → NC unchanged; P01 would drop from 91 to 78, still >=10).
2. **Untagged severities**: dogfood catches, "I-n" findings (GR-26), and self-caught AC-command bugs (GR-20 AC7 awk, GR-23) carry no P-tag in the record. Counted conservatively as P2 (biases P01 down). Notably GR-18's dogfood dotfile-copy bug and GR-23's 4th-drift catch are arguably P1-grade but were kept at P2.
3. **Dedup judgment calls**: GR-11 (BA P0-3 = CR P0-1/P0-2), GR-20 (BA P0-3 = CR P0-2), GR-09 (CR/BA-P1-3) deduped per explicit "same fix / already fixed / shared ID" statements. GR-09 has an internal record discrepancy (exec summary "3 P0 + 9 P1" vs checklist "3 P0 + 7 P1"; round-1 table sums to 9 P1 across reviewers) — I used the round-1 table minus the 1 known cross-reviewer dup = 8 P1.
4. **Non-defect review findings excluded**: false positive (GR-10 BA P0-1), acknowledged-as-expected (GR-13 BA P1-1), design-decision-not-bug (GR-19 P1-1/P1-2), acceptable-deviation/design-choice (GR-22 MIG-10/11), advisory concerns (GR-26 I-2/I-4). Counting these would have inflated the gates' numbers.
5. **GR-04's 11th issue**: the archived handoff says "11 issues integrated"; only 10 are individually identifiable across the Audit-Trail-equivalent tables. The 11th was NOT counted.
6. **GR-05 Gate-2 finding IDs imply more findings** (e.g. CR-P0-6 implies at least 6 CR P0-numbered items) than the COMPLETION restates; only restated findings were counted. Undercounts, biases against gates.
7. **Broken-ship borderline**: GR-14's div-by-zero on solid-color images was classified broken-ship via the rubric anchor "breaks on legal input"; a reviewer preferring "rare input class" could argue silent/cosmetic — flagging for the AC13 spot-check. Row remains NC either way (its two P0 void-guards are silent-degradation).
8. **Sample frozen as instructed**: used /tmp/gate-roi-sample.txt verbatim (verified byte-identical to a fresh FR1 draw: 27/27). No gate-roi Epic bookkeeping appeared in the sample (none expected, none found).
9. **Trace-emission gap observed** (annotation only): 7 post-2026-05-19 sampled rows have `gate3_verdict: pass` frontmatter but NO gate_result trace event (e.g. dual-platform-parity-fix, publish-gate-phase5, research-input-quality). Recorded in report Method §4 + Limitations 6 — possible future maintenance item.
10. **Foreign file in AC7 diff**: the final baseline-diff shows one untracked file I did NOT create — `.tad/decisions/DR-20260712-native-capability-overlap-verdicts.md` (appeared in the working tree from outside this task; `.tad/decisions/` is not on the AC7 protected list, so AC7 remains 0). Zero writes by this task outside the two files listed above.

**Blake声明**: 此实现已完成。Verdict = net-positive, Recommendation = GO (mechanical application of FR7). 待 Gate 3 执行 AC13 独立 spot-check（>=4/5 agreement），再交 Gate 4 human 验收（"这个 verdict 的推理我信"）。
