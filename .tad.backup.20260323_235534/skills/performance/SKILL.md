---
name: "Performance"
id: "performance"
version: "1.0"
claude_subagent: "performance-optimizer"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
conditional: true
trigger_pattern: "database|query|cache|batch|loop|sort|search|O\\(n"
---

# Performance Skill

## Purpose
Analyze code for performance issues, inefficient algorithms, memory problems, and optimization opportunities.

## When to Use
- When code contains performance-sensitive patterns
- During Gate 3 (implementation quality)
- During Gate 4 (integration verification)
- For database operations
- For loops and batch processing

## Trigger Patterns
This skill is conditionally triggered when code matches:
```regex
database|query|cache|batch|loop|sort|search|O\(n
```

## Checklist

### P0 - Blocking (Must Pass)
- [ ] No O(n^3) algorithms without justification
- [ ] No O(n^2) algorithms in hot paths without justification
- [ ] No unbounded recursion
- [ ] No obvious memory leaks
- [ ] No unbounded memory growth
- [ ] No N+1 query patterns
- [ ] No unbounded result sets

### P1 - Critical (Must Pass)
- [ ] O(n^2) algorithms have justification
- [ ] Efficient data structures chosen
- [ ] Large allocations not in tight loops
- [ ] Query patterns are efficient

### P2 - Warning (Should Address)
- [ ] Caching considered where beneficial
- [ ] Pagination implemented for large datasets
- [ ] Resource cleanup implemented
- [ ] Timeouts on external calls

### P3 - Informational (Nice-to-have)
- [ ] Performance benchmarks documented
- [ ] Resource usage profiled
- [ ] Optimization opportunities noted
- [ ] Scalability considerations documented

## Pass Criteria
| Severity | Requirement |
|----------|-------------|
| P0 | Zero issues allowed - blocks release |
| P1 | Zero issues allowed - must fix before merge |
| P2 | Documented justification required |
| P3 | Optional improvements, document only |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-performance-{task}.md`

## Execution Contract
- **Input**: file_paths[], context{}, patterns_found[]
- **Output**: {passed: bool, findings: [{category, severity, file, line, description, recommendation}], evidence_path: string}
- **Timeout**: 180s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `performance-optimizer` for deeper analysis.
Reference: `.tad/templates/output-formats/performance-review-format.md`

## Performance Categories

### Algorithm Complexity
- O(n^3) without justification → P0
- O(n^2) in hot path without justification → P0
- Unbounded recursion → P0
- O(n^2) with justification → P1
- Inefficient data structure choice → P1

### Memory Usage
- Obvious memory leak → P0
- Unbounded growth → P0
- Large allocation in tight loop → P0
- Large allocation in loop → P1
- Potential memory pressure → P2

### Database Access
- N+1 query pattern → P0
- Missing index on frequent query → P0
- Unbounded result set → P0
- Could benefit from caching → P2
- Consider pagination → P2

### Network/IO
- Synchronous blocking in async context → P0
- No timeout on external calls → P2
- Missing retry logic → P2
- Inefficient serialization → P3
