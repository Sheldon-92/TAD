# Ralph Loop Documentation

## Overview

Ralph Loop is TAD v2.0's iterative quality mechanism that ensures code quality through expert-driven exit conditions rather than self-judgment. Named after the "Ralph Wiggum Loop" technique, it implements a two-layer quality check system with persistent evidence and escalation rules. These are agent instructions in the existing Skill/configuration, not an unbypassable runtime loop engine.

## Core Concepts

### Why Ralph Loop?

Traditional development workflows rely on developers judging their own work as "complete". Ralph Loop changes this paradigm:

- **Expert Exit Conditions**: Independent reviewers with different lenses (run, consistency, and domain when security/data/money is hit; review contract §5, §8) determine when work meets quality standards
- **Iterative Refinement**: Code is refined through multiple passes until all experts pass
- **Escalation**: round 3 with an open P0, the same-category breaker or the standing risk veto returns the evidence to Alex/human
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
│ Layer 2: Gate 3 reviewers (review contract §5-§8)       │
│ - run (re-runs every AC + real path, signs Gate 3)      │
│ - consistency (contradictions, consumers, archive)      │
│ - domain when security / data / money is hit            │
│ - Rounds converge; round 3 with open P0 → Alex          │
│ - Escalation: 3 same-category failures → Alex re-design │
└─────────────────────────────────────────────────────────┘
```

## Layer 1: Self-Check

### Commands

Layer 1 executes the technical check rows declared in handoff §9.1 (Spec Compliance Checklist) — the sole authoritative source. `loop-config.yaml` 的 `layer1.commands` 仅在 §9.1 未声明任何技术检查行时兜底；两者都为空 → 零命令通过，并在 completion report 的 Gate 3 小节记录一行（禁止静默跳过）。

| Command | Timeout | Required | Description |
|---------|---------|----------|-------------|
| §9.1 声明的技术检查行 1 | per §9.1 | Yes | 按 §9.1 该行的 Verification Method 执行 |
| §9.1 声明的技术检查行 2 | per §9.1 | Yes | 按 §9.1 该行的 Verification Method 执行 |
| §9.1 声明的技术检查行 3 | per §9.1 | Yes | 按 §9.1 该行的 Verification Method 执行 |
| §9.1 声明的技术检查行 N | per §9.1 | Yes | 按 §9.1 该行的 Verification Method 执行 |

### Circuit Breaker

Detects when Blake is stuck on the same error:

```yaml
circuit_breaker:
  consecutive_same_error: 3
  action: escalate_to_human
  message: "Same error occurred 3 times. Human intervention required."
```

**Detection**: Error messages are hashed and compared. Three identical errors in a row trigger the circuit breaker.

## Layer 2: Gate 3 Reviewers

Layer 2 is the Gate 3 review of `.tad/templates/review-contract.md` (§5 lenses, §7 rounds,
§8 who reviews what). The builder never reviews or signs its own work.

### Lenses (every task_type, express and `*bug` included)

- **run** (always; writes the Gate 3 verdict file and the `gate3_verdict:` marker): re-runs every
  §9.1 row by hand in one throwaway copy of the project (`## AC runs` table) and every `real_path`
  (`## Real paths` table, `## Not run` with reasons). No script executes handoff commands;
  `gate3-check.sh` only checks the evidence.
- **consistency** (always): contradictions with unchanged rules and code, every consumer of a
  changed line, `risk_triggers` against the diff, what enters the release archive.
- **domain** (only when `risk_triggers` lists security, data or money).

Two reviewers with different lenses is the floor; never two of the same lens; a self-review never counts.

### Pass rule

Only a P0, a FAIL or a PARTIAL blocks. A P1 is carried (listed in the completion report and,
at Gate 4, to the human). No P1/P2 count cap; coverage thresholds apply only when §9.1 states one.
Spec AC truth is separate: an unmet AC cannot be closed by a finding label.

### Rounds and limits (the Full Layer 2 review brakes, inside contract §7)

Rounds converge rather than run to a fixed cap: round 1 runs every lens; round k ≥ 2 runs only
the lenses whose previous file had a P0, FAIL or PARTIAL, plus the run lens after every rework
(its verdict must judge the final commit). The brakes merged from 1901b97e (2026-10-19) are limits
inside that rule:

- **Round count is honest.** `layer2_rounds` counts started rounds including round 1 and is
  persisted before the first dispatch of a round. A failure does not add a second count; an
  interrupted round on the same input resumes its unfinished calls without a new count; compact,
  crash, stale context, `*ralph-reset` or a new task ID never reset it. Only a re-plan (contract §7)
  restarts the count.
- **Round 3 is the upstream stop.** Round 3, counted from round 1 or the last re-plan, still has an
  open P0 (or a lens it cannot complete): record ESCALATED_TO_ALEX with the open findings, NOT_RUN
  items and `escalation_reason`; stop repairs and re-review; there is no round 4 without a re-plan.
  The escalation message says whether the stop came from the round-3 rule or from the same-category
  breaker below.
