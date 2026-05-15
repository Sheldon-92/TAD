# Unit Testing Rules
<!-- capability: unit_testing -->

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| U1 | Vitest Browser Mode over jsdom for component tests | Setting up component testing |
| U2 | MSW for network, vi.mock for modules | Choosing mocking strategy |
| U3 | Inline snapshots: 3-7 lines max | Writing snapshot tests |
| U4 | 80% coverage on business logic; mutation testing for AI code | Setting coverage targets |
| U5 | Co-locate tests with source files | Organizing test files |
| U6 | Assert behavior, not implementation | Writing assertions |
| U7 | AAA pattern with descriptive names | Structuring tests |
| U8 | Data builders for test fixtures | Creating test data |

---

## Rules

### U1: Vitest Browser Mode Over jsdom

When testing components that depend on browser APIs, CSS rendering, or DOM layout:

- **Use `@vitest/browser-playwright`** for real browser rendering instead of jsdom
- jsdom fakes CSS (no computed styles), fakes layout (no bounding rects), and misses browser-specific quirks
- Vitest 4.0 Browser Mode runs in a real Chromium instance with full CSS/API support
- **Bridge**: `page.elementLocator()` connects Vitest Browser Mode to Testing Library selectors

```bash
# Setup
npm i -D @vitest/browser-playwright

# vitest.config.ts
# browser: { enabled: true, provider: 'playwright', name: 'chromium' }
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
- **Mutation testing (Stryker) for AI-generated code**: AI can produce code that passes line coverage by testing trivial paths while leaving real logic untested

```bash
# Coverage
npx vitest run --coverage

# Mutation testing
npx stryker init
npx stryker run
```

**Anti-pattern**: Coverage gaming -- testing getters/setters to inflate numbers while business logic sits at 30%.

### U5: Test File Co-location

When organizing test files:

- Place test files next to their source: `src/lib/utils.test.ts` beside `src/lib/utils.ts`
- Co-location makes it obvious which code is tested and which is not
- Exception: E2E tests live in a top-level `tests/` or `e2e/` directory (they test flows, not files)

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

### U7: AAA Pattern with Descriptive Names

When structuring tests:

- **Arrange**: Set up test data and dependencies
- **Act**: Execute the function/action under test
- **Assert**: Verify the result
- **Test name**: `"should return empty array when no items match filter"` -- describes behavior, not method name

```typescript
it('should return empty array when no items match filter', () => {
  // Arrange
  const items = [{ status: 'active' }, { status: 'active' }];
  // Act
  const result = filterByStatus(items, 'archived');
  // Assert
  expect(result).toEqual([]);
});
```

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
