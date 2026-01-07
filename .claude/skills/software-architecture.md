# Software Architecture Skill

---
title: "Software Architecture"
version: "2.0"
last_updated: "2026-01-06"
tags: [architecture, design, patterns, engineering]
domains: [all]
level: advanced
estimated_time: "45min"
prerequisites: []
sources:
  - "Clean Architecture - Robert C. Martin"
  - "Patterns of Enterprise Application Architecture - Martin Fowler"
  - "Software Architecture in Practice - SEI"
enforcement: recommended
---

## TL;DR Quick Checklist

```
1. [ ] Clear separation of concerns (layered/modular)
2. [ ] Dependencies point inward (toward domain)
3. [ ] Core logic has no framework dependencies
4. [ ] External services abstracted behind interfaces
5. [ ] Architecture Decision Records (ADRs) documented
```

**Red Flags:**
- Business logic mixed with UI/database code
- Circular dependencies between modules
- Framework code scattered everywhere
- No clear module boundaries
- "Big Ball of Mud" structure

---

## Overview

This skill guides system architecture design, technical decisions, and structural patterns.

**Core Principle:** "Good architecture makes change easy and mistakes hard."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| New system design | Alex planning | Select architecture pattern |
| MQ4 | Architecture impact assessment | Evaluate changes |
| Technical decision | Choosing technologies | Create ADR |
| Code structure review | Reviewing organization | Apply principles |

---

## Inputs

- Functional requirements
- Non-functional requirements (performance, scalability)
- Team size and expertise
- Deployment constraints
- Integration requirements

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `architecture_diagram` | C4 or similar diagram | `.tad/docs/architecture/` |
| `adr` | Architecture Decision Records | `.tad/docs/adr/` |
| `module_structure` | Component/module breakdown | Design document |

### Acceptance Criteria

```
[ ] Architecture pattern selected and justified
[ ] Layers/modules clearly defined
[ ] Dependencies documented
[ ] Non-functional requirements addressed
[ ] ADRs created for key decisions
[ ] Migration path considered (if applicable)
```

---

## Procedure

### Step 1: Apply SOLID Principles

| Principle | Meaning | Practice |
|-----------|---------|----------|
| **S**ingle Responsibility | One reason to change | Split large classes |
| **O**pen/Closed | Open for extension, closed for modification | Use interfaces |
| **L**iskov Substitution | Subtypes substitutable | Follow contracts |
| **I**nterface Segregation | Small, specific interfaces | Split fat interfaces |
| **D**ependency Inversion | Depend on abstractions | Inject dependencies |

### Step 2: Follow Additional Principles

```
DRY (Don't Repeat Yourself)
  - Eliminate duplicate code
  - But don't over-abstract

KISS (Keep It Simple, Stupid)
  - Choose simplest solution
  - Avoid over-engineering

YAGNI (You Aren't Gonna Need It)
  - Don't code for hypothetical future
  - Implement only what's needed now
```

### Step 3: Select Architecture Pattern

#### Layered Architecture

```
┌─────────────────────────┐
│    Presentation Layer   │  ← UI, API Controllers
├─────────────────────────┤
│    Application Layer    │  ← Use Cases, Services
├─────────────────────────┤
│      Domain Layer       │  ← Business Logic, Entities
├─────────────────────────┤
│  Infrastructure Layer   │  ← Database, External APIs
└─────────────────────────┘
```
**Use for:** Traditional enterprise apps, CRUD systems

#### Hexagonal Architecture (Ports & Adapters)

```
                 ┌─────────────┐
    HTTP ────────┤             ├──────── Database
                 │   Domain    │
    CLI ─────────┤   Core      ├──────── Message Queue
                 │             │
    Tests ───────┤             ├──────── External API
                 └─────────────┘
                    Adapters
```
**Use for:** High testability, multiple entry/exit points

#### Clean Architecture

```
              ┌─────────────────────┐
              │    Frameworks &     │
              │       Drivers       │
              │  ┌───────────────┐  │
              │  │   Interface   │  │
              │  │   Adapters    │  │
              │  │  ┌─────────┐  │  │
              │  │  │   Use   │  │  │
              │  │  │  Cases  │  │  │
              │  │  │ ┌─────┐ │  │  │
              │  │  │ │Enti-│ │  │  │
              │  │  │ │ties │ │  │  │
              └──┴──┴─┴─────┴─┴──┴──┘

Dependency direction: Outer → Inner
```
**Use for:** Complex business logic, long-term maintenance

#### Microservices

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Service  │  │ Service  │  │ Service  │
│    A     │  │    B     │  │    C     │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └──────┬──────┴──────┬──────┘
            │             │
       ┌────┴────┐   ┌────┴────┐
       │ API GW  │   │ Message │
       │         │   │  Queue  │
       └─────────┘   └─────────┘
