# Ralph Loop Documentation

## Overview

Ralph Loop is TAD v2.0's iterative quality mechanism that ensures code quality through expert-driven exit conditions rather than self-judgment. Named after the "Ralph Wiggum Loop" technique, it implements a two-layer quality check system with state persistence and automatic escalation.

## Core Concepts

### Why Ralph Loop?

Traditional development workflows rely on developers judging their own work as "complete". Ralph Loop changes this paradigm:

- **Expert Exit Conditions**: Specialized agents (code-reviewer, test-runner, security-auditor, performance-optimizer) determine when work meets quality standards
- **Iterative Refinement**: Code is refined through multiple passes until all experts pass
- **Automatic Escalation**: System detects stuck states and escalates appropriately
- **Crash Recovery**: State persistence allows resuming after interruptions

### Two-Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Layer 1: Self-Check                                     │
│ - Fast, cheap local checks                              │
│ - Build, test, lint, typecheck                          │
│ - Max 15 retries                                        │
│ - Circuit breaker: 3 consecutive same errors → human    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ Layer 2: Expert Review                                  │
│ - Priority-grouped expert agents                        │
│ - Group 1: code-reviewer (blocking gate)                │
│ - Group 2: test-runner, security-auditor, performance   │
│ - Max 5 rounds                                          │
│ - Escalation: 3 same-category failures → Alex re-design │
└─────────────────────────────────────────────────────────┘
```

## Layer 1: Self-Check

### Commands

| Command | Timeout | Required | Description |
|---------|---------|----------|-------------|
| `npm run build` | 2 min | Yes | Build the project |
| `npm test` | 5 min | Yes | Run test suite |
| `npm run lint` | 1 min | Yes | Check code style |
| `npx tsc --noEmit` | 2 min | Yes | TypeScript type check |

### Circuit Breaker

Detects when Blake is stuck on the same error:

```yaml
circuit_breaker:
  consecutive_same_error: 3
  action: escalate_to_human
  message: "Same error occurred 3 times. Human intervention required."
```

**Detection**: Error messages are hashed and compared. Three identical errors in a row trigger the circuit breaker.

## Layer 2: Expert Review

### Priority Groups

**Group 1 (Sequential, Blocking)**:
- `code-reviewer`: Must pass before Group 2 runs
- Pass criteria: P0=0, P1=0, P2≤10

**Group 2 (Parallel, after Group 1)**:
- `test-runner`: 100% pass rate, 70% coverage
- `security-auditor`: Conditional (triggered by security patterns)
- `performance-optimizer`: Conditional (triggered by performance patterns)

### Expert Pass Criteria

#### code-reviewer
```yaml
severity_threshold: P2
max_issues:
  P0: 0  # Critical - blocking
  P1: 0  # High - blocking
  P2: 10 # Medium - warning
  P3: -1 # Low - unlimited
```

#### test-runner
```yaml
test_pass_rate: 100%
coverage_minimum: 70%
environment_overrides:
  production: 80%
  staging: 70%
  prototype: 0%
```

#### security-auditor
```yaml
trigger_pattern: "auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval"
severity_threshold: medium
max_issues:
  critical: 0
  high: 0
  medium: 5
  low: unlimited
```

#### performance-optimizer
```yaml
trigger_pattern: "database|query|cache|batch|loop|sort|search|O\\(n"
blocking_patterns:
  - "O(n^3) without justification"
  - "O(n^2) in hot path without justification"
  - "Unbounded recursion"
  - "Obvious memory leak"
```

### Escalation

When Layer 2 fails 3 times on the same category of issue:

```yaml
escalation:
  threshold: 3
  action: escalate_to_alex
  message: "Same category of issue failed 3 times. Returning to Alex for re-design."
```

## State Persistence

### State File

Location: `.tad/evidence/ralph-loops/{task_id}_state.yaml`

```yaml
current_iteration: 5
layer1_retries: 3
layer2_rounds: 2
last_completed_layer: "layer1"
last_error_category: "build"
consecutive_same_error: 1
started_at: "2026-01-26T10:00:00Z"
last_checkpoint_at: "2026-01-26T10:15:00Z"
```

### Checkpoint Frequency

- After Layer 1 success
- After each Layer 2 round
- On any error

### Recovery

```yaml
recovery:
  enabled: true
  on_resume: continue_from_last_checkpoint
  stale_threshold_minutes: 30  # Ask user if state older than 30 min
