---
name: code-review
description: Review code for quality, security, and best practices. Use this skill when completing a feature, fixing a bug, preparing to commit code, or when asked to review code changes. Automatically applies code review checklist covering functionality, readability, security, and testing.
---

# Code Review Skill

> Applies comprehensive code review checklist when completing features, fixing bugs, or before commits.

## TL;DR Quick Checklist

```
1. [ ] Functionality correct + edge cases handled
2. [ ] Readability: clear naming, single responsibility, no duplication
3. [ ] Security: input validation, no injection/XSS, no sensitive data leaks
4. [ ] Tests: key paths covered + regression cases
5. [ ] Commits: atomic commits + clear description + risk/rollback plan
```

**Red Flags:** Large PR (>500 lines) without splitting, implicit global side effects, no tests or happy path only, no error handling

---

## When to Use

### Must Review
- After completing a task
- After major feature development
- Before merging to main branch
- When user asks "review this code" or "check my changes"

### Should Review
- When stuck and need help
- Before refactoring
- After complex bug fixes

---

## Review Checklist

### Functionality
- [ ] Does the code implement the requirements?
- [ ] Are edge cases handled?
- [ ] Is error handling complete?

### Code Quality
- [ ] Are names clear and meaningful?
- [ ] Do functions have single responsibility?
- [ ] Is there duplicated code?

### Testing
- [ ] Are there unit tests?
- [ ] Do tests cover main paths?
- [ ] Do tests cover edge cases?

### Security
- [ ] Is input validated?
- [ ] Is SQL injection prevented?
- [ ] Is XSS prevented?
- [ ] Is sensitive data protected?

---

## Review Output Format

When reviewing, produce:

```markdown
## Code Review Summary

### Files Reviewed
- [file list]

### Findings

| Severity | Issue | Location | Recommendation |
|----------|-------|----------|----------------|
| Critical | [description] | file:line | [fix] |
| Important | [description] | file:line | [fix] |
| Minor | [description] | file:line | [suggestion] |

### Overall Assessment
- [ ] Ready to merge
- [ ] Needs fixes before merge
- [ ] Needs major rework
```

---

## Common Anti-Patterns

```javascript
// Magic numbers
if (users.length > 100) { ... }  // BAD
const MAX_USERS = 100;
if (users.length > MAX_USERS) { ... }  // GOOD

// Long functions (>50 lines)
function doEverything() { /* 200 lines */ }  // BAD

// Deep nesting
if (a) { if (b) { if (c) { ... } } }  // BAD
if (!a) return;
if (!b) return;
// main logic  // GOOD

// Commented out code
// function oldFunction() { ... }  // BAD - delete it
```

---

## TAD Framework Integration

In TAD workflow, code review happens at:

```
Alex Design → Blake Implement → Code Review → Gate Verification
                                    ↓
                              [This Skill]
```

This skill is automatically invoked during Gate 3 (Implementation Quality) and Gate 4 (Integration Verification).
