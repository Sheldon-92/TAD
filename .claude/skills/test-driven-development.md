# Test-Driven Development (TDD) Skill

---
title: "Test-Driven Development"
version: "3.1"
last_updated: "2026-01-07"
tags: [testing, mandatory, gate3, tdd, quality, evidence-driven]
domains: [all]
level: intermediate
estimated_time: "30min"
prerequisites: []
sources:
  - "obra/superpowers"
  - "Kent Beck - Test Driven Development"
  - "Growing Object-Oriented Software, Guided by Tests"
enforcement: mandatory
tad_gates: [Gate3_Testing]

# v1.5 Skill 自动匹配触发条件
triggers:
  when_user_says:
    - "写测试"
    - "单元测试"
    - "测试用例"
    - "TDD"
    - "write test"
    - "unit test"
    - "test case"

  when_creating_file:
    - "*.test.ts"
    - "*.spec.ts"
    - "*_test.go"
    - "*_test.py"
    - "test_*.py"
    - "**/__tests__/**"

  when_command:
    - "*test"
    - "*develop"

  action: "mandatory"  # TDD 是强制性的
  auto_load: true
  message: |
    📚 正在加载 TDD Skill (强制)
    确保遵循红-绿-重构循环...
---

## TL;DR Quick Checklist

```
1. [ ] Write a failing test FIRST (RED)
2. [ ] Verify test fails for the RIGHT reason
3. [ ] Write MINIMAL code to pass (GREEN)
4. [ ] Verify ALL tests pass
5. [ ] Refactor while keeping tests green
```

**Red Flags:**
- Writing production code before tests
- Tests that pass immediately without implementation
- Skipping the "verify failure" step
- Testing implementation details instead of behavior
- Coverage < 80% for critical paths

---

## Overview

TDD is a development practice where tests are written before implementation. The core cycle is Red-Green-Refactor.

**Core Principle:** "Write a failing test first. Watch it fail. Then write the minimum code to make it pass."

This proves the test actually validates the expected behavior - if a test passes immediately, it proves nothing.

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Gate3 | Testing quality gate | Verify TDD evidence |
| `*develop` command | Blake implementing | Follow TDD cycle |
| `*test` command | Running tests | Coverage verification |
| New feature request | Any development | Start with test |

---

## Inputs

- Feature requirements or bug description
- Existing test suite (if any)
- Code coverage baseline
- Testing framework configuration

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `test_result` | Test execution output | `.tad/evidence/tests/` |
| `coverage_report` | Coverage metrics | `.tad/evidence/tests/coverage/` |
| `tdd_cycle_log` | RED → GREEN transitions | PR description or commit messages |

### Minimum Evidence Package (Required for Gate3)

The TDD evidence package MUST demonstrate the complete RED → GREEN → COVERAGE cycle:

