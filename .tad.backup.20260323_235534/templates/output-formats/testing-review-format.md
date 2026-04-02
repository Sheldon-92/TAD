# Testing Review Output Format

> Extracted from testing-strategy skill - use this for test coverage and quality reviews

## Quick Checklist

```
1. [ ] Test pyramid followed (70% unit, 20% integration, 10% E2E)
2. [ ] AAA pattern used (Arrange, Act, Assert)
3. [ ] Code coverage ≥ 80% for critical paths
4. [ ] Edge cases covered (null, empty, boundary values)
5. [ ] Tests are independent (no shared state)
6. [ ] CI runs tests on every PR
```

## Red Flags

- Tests depend on execution order
- Shared mutable state between tests
- Testing implementation details instead of behavior
- No assertions in test (false positive)
- Flaky tests ignored instead of fixed
- E2E tests for unit-testable logic
- Mocking everything (no integration confidence)

## Output Format

### Coverage Report

| Module | Line Coverage | Branch Coverage | Critical Paths | Status |
|--------|--------------|-----------------|----------------|--------|
| [module] | [%] | [%] | Covered/Missing | Pass/Fail |

### Test Quality Assessment

| Category | Count | Pass Rate | Issues |
|----------|-------|-----------|--------|
| Unit Tests | [n] | [%] | [findings] |
| Integration | [n] | [%] | [findings] |
| E2E Tests | [n] | [%] | [findings] |

### Test Smells Found

| Smell | Location | Impact | Fix |
|-------|----------|--------|-----|
| Shared state | [file:line] | High/Med/Low | [solution] |
| No assertion | [file:line] | High/Med/Low | [solution] |
| Flaky test | [file:line] | High/Med/Low | [solution] |

### Recommendations

1. **Critical**: Tests needed for [untested critical path]
2. **Important**: Refactor [test smell] in [location]
3. **Nice to have**: Add [edge case] coverage
