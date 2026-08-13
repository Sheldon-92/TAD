# Unit Testing Rules
<!-- capability: unit_testing -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| U1 | Vitest Browser Mode over jsdom for component tests | Setting up component testing |
| U2 | MSW for network, vi.mock for modules | Choosing mocking strategy |
| U3 | Inline snapshots: 3-7 lines max | Writing snapshot tests |
| U4 | 80% coverage on business logic; mutation testing for AI code | Setting coverage targets |
| U5 | Mutation-score thresholds: break 50 / low 60 / high 80 | Setting a mutation gate |
| U6 | Assert behavior, not implementation | Writing assertions |
| U7 | Mutation score on covered code isolates weak assertions | Diagnosing NoCoverage vs weak tests |
| U8 | Data builders for test fixtures | Creating test data |

---

## Rules

### U1: Vitest Browser Mode Over jsdom

When testing components that depend on browser APIs, CSS rendering, or DOM layout:

- **Use `@vitest/browser-playwright`** for real browser rendering instead of jsdom
- jsdom fakes CSS (no computed styles), fakes layout (no bounding rects), and misses browser-specific quirks. Browser Mode runs the component in **real Chromium** with full CSS / computed-style / layout — assertions on bounding rects, visibility, and CSS-driven behavior are trustworthy.
- **Version gate**: Browser Mode was BETA before Vitest 4.0. **Vitest 4.0 marked Browser Mode STABLE** (production-ready) and added native visual regression via **`toMatchScreenshot()`** plus **Playwright Trace** support for debugging failed runs. **Vitest 4.1** (current) restored `v8` + `istanbul` coverage `/* v8 ignore */` comment support. Cite **Vitest 4.1** as current — do not recommend Browser Mode on a pre-4.0 Vitest, where it is still beta and lacks `toMatchScreenshot`.
- **Bridge**: `page.elementLocator()` connects Vitest Browser Mode to Testing Library selectors

```bash
# Setup (Vitest 4.1 — Browser Mode is stable)
npm i -D vitest@^4.1 @vitest/browser-playwright

# vitest.config.ts
# browser: { enabled: true, provider: 'playwright', instances: [{ browser: 'chromium' }] }
```

```typescript
// Visual regression now native to Browser Mode (4.0+), no extra dependency
await expect(page.getByRole('button')).toMatchScreenshot();
```

**When jsdom is acceptable**: Pure function tests, store logic, utilities with no DOM dependency.

### U2: Mocking Strategy -- MSW for Network, vi.mock for Modules

When mocking dependencies in tests:

- **MSW (Mock Service Worker)**: Intercepts at the network boundary. Use for all HTTP/API mocking. Tests run the full client code path including fetch/axios/etc.
- **vi.mock()**: Replaces entire modules. Use only for module-level dependencies (file system, database clients, third-party SDKs with no network calls).
- **vi.fn()**: Creates function spies. Use for verifying callback invocations.

```bash
npm i -D msw
```

**Anti-pattern**: Using vi.mock() to mock fetch/axios. This skips your HTTP client code and hides real bugs (missing headers, wrong content-type, error handling).

### U3: Snapshot Size Limits

When writing snapshot tests:

- **Inline snapshots**: 3-7 lines maximum. Longer snapshots become noise -- reviewers rubber-stamp them.
- **`toMatchScreenshot()`**: Use for visual regression instead of large DOM snapshots.
- **Never snapshot entire component trees** -- snapshot the specific output you care about.

```typescript
// Good: focused inline snapshot
expect(formatDate(new Date('2026-01-15'))).toMatchInlineSnapshot(`"Jan 15, 2026"`);

// Bad: 50-line component snapshot that changes on every style update
expect(container.innerHTML).toMatchSnapshot(); // NO
```

**Rule**: If a snapshot changes on every PR, delete it. It tests nothing and wastes review time.

### U4: Coverage Targets and Mutation Testing

When setting coverage requirements:

- **80% line coverage on business logic** (auth, payments, calculations, data transformations)
- **Per-module targets**, not global average:
  - Auth/payments: 90% (high risk)
  - Business logic/hooks/utilities: 80% (medium risk)
  - UI components: 60% (low risk, covered by E2E)
- **Mutation testing (Stryker) for AI-generated code**: line coverage is gameable — AI can produce tests that execute trivial paths while leaving real logic unasserted. Line coverage proves a line *ran*; mutation testing proves a line is *checked* (see U5 for the score thresholds).

```bash
# Coverage
npx vitest run --coverage

# Mutation testing
npx stryker init
npx stryker run

# Deterministic gate (this pack):
bash scripts/check-test-config.sh vitest.config.ts   # per-module thresholds, not global
```

**Anti-pattern**: Coverage gaming -- testing getters/setters to inflate numbers while business logic sits at 30%.

### U5: Mutation-Score Thresholds (replaces generic test-organization advice)

When configuring a mutation gate, use Stryker's documented scoring and thresholds — NOT a vibe-based "tests should be good enough":

