# Verification Before Completion Skill

---
title: "Verification Before Completion"
version: "3.0"
last_updated: "2026-01-06"
tags: [verification, mandatory, handoff, evidence, quality]
domains: [all]
level: beginner
estimated_time: "10min"
prerequisites: []
sources:
  - "obra/superpowers"
  - "TAD Framework"
enforcement: mandatory
---

## TL;DR Quick Checklist

```
1. [ ] Identify verification command(s) for this task type
2. [ ] Execute FULL command (not partial, not cached)
3. [ ] Read COMPLETE output (not just last lines)
4. [ ] Confirm exit code is 0 (success)
5. [ ] State results with EVIDENCE, not assumptions
```

**Red Flags:**
- Saying "should work" without running anything
- Using cached/previous results as proof
- Only reading partial output
- Skipping verification "because code looks correct"
- Claiming completion without evidence

---

## Overview

This skill enforces evidence-based completion claims. Before declaring any task finished, you must execute verification commands and read their complete output.

**Core Principle:** "Evidence before claims, always."

Without actually running verification commands and confirming output, any completion claim is invalid. Visual inspection of code is not verification.

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Task completion | Any task about to be marked done | Run verification |
| `*handoff` command | Alex preparing handoff to Blake | Verify design completeness |
| `*done` command | Blake completing implementation | Verify implementation |
| Bug fix | After applying fix | Verify fix works |
| Refactoring | After code changes | Verify no regression |

---

## Inputs

- Task type (test, build, lint, bug fix, etc.)
- Expected verification commands
- Success criteria for the task
- Previous test/build state (if applicable)

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `command_output` | Full verification command output | Inline in completion report |
| `exit_code` | Command exit code (0 = success) | Implicit in output |
| `before_after` | For bug fixes: failing then passing | Inline comparison |

### Minimum Evidence Package

```markdown
## Verification Report

### Test Results
\`\`\`
$ npm test
PASS  src/cart.test.ts
  ✓ should calculate total (2ms)
  ✓ should apply discount (1ms)

Tests:       2 passed, 2 total
Time:        1.234s
\`\`\`

### Build Check
\`\`\`
$ npm run build
✓ Compiled successfully
✓ No warnings
\`\`\`

### Type Check
\`\`\`
$ tsc --noEmit
No errors found.
\`\`\`

✅ All verifications passed.
```

### Acceptance Criteria

```
[ ] Verification command(s) actually executed (not cached)
[ ] Complete output read and analyzed
[ ] Exit code confirmed as success (0)
[ ] No errors or unexpected warnings in output
[ ] For bug fixes: before/after evidence provided
```

---

### Artifacts

| Artifact        | Path                                     |
|-----------------|------------------------------------------|
| Build Log       | `.tad/evidence/verification/build.log`   |
| Lint Report     | `.tad/evidence/verification/lint.txt`    |
| Test Summary    | `.tad/evidence/tests/summary.txt`        |

## Procedure

### Step 1: Identify Verification Commands

Choose appropriate commands based on task type:

| Task Type | Verification Command(s) |
|-----------|-------------------------|
| Test | `npm test` / `pytest` / `go test ./...` |
| Build | `npm run build` / `cargo build` |
| Type Check | `tsc --noEmit` / `mypy .` |
| Lint | `eslint .` / `ruff check .` |
| Start App | `npm run dev` (verify it starts) |
| Bug Fix | Run specific failing test, then all tests |
| API Change | Test endpoint manually + automated tests |

### Step 2: Execute Full Command

```bash
# ✅ Correct: Run full test suite
npm test

# ⚠️ Partial: Only runs one file (insufficient for completion claim)
npm test -- src/specific.test.ts

# ❌ Invalid: Using cached result
# "Tests passed last time" - NOT ACCEPTABLE
```

**Rules:**
- Run the COMPLETE command, not subset
- Execute fresh, not from cache
- Don't assume success from code inspection

### Step 3: Read Complete Output

```
Verification Reading Checklist:
□ Read ALL output lines (scroll up if needed)
□ Check for error messages anywhere
□ Check for warnings (evaluate if acceptable)
□ Confirm final status/count
□ Verify exit code is 0
```

**What to look for:**
```bash
# Good output
Tests:       42 passed, 42 total
Time:        3.245 s
✓ All tests passed

# Bad output (easy to miss if only reading last line)
Tests:       41 passed, 1 failed, 42 total  # <-- FAILED!
Time:        3.245 s
```

### Step 4: State Results with Evidence

**Correct claim (with evidence):**
```markdown
✅ Tests pass. Output:
Tests: 42 passed, 42 total
Time: 3.2s
```

**Invalid claims (no evidence):**
```markdown
❌ "Tests should pass now."
❌ "I think it works."
❌ "Looks correct to me."
❌ "Done!"
❌ "Perfect!"
```

### Step 5: Handle Failures

If verification fails:

