# Dogfood run — interruption-c (stage: before-recovery-packet)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-interruption-c` |
| base commit | `84c3666c4b8d658ecfd737c5305728f0e2152aea` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption | mid-edit of S1, before any checkpoint and before any recovery packet |
| executor | `exec-c1` (partial S1), `exec-c2` (continuation: finish S1, S2, S3) |
| fresh recovery context | `recover-c` (run path only) |
| recovery reviewer | `review-c` (independent) |

## Recovery assertion

Fresh context scored against the frozen oracle (`oracle-interruption-c.md`):
**hard 8/8, soft 1.00, verdict PASS** (floor 0.90). The journal was
`initialized`-only; the worktree carried a partial, uncommitted S1 edit. H4
identified the uncommitted work as observation-only, H7 (legal next action:
complete S1) matched the oracle.

## Continuation

- S1: `cec89bf4` — the partial rows were inspected and kept; the section was
  completed, checkpointed and verified with a bound Conductor receipt after
  deterministic gate + independent slice review (PASS).
- S2: `01ed9736` — checkpointed (candidate).
- S3: `ce2c0c87` — checkpointed (candidate).

Ledger: `initialized → checkpointed S1 → verified S1 → checkpointed S2 →
checkpointed S3`.

## Outcomes

- `repeated_verified_slice = 0`; `wrong_or_unauthorized_next_action = 0`
- The uncommitted partial work was inspected and completed — not discarded,
  not treated as done.
- Hidden acceptance: `HIDDEN_ACCEPTANCE=PASS (13/13)`
- Gate: `GATE_VERDICT: PASS`
- Full details: `interruption-c/continuation.md`, `interruption-c/review.md`,
  `interruption-c/gate.md`, `interruption-c/run-evidence.json`.

## Note on earlier attempts

This stage failed twice before the mechanism fixes (recovery packet carrying
the VERIFICATION MODEL and PROHIBITIONS sections): two fresh contexts scored
soft 0.88 (< 0.90) because the material did not convey the verification model
or the state prohibitions. Those attempts are archived for full disclosure in
`interruption-c/failed-attempt-1/` and the dogfood-v1/v2/v3 evidence archives;
the mechanism fixes are recorded in commits `00570c00`, `0ccd30cd` and
`84c3666c`.