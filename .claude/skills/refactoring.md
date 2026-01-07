# Refactoring Skill

---
title: "Refactoring"
version: "2.0"
last_updated: "2026-01-06"
tags: [refactoring, code-quality, engineering, maintenance]
domains: [all]
level: intermediate
estimated_time: "30min"
prerequisites: [testing-strategy]
sources:
  - "Refactoring - Martin Fowler"
  - "Working Effectively with Legacy Code - Michael Feathers"
enforcement: recommended
---

## TL;DR Quick Checklist

```
1. [ ] Tests exist and pass BEFORE refactoring
2. [ ] Identify specific code smell to address
3. [ ] Choose appropriate refactoring technique
4. [ ] Small steps: change → test → repeat
5. [ ] Commit after each successful refactoring
```

**Red Flags:**
- Refactoring without tests
- Combining refactoring with new features
- Large, sweeping changes
- No clear goal for the refactoring
- Breaking external behavior

---

## Overview

Refactoring is improving code structure without changing external behavior.

**Core Principle:** "Refactoring is the process of changing a software system in such a way that it does not alter the external behavior of the code yet improves its internal structure."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Code smell detected | Code review | Apply refactoring technique |
| Before adding feature | Prep for change | Clean up target area |
| Bug investigation | Understanding code | Clarify structure |
| Technical debt sprint | Planned cleanup | Systematic refactoring |

---

## Inputs

- Code with identified smell
- Existing test coverage
- Clear refactoring goal
- Time constraint

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `test_before` | Tests pass before refactoring | Inline output |
| `test_after` | Tests pass after refactoring | Inline output |
| `smell_addressed` | Code smell eliminated | Commit message |

### Acceptance Criteria

```
[ ] All existing tests still pass
[ ] No new behavior introduced
[ ] Identified smell eliminated
[ ] Code is cleaner/simpler
[ ] Commits are small and focused
```

---

## Procedure

### Step 1: Refactoring Workflow

```
┌─────────────────────────────────────────┐
│  1. Ensure test coverage exists         │
│  2. Identify code smell                 │
│  3. Select refactoring technique        │
│  4. Small step, run tests               │
│  5. Repeat until smell eliminated       │
│  6. Commit with clear message           │
└─────────────────────────────────────────┘
```

**Critical:** Run tests after EVERY small change.

### Step 2: Identify Code Smells

#### Bloaters

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Long Method | Method >20 lines | Extract Method |
| Large Class | Class has too many responsibilities | Extract Class |
| Long Parameter List | >3 parameters | Introduce Parameter Object |
| Data Clumps | Same data groups appear together | Extract Class |
| Primitive Obsession | Overuse of primitives | Replace with Object |

#### OO Abusers

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Switch Statements | Large switch/if-else chains | Replace with Polymorphism |
| Parallel Inheritance | Change one = change many | Collapse Hierarchy |
| Refused Bequest | Subclass doesn't use parent features | Replace Inheritance with Delegation |

#### Change Preventers

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Divergent Change | One class changed for multiple reasons | Extract Class |
| Shotgun Surgery | One change touches many classes | Move Method/Field |

#### Dispensables

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Comments | Comments explaining complex code | Extract Method, Rename |
| Duplicate Code | Same code in multiple places | Extract Method/Class |
| Lazy Class | Class does too little | Inline Class |
| Dead Code | Never-used code | Delete |

#### Couplers

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Feature Envy | Method uses other class's data more | Move Method |
| Inappropriate Intimacy | Classes access each other's internals | Move Method/Field |
| Message Chains | a.getB().getC().getD() | Hide Delegate |
| Middle Man | Class only delegates | Remove Middle Man |

### Step 3: Apply Refactoring Techniques

#### Extract Method

```javascript
// Before ❌
function printOwing() {
  printBanner();

  // Calculate outstanding
  let outstanding = 0;
  for (const order of orders) {
    outstanding += order.amount;
  }

  // Print details
  console.log(`name: ${name}`);
  console.log(`amount: ${outstanding}`);
}

// After ✅
function printOwing() {
  printBanner();
  const outstanding = calculateOutstanding();
  printDetails(outstanding);
}

function calculateOutstanding() {
  return orders.reduce((sum, order) => sum + order.amount, 0);
}

function printDetails(outstanding) {
  console.log(`name: ${name}`);
  console.log(`amount: ${outstanding}`);
}
```

#### Extract Class

```javascript
// Before ❌
class Person {
  name;
  officeAreaCode;
  officeNumber;

  getTelephoneNumber() {
    return `(${this.officeAreaCode}) ${this.officeNumber}`;
  }
}

// After ✅
class Person {
  name;
  telephoneNumber; // TelephoneNumber instance

  getTelephoneNumber() {
    return this.telephoneNumber.toString();
  }
}

class TelephoneNumber {
  areaCode;
  number;

  toString() {
    return `(${this.areaCode}) ${this.number}`;
  }
}
```

#### Introduce Parameter Object

```javascript
// Before ❌
function amountInvoiced(startDate, endDate) { ... }
function amountReceived(startDate, endDate) { ... }
function amountOverdue(startDate, endDate) { ... }

// After ✅
class DateRange {
  constructor(start, end) {
    this.start = start;
    this.end = end;
  }
}

function amountInvoiced(dateRange) { ... }
function amountReceived(dateRange) { ... }
function amountOverdue(dateRange) { ... }
```

