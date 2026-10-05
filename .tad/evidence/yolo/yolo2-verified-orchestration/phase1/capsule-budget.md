# Capsule budget evidence — Phase 1

Budget: **2500 estimated tokens** for `recovery.md`.

Estimator (deliberately conservative, defined in `yolo-recovery.mjs`
`estimateTokens`): ASCII characters counted at 4 per token, every non-ASCII
character counted as one whole token. It over-estimates rather than under, so a
packet that passes here has real headroom.

## Measured on the four real dogfood runs

| run | recovery.md bytes | estimated tokens | budget | result |
|---|---:|---:|---:|---|
| control | 2736 | 689 | 2500 | PASS |
| interruption-a | 2503 | 628 | 2500 | PASS |
| interruption-b | 2932 | 736 | 2500 | PASS |
| interruption-c | 2501 | 629 | 2500 | PASS |

Every packet fits with large margin, and none of them was trimmed to do so:
each still carries GOAL, SUCCESS CRITERIA, NON-GOALS, FORBIDDEN SCOPE, HANDOFF
REVISION, VERIFIED, UNVERIFIED, BLOCKED, OUTCOME_UNKNOWN, PENDING ACTION,
LEGAL NEXT ACTION (+ WHY), OWNER, RESUME COMMAND and AUTHORITY ORDER.

## Over-budget behaviour has a real red state

`yolo-recovery.test.mjs --case status-capsule` constructs a goal whose frozen
success list is ~400 entries. The tool writes the full packet, then fails with
`reason: capsule_over_budget` and a per-section composition breakdown, exit 1.
The test additionally asserts that the over-budget packet still contains every
required label — i.e. the tool stops rather than buying headroom by deleting
non-goals, forbidden scope, blockers or the next-action reasoning.
