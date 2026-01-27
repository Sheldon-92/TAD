---
name: "Architecture"
id: "architecture"
version: "1.0"
claude_subagent: "backend-architect"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# Architecture Skill

## Purpose
Review system architecture, design patterns, data flow, and structural decisions for scalability, maintainability, and best practices.

## When to Use
- During Gate 2 (design completeness)
- For new feature architecture
- For refactoring decisions
- For microservices/module boundaries
- For database schema design

## Checklist

### Critical (P0) - Must Pass
- [ ] Clear separation of concerns
- [ ] No circular dependencies
- [ ] Data flow is traceable
- [ ] Error boundaries defined
- [ ] No architectural anti-patterns

### Important (P1) - Should Pass
- [ ] Consistent design patterns used
- [ ] Module boundaries well-defined
- [ ] Dependencies injected (not hardcoded)
- [ ] Configuration externalized
- [ ] Scalability considered

### Nice-to-have (P2) - Informational
- [ ] Documentation reflects architecture
- [ ] ADRs (Architecture Decision Records) present
- [ ] Monitoring hooks planned
- [ ] Feature flags for gradual rollout
- [ ] Migration path documented

### Suggestions (P3) - Optional
- [ ] Future scaling considerations
- [ ] Technology upgrade paths
- [ ] Alternative approaches considered
- [ ] Technical debt items identified

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max 2 failures |
| P2 | Informational |
| P3 | Optional |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-architecture-{task}.md`

## Execution Contract
- **Input**: file_paths[], diagrams[], context{}
- **Output**: {passed: bool, findings: [{severity, category, component, description, recommendation}], evidence_path: string}
- **Timeout**: 240s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `backend-architect` for deeper analysis.
Reference: `.tad/templates/output-formats/architecture-review-format.md`

## Architecture Review Categories

### Structural Patterns
- Layered architecture
- Clean architecture
- Hexagonal/ports-adapters
- Event-driven
- Microservices boundaries

### Data Architecture
- Database schema design
- Data flow patterns
- Caching strategies
- Data consistency models
- Migration strategies

### Integration Patterns
- API design
- Message queues
- Event sourcing
- CQRS considerations
- Third-party integrations

### Quality Attributes
- Scalability
- Maintainability
- Testability
- Observability
- Reliability

### Anti-Patterns to Avoid
- God classes/modules
- Circular dependencies
- Tight coupling
- Leaky abstractions
- Premature optimization
