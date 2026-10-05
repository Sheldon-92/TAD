# Recovery Packet — run control

Derived from goal.json + journal.jsonl at 2026-08-25T19:29:13.978Z.
This file has NO authority. If it disagrees with goal.json/journal.jsonl, the
journal wins and this file must be rebuilt. Do not treat it, session-state.md,
or a compact summary as progress truth.

## GOAL

Maintain .tad/guides/yolo-recovery.md by adding a Command Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3), without changing any other file.

Goal id: `yolo2-p1-guide-maintenance`

## SUCCESS CRITERIA

1. S1: section '## 10. Command Reference' documents every CLI command with its required flags and exit codes
2. S2: section '## 11. Troubleshooting' maps real CLI reason strings to symptom and remedy
3. S3: section '## 12. Worked Example' is a copy-pasteable transcript from init through resume

## NON-GOALS

- do not improve or restructure the existing guide sections
- do not change the CLI or its tests

## FORBIDDEN SCOPE

- .tad/scripts/
- .claude/
- .tad/hooks/

## HANDOFF REVISION

`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` @ sha256 `1e064fd530cce81505b20a86a9d0ba2b4a8674960081758de1a94a9e5bcd7ba8`
Base commit `84c3666c4b8d658ecfd737c5305728f0e2152aea`; worktree `/private/tmp/tad-yolo2-p1/wt-control`; latest observed HEAD `f2fc8fd900dd090e806751d69adce302a95987b7`.

## VERIFIED

- `S1` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json` (sha256 b5f692c5c532f753675ab8e7ddb679bace06f9b2551368970e76d812caa449e2), verified at HEAD `45c72b7a96594727cf3cee6a061af0f3032fbce6`. DO NOT redo this work.
- `S2` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S2.json` (sha256 6d2d03b187e184bdadb7e20c573c9ffe96d7df53f0e171ce1f43e25d6b6f4d2a), verified at HEAD `93c050f9f6e54b0c0173a99e067d67a18a4e0639`. DO NOT redo this work.
- `S3` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S3.json` (sha256 af32aa287281f4beba4b8e6392bae90d9f4f12f4d8590cd07df69efe7d2d873a), verified at HEAD `f2fc8fd900dd090e806751d69adce302a95987b7`. DO NOT redo this work.

## UNVERIFIED

- (no checkpoint candidates)
- working tree observation: 1 uncommitted path(s) in the frozen worktree (observation, not authority).

## BLOCKED

- (none)

## OUTCOME_UNKNOWN

- (none)

## PENDING ACTION

- (none)

## LEGAL NEXT ACTION

All frozen slices are verified. Run the handoff-level acceptance and hand back to the Conductor; do NOT invent extra scope.

**WHY:** the frozen slice plan is exhausted and nothing is pending

## OWNER

conductor

## RESUME COMMAND

```
node .tad/scripts/yolo-recovery.mjs resume --run /private/tmp/tad-yolo2-p1/wt-control/.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/run
```

## AUTHORITY ORDER

1. approved handoff revision + immutable `goal.json`
2. fully parseable `journal.jsonl` + its evidence pointers
3. rebuildable `checkpoint.json`
4. this packet / `session-state.md` / PreCompact snapshots — navigation only

## VERIFICATION MODEL

- A checkpoint is only a CANDIDATE: it records intent, it does not verify the work.
- `verified` advances ONLY when a Conductor (an identity distinct from the executor, `written_by_id` != `executor_id`) writes a bound verification receipt after the existing Gate and an independent review have both PASSed.
- Completion prose, an ordinary file, a self-authored receipt, or any executor assertion NEVER advances `verified`.
- Until a validated receipt names the slice, that slice stays unverified — even if the work appears done.

## PROHIBITIONS

- Uncommitted worktree changes are observation only and MUST NOT be treated as progress or as done; inspect them before continuing — do not silently discard them.
- Completion prose, a self-authored receipt, or any executor assertion NEVER advances `verified` (see VERIFICATION MODEL).
