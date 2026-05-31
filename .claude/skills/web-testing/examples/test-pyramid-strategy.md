---
name: test-pyramid-strategy
description: "Tests ice-cream-cone anti-pattern + per-module coverage targets + fastest-fail-first ordering + automated-a11y 30-50%/n=550 stat + mutation testing"
pack: web-testing
tests_rules:
  - "Cross-Cutting: Fastest-Fail-First pipeline ordering"
  - "test-strategy-rules.md: testing pyramid / ice-cream-cone anti-pattern"
  - "Per-module coverage targets (auth 90 / logic 80 / UI 60), not global 80%"
  - "accessibility-testing-rules.md: automated catches 30-50% (n=550), top-5 failures"
  - "Mutation testing (Stryker) over line coverage"
min_marker_count: 3
---

# Fixture: Test Strategy / Pyramid Review

## Input Scenario

"Our test suite is all Playwright E2E (30 tests, 20 minutes), we target a global 80% coverage number, and we run every test in parallel on each PR. We mock the database, API, and auth. Accessibility is on the backlog. Review our test strategy."

## Expected Markers

When an AI agent processes the Input Scenario with the web-testing pack loaded,
the output MUST contain these markers:

1. **Ice-cream-cone / inverted-pyramid anti-pattern** [structural]: the agent diagnoses E2E-heavy suite as inverted pyramid and prescribes moving logic to unit level, not "add more E2E"
   grep pattern: `ice.?cream.?cone|inverted pyramid|testing pyramid|wrong (pyramid )?level|unit (test).*(business )?logic`
2. **Per-module coverage targets**: rejects global 80%, sets auth 90 / logic 80 / UI 60
   grep pattern: `per.?module (coverage )?target|auth 90|logic 80|UI (components? )?60|global 80%`
3. **Fastest-fail-first ordering + sharding**: lint→unit→integration→E2E gating, not parallel-all
   grep pattern: `fastest.?fail.?first|lint.+unit.+integration.+E2E|gate(s)? the next|shard|--shard`
4. **Automated-a11y stat + mutation testing**: pack's specific numbers
   grep pattern: `30.?50%|n=550|57%|axe.?core|mutation testing|Stryker|over.?mock`

## Verification Command

```bash
grep -oE 'ice.?cream.?cone|inverted pyramid|testing pyramid|wrong level|unit test.*logic|per.?module target|auth 90|logic 80|UI 60|global 80%|fastest.?fail.?first|gate the next|shard|--shard|30.?50%|n=550|57%|mutation testing|Stryker|over.?mock' test-pyramid-strategy-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "ice-cream-cone / inverted pyramid" (the pack's named anti-pattern for E2E-heavy suites)
- ✅ "per-module coverage: auth 90 / logic 80 / UI 60 (not global 80%)" (the pack's specific coverage rule)
- ✅ "automated a11y catches 30-50% (n=550 / 57% by volume)" (the pack's specific research stat)
- ✅ "mutation testing (Stryker) over line coverage / over-mocking" (the pack's named quality rules)
- ❌ "add more tests" (generic — any agent says this)
- ❌ "increase coverage" (generic without the per-module targets)
- ❌ "use Playwright" (in the input)
