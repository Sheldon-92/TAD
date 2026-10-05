# Dogfood run — interruption-a (stage: after-verified-slice)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-interruption-a` |
| base commit | `84c3666c4b8d658ecfd737c5305728f0e2152aea` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption | after the `verified` event for S1, with S2 work started and left uncommitted |
| executor | `exec-a1` (S1), `exec-a2` (continuation S2/S3) |
| fresh recovery context | `recover-a` (run path only) |
| recovery reviewer | `review-a` (independent) |

## Recovery assertion

Fresh context scored against the frozen oracle (`oracle-interruption-a.md`):
**hard 8/8, soft 1.00, verdict PASS** (floor 0.90). H7 (legal next action:
complete S2) matched the oracle.

## Continuation

- S1: `c35dc975` — verified with bound Conductor receipt after deterministic
  gate + independent slice review (PASS).
- S2: `c4b8d52d` — completed post-recovery, checkpointed (candidate).
- S3: `2ab10e2a` — completed post-recovery, checkpointed (candidate).

Ledger: `initialized → checkpointed S1 → verified S1 → checkpointed S2 →
checkpointed S3`.

## Outcomes

- `repeated_verified_slice = 0`; `wrong_or_unauthorized_next_action = 0`
- Hidden acceptance: `HIDDEN_ACCEPTANCE=PASS (13/13)`
- Gate: `GATE_VERDICT: PASS`
- Full details: `interruption-a/continuation.md`, `interruption-a/review.md`,
  `interruption-a/gate.md`, `interruption-a/run-evidence.json`.