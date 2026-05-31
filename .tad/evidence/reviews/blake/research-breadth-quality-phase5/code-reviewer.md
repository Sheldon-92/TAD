# Code Review — research-breadth-quality-phase5 (commit 5456afb)

**Reviewer:** code-reviewer (post-impl Layer 2, blue-team)
**Artifact:** worktree agent-ab6b738c712ec7d0f @ 5456afb
**Files reviewed:** `.claude/skills/alex/SKILL.md` (Phase 4 Step 1 persona pass; Phase 4c Step 4b rubric), `.tad/templates/research-challenge-prompt.md` (findings-variant `## Quality Rubric` block), `.tad/templates/research-quality-rubric.md` (calibration), COMPLETION-20260531.
**Overall: PASS**

The two load-bearing claims (no-new-invocation; advisory-not-blocking) hold under verification. No P0. No P1. Three P2 (documentation/clarity), none blocking. Detail below per FOCUS area.

---

## FOCUS 1 — No-new-invocation claim (LOAD-BEARING): VERIFIED SOUND

The rubric scores are parsed from the EXISTING 4c Codex+Gemini reports, not from any new CLI call. Concrete trace:

- `research-challenge-prompt.md:78-86` adds the `## Quality Rubric` block INSIDE the `<!-- BEGIN findings --> … <!-- END findings -->` envelope. This block is part of the model's required OUTPUT FORMAT (the prompt instructs the model to fill `dim_name: SCORE` lines), so the same Codex+Gemini response that already carried the INSUFFICIENT/ADEQUATE/STRONG verdict now ALSO carries the 4 scores.
- `SKILL.md:1606-1608` Step 4b explicitly reads "The Step 3 Codex+Gemini reports ALSO contain a `## Quality Rubric` block … extracted in Step 2." Step 2 (`SKILL.md:1587`) `sed`-extracts the findings envelope (which now includes the rubric block) into the challenge payload; Step 3 (`SKILL.md:1591-1598`) is the unchanged single Codex + single Gemini invocation; Step 4b parses scores from those saved report files. There is no second `codex exec` / `gemini -p` in the Step 4b region.
- AC5.5 tripwire guards all hold (re-derived, not read from COMPLETION):
  - `grep -c 'codex exec --full-auto'` = **3** (unchanged)
  - `grep -c 'gemini -p'` = **3** (unchanged)
  - `grep -c 'DR-20260531'` = **9**
  - `grep -c 'NOT_via_alex_auto: true'` = **1**; anchor present byte-exact at `SKILL.md:482` (`  NOT_via_alex_auto: true  # Alex NEVER auto-invokes external CLI — suggest or delegate only`)
  - `git diff 58c9cac 5456afb -- SKILL.md | grep -c forbidden_implementations` = **0** (forbidden block untouched)

The template edit is the correct (and only) mechanism for "no new call site" — the models can only emit the rubric if their output format requests it. This is genuine reuse of the existing invocation, not a disguised second call.

**Verdict: SOUND.** The carve-out coverage claim (FR2 rides existing 4c → no new SAFETY/DR edit) is implemented as designed.

---

## FOCUS 2 — Persona pass: VERIFIED CORRECT on all four sub-claims

`SKILL.md:1375-1403` (Step 1 region, runs all tiers):

1. **Runs in Phase 4 Step 1 all-tiers:** attached BEFORE the KR-derived seed loop, inside the `Step 1` block that the surrounding prose declares "the CORE deliverable and runs for ALL tiers (simple|comparison|complex)" (`SKILL.md:1345-1346`). Correct location.
2. **Scales by research_complexity:** scaling table at `SKILL.md:1382-1387` — simple `0 or 1 (DEFAULT 0)`, comparison `3`, complex `4`. Greppable row present (`simple 0|1 · comparison 3 · complex 4`). Reads the persisted Phase 0class key (`do NOT re-derive the tier`), consistent with the persistence contract at `SKILL.md:1563-1568`.
3. **Merges against the existing 2-3 cap (not bypass):** `SKILL.md:1393-1400` — explicit "⚠️ SHARED BUDGET: persona sub-questions + KR-derived seeds TOGETHER count against the existing 2-3 Step 1 cap … Personas do NOT silently bypass the cap." Allocation order is specified (persona seeds first up to the scaling cap, then KR seeds for the remaining budget, prioritize by uncertainty/relevance on overflow). This directly resolves the pre-handoff code-reviewer P2.
4. **Does NOT re-gate on run_dynamic_seeds:** `SKILL.md:1401-1402` — "⚠️ This persona pass AUGMENTS Step 1 (the all-tiers baseline) — it does NOT re-gate Step 1 on `run_dynamic_seeds`." Preserves the Phase 4 disambiguation. The simple-tier `DEFAULT 0` also protects the single-ask path from inflation (the specific P2 concern).

Display integration: Question Tree gains a Persona column (`SKILL.md:1412-1416`), consistent with the existing display+override ethos. Correct.

---

## FOCUS 3 — Hybrid floor aggregation: VERIFIED CORRECT

`SKILL.md:1619-1625` and rubric `§4` (`research-quality-rubric.md:103-115`) agree byte-for-logic:

```
IF factual_accuracy < 0.5 OR citation_accuracy < 0.5 → overall = min(factual, citation)
ELSE → overall = mean(citation, factual, completeness, source_quality)   # 4 scored dims
```

- Efficiency is **advisory-unscored**: it is NOT a term in either aggregation branch (the `mean(...)` line names exactly the 4 scored dims; `research-quality-rubric.md:115` states "`efficiency` is never in the aggregate"). Verified at `SKILL.md:1623`.
- Per-model combination = mean of Codex+Gemini per scored dim (`SKILL.md:1618`), then the floor rule on the combined values. Order is correct (average the two raters, then aggregate).
- Calibration math spot-checked and reproduces exactly: case 6 `mean(0.5,0.5,0.0,0.5)=0.375` (mean branch, no floor since both accuracy dims =0.5, not <0.5); case 7 `=0.625`; case 22 `=0.75`; case 15 `=0.875`. All match the table.

