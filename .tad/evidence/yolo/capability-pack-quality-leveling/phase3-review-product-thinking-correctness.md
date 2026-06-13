# Phase 3 Review — product-thinking — CORRECTNESS lens

- **Lens**: correctness (internal consistency + actionability of the dual-layer guidance)
- **Reviewer**: adversarial subagent (Opus 4.8)
- **Date**: 2026-06-13
- **Verdict**: meets_bar = FALSE

## Summary

Structure (Layer A) and depth (Layer B) are strong: 78-line SKILL body (<550),
2 fixtures, 1 wired discriminative_pattern, executable verify-verdict.sh, deny-listed
CONSUMES/PRODUCES contract, anti-rationalization registry, Quick Rule Index whose every
threshold traces to a sourced adapter/checklist with retrieval dates. specN=32.
verify-verdict.sh PASSes the real walkthrough and correctly FAILs the marker-spec fixture.

BUT the correctness lens fails on the pack's load-bearing mechanical core — the
verdict decision logic is internally CONTRADICTORY across three files, and the canonical
worked example demonstrates a verdict that VIOLATES the pack's own KILL rule.

## Findings (refutations)

### F-A (P0) — Canonical walkthrough example violates the pack's own "2+ fatal = KILL" rule
- `examples/pressure-test-example.md` L218-235: emits **"Fatal Flaws: 2" (F3 + F7)** with
  **VERDICT: PIVOT, Confidence 5/10**.
- This directly contradicts the decision rule it is supposed to demonstrate:
  - `skills/pressure-test.md` L271: `KILL → ... 2+ fatal flaws (regardless of confidence)`
  - `SKILL.md` L60 Quick Rule Index: `2+ fatal flaws = KILL · regardless of confidence`
  - `checklists/fatal-flaws.md` L160 Severity Guide: `2 fatal flaws | KILL`
- The gold reference fixture teaches the WRONG behavior. An agent imitating the example
  learns to soften a mandated KILL into a PIVOT — the exact anti-rigor failure the pack
  exists to prevent. This is not a typo: the verdict, confidence, and a 2-step "PIVOT
  Validation Plan" are all internally built around PIVOT.

### F-B (P1) — Step 7 decision tree has no clause for a single STRUCTURAL fatal flaw → contradicts fatal-flaws.md
- `skills/pressure-test.md` L270 + L274: `PIVOT → ... conf≥7 with 1 fatal flaw that a pivot
  could address`, and the flat Note `A fatal flaw always downgrades the verdict — confidence
  ≥ 7 with 1 fatal flaw = PIVOT (not BUILD)`.
- `checklists/fatal-flaws.md` L159 + L163: `1 fatal flaw | ... KILL if the flaw is structural
  (F9 legal, F13 unit economics)` and `A single F-level flaw with high severity (F9 legal,
  F13 negative unit economics) can be a KILL on its own`.
- Step 7's KILL clause (L271) lists only "conf≤3 / 2+ fatal / core assumption disproven" — it
  does NOT encode "single structural F9/F13 = KILL". An agent following Step 7 verbatim on a
  conf-8 idea with one F9 (illegal business model) would output PIVOT, when the checklist
  mandates KILL. The L274 Note ("1 fatal = PIVOT") is categorically stated with no carve-out,
  actively masking the structural-flaw exception. The KILL/PIVOT boundary — the single most
  load-bearing output of the whole pack — is under-specified and self-contradictory.

### F-C (P2) — Minor citation drift in Anti-Rationalization Registry
- `SKILL.md` L48 cites the named-person rule at `skills/pressure-test.md` "Step 3, L138-139".
  Actual content: L138 is blank, L139 is the "### Pushback patterns:" header. The
  demographic-refusal rule is at **L141-142**. Off-by-~3. (Other citations verified accurate:
  anti-sycophancy L14-28 ✓, fatal-flaws L5 ✓, rubric §B/§C ✓, PMF/LTV:CAC/take-rate/Kickstarter
  thresholds all trace correctly to adapters with sources.)

## Fact_checks (verified TRUE — not defects)
- A1 frontmatter present, 3rd-person, what+when. ✓
- A3 body = 78 lines < 550. ✓
- A8 2 fixtures; A9 discriminative_pattern wired in pressure-test-verdict.md (min_discriminative=2). ✓
- A10 verify-verdict.sh executable, BSD/GNU-safe, conclusion-neutral; PASSes walkthrough,
  FAILs marker-spec fixture (expected). ✓
- specN=32 (bucket 25-39→3 raw; depth genuinely in operationalized criteria, consistent with
  QUALITY-BAR §2.3 "specN is one input"). ✓
- Quick Rule Index thresholds (LTV:CAC 3:1-4:1/median 3.6, Rule of 40, CAC payback 6.8mo,
  free-trial 8-18/31-49, freemium 1-5/5-15, take rate 5-15/15-30, Kickstarter 42%/80%, PMF 40%)
  ALL traced to sourced adapter/checklist lines with 2026-06-13 retrieval dates. ✓
- BUILD clause consistent across SKILL L58, pressure-test L269 (conf≥7 AND 0 fatal). ✓

## Why this fails the bar (correctness specifically)
The QUALITY-BAR's headline risk is "validation theater" — structure that looks rigorous but
doesn't change behavior. Here the inverse bites: the structure is excellent, but the actual
DECISION CONTENT is contradictory, and the teaching example encodes the contradiction. The
pack's entire value proposition is a disciplined, mechanical BUILD/PIVOT/KILL verdict. A
verdict rule that (a) its own gold example violates and (b) silently drops the structural-flaw
KILL carve-out is not "internally consistent and actionable." F-A alone is a blocking P0:
ship a pack whose canonical demo breaks its own rule and every agent that few-shots off it
inherits the bug.