```markdown
## TDD Evidence - [Feature Name]

**Date:** [Date]
**Developer:** [Name]
**Commits:** [SHA range]

---

### 1. RED Phase - Failing Test

**Test File:** `src/__tests__/cart.test.ts`

**Test Code:**
\`\`\`typescript
describe('ShoppingCart', () => {
  it('should calculate total with 10% discount for orders over $100', () => {
    const cart = new ShoppingCart();
    cart.addItem({ name: 'Widget', price: 50 });
    cart.addItem({ name: 'Gadget', price: 70 });
    expect(cart.calculateTotal()).toBe(108);
  });
});
\`\`\`

**Failure Output:**
\`\`\`bash
$ npm test -- --grep "should calculate total"

FAIL  src/__tests__/cart.test.ts
  ShoppingCart
    ✕ should calculate total with 10% discount (3ms)

  ● ShoppingCart › should calculate total with 10% discount

    TypeError: cart.calculateTotal is not a function

    Test Suites: 1 failed, 1 total
    Tests:       1 failed, 1 total
\`\`\`

**Failure Reason Verification:**
- [x] Fails for the RIGHT reason (missing implementation)
- [x] NOT a syntax error
- [x] NOT an import error
- [x] NOT a test bug

**Commit:** `test: add failing test for cart discount calculation`

---

### 2. GREEN Phase - Minimal Implementation

**Implementation File:** `src/cart.ts`

**Code Added:**
\`\`\`typescript
calculateTotal(): number {
  const subtotal = this.items.reduce((sum, item) => sum + item.price, 0);
  if (subtotal > 100) {
    return subtotal * 0.9;
  }
  return subtotal;
}
\`\`\`

**Pass Output:**
\`\`\`bash
$ npm test -- --grep "should calculate total"

PASS  src/__tests__/cart.test.ts
  ShoppingCart
    ✓ should calculate total with 10% discount (2ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Time:        1.234s
\`\`\`

**All Tests Still Pass:**
\`\`\`bash
$ npm test

Test Suites: 15 passed, 15 total
Tests:       147 passed, 147 total
Time:        8.456s
\`\`\`

**Commit:** `feat: implement cart discount calculation`

---

### 3. COVERAGE Report

**Overall Coverage:**
\`\`\`
File           | % Stmts | % Branch | % Funcs | % Lines | Uncovered
---------------|---------|----------|---------|---------|----------
All files      |   87.3  |   82.1   |   91.2  |   86.9  |
 src/cart.ts   |   95.2  |   88.5   |   100   |   94.8  | 45-47
\`\`\`

**Coverage Thresholds:**
| Metric | Required | Actual | Status |
|--------|----------|--------|--------|
| Statements | 80% | 87.3% | ✅ Pass |
| Branches | 80% | 82.1% | ✅ Pass |
| Functions | 80% | 91.2% | ✅ Pass |
| Lines | 80% | 86.9% | ✅ Pass |

**Critical Path Coverage (src/cart.ts):**
| Metric | Required | Actual | Status |
|--------|----------|--------|--------|
| Lines | 90% | 94.8% | ✅ Pass |

**Commit:** `refactor: extract discount constants and improve naming`

---

### 4. Edge Cases Covered

| Case | Test | Status |
|------|------|--------|
| Order exactly $100 | `should not apply discount at $100 boundary` | ✅ |
| Order $100.01 | `should apply discount just above threshold` | ✅ |
| Empty cart | `should return 0 for empty cart` | ✅ |
| Single item | `should calculate total for single item` | ✅ |

---

### Sign-off

**TDD Cycle Complete:** ✅
**Ready for Review:** Yes
```

### Acceptance Criteria

```
[ ] Every new feature has tests written BEFORE implementation
[ ] Test failure reason matches expected behavior gap
[ ] All tests pass after implementation
[ ] Coverage meets threshold (80%+ for critical paths)
[ ] Refactoring doesn't break existing tests
```

---

## Procedure

### The Red-Green-Refactor Cycle

```
    ┌─────────────────────────────────────────┐
    │                                         │
    ▼                                         │
┌───────┐    ┌───────┐    ┌──────────┐       │
│  RED  │───▶│ GREEN │───▶│ REFACTOR │───────┘
└───────┘    └───────┘    └──────────┘
  Write       Minimal      Clean up
  failing     code to      while green
  test        pass
```

### Step 1: RED - Write a Failing Test

```typescript
// Start with behavior, not implementation
describe('ShoppingCart', () => {
  it('should calculate total with 10% discount for orders over $100', () => {
    const cart = new ShoppingCart();
    cart.addItem({ name: 'Widget', price: 50 });
    cart.addItem({ name: 'Gadget', price: 70 });

    const total = cart.calculateTotal();

    expect(total).toBe(108); // $120 - 10% = $108
  });
});
```

**Key principles:**
- Test ONE behavior per test
- Use descriptive test names
- Arrange-Act-Assert pattern
- Don't test implementation details

### Step 2: Verify RED - Confirm Correct Failure

