# Code Review: trajectory-eval-p3
Reviewer: code-reviewer (Agent subagent)
Date: 2026-07-02

## Freeze Constraint Verification
| Constraint | Status |
|---|---|
| judge-prompt.md / rubric.md ZERO changes | PASS |
| golden-set/ ZERO changes | PASS |
| acceptance-protocol.md existing lines ZERO deletion/modification | PASS — diff purely additive |
| assemble-bundle.sh bundle CONTENT format ZERO drift | PASS — AC4 byte-diff empty |

## Findings

### P1-1: grep -H flag needed for single-file case (gate-roi-report.sh line 59)
When find locates exactly one .jsonl file, grep without -H omits filename prefix. `${line#*:}` then strips into JSON content, breaking jq parsing.
**Status**: FIXED — added `-H` flag

### P1-2: UNRECOVERABLE scores coerced to 0 in Section 4 aggregation (gate-roi-report.sh lines 236-250)
awk `$i+0` coerces "UNRECOVERABLE" string to 0, polluting mean/min/max.
**Status**: FIXED — added numeric filter `if ($i ~ /^[0-9]+$/)`

### P2-1: Section 1/5 jq+awk duplication
Both sections run same pipeline. Low priority, correctness unaffected.
**Status**: ACCEPTED — report-only script

### P2-2: sed with unescaped regex metacharacter (gate-roi-report.sh line 214)
`$JUDGE_DIR` contains `.tad` where `.` is regex metachar. Practically safe since input is find output.
**Status**: ACCEPTED — low risk

### P2-3: Trap quoting style
Works correctly for mktemp paths.
**Status**: ACCEPTED

## Verdict: PASS (after P1-1 and P1-2 fixes applied)
