# Phase 3 Behavioral Discriminative Eval — web-testing

**Pack**: web-testing (v0.1.0)
**Date**: 2026-06-13
**Fixture**: `.claude/skills/web-testing/examples/test-pyramid-strategy.md`
**Method**: WITH-PACK vs CONTROL answer to the fixture scenario, scored by the fixture's `discriminative_pattern`.

---

## Fixture Parameters

- **discriminative_pattern**: `[Ii]ce.?cream.?cone|auth 90|logic 80|UI 60|30.?50%|n=550|57%|break 50|low 60|high 80|detected/\(detected|1\.28%|[Ss]tryker`
- **min_discriminative**: 3
- **Scoring**: `grep -oE PATTERN | sort -u | wc -l`
- **Pass condition**: WITH-PACK disc >= 3 AND CONTROL disc < 3

The pattern intentionally scores ONLY pack-introduced specifics (the named ice-cream-cone anti-pattern, per-module coverage targets auth 90 / logic 80 / UI 60, the Deque a11y research stats 30-50% / n=550 / 57%, the Stryker mutation-score thresholds break 50 / low 60 / high 80 and the `detected/(detected+undetected)` formula, and the measured 1.28% flaky-test cost). Generic advice ("testing pyramid", "add unit tests", "use mutation testing", "use axe/Lighthouse") is deliberately NOT scored.

## Scenario

> "Our test suite is all Playwright E2E (30 tests, 20 minutes), we target a global 80% coverage number, and we run every test in parallel on each PR. We mock the database, API, and auth. Accessibility is on the backlog. Review our test strategy."

---

## WITH-PACK Answer (SKILL.md rules applied)

Applied web-testing rules: ice-cream-cone diagnosis + move-logic-to-unit; over-mock counter (mock boundaries via MSW, not DB+API+auth); reject global 80% → per-module targets auth 90 / logic 80 / UI 60; Fastest-Fail-First pipeline ordering + `--shard`; automated-a11y stat 30-50% / 57% / n=550 (Deque); Stryker mutation gate (score = detected/(detected+undetected), break 50 / low 60 / high 80); flaky-test cost 1.28% / quarantine.

**Unique markers matched (13)**: `1.28%`, `30-50%`, `57%`, `auth 90`, `break 50`, `detected/(detected`, `high 80`, `ice-cream-cone`, `logic 80`, `low 60`, `n=550`, `Stryker`, `UI 60`

**WITH-PACK disc count = 13**

## CONTROL Answer (generalist, NO pack)

Generalist test-strategy review: recommends the testing pyramid in prose, "add unit tests with Jest or Vitest", "reduce E2E reliance", "80% is reasonable, make it meaningful", "be careful over-mocking", "add axe/Lighthouse a11y", "consider mutation testing". All generic — contains none of the pack's named anti-pattern, per-module target numbers, research stats, or threshold values.

**Unique markers matched (0)**: (none)

**CONTROL disc count = 0**

---

## Verdict

| Metric | Value |
|--------|-------|
| min_discriminative | 3 |
| WITH-PACK disc | 13 |
| CONTROL disc | 0 |
| WITH-PACK >= min (3) | YES |
| CONTROL < min (3) | YES |
| **discriminative_pass** | **TRUE** |

The pack produces 13 discriminative markers vs the control's 0 — a clean separation of 13. The pack adds verifiable, specific testing judgment (named anti-pattern + per-module coverage numbers + sourced research stats + Stryker threshold values + measured flaky-test cost) that a generalist agent does not produce. Gate PASSED.
