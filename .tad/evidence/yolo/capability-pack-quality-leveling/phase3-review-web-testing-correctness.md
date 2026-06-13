# Phase 3 Review — web-testing — CORRECTNESS lens

**Lens**: correctness (does the upgraded SKILL.md genuinely meet the dual-layer bar; is the guidance internally consistent + actionable; adversarial refutation attempt)
**Reviewer**: subagent (adversarial, default-skeptic)
**Date**: 2026-06-13
**Verdict**: meets_bar = TRUE (clears the bar on this lens after attempting refutation)

---

## Method

Read SKILL.md + all 7 references + the single fixture + all 3 validation scripts.
Ran the QUALITY-BAR §1 Layer A grep checks, the §2.3 specN count, validated the
fixture's `discriminative_pattern` regex against a plausible agent output, and
cross-checked version/metric claims across SKILL and references for internal
contradictions. Tried hardest to break the TBT→INP proxy and the
fixture-key duplication.

---

## Layer A (structure) — PASS 10/10

- A1 frontmatter: `name` (web-testing, no "anthropic"/"claude", lowercase-hyphen) + third-person `description` with what+when. PASS.
- A2 progressive disclosure: 7 references/ + examples/ + scripts/. PASS.
- A3 body discipline: SKILL.md = **141 lines** (far under the 550 buffer). PASS.
- A4 routing: Step 0 "Context Detection" signal→reference table + Step 1/2. PASS.
- A5 contract: CONSUMES/PRODUCES present (lines 8-9). PASS.
- A6 anti-skip: dedicated Anti-Skip Table with per-excuse counters. PASS.
- A7 navigation: each reference has a Quick Rule Index; SKILL has Tool Quick Reference + Step table. PASS.
- A8 fixture: examples/test-pyramid-strategy.md present. PASS.
- A9 eval-ready: fixture has both `discriminative_pattern:` + `min_discriminative:`. PASS.
- A10 scripts: 3 executable .sh validators (chmod +x confirmed). PASS.
- Soft constraints: references one level deep (no nesting); forward-slash paths; sources carry URL + 2026-06-13 retrieval date; no Windows paths; default+escape-hatch present (e.g. "when jsdom is acceptable"). All clean.

## Layer B (depth) — PASS, ~4/5

- specN = **54** (40-59 bucket → 4). Carries research-grounded specifics an LLM cannot reliably recall: Stryker `break 50/low 60/high 80` + `detected/(detected+undetected)`; CWV LCP 2.5s/INP 200ms/CLS 0.1 at 75th-pct CrUX, ~55.9% origins pass / ~43% fail INP; k6 exit code 99 + v1.0 2025-05-07/1.3.0; axe-core 4.12.x + WCAG 2.2 SC 2.5.8 target-size 24px + 4.1.1-removed; flaky-cost 1.28% dev time / 58% monthly; Deque n=550 / 30-50% / 57%-by-volume; Playwright Test Agents v1.56 / browser.bind v1.59 / current 1.60; Vitest Browser Mode STABLE since 4.0.
- B2 tool freshness: every tool named with version + usage, each reference has dated source URLs. Strong.
- B3 operationalized: P0/P1/P2 output schema + tiered coverage tables + tiered VU budgets. Strong.
- B4 anti-pattern-from-incident: ice-cream-cone, coverage-gaming, over-mock, FID-instead-of-INP, flagging-removed-4.1.1, doomed-load-test. Strong.

---

## Refutation attempts (all failed to sink the pack)

1. **STRONGEST — TBT-as-INP proxy in cwv-budget-check.sh compared against the 200ms INP threshold.**
   The script falls back to Lighthouse `total-blocking-time` when `interaction-to-next-paint` is absent, then asserts `inp<=200`. TBT and INP are *different* metrics on *different* scales — a TBT of 200ms is not equivalent to an INP of 200ms, so a PASS on the TBT path does not prove INP≤200ms. HOWEVER: (a) the script labels the value "TBT (INP lab proxy)" in output so it never silently claims to be INP; (b) the comment explicitly states "Real INP only exists in field reports; lab uses TBT as the documented proxy"; (c) standard Lighthouse JSON genuinely has no INP audit (INP is field-only), so a fallback is *necessary* for the script to function at all. This is an honestly-disclosed approximation, not a false claim. It is a P2 advisory (the 200ms numeric comparison is technically apples-to-oranges and could mislead a user who ignores the label), NOT a correctness failure that fails the lens.

2. **Fixture key duplication: `min_marker_count: 3` AND `min_discriminative: 3`.** Two keys carrying the same value. Per QUALITY-BAR §3 the runner drives PASS off `discriminative_pattern`+`min_discriminative` (the eval-ready signal A9 checks). `min_marker_count` pairs with the older combined "Verification Command" grep. Both are 3, so no contradiction in practice, but the redundant key is mild clutter. Not a correctness defect — A9 wiring is intact.

3. **discriminative_pattern vs the Verification Command regex diverge.** The `discriminative_pattern` (PASS driver) is a tight pack-only marker set; the in-fixture `## Verification Command` grep is broader (adds generic-ish `inverted pyramid|testing pyramid|shard|over.?mock`). This is EXPECTED and correct per QUALITY-BAR §3: the combined command is SECONDARY/display only and must NOT drive PASS (it would let a no-pack control pass = validation theater). The discriminative_pattern correctly excludes the generic markers. Validated the regex compiles and matches a plausible agent output (8 distinct markers on a 3-sentence sample, well over min 3). Consistent with the rubric, not a bug.

4. **Internal version contradictions.** Cross-checked Playwright (SKILL 1.60 / Test Agents 1.56 / bind 1.59 vs agentic ref — agree), Vitest Browser Mode (SKILL "STABLE since 4.0" vs unit ref "STABLE in 4.0, current 4.1" — agree), k6 (SKILL 1.0/1.3.0 vs perf ref — agree), axe-core 4.12.x + wcag22aa (SKILL vs a11y ref — agree). No contradictions found.

5. **Actionability.** Every rule states the violation + a specific fix with copy-pasteable config (vitest thresholds, stryker.config.json, GitHub Actions matrix, k6 thresholds, AxeBuilder withTags). Output format is a concrete P0/P1/P2 schema. Highly actionable.

---

## Findings (advisory; none block the lens verdict)

- [P2] cwv-budget-check.sh compares a TBT fallback value directly against the 200ms INP budget. TBT≠INP numerically; the label discloses it but a tighter design would apply a TBT-specific "good" band (TBT good ≤200ms is itself a Lighthouse threshold, which is why the number coincides) or print a clearer "this is NOT INP, treat as lab estimate" caveat in the FAIL/PASS line, not only in the metric label.
- [P2] Fixture carries both `min_marker_count: 3` and `min_discriminative: 3`. Drop `min_marker_count` (legacy combined-grep key) to avoid implying the broad Verification Command drives PASS.
- [P2] Layer B specN=54 sits mid-bucket (4/5), not 5. Depth is real but slightly below the gold anchors; this is consistent with a v0.1.0 pack and does not fail the bar (pass = structurally ≥7/10 + non-shallow Layer B; both met).
