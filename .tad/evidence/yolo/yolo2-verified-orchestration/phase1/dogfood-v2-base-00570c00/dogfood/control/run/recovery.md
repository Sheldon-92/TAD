# Recovery Packet — run control

Derived from goal.json + journal.jsonl at 2026-08-24T22:45:02.835Z.
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
Base commit `323c380dbb02dcdc4b58facd15e96825be66eb50`; worktree `/private/tmp/tad-yolo2-p1/wt-control`; latest observed HEAD `5e6211e2c6303b5b348a04526c203e0a7e45653e`.

## VERIFIED

- `S1` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json` (sha256 b51929263485e28460bf7ea3dd1f8e663d3022427aabf753c8a59643ef1c0292), verified at HEAD `5e6211e2c6303b5b348a04526c203e0a7e45653e`. DO NOT redo this work.
- `S2` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S2.json` (sha256 9d319fe8e0d2d0f5cc57a73822e499ac230008ee86a78e8a10fca6710ab9d6e1), verified at HEAD `5e6211e2c6303b5b348a04526c203e0a7e45653e`. DO NOT redo this work.
- `S3` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S3.json` (sha256 157394b894619cce821196ca39f007c88138a6150bffbb902955604fbb336903), verified at HEAD `5e6211e2c6303b5b348a04526c203e0a7e45653e`. DO NOT redo this work.

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
