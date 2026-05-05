# Refactoring Review Output Format

> Extracted from refactoring skill - use this for code refactoring reviews

## Quick Checklist

```
1. [ ] Tests exist BEFORE refactoring (safety net)
2. [ ] Small steps (one change at a time)
3. [ ] Commit after each successful refactor
4. [ ] Behavior preserved (tests still pass)
5. [ ] No feature changes mixed with refactoring
6. [ ] Code smells addressed systematically
```

## Red Flags

- Refactoring without test coverage
- Large "big bang" refactors (hard to review/rollback)
- Mixing refactoring with feature development
- Breaking public API without deprecation
- Premature abstraction (refactoring for hypothetical needs)
- Refactoring working code "just because"

## Code Smells to Address

| Smell | Indicator | Refactoring |
|-------|-----------|-------------|
| Long Method | >20 lines | Extract Method |
| Large Class | >200 lines | Extract Class |
| Duplicate Code | Copy-paste | Extract to shared function |
| Feature Envy | Method uses other class's data | Move Method |
| Data Clumps | Same params together | Extract Parameter Object |
| Primitive Obsession | Many related primitives | Extract Value Object |
| Switch Statements | Type-based switching | Replace with Polymorphism |
| Speculative Generality | Unused abstraction | Remove/Inline |

## Output Format

### Refactoring Plan

| Step | Target | Smell | Refactoring | Risk |
|------|--------|-------|-------------|------|
| 1 | [file:function] | [smell] | [technique] | Low/Med/High |
| 2 | [file:class] | [smell] | [technique] | Low/Med/High |

### Before/After Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Lines of Code | [n] | [n] | [diff] |
| Cyclomatic Complexity | [n] | [n] | [diff] |
| Test Coverage | [%] | [%] | [diff] |
| Duplicate Code | [%] | [%] | [diff] |

### Safety Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Tests pass before | ✅/❌ | - |
| Tests pass after | ✅/❌ | - |
| No behavior change | ✅/❌ | [if any] |
| API compatibility | ✅/❌ | [breaking changes] |
| Commits atomic | ✅/❌ | [commit count] |

### Recommendations

1. **Do First**: [safest, highest impact refactoring]
2. **Then**: [next priority]
3. **Consider Later**: [lower priority or riskier changes]
