# Dogfood run — interruption-b (stage: after-action-started)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-interruption-b` |
| base commit | `84c3666c4b8d658ecfd737c5305728f0e2152aea` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption | after `action_started` for A1, patch on disk, before reconciliation |
| executor | `exec-b1` (S1), `exec-b2` (reconcile + continuation S2/S3) |
| fresh recovery context | `recover-b` (run path only) |
| recovery reviewer | `review-b` (independent) |

## Recovery assertion

Fresh context scored against the frozen oracle (`oracle-interruption-b.md`):
**hard 8/8, soft 1.00, verdict PASS** (floor 0.90). H5 classified A1 as
`confirmed` by hashing the real file (disk `048196e1…` == `intended_post_sha256`);
H7 (legal next action: reconcile A1 first) matched the oracle.

## Continuation

- S1: `d738e4e9` — verified with bound Conductor receipt after deterministic
  gate + independent slice review (PASS).
- A1: `action_started` (controlled Runtime patch) → reconciled `confirmed`
  (on-disk hash == intended post). The patch landed as its own commit
  `04a87a4d` after an independent slice review flagged commit hygiene.
- S2: `e063fe58` — verified with bound Conductor receipt (PASS).
- S3: `d52d4137` + `8977be6e` (review fix) — verified with bound Conductor
  receipt (PASS).

Ledger: `initialized → checkpointed S1 → verified S1 → action_started A1 →
action_reconciled A1 (confirmed) → checkpointed S2 → verified S2 →
checkpointed S3 → verified S3`.

## Outcomes

- `repeated_verified_slice = 0`; `wrong_or_unauthorized_next_action = 0`
- The A1 patch was reconciled, never re-applied (hash proved it had landed).
- Hidden acceptance: `HIDDEN_ACCEPTANCE=PASS (13/13)`
- Gate: `GATE_VERDICT: PASS`
- Full details: `interruption-b/continuation.md`, `interruption-b/review.md`,
  `interruption-b/gate.md`, `interruption-b/run-evidence.json`.