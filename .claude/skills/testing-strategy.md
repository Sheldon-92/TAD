# Testing Strategy Skill

---
title: "Testing Strategy"
version: "2.0"
last_updated: "2026-01-06"
tags: [testing, quality, tdd, engineering]
domains: [all]
level: intermediate
estimated_time: "30min"
prerequisites: []
sources:
  - "Growing Object-Oriented Software, Guided by Tests"
  - "xUnit Test Patterns"
  - "Google Testing Blog"
enforcement: recommended
---

## TL;DR Quick Checklist

```
1. [ ] Test pyramid balanced: 70% unit / 20% integration / 10% E2E
2. [ ] Test names describe behavior, not implementation
3. [ ] AAA pattern: Arrange-Act-Assert
4. [ ] Mocks only for external dependencies
5. [ ] Coverage 80%+ for critical paths
```

**Red Flags:**
- Testing implementation details
- Tests that depend on each other
- Excessive mocking
- Ignored/skipped tests
- No edge case coverage

---

## Overview

This skill guides test design, strategy, and best practices across all test types.

**Core Principle:** "Tests don't prove code works - they prove it behaves as expected under specified conditions."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| New feature | Blake implementing | Design test strategy |
| Code review | Reviewing tests | Validate test quality |
| Gate3 | Testing quality gate | Verify coverage |
| Bug fix | After fixing bug | Add regression test |

---

## Inputs

- Feature requirements
- Acceptance criteria
- Existing test suite
- Coverage baseline
- Test framework configuration

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `test_results` | Test execution output | `.tad/evidence/tests/` |
| `coverage_report` | Coverage metrics | `.tad/evidence/tests/coverage/` |
| `test_plan` | Test strategy document | Design doc |

### Acceptance Criteria

```
[ ] All tests pass
[ ] Coverage meets threshold (80%+)
[ ] Critical paths covered at 90%+
[ ] Edge cases tested
[ ] No skipped tests in critical paths
```

---

## Procedure

### Step 1: Understand Test Pyramid

```
        /\
       /  \
      / E2E \     Few end-to-end tests
     /──────\    (slow, brittle, expensive)
    /        \
   / Integration\   Some integration tests
  /──────────────\  (medium speed/cost)
 /                \
/    Unit Tests    \  Many unit tests
────────────────────  (fast, stable, cheap)
```

**Target Ratio:** 70% unit / 20% integration / 10% E2E

### Step 2: Write Unit Tests

```javascript
// Test single function/method in isolation
describe('calculateDiscount', () => {
  it('should return 0 for orders under $100', () => {
    expect(calculateDiscount(50)).toBe(0);
  });

  it('should return 10% for orders over $100', () => {
    expect(calculateDiscount(200)).toBe(20);
  });

  it('should return 20% for orders over $500', () => {
    expect(calculateDiscount(600)).toBe(120);
  });
});
```

**Characteristics:**
- Fast execution (milliseconds)
- Isolated (no external dependencies)
- Easy to locate failures

### Step 3: Write Integration Tests

```javascript
// Test component interactions
describe('UserService', () => {
  let userService;
  let db;

  beforeEach(async () => {
    db = await createTestDatabase();
    userService = new UserService(db);
  });

  afterEach(async () => {
    await db.close();
  });

  it('should create user and store in database', async () => {
    const user = await userService.register({
      email: 'test@example.com',
      password: 'password123'
    });

    expect(user.id).toBeDefined();
    expect(await db.users.findById(user.id)).toBeTruthy();
  });
});
```

**Characteristics:**
- Tests component interactions
- May use real dependencies
- Slower execution

### Step 4: Write E2E Tests

```javascript
// Test complete user flows
describe('User Registration Flow', () => {
  it('should allow user to register and login', async () => {
    await page.goto('/register');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('.welcome')).toContainText('Welcome');
  });
});
```

**Characteristics:**
- Simulates real user
- Highest confidence
- Slowest, most brittle

### Step 5: Name Tests Properly

**Format:**
```
should <expected behavior> when <condition>
```

**Examples:**
```javascript
// ✅ Good naming
it('should return empty array when no users exist')
it('should throw ValidationError when email is invalid')
it('should update user when valid data provided')

// ❌ Bad naming
it('test user creation')
it('works correctly')
it('handles error')
```

### Step 6: Follow AAA Pattern

```javascript
it('should calculate total with discount', () => {
  // Arrange - Set up test data
  const cart = new ShoppingCart();
  cart.add({ price: 100, quantity: 2 });
  cart.applyCoupon('SAVE10');

  // Act - Execute code under test
  const total = cart.calculateTotal();

  // Assert - Verify results
  expect(total).toBe(180); // 200 - 10% discount
});
```

### Step 7: Mock Strategically

**When to Mock:**
```
✅ Should Mock:
□ External API calls
□ Database operations (in unit tests)
□ File system operations
□ Time-related functions
□ Random number generation

❌ Should NOT Mock:
□ The code being tested
□ Simple value objects
□ Pure functions
```

**Mock Example:**
```javascript
jest.mock('./paymentService');

describe('OrderService', () => {
  it('should process payment when order placed', async () => {
    paymentService.charge.mockResolvedValue({ success: true });

    const order = await orderService.placeOrder(orderData);

    expect(paymentService.charge).toHaveBeenCalledWith({
      amount: orderData.total,
      cardId: orderData.cardId
    });
    expect(order.status).toBe('paid');
  });
});
```