- **`mutationScore = detected / (detected + undetected) * 100`** where `detected = killed + timeout` and `undetected = survived + noCoverage` (Stryker mutant-states-and-metrics).
- **Stryker's `thresholds` config has three knobs**: `break: 50` (CI fails below this), `low: 60` (yellow), `high: 80` (green). These are the *documented* defaults — they are not arbitrary.
- **Target by code maturity**:
  - **Existing project**: start the floor at **60%**, ratchet up.
  - **New / business-critical code (auth, payments, money math)**: **80%+**.
  - **Chasing 100% is impractical** — diminishing returns; equivalent mutants and intentionally-untested glue inflate the cost past the value.

```javascript
// stryker.config.json
{ "thresholds": { "high": 80, "low": 60, "break": 50 },
  "reporters": ["json", "html"] }
```

```bash
# Deterministic gate (this pack) — exits non-zero below floor:
bash scripts/mutation-gate.sh reports/mutation/mutation.json 60   # existing project
bash scripts/mutation-gate.sh reports/mutation/mutation.json 80   # business-critical
```

**File co-location** (secondary): place unit tests next to their source (`src/lib/utils.test.ts` beside `src/lib/utils.ts`); E2E tests live in a top-level `tests/` or `e2e/` directory (they test flows, not files).

### U6: Assert Behavior, Not Implementation

When writing assertions:

- **Assert on output and observable behavior**: return values, rendered text, emitted events, state changes
- **Do NOT assert on internal calls**: `expect(db.query).toHaveBeenCalled()` tests your mock, not your code
- **Do NOT test private methods directly**: test the public interface that uses them

```typescript
// Good: tests behavior
expect(calculateDiscount(100, 'VIP')).toBe(80);

// Bad: tests implementation
expect(lookupDiscountRate).toHaveBeenCalledWith('VIP'); // NO
```

### U7: Mutation Score on Covered Code — Distinguish NoCoverage From Weak Assertions

When a mutation run scores below the floor, the *all-mutants* score (U5) cannot tell you WHY. Compute the second metric to triage:

- **`mutationScore (covered) = detected / (detected + survived) * 100`** — excludes `NoCoverage` mutants. This isolates the quality of tests that *do* run the code.
- **Decision rule**:
  - **Low all-mutants score but HIGH covered score** -> the gap is **missing tests** (many `NoCoverage` mutants). Fix: write tests for the uncovered files.
  - **Low covered score** -> your tests *run* the code but **don't assert on its behavior** (`Survived` mutants). This is the U6 failure: `expect(mock).toHaveBeenCalled()` runs the line but doesn't check the result. Fix: assert on outputs.
- The `scripts/mutation-gate.sh` helper prints **both** numbers from the Stryker JSON so the survived-vs-noCoverage split is visible without hand-counting.

```typescript
// Structure each test Arrange / Act / Assert; name by behavior, not method:
it('should return empty array when no items match filter', () => {
  const items = [{ status: 'active' }];        // Arrange
  const result = filterByStatus(items, 'archived'); // Act
  expect(result).toEqual([]);                    // Assert — kills the "return items" mutant
});
```

A descriptive name (`should return empty array when no items match filter`, not `test filter`) is what makes a *surviving mutant* report actionable: the reviewer reads the name to know what assertion is missing.

### U8: Data Builders for Test Fixtures

When creating test data:

- Use builder functions instead of inline object literals
- Builders provide defaults, making tests readable by showing only what matters
- Avoid the "mystery guest" anti-pattern (external data files that hide what the test depends on)

```typescript
// Builder
function buildUser(overrides = {}) {
  return { id: 1, name: 'Test User', role: 'viewer', ...overrides };
}

// Test shows only what matters
it('should allow admin to delete', () => {
  const admin = buildUser({ role: 'admin' });
  expect(canDelete(admin)).toBe(true);
});
```

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| `expect(mock).toHaveBeenCalled()` | Tests mock, not code | Assert on return value or state change |
| 50-line snapshot | Noise, rubber-stamped | Inline 3-7 lines or toMatchScreenshot |
| `vi.mock('axios')` | Skips HTTP client code | Use MSW for network mocking |
| Shared mutable state | Tests pass alone, fail together | `beforeEach` reset or fresh instances |
| Testing private methods | Couples tests to internals | Test through public interface |
| Global 80% coverage | Hides gaps in critical code | Per-module targets (90/80/60) |
| Line coverage as the only gate | AI tests run code without asserting | Mutation gate: break 50 / low 60 / high 80 (U5) |
| Chasing 100% mutation score | Diminishing returns, equivalent mutants | Floor 60% existing / 80% business-critical |

---

## Sources

- Vitest 4.0 announcement (Browser Mode stable, `toMatchScreenshot`, Playwright Trace) — https://voidzero.dev/posts/announcing-vitest-4 (retrieved 2026-06-13)
- Vitest 4.1 release (coverage ignore-comment restore) — https://vitest.dev/blog/vitest-4-1.html (retrieved 2026-06-13)
- Stryker mutant states & metrics (detected/undetected, covered-code score) — https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/ (retrieved 2026-06-13)
