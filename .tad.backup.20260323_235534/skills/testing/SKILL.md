---
name: "Testing"
id: "testing"
version: "1.0"
claude_subagent: "test-runner"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# Testing Skill

## Purpose
Execute and verify test suites, ensure adequate test coverage, and validate that all tests pass before code integration.

## When to Use
- After implementing new features
- After fixing bugs
- Before Gate 3 verification
- During CI/CD pipelines

## Checklist

### Critical (P0) - Must Pass
- [ ] All existing tests pass without failures
- [ ] No test timeouts or hanging tests
- [ ] Test output is clean (no unexpected warnings)
- [ ] Critical paths have test coverage

### Important (P1) - Should Pass
- [ ] New code has corresponding unit tests
- [ ] Test coverage meets project minimum (default: 70%)
- [ ] Integration tests pass for affected modules
- [ ] Edge cases are tested

### Nice-to-have (P2) - Informational
- [ ] Tests are well-documented with clear descriptions
- [ ] Test data is properly isolated
- [ ] Performance-sensitive tests have benchmarks
- [ ] Tests follow project naming conventions

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | All items pass |
| P1 | Max 1 failure |
| P2 | Informational |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-testing-{task}.md`

## Execution Contract
- **Input**: file_paths[], test_command, coverage_threshold
- **Output**: {passed: bool, test_results: [], coverage: number, evidence_path: string}
- **Timeout**: 300s
- **Parallelizable**: false

## Claude Enhancement
When running on Claude Code, call subagent `test-runner` for deeper analysis.
Reference: `.claude/skills/` for extended test guidance.

## Platform-Specific Execution

### Claude Code
```
Use Task tool with subagent_type: "test-runner"
```

### Codex CLI / Gemini CLI
```
1. Read this SKILL.md checklist
2. Run project test command (npm test, pytest, etc.)
3. Verify each P0/P1 item manually
4. Generate evidence file with results
```