#### Replace Conditional with Polymorphism

```javascript
// Before ❌
function getSpeed(bird) {
  switch (bird.type) {
    case 'European':
      return 35;
    case 'African':
      return 40 - 2 * bird.numberOfCoconuts;
    case 'Norwegian Blue':
      return bird.isNailed ? 0 : 10 + bird.voltage / 10;
  }
}

// After ✅
class Bird {
  getSpeed() { throw new Error('Abstract'); }
}

class European extends Bird {
  getSpeed() { return 35; }
}

class African extends Bird {
  getSpeed() { return 40 - 2 * this.numberOfCoconuts; }
}

class NorwegianBlue extends Bird {
  getSpeed() { return this.isNailed ? 0 : 10 + this.voltage / 10; }
}
```

#### Replace Nested Conditional with Guard Clauses

```javascript
// Before ❌
function getPayAmount() {
  let result;
  if (isDead) {
    result = deadAmount();
  } else {
    if (isSeparated) {
      result = separatedAmount();
    } else {
      if (isRetired) {
        result = retiredAmount();
      } else {
        result = normalPayAmount();
      }
    }
  }
  return result;
}

// After ✅
function getPayAmount() {
  if (isDead) return deadAmount();
  if (isSeparated) return separatedAmount();
  if (isRetired) return retiredAmount();
  return normalPayAmount();
}
```

---

## Checklists

### Before Refactoring

```
[ ] Tests exist for the code
[ ] All tests currently pass
[ ] Specific smell identified
[ ] Refactoring technique selected
```

### During Refactoring

```
[ ] Only one small change at a time
[ ] Run tests after each change
[ ] Commit frequently
[ ] No new features added
```

### After Refactoring

```
[ ] All tests still pass
[ ] Smell eliminated
[ ] No new smells introduced
[ ] Commit message is clear
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Refactor + feature | Hard to debug if tests fail | Separate commits |
| No tests | Can't verify behavior unchanged | Add tests first |
| Big bang refactor | Risk of breaking things | Small steps |
| No clear goal | Aimless changes | Identify specific smell |
| Refactoring untouched code | Unnecessary risk | Only refactor what you're changing |

---

## Safety Net

### Test Coverage Requirements

```
Before refactoring:
□ Automated tests cover the refactoring area
□ All tests pass
□ Tests cover edge cases
```

### Refactoring Steps

```
1. Run all tests ✅
2. Make one small refactoring
3. Run all tests ✅
4. Repeat 2-3 until complete
5. Commit
```

### Rollback Strategy

```bash
# If refactoring goes wrong
git stash        # or
git checkout -- . # or
git reset --hard HEAD
```

---

## Tools / Commands

### IDE Support

```
IntelliJ/WebStorm:
- Ctrl+Alt+M: Extract Method
- F6: Move
- Shift+F6: Rename
- Ctrl+Alt+N: Inline

VS Code:
- Ctrl+Shift+R: Refactor menu
- F2: Rename symbol
```

### Static Analysis

```bash
# Detect code smells (JS)
npx eslint --fix src/

# Complexity analysis
npx plato -r -d report src/

# Python
ruff check --fix .
```

---

## TAD Integration

### Gate Mapping

```yaml
Refactoring:
  skill: refactoring.md
  enforcement: RECOMMENDED
  triggers:
    - Code review identifies smell
    - Before adding new feature
    - Technical debt sprint
  evidence_required:
    - test_before (pass)
    - test_after (pass)
    - smell_addressed
  acceptance:
    - All tests pass
    - Behavior unchanged
    - Code improved
```

### Evidence Template

```markdown
## Refactoring Evidence

### Smell Identified
Long Method in `OrderService.processOrder()` (47 lines)

### Technique Applied
Extract Method - split into:
- `validateOrder()`
- `calculateTotals()`
- `applyDiscounts()`
- `finalizeOrder()`

### Test Results Before
\`\`\`
$ npm test
Tests: 24 passed, 24 total
\`\`\`

### Test Results After
\`\`\`
$ npm test
Tests: 24 passed, 24 total
\`\`\`

### Commit
`refactor(order): extract methods from processOrder for clarity`
```

---

## Key Mindset

> "Refactoring is not a one-time activity, it's a continuous habit."

**When to refactor:**
- Before adding a feature
- Before fixing a bug
- During code review
- When understanding code

**When NOT to refactor:**
- While adding features
- Without tests
- Large-scale rewrites
- Code you're not working on

---

## Related Skills

- `testing-strategy.md` - Tests enable safe refactoring
- `code-review.md` - Review identifies refactoring opportunities
- `verification.md` - Verify behavior unchanged
- `software-architecture.md` - Larger structural improvements

---

## References

- [Refactoring - Martin Fowler](https://refactoring.com/)
- [Refactoring Catalog](https://refactoring.com/catalog/)
- [Working Effectively with Legacy Code](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
- [Code Smells](https://refactoring.guru/refactoring/smells)

---

*This skill guides Claude in safely and effectively refactoring code.*