```
1. DO NOT claim completion
2. Analyze the failure
3. Fix the issue
4. Re-run verification
5. Only claim completion when verification passes
```

---

## Checklists

### Pre-Completion Verification

```
[ ] Identified correct verification command(s)
[ ] Executed command (fresh, not cached)
[ ] Read complete output
[ ] No errors present
[ ] No unexpected warnings
[ ] Exit code is 0
[ ] Ready to provide evidence in completion claim
```

### Bug Fix Verification

```
[ ] Reproduced bug first (have failing test)
[ ] Applied fix
[ ] Same test now passes
[ ] Full test suite still passes
[ ] No regressions introduced
```

### Refactoring Verification

```
[ ] All existing tests pass before starting
[ ] Made refactoring changes
[ ] All existing tests still pass
[ ] No new warnings introduced
[ ] Functionality unchanged
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| "Should work" | No verification done | Run the command |
| "Looks correct" | Visual inspection insufficient | Execute and read output |
| "Tests passed before" | Stale information | Run tests again |
| Partial test run | May miss regressions | Run full suite |
| Ignoring warnings | May hide real issues | Evaluate each warning |
| Skipping for speed | Technical debt | Always verify |

---

## Dangerous Phrases (Warning Signs)

When you catch yourself saying these, **STOP and verify**:

| Phrase | Problem |
|--------|---------|
| "Should work" | Assumption, not fact |
| "Should be fine" | Guessing, not verifying |
| "Probably fixed" | Uncertainty |
| "Looks right" | Visual only |
| "Done!" | No evidence |
| "Perfect!" | Overconfidence |

**Correct yourself:**
```
WRONG: "The bug should be fixed now."
RIGHT: "Let me verify the fix works."
       *runs test*
       "Bug is fixed. Test output shows: ✓ 1 passed"
```

---

## Invalid Verification Methods

These do NOT count as verification:

```
❌ Previous run results ("tests passed earlier")
❌ Another agent's report (verify yourself)
❌ Partial execution (must run full command)
❌ Reading only end of output (read everything)
❌ Assuming code changes work (must execute)
❌ "I reviewed the code" (execution required)
```

---

## Tools / Commands

### Common Verification Commands

```bash
# JavaScript/TypeScript
npm test                    # Jest/Vitest tests
npm run build              # Production build
npm run lint               # ESLint
tsc --noEmit               # Type checking

# Python
pytest                     # Tests
python -m mypy .           # Type checking
ruff check .               # Linting
python -m build            # Build package

# Go
go test ./...              # Tests
go build ./...             # Build
go vet ./...               # Static analysis

# Rust
cargo test                 # Tests
cargo build --release      # Build
cargo clippy               # Linting
```

### Quick Verification Script

```bash
#!/bin/bash
# verify.sh - Run all verification steps

set -e  # Exit on first failure

echo "🧪 Running tests..."
npm test

echo "🔨 Building..."
npm run build

echo "📝 Type checking..."
tsc --noEmit

echo "✅ All verifications passed!"
```

---

## TAD Integration

### Gate Mapping

```yaml
All_Gates:
  skill: verification.md
  enforcement: MANDATORY
  when: Before any completion claim
  evidence_required:
    - command_output
    - exit_code (0)
  acceptance:
    - Verification actually executed
    - Complete output reviewed
    - No errors present
```

### Handoff Integration

```markdown
## Alex → Blake Handoff Verification

Before handoff, Alex must verify:
- [ ] Design documents complete
- [ ] Acceptance criteria clear
- [ ] No blocking questions

## Blake Completion Verification

Before claiming done, Blake must verify:
- [ ] Tests pass (npm test)
- [ ] Build succeeds (npm run build)
- [ ] Lint clean (npm run lint)
- [ ] Functionality demonstrable
```

### Evidence Location

```
Verification evidence goes INLINE in:
- PR description
- Task completion message
- Gate pass report

NOT in separate files (too easy to skip reading).
```

---

## Related Skills

- `test-driven-development.md` - Tests provide verification targets
- `testing-strategy.md` - Test coverage for verification
- `security-checklist.md` - Security verification before deploy
- `code-review.md` - Review includes verification check

---

## References

- [obra/superpowers](https://github.com/obra/superpowers) - Original verification skill
- [TAD Framework](https://github.com/sheldonzhao/TAD) - Gate-based quality assurance
- [Evidence-Based Software Engineering](https://www.amazon.com/Evidence-Based-Software-Engineering-David-Budgen/dp/0321717589)

---

## Key Mindset

> "Skipping verification is not efficiency. It's dishonesty."

**Why verification matters:**
- Proves work actually functions
- Catches issues early
- Builds trust with users
- Reduces rework and debugging

---

## The Bottom Line

```
Execute → Read Output → Then Claim

This is non-negotiable.
```

Being tired, confident, or rushed does not excuse skipping verification. Partial checks don't count as complete verification.

---

*This skill is MANDATORY and enforces evidence-based completion claims for all tasks.*
