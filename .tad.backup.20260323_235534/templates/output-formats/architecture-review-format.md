# Architecture Review Output Format

> Extracted from software-architecture skill - use this for architecture design reviews

## Quick Checklist

```
1. [ ] Separation of concerns (UI / Business Logic / Data)
2. [ ] Dependencies point inward (Clean Architecture)
3. [ ] ADRs documented for key decisions
4. [ ] No circular dependencies
5. [ ] Clear module boundaries (public API defined)
6. [ ] Error handling strategy consistent
```

## Red Flags

- Business logic in UI components
- Direct database calls from controllers
- Circular dependencies between modules
- God objects (classes that do everything)
- No clear layer separation
- Missing error boundaries
- Hardcoded configuration in code

## Architecture Patterns

| Pattern | When to Use | Key Benefit |
|---------|-------------|-------------|
| Layered | CRUD apps, clear data flow | Simplicity |
| Clean/Hexagonal | Complex domain logic | Testability |
| Microservices | Team scaling, independent deploy | Autonomy |
| Event-Driven | Async workflows, decoupling | Scalability |
| CQRS | Read/write optimization | Performance |

## Output Format

### Layer Analysis

| Layer | Responsibilities | Dependencies | Violations |
|-------|-----------------|--------------|------------|
| Presentation | [what it does] | [depends on] | [issues] |
| Application | [what it does] | [depends on] | [issues] |
| Domain | [what it does] | [depends on] | [issues] |
| Infrastructure | [what it does] | [depends on] | [issues] |

### Dependency Graph

```
[Presentation] → [Application] → [Domain]
                      ↓
               [Infrastructure]

Violations Found:
- [component A] → [component B] (should not depend)
```

### Module Boundaries

| Module | Public API | Internal | Coupling Score |
|--------|------------|----------|----------------|
| [module] | [exports] | [hidden] | Low/Med/High |

### ADR (Architecture Decision Record) Template

```markdown
# ADR-[N]: [Title]

## Status
Proposed / Accepted / Deprecated / Superseded

## Context
[What is the issue that we're seeing that is motivating this decision?]

## Decision
[What is the change that we're proposing and/or doing?]

## Consequences
[What becomes easier or more difficult to do because of this change?]
```

### Recommendations

| Priority | Issue | Impact | Suggested Change |
|----------|-------|--------|------------------|
| Critical | [architectural violation] | [impact] | [solution] |
| Important | [design improvement] | [impact] | [solution] |
| Future | [technical debt] | [impact] | [solution] |
