---
name: "Code Review"
id: "code-review"
version: "1.0"
claude_subagent: "code-reviewer"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
---

# Code Review Skill

## Purpose
Review code for quality, maintainability, security, and adherence to best practices. Identify issues by severity level (P0-P3).

## When to Use
- Before committing code changes
- During Gate 2 (design review)
- During Gate 3 (implementation quality)
- During pull request reviews

## Checklist

### Critical (P0) - Must Pass
- [ ] No security vulnerabilities (SQL injection, XSS, etc.)
- [ ] No data loss or corruption risks
- [ ] No unhandled exceptions that crash the application
- [ ] No authentication/authorization bypasses
- [ ] No sensitive data exposure

### Important (P1) - Should Pass
- [ ] No logic errors causing wrong behavior
- [ ] No race conditions in async code
- [ ] Features work as specified
- [ ] Error handling for likely failures
- [ ] API contracts are correct

### Nice-to-have (P2) - Informational
- [ ] Consistent naming conventions
- [ ] Descriptive variable/function names
- [ ] Minimal code duplication
- [ ] Appropriate documentation
- [ ] Optimal but functional approach

### Suggestions (P3) - Optional
- [ ] Additional comments where helpful
- [ ] Alternative approaches to consider
- [ ] Future refactoring opportunities
- [ ] Stylistic preferences

## Pass Criteria
| Level | Requirement |
|-------|-------------|
| P0 | Zero issues allowed |
| P1 | Zero issues allowed |
| P2 | Max 10 issues |
| P3 | Unlimited (suggestions) |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-code-review-{task}.md`

## Execution Contract
- **Input**: file_paths[], context{}, changed_lines[]
- **Output**: {passed: bool, issues: [{severity, file, line, description}], evidence_path: string}
- **Timeout**: 180s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `code-reviewer` for deeper analysis.
Reference: `.claude/skills/code-review/SKILL.md` for extended guidance.

## Issue Severity Definitions

### P0 - Critical
Security vulnerability, data loss, crash. Examples:
- SQL injection vulnerability
- Unhandled exception that crashes app
- Data corruption possible
- Authentication bypass
- Sensitive data exposure

### P1 - High
Logic errors, race conditions, broken features. Examples:
- Logic error causing wrong calculation
- Race condition in async code
- Feature doesn't work as specified
- Missing error handling for likely failures
- Incorrect API contract

### P2 - Medium
Style, naming, minor improvements. Examples:
- Inconsistent naming convention
- Could use more descriptive variable name
- Minor code duplication
- Missing documentation
- Suboptimal but functional approach

### P3 - Low
Suggestions, nice-to-haves. Examples:
- Could add more comments
- Alternative approach might be cleaner
- Consider refactoring in future
- Stylistic preference