---

## FOCUS 4 — Advisory not blocking: VERIFIED, wired into BOTH exits

- Step 4b region (`SKILL.md:1606-1637`): `grep -cE 'BLOCK|deny|return.*fail'` over the Step 4b block = **0**. The WARN path (`SKILL.md:1628-1635`) states "research still PROCEEDS … does NOT halt the flow."
- **Both exits wired:**
  - PASS exit: `SKILL.md:1648` — "→ Run Step 4b Quality Rubric (if not already emitted this round) → Log to challenge-log.md → Proceed to Phase 4.5".
  - FAIL-max-rounds exit: `SKILL.md:1658` — "→ Run Step 4b Quality Rubric on the latest reports (annotate + advisory WARN only) → Proceed to Phase 4.5 (e_5) — do NOT halt."
  - `SKILL.md:1636-1637` closes the loop: "runs whenever 4c exits toward Phase 4.5 — on both the PASS path below and the FAIL-max-rounds exit. It never changes the PASS/FAIL gate; it only annotates + WARNs."

The `(if not already emitted this round)` idempotence guard on the PASS path correctly prevents a double-emit when both Step 4b and the PASS handler reference the same round.

---

## FOCUS 5 — AC technicality scan: no theater detected

Re-ran every §9.1 AC raw command; all PASS at the claimed values (DR=9, anchor=1, codex/gemini=3/3, AC5.4 phrase grep=3, scaling row greppable, Step 4b WARN region block-free). Distribution re-derived independently from the 22 overalls: Bucket A(<0.5)=6, Bucket B(0.5-0.65)=7, Bucket C(≥0.7)=9, dead-zone(0.65-0.7)=0 — matches the mandated `≥5 / ≥5 / rest` with no gap-band cases. All 6 sampled calibration findings files exist on disk. Parser self-trigger check (`^#+ *P[0-9]` / `| P[0-9] |`) on both new/edited template files = **0/0** — the rubric does not self-inflate `post-write-sync.sh`. The rubric file contains no `INSUFFICIENT|ADEQUATE|STRONG` tokens, so it cannot collide with the Step 4 `head -5` verdict extraction.

The behavior behind each passing AC is genuinely wired (not a substring coincidence). No technicality passes found.

---

## Findings

### P2-1 (clarity) — WARN threshold (0.6) vs "borderline bucket" (0.5-0.65) creates a silent semantic seam
Bucket B is defined as `0.5-0.65` and labeled "borderline," but the advisory WARN fires only at `overall < 0.6`. All 7 Bucket B cases sit at `0.625` (≥0.6) → none would actually trigger a WARN. So a calibration case the rubric calls "borderline" is operationally treated as OK. This is internally consistent (every Bucket B case is mean-branch, ≥0.6) and the threshold is correctly documented as FIXED 0.6 (`research-quality-rubric.md:124`), so it is not a bug — but a future rater could read "borderline bucket" as "the WARN band" and be confused. **Suggestion:** add one sentence to `§5` noting the borderline bucket spans the WARN boundary (cases <0.6 WARN, 0.6-0.65 are borderline-but-OK). Non-blocking.

### P2-2 (robustness, advisory) — Score-parsing format depends on model compliance with `dim_name: SCORE`
Step 4b parses `citation_accuracy: 1.0` etc. from free-form model output. The prompt mandates the strict `dim_name: SCORE` line format (`research-challenge-prompt.md:80`) and restricts to `{0.0,0.5,1.0}`, which is good. But there is no explicit fallback if a model emits e.g. `citation_accuracy: high` or omits a dim. Step 4b covers the model-UNAVAILABLE case (`SKILL.md:1616-1617`) but not the model-available-but-malformed-rubric case. Given the advisory-only nature (worst case: a skipped/garbled dim, never a block), this is low-severity. **Suggestion:** add a one-line "if a dim is unparseable → treat that dim as absent, note in findings, do not block" to mirror the UNAVAILABLE handling. Non-blocking (advisory output, single-user CLI).

### P2-3 (provenance, minor) — `[degraded-hypothetical]` rows are honestly tagged; one cross-check note
The calibration table correctly distinguishes `[as-is]` (scores the real file's observable shape) from `[degraded-hypothetical]` (scores a described weakened variant), and the provenance preamble (`research-quality-rubric.md:130-136`) is explicit that scores are rater-target JUDGMENTS, not claims about the cited file's real numbers. This is the right way to populate low buckets without fabricating provenance (satisfies the 2026-05-28 provenance lesson). No action needed — flagging only so Gate 4 / ux-expert confirms the degraded-hypothetical framing reads as honest rather than as a backdoor to fabricated low scores. The same real file appearing in multiple buckets (e.g. ml-training-pack at #3/#12/#15) is acceptable because the tag disambiguates the variant.

---

## Summary
- **P0:** none
- **P1:** none
- **P2:** 3 (all documentation/robustness clarity; none blocking)
- **Load-bearing claims:** no-new-invocation = SOUND (codex/gemini 3/3, template-driven reuse); advisory-not-blocking = SOUND (0 block tokens in Step 4b, wired into both PASS and FAIL-max-rounds exits).
- **Recommendation: PASS.** P2-1/P2-2 are worth a 2-line follow-up edit but do not block Gate 3. Defer rubric inter-rater-reliability judgment to ux-expert-reviewer (per the 2026-05-28 "Scoring Rubrics Need Methodology Review" lesson — code review does not certify anchor orthogonality).