```bash
$ npm test -- --grep "should calculate total"

FAIL  src/cart.test.ts
  ShoppingCart
    ✕ should calculate total with 10% discount (3ms)

  ● ShoppingCart › should calculate total with 10% discount

    TypeError: cart.calculateTotal is not a function

      at Object.<anonymous> (src/cart.test.ts:8:24)
```

**Verify the failure is because:**
- [ ] Function doesn't exist yet (NOT syntax error)
- [ ] Returns wrong value (NOT import error)
- [ ] Missing expected behavior (NOT test bug)

### Step 3: GREEN - Write Minimal Code

```typescript
// cart.ts - MINIMAL implementation
class ShoppingCart {
  private items: Array<{ name: string; price: number }> = [];

  addItem(item: { name: string; price: number }) {
    this.items.push(item);
  }

  calculateTotal(): number {
    const subtotal = this.items.reduce((sum, item) => sum + item.price, 0);
    if (subtotal > 100) {
      return subtotal * 0.9;
    }
    return subtotal;
  }
}
```

**Key principles:**
- Write the SIMPLEST code that passes
- Don't add features "just in case"
- Don't optimize yet
- Don't refactor yet

### Step 4: Verify GREEN - All Tests Pass

```bash
$ npm test

PASS  src/cart.test.ts
  ShoppingCart
    ✓ should calculate total with 10% discount (2ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
```

**Also verify:**
- [ ] No other tests broken
- [ ] No new warnings
- [ ] Coverage acceptable

### Step 5: REFACTOR - Improve While Green

```typescript
// Refactored version
class ShoppingCart {
  private items: CartItem[] = [];
  private readonly DISCOUNT_THRESHOLD = 100;
  private readonly DISCOUNT_RATE = 0.1;

  addItem(item: CartItem): void {
    this.items.push(item);
  }

  calculateTotal(): number {
    const subtotal = this.getSubtotal();
    return this.applyDiscount(subtotal);
  }

  private getSubtotal(): number {
    return this.items.reduce((sum, item) => sum + item.price, 0);
  }

  private applyDiscount(amount: number): number {
    if (amount > this.DISCOUNT_THRESHOLD) {
      return amount * (1 - this.DISCOUNT_RATE);
    }
    return amount;
  }
}
```

**Refactoring checklist:**
- [ ] Extract magic numbers to constants
- [ ] Extract methods for clarity
- [ ] Improve naming
- [ ] Remove duplication
- [ ] Run tests after EACH change

---

## Test Types and When to Use

### Unit Tests (Most Common in TDD)

```typescript
// Test isolated logic
describe('calculateDiscount', () => {
  it('should apply 10% discount for amounts over 100', () => {
    expect(calculateDiscount(120)).toBe(108);
  });

  it('should not apply discount for amounts under 100', () => {
    expect(calculateDiscount(80)).toBe(80);
  });

  it('should handle edge case at exactly 100', () => {
    expect(calculateDiscount(100)).toBe(100);
  });
});
```

### Integration Tests

```typescript
// Test component interactions
describe('OrderService', () => {
  it('should create order and update inventory', async () => {
    const orderService = new OrderService(db, inventoryService);

    const order = await orderService.createOrder({
      items: [{ productId: '123', quantity: 2 }]
    });

    expect(order.status).toBe('created');
    expect(await inventoryService.getStock('123')).toBe(8);
  });
});
```

### E2E Tests (Playwright/Cypress)

```typescript
// Test full user flows
test('user can complete checkout', async ({ page }) => {
  await page.goto('/products');
  await page.click('[data-testid="add-to-cart"]');
  await page.click('[data-testid="checkout"]');
  await page.fill('#email', 'test@example.com');
  await page.click('[data-testid="submit-order"]');

  await expect(page.locator('.order-confirmation')).toBeVisible();
});
```

---

## Coverage Requirements

### Minimum Thresholds

```json
// jest.config.js or package.json
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    },
    "./src/core/**": {
      "branches": 90,
      "functions": 90,
      "lines": 90
    }
  }
}
```

