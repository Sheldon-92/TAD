# Phase 4 Adversarial Review — ai-evaluation pack — CORRECTNESS lens

- **Lens**: correctness (factual accuracy of research-grounded numbers + internal consistency + actionability)
- **Reviewer stance**: default skepticism; tried to REFUTE that the pack meets the dual-layer bar
- **meets_bar**: false
- **Date**: 2026-06-13
- **Target**: `.claude/skills/ai-evaluation/` (SKILL.md + 7 references + 1 fixture + 1 lint script)

---

## Verdict

The pack is structurally strong (Layer A passes cleanly: 135-line body < 550, frontmatter
load-bearing, CONSUMES/PRODUCES, routing table, anti-skip, fixture with
`discriminative_pattern`+`min_discriminative`, executable deterministic linter, references
one-level-deep) and Layer-B-deep (carries real research thresholds: Wilson CI bands, McNemar,
ICC/Krippendorff cut-points, G-Eval 0.514, MT-Bench >80% ceiling, deepteam taxonomy). The
linter works correctly on clean true-positive / true-negative configs.

BUT the **correctness lens fails** because the pack ships at least one concrete, sourced
FACTUAL ERROR (OWASP numbering using deprecated 2023 IDs while claiming 2025 alignment, and
directly contradicting the sibling ai-guardrails pack that cites the OWASP-2025 PDF), plus
two self-contradicting research numbers (n=20 CI; "23" single-turn attacks vs 22 enumerated),
plus a silent false-negative in the headline linter check. For a pack whose entire job is to
hold OTHER systems to numeric rigor, shipping wrong numbers is a lens-specific bar failure.

---

## Findings (refutation evidence)

### F1 [P0 correctness] OWASP LLM numbering is the deprecated 2023 scheme, but the pack claims "OWASP Top 10 for LLMs 2025" alignment — and contradicts its own sibling pack
`references/adversarial-rules.md` ADV6 (L130):
`Prompt Injection (LLM01), Insecure Output (LLM02), Supply Chain (LLM05), Excessive Agency (LLM08)`.
In the OWASP Top 10 for LLM Applications **2025**: LLM02 = Sensitive Information Disclosure
(Improper Output Handling moved to **LLM05**); Supply Chain = **LLM03** (not LLM05);
Excessive Agency = **LLM06** (not LLM08, which is the 2023 number). So three of four IDs are
the 2023 numbering. Meanwhile ADV1 (L29) explicitly asserts "OWASP Top 10 for LLMs **2025**"
alignment — an internal contradiction. Cross-check: the sibling `ai-guardrails` pack uses the
CORRECT 2025 IDs (LLM02 Sensitive-Info, LLM05 Improper Output, LLM06 Excessive Agency,
LLM07/LLM08) and cites the OWASP-2025 PDF retrieved 2026-06-13. Two packs in the same repo
disagree on the same standard; ai-evaluation is the wrong one. Fix: renumber ADV6 to 2025
(LLM01 / LLM05 Improper Output / LLM06 Excessive Agency / LLM03 Supply Chain) or drop the
"2025" claim. (Version-sensitive — confirm against current OWASP doc per QUALITY-BAR §6 before
editing, but the internal + cross-pack contradiction stands regardless.)

### F2 [P1 correctness] Anti-skip table understates the n=20 confidence interval by ~2x and contradicts AB1
SKILL.md L109 anti-skip counter: "Quick evals with n=20 have **±10pp** confidence intervals."
The pack's own `references/ab-testing-rules.md` AB1 table (L27) says n=20 → **±15-20pp** and
n=100 → ±7-9.5pp. Computed Wilson 95% half-width at p=0.5: n=20 = ±20.1pp, n=100 = ±9.6pp.
So AB1 is correct and the SKILL headline is wrong — it quotes the n=100 figure (~±10pp) for
n=20. The directional message survives, but a pack that exists to enforce statistical rigor
states the wrong CI on its most-read surface. Fix: change L109 to "±20pp" (or "±15-20pp" to
match AB1).

### F3 [P1 correctness] "23 single-turn attacks" claimed in 3+ places, only 22 enumerated
ADV1, ADV2 header, SKILL.md Tool Quick Reference (L123), and the fixture all assert deepteam
"23 single-turn" methods. ADV2's actual list enumerates **22** (counted: Prompt Injection,
Roleplay, Leetspeak, ROT13, Base64, Prompt Probing, Gray Box, Math Problem, Multilingual,
Linguistic Confusion, Input Bypass, Character Stream, System Override, Permission Escalation,
Goal Redirection, Authority Escalation, Context Poisoning, Context Flooding, Synthetic Context
Injection, Embedded Instruction JSON, Adversarial Poetry, Emotional Manipulation = 22). A
research-grounded count the pack cannot reconcile against its own enumeration. Fix: add the
missing method or correct the count to 22 (verify against current deepteam release).

