# Recovery Packet — run interruption-a

Derived from goal.json + journal.jsonl at 2026-08-25T19:39:07.097Z.
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
Base commit `84c3666c4b8d658ecfd737c5305728f0e2152aea`; worktree `/private/tmp/tad-yolo2-p1/wt-interruption-a`; latest observed HEAD `2ab10e2a3eabc0d9c854da8c6264dcca764c10cc`.

## VERIFIED

- `S1` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json` (sha256 132c5fe5fa9f0a71ee76207a161ee02eb9166d7708023eb016d9317cb84ffcef), verified at HEAD `c35dc975e922593469f30ce99df6a5c48364e9d1`. DO NOT redo this work.

## UNVERIFIED

- `S2` — checkpoint candidate only (reason=candidate). Intent recorded: "continuing after recovery". NOT verified progress.
- `S3` — checkpoint candidate only (reason=candidate). Intent recorded: "continuing after recovery". NOT verified progress.
- working tree observation: 1 uncommitted path(s) in the frozen worktree (observation, not authority).

## BLOCKED

- (none)

## OUTCOME_UNKNOWN

- (none)

## PENDING ACTION

- (none)

## LEGAL NEXT ACTION

Slice S2 is a CANDIDATE only. Obtain a Conductor PASS receipt (existing Gate/reviewer must pass first), then run verify --slice S2 --receipt <receipt.json>

**WHY:** a checkpoint records intent, not verified progress; only a bound Conductor receipt may advance verified state

## OWNER

conductor

## RESUME COMMAND

```
node .tad/scripts/yolo-recovery.mjs resume --run /private/tmp/tad-yolo2-p1/wt-interruption-a/.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/run
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
