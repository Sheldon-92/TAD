# Fixture 3 — Testing pyramid collision (SAME-category testing → escalate)

**Topic**: `testing-pyramid`
**Packs**: web-frontend × web-testing
**Expected classification**: `same-cat-escalate` — both sides `testing` (correctness band), precedence cannot break the tie

## Both-side file:line (hand-re-derive against live `.claude/skills/` at acceptance)

| side | category | ref | quote |
|------|----------|-----|-------|
| A (cut E2E) | testing | `.claude/skills/web-frontend/references/testing.md:15` | `Unit (most) ~60%` — and `:19` `If E2E tests make up >20% of the test suite — cut` |
| B (more E2E) | testing | `.claude/skills/web-testing/references/test-strategy-rules.md:25` | `Unit tests (base) ... many (70% of test count)` — and `:31` `UI-heavy app: More E2E tests` |

## Why it escalates (does NOT auto-resolve)

Both directives are category `testing` (correctness band, category 2). Same-category →
precedence tie → ESCALATE. The tension is real and opposing:

- web-frontend prescribes Unit ~60% and **cuts** E2E above 20% of the suite.
- web-testing prescribes Unit ~70% and pushes **More E2E** exactly where web-frontend
  says cut (UI-heavy apps).

Differing base numbers (60% vs 70%) plus an opposing conditional → a human/project must
pick the test-distribution policy.

## Expected surfacing one-liner

```
⚠️ unresolved: web-frontend vs web-testing — human decides (testing-pyramid)
```
