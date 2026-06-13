# Dogfood Judgment: web-testing capability pack

**Task**: Review test strategy — 30 Playwright E2E (20 min), global 80% coverage, all parallel on each PR, DB/API/auth all mocked, a11y on backlog.

**Date**: 2026-06-13
**Judge**: independent (blind to which answer used the skill)

---

## Claim Verification (WebSearch against primary docs, June 2026)

| Claim | Answer | Verdict | Correct value |
|-------|--------|---------|---------------|
| axe-core catches 30-40% of a11y issues | A1 | OK (conservative; common cited range) | Deque: 57% by volume |
| axe-core catches 30-50%, "57% by volume, Deque n=550" | A2 | MOSTLY OK; **n wrong** | Deque study used >2,000 audits / ~13,000 pages / ~300,000 issues — NOT n=550. 57% figure correct. |
| EAA in effect 2025 (ADA/508 US) | A1 | OK | EAA enforcement began 28 June 2025; existing services by 2030 |
| Vitest 4.0 Browser Mode stable | A2 | OK | Confirmed stable in Vitest 4.0 (experimental tag dropped) |
| Vitest ^4.1 current | A2 | OK | Latest 4.1.8 as of June 2026 |
| WCAG 2.2 target-size = 2.5.8, axe-core `target-size` rule | A2 | OK | Correct; rule off by default, needs WCAG 2.2 ruleset config |
| `@axe-core/playwright` >= 4.12.x | A2 | **WRONG** | Latest `@axe-core/playwright` is 4.11.2. axe-core core lib is 4.12.1, but the playwright wrapper package version != core version. 4.12.x of the wrapper does not exist yet. |
| Pact / OpenAPI contract testing | both | OK | Standard tools |
| Stryker mutation testing | A2 | OK | Real tool, correct use |
| MSW for third-party network mocking | A2 | OK | Correct positioning |

**Wrong specifics found:**
- A2: "Deque n=550" — actual study sample is >2,000 audits / ~300,000 issues. The 57% headline number is right; the cited sample size is fabricated/wrong.
- A2: "`@axe-core/playwright` >= 4.12.x" — that wrapper package tops out at 4.11.2; conflated with axe-core core lib 4.12.1.

A1 has **zero** wrong specifics (it stays in verified ranges: "30-40%", EAA 2025 — both correct).

---

## Scoring

### Answer 1 (no skill, likely)
- **Correctness 5/5** — every specific verified true; ranges chosen conservatively and accurately. Strong conceptual core (integration-illusion, coverage-measures-execution-not-assertion, retry-masking, mock-state contamination).
- **Actionability 4/5** — clear priority-ordered action list; tool names (axe-core/playwright, Pact, Vitest, Stryker-absent). Slightly less prescriptive on thresholds.
- **Specificity 4/5** — good numbers (3-8 E2E, axe %, EAA), but fewer hard config values.
- **Completeness 4/5** — covers pyramid, mocks, coverage, parallel/flakiness, a11y. Misses mutation testing, staged/fastest-fail pipeline gating, per-module threshold table.

### Answer 2 (skill, likely)
- **Correctness 4/5** — strong and mostly verified, BUT two wrong specifics (n=550 fabricated; @axe-core/playwright 4.12.x doesn't exist). Headline 57% correct. The wrong sample-size and version are exactly the "confident wrong specific" the rubric penalizes.
- **Actionability 5/5** — P0/P1/P2 triage, staged pipeline with `needs:`, sharding command, per-module threshold values, named scripts, merge-gate checklist, test-level audit table. Highly executable.
- **Specificity 5/5** — densest correct specifics: WCAG 2.2 target-size rule + tags, Vitest Browser Mode, per-module % thresholds, Stryker break/low/high values, sharding syntax.
- **Completeness 5/5** — adds fastest-fail gating (S3), mutation testing for AI-gen code (S6), contract layer, sharding nuance ("don't shard <10min"), test-level audit table. Most comprehensive.

---

## Verdict

**Winner: Answer 2. Margin: slight.**

Answer 2 wins on **correct, load-bearing specifics that A1 lacks** — staged fastest-fail pipeline, per-module coverage thresholds (not just "set floors"), Playwright sharding with the explicit "don't shard <10min" caveat, mutation testing for gameable AI-generated coverage, and a test-level audit table that maps every current level to a recommended one. This is genuine depth, not verbosity: it answers the same critique A1 raises but with executable values.

However the win is only **slight**, not clear/decisive, because:
1. A2 carries TWO wrong specifics (n=550, @axe-core/playwright 4.12.x) while A1 has zero. A confident wrong specific is the rubric's named failure mode.
2. A1's conceptual framing is equal or better in places (retry-masking, coverage-measures-execution, mock-state contamination across parallel workers — A2 omits the parallel-worker isolation point entirely despite the prompt explicitly saying "parallel on each PR").
3. A2's rule-ID scaffolding (S1/U2/X3...) is noise to the end user and reads as internal pack plumbing leaking into output.

A2's actionability/specificity/completeness edge (correct portions) outweighs A1's clean-correctness edge, but the two wrong specifics keep it from a clear margin. If A2 had cited the 57% figure without the fake n=550 and pinned the right wrapper version, this would be clear/decisive.

**The winner won on correct specifics (the staged pipeline, per-module thresholds, mutation gate, audit table), discounted by two wrong specifics — not on verbosity.**