### Coverage Report Interpretation

```
File           | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
---------------|---------|----------|---------|---------|-------------------
All files      |   85.3  |   78.2   |   92.1  |   84.9  |
 cart.ts       |   95.2  |   88.5   |   100   |   94.8  | 45-47
 checkout.ts   |   72.1  |   65.3   |   80    |   71.2  | 23-35, 67-89
```

**Focus on:**
- Critical business logic: 90%+
- API endpoints: 85%+
- Utilities: 80%+
- Don't chase 100% everywhere

---

## Checklists

### Before Writing Test

```
[ ] Understand the requirement/behavior
[ ] Identify edge cases
[ ] Know expected inputs and outputs
[ ] Check if similar test exists
```

### After Each TDD Cycle

```
[ ] Test failed for correct reason (RED)
[ ] Minimal code written (GREEN)
[ ] All tests still pass
[ ] Code is clean (REFACTOR)
[ ] Commit with meaningful message
```

### PR Review Checklist

```
[ ] Tests written before implementation (check commit order)
[ ] Coverage meets threshold
[ ] No skipped tests
[ ] Edge cases covered
[ ] Test names are descriptive
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Tests after code | Doesn't validate behavior | Write test first |
| Testing implementation | Brittle tests | Test behavior/output |
| Too many mocks | Tests don't reflect reality | Use real objects when possible |
| Large test methods | Hard to maintain | One assertion per test |
| `test.skip()` everywhere | Technical debt | Fix or remove skipped tests |
| 100% coverage obsession | Diminishing returns | Focus on critical paths |

---

## Common Excuses (Warning Signs)

| Excuse | Truth | Action |
|--------|-------|--------|
| "Too simple to test" | Simple code can have bugs | Write the test anyway |
| "I'll add tests later" | You won't | TDD now |
| "I tested manually" | Not repeatable | Automate it |
| "Deadline is tight" | TDD is actually faster | Trust the process |
| "This is just a prototype" | Prototypes become production | TDD from start |

---

## Tools / Commands

### Jest (JavaScript/TypeScript)

```bash
# Run all tests
npm test

# Run specific file
npm test -- cart.test.ts

# Run specific test
npm test -- --grep "should calculate"

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage
```

### Pytest (Python)

```bash
# Run all tests
pytest

# Run specific file
pytest tests/test_cart.py

# Run specific test
pytest -k "test_calculate_discount"

# Coverage
pytest --cov=src --cov-report=html
```

### Vitest (Modern alternative)

```bash
# Run tests
npx vitest

# Watch mode (default)
npx vitest

# Coverage
npx vitest --coverage
```

---

## TAD Integration

### Gate Mapping

```yaml
Gate3_Testing:
  skill: test-driven-development.md
  enforcement: MANDATORY
  evidence_required:
    - test_result (passing)
    - coverage_report (meets threshold)
    - tdd_cycle_log (RED → GREEN evidence)
  acceptance:
    - All tests pass
    - Coverage >= 80%
    - No skipped tests in critical paths
```

### Commit Message Convention

```bash
# TDD commits should show the cycle
git commit -m "test: add failing test for discount calculation"
git commit -m "feat: implement discount calculation"
git commit -m "refactor: extract discount constants"
```

### Evidence Location

```
.tad/evidence/tests/
├── test-results.json       # Jest/Vitest output
├── coverage/
│   ├── lcov.info          # Coverage data
│   └── coverage-summary.json
└── tdd-log.md             # Manual RED→GREEN notes
```

---

## Related Skills

- `testing-strategy.md` - Test pyramid and strategy
- `verification.md` - Evidence-based completion
- `refactoring.md` - Safe refactoring with tests
- `code-review.md` - Reviewing test quality

---

## References

- [Kent Beck - Test Driven Development: By Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [Martin Fowler - TDD](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Testing Library](https://testing-library.com/)
- [Playwright](https://playwright.dev/)

---

*This skill is MANDATORY and enforces test-first development for all new features.*