### F4 [P1 correctness] Linter headline check (Judge ≠ Optimizer) has a silent false-negative
`scripts/eval-config-lint.sh` check (a) only counts the number of DISTINCT provider families
globally; it cannot tell WHICH provider is the judge. PROBE A (real self-enhancement: generator
= claude, gradingProvider = claude, plus an unrelated gpt-4o baseline being graded) → linter
reports "✓ Distinct generator/judge families detected" and EXIT=0. The real self-enhancement
bias (judge family == one generator family) passes clean because ≥2 families are present. This
is the pack's #1 P0 rule, and the mechanical check misses the multi-arm case that the pack's
own AB7 makes the COMMON case. Mitigant: SKILL.md L135 frames the linter as "a smoke alarm, not
a substitute for reading the rules," so the judgment layer still catches it — hence P1 not P0.
But the script header claims to flag "judge==generator family" without stating this blind spot;
add the caveat.

### F5 [P2 correctness] SKILL example output conflates B2 (trajectories) with B3 (scenarios)
SKILL.md L71-72 example finding: "[P0] Rule 3 (benchmark): Golden dataset has only 12 cases —
minimum is **50** representative trajectories → Expand to ≥50 cases." But "Rule 3 / B3" in
benchmark-rules.md is the SCENARIO coverage matrix whose floor is **≥5** (L57); the "50-100
trajectories" number is **B2** (L39). The linter's B3 floor is correctly 5. So the SKILL's
canonical worked example mislabels the rule and presents 50 as the B3 "minimum" when B3's
minimum is 5 and 50 is B2's production target. Actionability defect: an agent copying this
format will cite the wrong rule number and the wrong floor. Fix: relabel to "Rule B2" or change
"minimum is 50" to "B3 floor is 5; B2 target is 50-100 for production."

---

## Fact-checks performed

- Wilson 95% CI half-width recomputed in Python: n=20 ±20.1pp, n=100 ±9.6pp, n=550 ±4.2pp → AB1 table CORRECT; SKILL anti-skip ±10pp WRONG. Confirmed.
- deepteam single-turn attack list counted from ADV2 prose: 22, not 23. Confirmed.
- OWASP 2025 numbering cross-checked against sibling ai-guardrails pack (cites OWASP-2025 PDF, retrieved 2026-06-13): ai-evaluation ADV6 uses 2023 IDs → internal + cross-pack contradiction. Confirmed. (Live OWASP doc re-verification still advised per QUALITY-BAR §6.)
- eval-config-lint.sh exercised on 5 configs: true-positive (same-family/3-tests/unthresholded → EXIT 1, correct), true-negative (cross-family/5-tests/thresholds/repeat → EXIT 0, correct), false-negative PROBE A (multi-arm same-family judge → EXIT 0, MISS), assert-line inflation PROBE B (1 test/4 asserts → correctly counts 1, no inflation), external-file tests PROBE C (`tests: file://...` → "no scenarios" P2, acceptable).
- Layer A structural items verified by grep/wc/find: body 135 lines (<550), name+description present, CONSUMES/PRODUCES, discriminative_pattern + min_discriminative in fixture, executable script, references one-level. Layer A genuinely passes.
- discriminative_pattern matches 7 unique pack-specific markers under UTF-8 locale (self-enhancement bias, Judge ≠ Optimizer, cross-family, determinismLevel, dual-pass, McNemar, Spearman 0.5) — gate wired and pack-anchored. PASS.

## Net assessment
Layer A: PASS. Layer B depth: PASS. Discriminative wiring: PASS.
CORRECTNESS lens: FAIL — F1 (sourced factual error + self-contradiction + sibling-pack
contradiction) is disqualifying on this lens for an eval pack; F2/F3 are self-contradicting
numbers; F4 is a false-negative in the headline mechanical check; F5 is a mislabeled canonical
example. None are structural, all fixable in a focused edit pass, but AS SHIPPED the pack does
NOT clear the correctness bar.

---

## FIX applied (validated)

Fix pass date: 2026-06-13. Each finding re-validated before editing (WebSearch/WebFetch against
current primary docs for factual claims; recomputation / internal-consistency check for the rest).
Edits confined to `.claude/skills/ai-evaluation/`.

- **F1 [P0] OWASP LLM numbering (ADV6) — FIXED.** Verified official OWASP Top 10 for LLM
  Applications 2025 via genai.owasp.org + the v2025 PDF: LLM01 Prompt Injection, LLM02 Sensitive
  Information Disclosure, LLM03 Supply Chain, LLM05 Improper Output Handling, LLM06 Excessive
  Agency, LLM08 Vector & Embedding Weaknesses. Confirmed sibling pack ai-guardrails already uses
  the correct 2025 codes (two-pack contradiction real). Rewrote adversarial-rules.md L130 from the
  deprecated "Insecure Output (LLM02), Supply Chain (LLM05), Excessive Agency (LLM08)" to the
  correct 2025 mapping. ADV1's "OWASP Top 10 for LLMs 2025" claim is now consistent with ADV6.