- **Standing risk veto.** Whenever an unresolved serious out-of-scope safety or delivery risk is
  identified, persist BLOCKED_RISK with its evidence for Alex or the human. Check it before every
  dispatch, after every report or error and before any completion decision; it overrides COMPLETED.
  No self-waiver and no out-of-scope repair.
- **Not clean completion.** ESCALATED_TO_ALEX, BLOCKED_STATE, BLOCKED_RISK, ABORTED and NOT_RUN are
  never clean completion; Gate 3 and Gate 4 refuse them. COMPLETED means every lens covered on the
  same final commit with no open P0/FAIL/PARTIAL; it allows the Gate 3 check, it does not assert PASS.
- **Old PASS is not PASS for a new input.** Every round judges the current commit.

### Escalation

Two branches, both returning to Alex with evidence:

```yaml
escalation:
  round_rule: "round 3 (from round 1 or the last re-plan) still has an open P0"
  same_category_threshold: 3   # the same issue category failed 3 times
  action: escalate_to_alex
```

## State Persistence

### State File

Location: `.tad/evidence/ralph-loops/{task_id}_state.yaml`

```yaml
current_iteration: 5
layer1_retries: 3
layer2_rounds: 2  # started rounds, including R1; never a failure count
last_completed_layer: "layer1"
last_error_category: "build"
consecutive_same_error: 1
started_at: "2026-01-26T10:00:00Z"
last_checkpoint_at: "2026-01-26T10:15:00Z"
review_brakes_version: 1
task_identity:
  handoff_path: "..."
  handoff_digest: "sha256:..."
  baseline_ref: "..."  # starting HEAD + initial-byte snapshot/manifest
  budget_origin: "..." # same authorized task, prior ID or new authorization
layer2_status: STARTED
active_round: 2
round_history: []     # append number/input_id/input_manifest/STARTED before dispatch
lens_progress: {}    # per-lens status/report/last_reviewed_input
findings_ref: "..."  # immutable originals + independent disposition ledger
escalation_reason: null
```

`input_id` binds handoff content, task baseline, reviewed task-delta bytes/deletions/
renames and applicable reviewer contract. Save a replayable diff and content manifest;
a floating HEAD or timestamp alone is insufficient. Dirty-tree attribution uses initial
bytes and preserves others' existing hunks. Fixed inputs include reviewed deliverables
and acceptance scripts with execution semantics. State, reports, ledger, summary, final
reports and AC run logs carry input_id as outputs; exclude them from that input hash
so a checkpoint cannot change its own identity. Review frozen source within a round.
Read-only consumer observations record path/digest/dependency proof separately; relevant
source changes invalidate old conclusions rather than allowing them into current PASS.

### Checkpoint Frequency

- After Layer 1 success
- Before each round's first dispatch (durable STARTED and consumed budget)
- After every reviewer report, round completion/error, and terminal state

### Recovery and Reset

Reload the primary state at the existing path above. Summary/session-state only derive
from it and cannot reconstruct a smaller count. State older than 30 minutes triggers
context reload and input validation; compact, timeout, resume and `*ralph-reset` never
clear used rounds/history. Reset/fresh only reruns Layer 1 or refreshes context.

An interruption without a report still consumes the STARTED round. Resume unfinished
calls only for the same input without another count/global increment. If implementation,
handoff or applicable reviewer contract changes, close the old round as INTERRUPTED;
Layer 1 and a new counted round are required; round 3 with an open P0 returns to Alex.

Legacy state without review_brakes_version has a failure-count ambiguity. Migrate only
when original dispatch/report evidence fully reconstructs started rounds, inputs and
per-lens coverage; retain original state and derivation evidence. No fixed +1 formula.
Use zero only with proof no dispatch ever occurred. Used >=3 and not completed returns
to Alex; preserve historical >3 truth rather than truncating it. Missing/contradictory/
unprovable state is BLOCKED_STATE for Alex, never a guessed free R1. A changed task ID
retains the same handoff/baseline/budget_origin; only a re-plan (contract §7) restarts the count.

### Finding Ledger and Directed Consumer Checks

Preserve stable ID, origin reviewer/round, original text/path/hunk or command/severity,
baseline evidence, task causality, proposed disposition, reason/proof, independent
checker/checked input/evidence, decision, final disposition and reopen link.
Blake proposes; the independent reviewer responsible for the check approves:

- `fixed`: verified repair with relevant AC/raw check evidence and necessary coverage.
- `pre-existing`: proved prior existence, no task introduction/worsening/new exposure,
  no AC violation, and no unresolved severe security/delivery risk. Path outside the
  diff or an old-code pointer alone is insufficient.
- `dismissed`: locatable counterevidence disproves the original premise/applicability.

