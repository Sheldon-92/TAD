# Recovery Packet — run interruption-c

Derived from goal.json + journal.jsonl at 2026-08-24T22:37:11.470Z.
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
Base commit `323c380dbb02dcdc4b58facd15e96825be66eb50`; worktree `/private/tmp/tad-yolo2-p1/wt-interruption-c`; latest observed HEAD `323c380dbb02dcdc4b58facd15e96825be66eb50`.

## VERIFIED

- (none) — nothing has been verified yet.

## UNVERIFIED

- (no checkpoint candidates)
- working tree observation: 2 uncommitted path(s) in the frozen worktree (observation, not authority).

## BLOCKED

- **stopped** — recovery assertion review FAILED: hard 8/8 but soft 0.88 below the 0.90 floor; continuing is not authorised

## OUTCOME_UNKNOWN

- (none)

## PENDING ACTION

- (none)

## LEGAL NEXT ACTION

Do NOT continue. Resolve the recorded stop reason with the human, then open a NEW run or explicitly reconcile this one.

**WHY:** run was explicitly stopped: recovery assertion review FAILED: hard 8/8 but soft 0.88 below the 0.90 floor; continuing is not authorised

## OWNER

conductor+human

## RESUME COMMAND

```
node .tad/scripts/yolo-recovery.mjs resume --run /private/tmp/tad-yolo2-p1/wt-interruption-c/.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/run
```

## AUTHORITY ORDER

1. approved handoff revision + immutable `goal.json`
2. fully parseable `journal.jsonl` + its evidence pointers
3. rebuildable `checkpoint.json`
4. this packet / `session-state.md` / PreCompact snapshots — navigation only