```
**Use for:** Large teams, independent deployment, varied tech stacks

### Step 4: Create Architecture Decision Records

**ADR Template:**
```markdown
# ADR-001: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-xxx]

## Context
[Background and constraints leading to this decision]

## Decision
[The decision made]

## Options Considered

### Option A: [Name]
- Pros: ...
- Cons: ...

### Option B: [Name]
- Pros: ...
- Cons: ...

## Rationale
[Why this option was chosen]

## Consequences
[Impact of this decision]
```

**Example ADR:**
```markdown
# ADR-002: Use PostgreSQL as Primary Database

## Status
Accepted

## Context
- Need relational database for complex queries
- Require ACID transactions
- Team familiar with SQL

## Decision
Use PostgreSQL 14+ as primary database.

## Options Considered

### Option A: PostgreSQL
- Pros: Mature, feature-rich, JSONB support
- Cons: Horizontal scaling complex

### Option B: MongoDB
- Pros: Flexible schema, easy horizontal scaling
- Cons: Weaker transaction support

## Rationale
Business needs strong consistency and complex queries.

## Consequences
- Must design schema carefully
- May need read replicas for high traffic
```

---

## Checklists

### Architecture Evaluation

**Functionality:**
```
[ ] Meets all functional requirements
[ ] Edge cases considered
[ ] Error handling complete
```

**Maintainability:**
```
[ ] Code easy to understand
[ ] Modules high cohesion, low coupling
[ ] Clear layering/boundaries
[ ] Dependencies reasonable
```

**Scalability:**
```
[ ] Can scale horizontally
[ ] New features addable without major changes
[ ] Performance bottlenecks identified
```

**Testability:**
```
[ ] Core logic unit testable
[ ] External dependencies mockable
[ ] Integration test strategy exists
```

**Security:**
```
[ ] Authentication mechanism secure
[ ] Authorization implemented correctly
[ ] Sensitive data encrypted
[ ] Common attacks prevented
```

---

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|--------------|---------|-----|
| Big Ball of Mud | No clear structure | Establish layers/boundaries |
| Golden Hammer | Same solution for everything | Match solution to problem |
| Premature Optimization | Optimizing before needed | Make it work first |
| Accidental Complexity | Unnecessary abstraction | Remove unneeded layers |
| Circular Dependencies | A→B→C→A | Introduce interfaces |

---

## Architecture Diagrams (C4 Model)

```
Level 1: System Context
├── How users interact with system
└── Relationships with external systems

Level 2: Container
├── Applications, databases, file systems
└── How they communicate

Level 3: Component
├── Main components within containers
└── Component relationships

Level 4: Code
├── Class diagrams, sequence diagrams
└── Detailed implementation
```

---

## Tools / Commands

### Documentation Tools

```bash
# PlantUML for diagrams
java -jar plantuml.jar architecture.puml

# Mermaid in markdown
# ```mermaid
# graph TB
#   A[Client] --> B[API Gateway]
#   B --> C[Service A]
#   B --> D[Service B]
# ```

# Structurizr DSL
structurizr-cli export -w workspace.dsl -f plantuml
```

### Analysis Tools

```bash
# Dependency analysis (JS)
npx madge --circular src/

# Dependency analysis (Python)
pydeps src/ --cluster

# Architecture fitness functions
npm run arch-test
```

---

## TAD Integration

### Gate Mapping

```yaml
Architecture_Design:
  skill: software-architecture.md
  enforcement: RECOMMENDED
  triggers:
    - MQ4 (architecture impact)
    - New system design
    - Major feature planning
  evidence_required:
    - architecture_diagram
    - adr (for significant decisions)
  acceptance:
    - Pattern selected and justified
    - Principles applied
    - Decisions documented
```

### Evidence Template

```markdown
## Architecture Evidence

### Pattern Selected
Clean Architecture with Hexagonal ports/adapters

### Justification
- Complex domain logic requires isolation
- Multiple integration points (REST, CLI, events)
- High testability required

### Module Structure
```
src/
├── domain/         # Business entities and logic
├── application/    # Use cases
├── infrastructure/ # External integrations
└── presentation/   # Controllers, CLI
```

### ADRs Created
- ADR-001: Clean Architecture selection
- ADR-002: PostgreSQL as primary database
- ADR-003: Event-driven integration pattern
```

---

## Related Skills

- `api-design.md` - API architecture
- `database-patterns.md` - Data architecture
- `testing-strategy.md` - Test architecture
- `performance-optimization.md` - Performance considerations

---

## References

- [Clean Architecture - Robert C. Martin](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164)
- [Patterns of Enterprise Application Architecture](https://martinfowler.com/eaaCatalog/)
- [C4 Model](https://c4model.com/)
- [ADR GitHub Organization](https://adr.github.io/)
- [Software Architecture in Practice](https://www.amazon.com/Software-Architecture-Practice-SEI-Engineering/dp/0321815734)

---

*This skill guides Claude in system architecture design and technical decision-making.*
