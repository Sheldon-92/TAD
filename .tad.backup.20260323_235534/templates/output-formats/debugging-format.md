# Debugging Review Format

> Extracted from systematic-debugging skill - use this for debugging sessions

## Quick Checklist

```
1. [ ] Reproduce first: stable repro steps + minimal reproduction
2. [ ] Evidence collection: logs/stack/request-response/system state
3. [ ] Root cause analysis: compare with "working path", document differences
4. [ ] Fix proposal: minimal change + regression test case
5. [ ] Verification: full test suite + monitoring after merge
```

## Red Flags

- Fixing symptoms without finding root cause
- Cannot reproduce the issue
- Large changes without regression tests
- No evidence chain
- Multiple fix attempts without pausing to reassess

## The Four Phases

### Phase 1: Root Cause Investigation

```
┌─────────────────────────────────────────┐
│  1. Read error messages carefully        │
│  2. Stabilize reproduction               │
│  3. Check recent code changes            │
│  4. Collect diagnostic evidence          │
└─────────────────────────────────────────┘
```

### Phase 2: Pattern Analysis

```
┌─────────────────────────────────────────┐
│  1. Find working examples in codebase    │
│  2. Compare systematically with broken   │
│  3. Document every difference            │
└─────────────────────────────────────────┘
```

### Phase 3: Hypothesis Testing

```
Hypothesis Template:
I believe the problem is [specific cause],
because [observed evidence],
and I will verify by [specific test steps].
```

### Phase 4: Fix Implementation

```
┌─────────────────────────────────────────┐
│  1. Create test that reproduces issue    │
│  2. Apply single, targeted fix           │
│  3. Verify fix works                     │
│  4. Ensure no regressions                │
└─────────────────────────────────────────┘
```

## Output Format

### Bug Investigation Report

| Field | Content |
|-------|---------|
| Issue | [brief description] |
| Severity | Critical/High/Medium/Low |
| Reproducible | Yes/No/Intermittent |
| First Seen | [date/commit/version] |

### Reproduction Steps

```markdown
1. [Step 1]
2. [Step 2]
3. [Step 3]

Expected: [what should happen]
Actual: [what happens]

Minimal reproduction: [link to repo/script]
```

### Evidence Collected

| Type | Location | Finding |
|------|----------|---------|
| Error log | [path/line] | [relevant excerpt] |
| Stack trace | [path/line] | [key frames] |
| System state | [where] | [relevant state] |
| Recent changes | [commits] | [suspicious changes] |

### Root Cause Analysis

| Comparison Point | Working | Broken | Difference |
|------------------|---------|--------|------------|
| Imports | [value] | [value] | [diff] |
| Config | [value] | [value] | [diff] |
| Data structure | [value] | [value] | [diff] |
| Call order | [value] | [value] | [diff] |
| Environment | [value] | [value] | [diff] |

### Hypothesis Log

| # | Hypothesis | Test | Result |
|---|------------|------|--------|
| 1 | [hypothesis] | [test] | Confirmed/Rejected |
| 2 | [hypothesis] | [test] | Confirmed/Rejected |

### Fix Plan

| Item | Details |
|------|---------|
| Root cause | [confirmed cause] |
| Fix approach | [minimal change] |
| Files changed | [list] |
| Regression test | [test name/description] |
| Verification | [how to verify fix works] |

### Three Strike Rule

> If 3+ fix attempts fail, STOP and reassess whether the underlying architecture needs reconsideration.

| Attempt | What was tried | Why it failed |
|---------|----------------|---------------|
| 1 | [attempt] | [reason] |
| 2 | [attempt] | [reason] |
| 3 | [attempt] | [reason] |

**Reassessment needed**: Yes/No