- **F2 [P1] n=20 CI on SKILL anti-skip — FIXED.** Recomputed Wilson 95% half-width at p=0.5:
  n=20 = ±20.1pp, n=100 = ±9.6pp, n=550 = ±4.2pp. AB1's "±15-20pp for n=20" is correct; the SKILL
  headline "±10pp" was the n=100 figure (~2x understatement). Changed SKILL.md L109 to
  "±20pp Wilson confidence intervals (at p=0.5; ±10pp is the n=100 figure)". Also corrected the
  same misstatement in the fixture's anti-slop bullet (examples/llm-judge-ab-eval.md L60). Fixture
  grep marker pattern + discriminative_pattern unchanged (both still match), so the gate is intact.

- **F3 [P1] deepteam "23 single-turn" — FIXED.** Verified trydeepteam.com docs taxonomy
  (retrieved 2026-06-13): 14 single-turn + 5 multi-turn. Counted ADV2's own enumerated list = 22
  (self-miscount vs the "23" headline). Replaced every "23 single-turn" occurrence (ADV1 index L8,
  ADV1 table L25, ADV1 body L29, ADV2 header L66, SKILL.md tool table L123) with "14 single-turn +
  5 multi-turn per docs taxonomy" and added the README "20+ combined" framing + source URL/date.
  Trimmed ADV2's named single-turn list to the 14 documented methods (removed names not in the
  official taxonomy). Multi-turn list (5 names) verified correct and left unchanged.

- **F4 [P1] linter check (a) false-negative — FIXED (honesty fix, not logic rewrite).** Reproduced:
  a probe with generator=claude + gradingProvider=claude + an unrelated gpt-4o baseline exits 0
  "distinct families detected". The script header claimed to flag "judge==generator family" without
  caveat. Per the finding's own mitigation note (SKILL frames the linter as a smoke alarm), fixed
  the dishonest claim rather than attempting full judge-vs-generator parsing in grep: rewrote the
  header comment for check (a) to state it counts globally-distinct families only, documents the
  known false-negative, and points to AB3 for the real determination; softened the in-body PASS
  message from "Distinct generator/judge families detected" to a caveated "≥2 provider families
  present … cannot confirm the JUDGE differs from the GENERATOR; verify by hand per AB3."
  `bash -n` clean; behavior unchanged, claims now accurate.

- **F5 [P2] SKILL example mislabels Rule 3 / floor 50 — FIXED.** Confirmed against benchmark-rules:
  the 50-100 trajectory floor is B2 (L39), B3 is the scenario-coverage matrix with floor ≥5 (L57),
  and the linter's B3 floor is correctly 5. Changed SKILL.md L71-72 example from "Rule 3
  (benchmark): … minimum is 50 representative trajectories" to "Rule B2 (benchmark): … minimum is
  50-100 representative trajectories" and split the fix line to cite B2 (≥50 trajectories) and the
  B3 matrix (floor ≥5) separately.

### SKIPPED — FALSE POSITIVE

- **fact-api [P2] deepeval "50+ metrics" — SKIPPED (false positive).** The finding claimed "current
  deepeval docs do not headline a 50+ count." Verified the opposite: deepeval.com/docs/metrics-introduction
  headlines "50+ SOTA, ready-to-use metrics" and confident-ai.com's evaluation-metrics blog states
  "50+ state-of-the-art, ready-to-use metrics." The number IS sourced to the vendor's primary docs.
  No change.

- **fact-api [P2-noop] deepteam "50+ vulns" — SKIPPED (explicitly no-op).** Confirmed CORRECT against
  the official README (50+ vulnerability types). Finding itself flagged it only to prevent a future
  editor "correcting" it to the news-article's "80+". Left as-is, as instructed.

### Anti-slop findings dispositions

- P1 fabricated-precision (deepteam 23+5 asserted 5x) — FIXED via F3 (same root cause; all
  occurrences replaced with the sourced 14+5 / "20+ combined" framing + URL + retrieval date).
- P2 unsourced numbers (self-enhancement bias "10-15%", HE3 "0.86" Spearman, ICC>0.92 / ICC>0.97,
  Krippendorff 0.8/0.667) — NOT changed in this pass: scoped strictly to the refuting reviewers'
  enumerated correctness/fact-api findings (F1-F5 + the explicit fact-api list). The anti-slop lens
  VERDICT was meets_bar=TRUE and these P2s are "should fix, do not sink the bar." Left for a
  follow-up sourcing pass to avoid scope creep into a non-blocking lens during a correctness fix.
- All anti-slop POSITIVES (G-Eval 0.514, AB8 position-sensitivity 0.04 + dual-pass, MT-Bench >80%
  ceiling, B4 promptfoo no-op-gate contract, AB2/AB5 stats, fixture discriminative hygiene) were
  left untouched — verified correct, load-bearing, and not implicated by any refutation.
