# Test Strategy Rules
<!-- capability: test_strategy -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| S1 | Testing pyramid: unit (many, fast) -> integration (medium) -> E2E (few, slow) | Designing test distribution |
| S2 | Per-module coverage targets, not global average | Setting coverage requirements |
| S3 | Fastest-fail-first pipeline ordering | Configuring CI/CD |
| S4 | Playwright sharding for E2E parallelization | Optimizing E2E runtime |
| S5 | Flaky test policy: quarantine -> fix within 48h -> restore or delete | Managing test reliability |
| S6 | AI-generated code: mutation testing over line coverage | Testing AI code |
| S7 | Risk-based test level assignment | Prioritizing test effort |
| S8 | Quality gates: zero tolerance for test failures in CI | Setting merge policies |

---

## Rules

### S1: Testing Pyramid

When designing the test distribution for a project:

- **Unit tests (base)**: Fast (< 30s total), many (70% of test count), test logic in isolation
- **Integration tests (middle)**: Medium (2-10 min), moderate count (20%), test component interaction
- **E2E tests (top)**: Slow (10-30 min), few (10%), test critical user flows end-to-end

Adjust for project type:
- **Data-heavy app** (dashboards, analytics): More integration tests (API layer critical)
- **UI-heavy app** (marketing, content): More E2E tests (visual correctness matters)
- **Logic-heavy app** (calculators, algorithms): More unit tests

**Anti-pattern**: Ice cream cone (inverted pyramid) -- relying primarily on E2E. Results in 30+ minute CI, flaky tests, and CSS-change-breaks-everything fragility.

### S2: Per-Module Coverage Targets

When setting coverage requirements:

| Module Risk Level | Example | Coverage Target |
|-------------------|---------|-----------------|
| Critical | Auth, payments, data mutations | 90% |
| High | Business logic, hooks, utilities | 80% |
| Medium | API routes, middleware | 70% |
| Low | UI components, formatting | 60% |

- **Global 80% is a lie**: It hides auth at 40% behind getters at 100%
- Set targets per directory or module in vitest.config.ts / jest.config.ts
- Coverage gates block merge when targets are missed

```typescript
// vitest.config.ts
coverage: {
  thresholds: {
    'src/auth/**': { lines: 90, branches: 85 },
    'src/lib/**': { lines: 80, branches: 75 },
    'src/components/**': { lines: 60, branches: 50 },
  }
}
```

### S3: Fastest-Fail-First Pipeline

When configuring CI/CD pipeline stages:

```
Stage 1: Lint + Typecheck         (<10s, pre-commit)
    |
Stage 2: Unit Tests               (<30s, PR gate)
    |
Stage 3: Integration Tests        (2-10min, PR gate)
    |
Stage 4: E2E Tests                (10-30min, merge gate or nightly)
    |
Stage 5: Performance + A11y       (nightly)
```

Each stage gates the next. A lint error at 5 seconds saves 30 minutes of E2E time.

```yaml
# GitHub Actions example
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint && npx tsc --noEmit

  test-unit:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - run: npx vitest run

  test-e2e:
    needs: test-unit
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    runs-on: ubuntu-latest
    steps:
      - run: npx playwright test --shard=${{ matrix.shard }}/4
```

### S4: Playwright Sharding

When E2E tests take too long:

```bash
# Split across 4 shards
npx playwright test --shard=1/4
npx playwright test --shard=2/4
npx playwright test --shard=3/4
npx playwright test --shard=4/4

# Merge reports afterward
npx playwright merge-reports ./blob-reports --reporter=html
```

- **20 minutes -> 5 minutes** with 4 shards in parallel
- Use GitHub Actions matrix strategy for parallel execution
- Merge reports after all shards complete for unified results
- Only shard when suite exceeds 10 minutes -- overhead isn't worth it for small suites

### S5: Flaky Test Policy — Quarantine Immediately (the cost is measured, not theoretical)

When dealing with flaky tests (pass sometimes, fail sometimes):

1. **Quarantine immediately**: Move to a separate test group that doesn't block CI
2. **Fix within 48 hours**: Assign an owner, investigate root cause
3. **Restore or delete**: If fixed, return to main suite. If not fixable within 48h, delete the test and open a ticket for rewrite.

**Why "immediately", not "when we get to it" — the numbers (2025-2026 research):**
- Developers spend **~1.28% of working time** repairing flaky tests; one analysis puts total flaky-related drag at **>8% of dev time (~$120k/yr per 50-engineer team)**.
- **58% of developers** hit flaky tests at least **monthly**; **79%** rate them moderate-to-serious (Eck et al.).
- **Trust-erosion mechanism (Microsoft)**: developers who hit a flaky test become **significantly LESS likely to investigate the next real failure** — the flaky test trains the team to ignore red. This is why quarantine is immediate: a flaky test left in the main suite poisons the signal of every other test.
- Teams with **flaky-detection monitoring see ~25% fewer flaky reruns** — detection pays for itself.