Until independently approved, proposals/insufficient evidence/disputes stay open with
final=null. Preserve raw counts/severity and effective open blocking counts/IDs plus
closure evidence. Reuse the ID for rediscovery; new evidence may reopen it. A reviewer
who did not implement may recheck; unavailable reviewers require an equivalent fresh
independent reviewer with original objective evidence and repair input, never Blake
self-review. Pure out-of-scope severe risk is BLOCKED_RISK for Alex/human, without
silent repair or exemption. An open P0 at round 3 returns to Alex.

From task delta/§10, follow actual references/configuration consumers/calls for directed
read-only consumer checks; log origin → proven edge → path+digest → check →
result/proof/unproven. Newly identified consumers may be read along that chain.
No chain permits no free repository exploration; no search hit is not safety proof.
`unproven` affecting AC/security/necessary coverage remains open; unrelated unsupported
guesses do not automatically become P0. Read permission never grants out-of-scope
writes: return necessary repair to Alex. The optional K1 falsify-only pass is separate
from R2/R3 repair review and cannot suppress new regressions or replace independent
approval (see `docs/process-tax-cut.md` §4).

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
5. Round 3 with an open P0 → ESCALATED_TO_ALEX; stop repairs/review, preserve evidence, no round 4 without a re-plan

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
- Layer 2 Started Rounds: {layer2_rounds} (R1 included; counted from the last re-plan)
- Budget Origin / Baseline: {budget_origin} / {baseline_ref}
- Final Input: {input_id} / {input_manifest}
- Escalation Reason: {escalation_reason}
- Final Status: {status}
- Duration: {duration}

## Layer 1 Results
| Iteration | Build | Test | Lint | TSC | Result |
|-----------|-------|------|------|-----|--------|
| 1         | ✅    | ❌   | ✅   | ✅  | FAIL   |
| 2         | ✅    | ✅   | ✅   | ✅  | PASS   |

## Layer 2 Results
| Round / commit | run | consistency | domain | Round status |
|----------------|-----|-------------|--------|--------------|
| R1 / {sha1}    | FAIL (AC-3) | CONDITIONAL (P1:2) | N/A+reason | FAILED |
| R2 / {sha2}    | PASS | (not re-run: no open P0) | N/A+reason | COMPLETED |

## Coverage and Findings
| Lens | Last reviewed input | Current input / status | Report / trigger reason |
|------|---------------------|------------------------|-------------------------|
| {lens} | {baseline or never} | {input/status}       | {immutable report}      |

- Raw counts / effective open blocker counts and IDs: {counts/IDs}
- Finding ledger / independent dispositions and checked input evidence: {path}
- Read-only consumer chain checks / unproven links: {paths/results}
- Open findings / NOT_RUN / escalation or blocked reason: {details}
- Status explicitly distinguishes STARTED, FAILED, NOT_RUN, COMPLETED,
  ESCALATED_TO_ALEX, BLOCKED_STATE, BLOCKED_RISK and ABORTED.
```

## Commands

### Blake Commands

| Command | Description |
|---------|-------------|
| `*develop [task-id]` | Start Ralph Loop development cycle |
| `*ralph-status` | Show current Ralph Loop state |
| `*ralph-resume` | Resume from last checkpoint |
| `*ralph-reset` | Refresh context / rerun Layer 1; retain consumed Layer 2 budget and history |
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

### Gate 3 (run + consistency reviewers)

Gate 3 includes all Ralph Loop verification (the run reviewer signs):
- Layer 1 self-check results
- Layer 2 independent results on the final input, complete applicable coverage and valid dispositions; NOT_RUN/escalated/blocked/aborted are not clean completion
- Evidence file verification and every handoff §9.1 AC; labels never override AC or evidence failure
- Knowledge Assessment

### Gate 4 (acceptor, by real use)

Gate 4 is acceptance by real use:
- No technical review (done by the Gate 3 reviewers); §9.1 results come from the run reviewer's `## AC runs` table, quantitative ACs recomputed from raw files; a missing, self-reported or contradictory row fails
- Consume the fixed / pre-existing / dismissed dispositions recognized at Gate 3 by a reviewer of that lens; do not require every valid exempt issue to be fixed; reopening needs explicit new evidence
- An acceptor that took no part; the human receives the verdict and 3-5 evidence lines
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

- Three started rounds exhausted without complete passing coverage, or same-category escalation triggered earlier
- May indicate design-level problem
- Return to Alex for re-design

### "State file stale"

- State older than 30 minutes
- Reload context and revalidate the input; retain consumed rounds and history
- Same input resumes unfinished calls; changed input needs the next available round
- Unrecoverable/legacy ambiguous state → BLOCKED_STATE for Alex; never a free R1

### "Max iterations reached"

- Exceeded 30 total iterations
- Review the approach fundamentally
- May need simpler solution or phased implementation