```

## Global Limits

```yaml
limits:
  total_iterations: 30  # Combined Layer 1 + Layer 2
  timeout_minutes: 120  # 2 hours max
  per_iteration_timeout: 15  # 15 min per iteration
```

### Abort Conditions

1. `total_iterations >= 30` → Abort with human intervention
2. `timeout_minutes >= 120` → Abort with timeout
3. `layer1.circuit_breaker.triggered` → Abort, preserve evidence
4. `layer2.escalation.triggered` → Escalate to Alex

## Evidence Collection

### Directory Structure

```
.tad/evidence/
├── ralph-loops/
│   ├── {task_id}_state.yaml    # Current state
│   ├── {task_id}_summary.md    # Aggregated summary
│   └── {timestamp}_{task_id}_iter_{n}.md  # Per-iteration log
└── reviews/
    ├── {date}-code-review-{task}.md
    ├── {date}-testing-review-{task}.md
    ├── {date}-security-review-{task}.md
    └── {date}-performance-review-{task}.md
```

### Summary Format

```markdown
# Ralph Loop Summary: {task_id}

## Execution Overview
- Total Iterations: {total_iterations}
- Layer 1 Retries: {layer1_retries}
- Layer 2 Rounds: {layer2_rounds}
- Final Status: {status}
- Duration: {duration}

## Layer 1 Results
| Iteration | Build | Test | Lint | TSC | Result |
|-----------|-------|------|------|-----|--------|
| 1         | ✅    | ❌   | ✅   | ✅  | FAIL   |
| 2         | ✅    | ✅   | ✅   | ✅  | PASS   |

## Layer 2 Results
| Round | code-reviewer | test-runner | security | performance | Result |
|-------|---------------|-------------|----------|-------------|--------|
| 1     | P1:2          | 95%         | N/A      | N/A         | FAIL   |
| 2     | PASS          | PASS        | PASS     | PASS        | PASS   |
```

## Commands

### Blake Commands

| Command | Description |
|---------|-------------|
| `*develop [task-id]` | Start Ralph Loop development cycle |
| `*ralph-status` | Show current Ralph Loop state |
| `*ralph-resume` | Resume from last checkpoint |
| `*ralph-reset` | Reset state and start fresh |
| `*layer1` | Run Layer 1 self-check only |
| `*layer2` | Run Layer 2 expert review only |

## Rollback Strategy

When Ralph Loop aborts:

```yaml
rollback:
  enabled: true
  on_abort:
    action: "git stash push -m 'Ralph Loop aborted: {task_id}'"
    preserve_evidence: true
    notification: |
      Ralph Loop aborted at iteration {n}.
      Partial changes stashed: {stash_ref}
      Evidence preserved at: {evidence_path}
```

## Configuration Files

| File | Purpose |
|------|---------|
| `.tad/ralph-config/loop-config.yaml` | Main loop configuration |
| `.tad/ralph-config/expert-criteria.yaml` | Expert pass conditions |
| `.tad/schemas/loop-config.schema.json` | Schema validation |
| `.tad/schemas/expert-criteria.schema.json` | Schema validation |

## Integration with Gates

### Gate 3 v2 (Expanded)

Gate 3 now includes all Ralph Loop verification:
- Layer 1 self-check results
- Layer 2 expert review results
- Evidence file verification
- Knowledge Assessment

### Gate 4 v2 (Simplified)

Gate 4 is now pure business acceptance:
- No technical review (moved to Gate 3 v2)
- Human approval required
- Archive handoff

## Best Practices

1. **Trust the Experts**: Let experts judge completion, not yourself
2. **Checkpoint Often**: State persistence prevents lost progress
3. **Escalate Early**: Don't fight the same error forever
4. **Track Categories**: Error categorization enables smart escalation
5. **Preserve Evidence**: Evidence files prove quality at each step

## Troubleshooting

### "Circuit breaker triggered"

- Same error occurred 3 times
- Check the error category and message
- Human intervention required to unblock

### "Escalation to Alex"

- Layer 2 failed 3 times on same issue category
- May indicate design-level problem
- Return to Alex for re-design

### "State file stale"

- State older than 30 minutes
- Choose: resume from checkpoint or start fresh
- Consider if context has changed

### "Max iterations reached"

- Exceeded 30 total iterations
- Review the approach fundamentally
- May need simpler solution or phased implementation