### Step 8: Test Boundaries

**Common Boundaries:**
```
Numbers:
□ 0, 1, -1
□ Max value, min value
□ Boundary ±1

Strings:
□ Empty string
□ Single character
□ Maximum length
□ Special characters

Arrays:
□ Empty array
□ Single element
□ Multiple elements
□ Duplicate elements

Dates:
□ Today
□ Past date
□ Future date
□ Leap year
```

**Example:**
```javascript
describe('validateAge', () => {
  // Valid range
  it('should accept age 18', () => {
    expect(validateAge(18)).toBe(true);
  });

  it('should accept age 65', () => {
    expect(validateAge(65)).toBe(true);
  });

  // Invalid range
  it('should reject age 17', () => {
    expect(validateAge(17)).toBe(false);
  });

  it('should reject age 66', () => {
    expect(validateAge(66)).toBe(false);
  });

  // Boundary values
  it('should accept exactly 18 (minimum)', () => {
    expect(validateAge(18)).toBe(true);
  });

  it('should accept exactly 65 (maximum)', () => {
    expect(validateAge(65)).toBe(true);
  });
});
```

---

## Checklists

### Before Writing Tests

```
[ ] Understand behavior to test
[ ] Identify boundary conditions
[ ] Determine test type (unit/integration/E2E)
[ ] Check for existing similar tests
```

### Writing Tests

```
[ ] Using AAA pattern
[ ] Names describe behavior
[ ] Tests are independent
[ ] Mocking is appropriate
```

### After Writing Tests

```
[ ] All tests pass
[ ] Main paths covered
[ ] Edge cases covered
[ ] Error cases covered
[ ] Coverage acceptable
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Testing implementation | Brittle tests | Test behavior/output |
| Shared test state | Order-dependent | Isolate each test |
| Over-mocking | Tests don't reflect reality | Use real objects where possible |
| Ignoring failures | Technical debt | Fix or remove tests |
| 100% coverage obsession | Diminishing returns | Focus on critical paths |

---

## Coverage Guidelines

### Targets

```
Recommended:
□ Overall coverage: 80%+
□ Critical business logic: 100%
□ New code: 90%+

Note:
- High coverage ≠ high quality tests
- Focus on meaningful tests
- Don't test for coverage's sake
```

### Generate Reports

```bash
# Jest
npm test -- --coverage

# Pytest
pytest --cov=src --cov-report=html

# Vitest
npx vitest --coverage
```

---

## Tools / Commands

### Jest (JavaScript/TypeScript)

```bash
npm test                          # Run all tests
npm test -- cart.test.ts          # Run specific file
npm test -- --grep "discount"     # Run matching tests
npm test -- --watch               # Watch mode
npm test -- --coverage            # With coverage
```

### Pytest (Python)

```bash
pytest                            # Run all tests
pytest tests/test_cart.py         # Run specific file
pytest -k "test_discount"         # Run matching tests
pytest --cov=src --cov-report=html  # With coverage
```

### Playwright (E2E)

```bash
npx playwright test               # Run all E2E tests
npx playwright test --ui          # Interactive UI mode
npx playwright test --debug       # Debug mode
npx playwright show-report        # View report
```

---

## TAD Integration

### Gate Mapping

```yaml
Gate3_Testing:
  skill: testing-strategy.md
  enforcement: MANDATORY
  evidence_required:
    - test_results (all pass)
    - coverage_report (meets threshold)
  acceptance:
    - All tests pass
    - Coverage >= 80%
    - Critical paths >= 90%
    - No skipped tests in core
```

### Evidence Template

```markdown
## Testing Evidence

### Test Results
\`\`\`
$ npm test
PASS  src/cart.test.ts (15 tests)
PASS  src/user.test.ts (23 tests)
PASS  src/order.test.ts (18 tests)

Test Suites: 3 passed, 3 total
Tests:       56 passed, 56 total
Time:        4.521s
\`\`\`

### Coverage Report
\`\`\`
File           | % Stmts | % Branch | % Funcs | % Lines
---------------|---------|----------|---------|--------
All files      |   87.3  |   82.1   |   91.2  |   86.9
 cart.ts       |   95.2  |   90.5   |   100   |   94.8
 user.ts       |   82.1  |   75.3   |   85    |   81.2
 order.ts      |   88.7  |   82.4   |   90    |   87.6
\`\`\`

### Test Pyramid Distribution
- Unit tests: 42 (75%)
- Integration tests: 10 (18%)
- E2E tests: 4 (7%)
```

---

## Related Skills

- `test-driven-development.md` - TDD practice
- `verification.md` - Test verification
- `refactoring.md` - Safe refactoring with tests
- `code-review.md` - Reviewing test quality

---

## References

- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)
- [xUnit Test Patterns](https://www.amazon.com/xUnit-Test-Patterns-Refactoring-Code/dp/0131495054)
- [Google Testing Blog](https://testing.googleblog.com/)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Playwright Documentation](https://playwright.dev/docs/intro)

---

*This skill guides Claude in designing and writing high-quality tests.*