Common flaky causes:
- **Timing**: Hardcoded `sleep()` instead of auto-waiting. Fix: use `page.waitForSelector()` or Playwright auto-waiting.
- **Shared state**: Tests depend on execution order. Fix: isolated browser contexts per test.
- **Non-deterministic data**: Test depends on database row ordering. Fix: explicit ORDER BY or test fixtures.

**Anti-pattern**: Allowing flaky tests to persist. The measured consequence above (trust erosion -> ignored real failures -> shipped bugs) is the chain, not an assertion.

### S6: AI-Generated Code -- Mutation Testing

When testing code generated by AI (Copilot, Claude, etc.):

- **Mutation testing (Stryker) over line coverage**: AI-generated code can pass line coverage by testing trivial paths while leaving logic gaps
- **Stryker** mutates your source code (changes `>` to `>=`, removes conditions, etc.) and checks if tests catch the mutation
- If a mutation survives (tests still pass), you have a test gap

```bash
npx stryker init
npx stryker run

# mutationScore = detected / (detected + undetected) * 100   (detected = killed + timeout)
# Stryker thresholds: break 50 / low 60 / high 80
# Floor: 60% existing projects; 80%+ new/business-critical code. 100% is impractical.
bash scripts/mutation-gate.sh reports/mutation/mutation.json 80
```

- **Human-authored business logic tests ON TOP of AI-generated tests**: AI generates edge cases well but misses business intent
- **Closed-loop validator**: AI generates code -> test -> classify failures -> feed back to AI for iteration
- **Survived vs NoCoverage matters**: a low score with high `NoCoverage` = missing tests; a low *covered-code* score = tests run but don't assert (see unit-testing-rules.md U7).

### S7: Risk-Based Test Level Assignment

When deciding what to test at which level:

| Risk Area | Test Level | Rationale |
|-----------|-----------|-----------|
| Authentication/authorization | Unit + Integration | Logic correctness + boundary testing |
| Payment processing | Unit + E2E | Calculation accuracy + full flow verification |
| Data transformations | Unit | Pure functions, highly testable |
| API integrations | Integration + Contract | Boundary testing + schema compliance |
| Critical user flows | E2E | End-to-end behavior validation |
| Visual layout/design | E2E (screenshot) | Visual regression only |
| Form validation | Unit | Edge case coverage |

**Rule**: Test at the LOWEST level that catches the bug. If a unit test can catch it, don't write an E2E test for it.

### S8: Quality Gates in CI

When setting merge policies:

- **Zero tolerance for test failures**: Build fails on ANY test failure. No "known failures" list.
- **Coverage below threshold blocks merge**: Per-module thresholds, not global
- **Performance regression blocks deploy**: Lighthouse score < 80 or k6 threshold breach
- **a11y violations block merge**: Zero critical WCAG violations (axe-core)

```yaml
# Example merge requirements
required_status_checks:
  - lint
  - typecheck
  - test-unit
  - test-integration
  - coverage-gate
```

**Anti-pattern**: "We'll fix the test later" checkbox. Once you allow bypassing, every failing test gets bypassed.

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Ice cream cone (E2E-heavy) | 30+ min CI, brittle, expensive | Invert to pyramid: unit base |
| Global coverage target | Hides gaps in critical modules | Per-module targets (S2) |
| All tests in one CI stage | 30 min to find a lint error | Fastest-fail-first pipeline (S3) |
| Flaky tests in main suite | Erode trust, mask real failures | Quarantine + 48h fix deadline (S5) |
| Line coverage for AI code | AI fools traditional metrics | Mutation testing with Stryker (S6) |
| Testing everything equally | Wastes effort on low-risk areas | Risk-based assignment (S7) |
| "We'll fix tests later" bypass | Permanent broken window | Zero tolerance quality gates (S8) |
| Leaving a flaky test in main suite | Trust erosion: team ignores next real failure | Quarantine immediately (S5) |

---

## Sources

- Flaky-test cost benchmark (1.28% dev time, 58% monthly, trust erosion) — https://testdino.com/blog/flaky-test-benchmark (retrieved 2026-06-13)
- Eck et al., understanding flaky tests (developer survey) — https://arxiv.org/pdf/2112.04919 (retrieved 2026-06-13)
- Stryker mutant states & metrics (mutationScore = detected/(detected+undetected)) — https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/ (retrieved 2026-06-13)
