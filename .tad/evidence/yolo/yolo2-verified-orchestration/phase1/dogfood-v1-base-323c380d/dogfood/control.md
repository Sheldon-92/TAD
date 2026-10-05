# Dogfood run — control (uninterrupted baseline)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-control` |
| base commit | `323c380dbb02dcdc4b58facd15e96825be66eb50` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption | none — this run was never interrupted |
| executor | `exec-control` (fresh Task sub-agent, claude-opus-5) |
| slice reviewer | `slice-review-control` (independent) |
| gate reviewer | `gate-control` (independent) |

## Purpose

The control establishes that the same frozen base commit and the same frozen
input produce a completed, Gate-passing result **without any recovery machinery
being exercised**. It carries no recovery score and is excluded from the
recovery-rate numerator/denominator; its role is baseline parity. If the control
were missing, or started from a different base or input, the dogfood gate fails.

## What happened

- 5e6211e2 S3: add §12 Worked Example — copy-pasteable init/checkpoint/receipt/verify/resume transcript
- 87107745 S2: add §11 Troubleshooting — exact CLI reason strings grouped by layer, with symptom/signal/remedy
- be247c99 S1: add §10 Command Reference table derived from yolo-recovery.mjs (per-command required/optional flags + reachable exit codes)

Ledger (`journal.jsonl`):

```
seq  1  initialized        
seq  2  checkpointed       S1
seq  3  checkpointed       S2
seq  4  checkpointed       S3
seq  5  verified           S1
seq  6  verified           S2
seq  7  verified           S3
```

All three slices were verified only after (a) the deterministic slice gate
passed and (b) an independent reviewer returned PASS, with the Conductor then
writing a receipt bound to run/slice/handoff-revision/worktree/HEAD. No slice
was verified twice.

## Results

- Deterministic slice gates: S1 PASS (5/5), S2 PASS (5/5), S3 PASS (4/4)
- Independent slice reviews: S1 PASS, S2 PASS, S3 PASS
- Hidden acceptance: **PASS (13/13)** — see `control/hidden-acceptance.txt`
- Independent gate verdict: **PASS** — see `control/gate.md`
- Verified slices at end: `["S1","S2","S3"]`

## Raw evidence

| artifact | path |
|---|---|
| archived ledger | `control/run/` |
| slice gates + reviews + receipts | `control/conductor/` |
| hidden acceptance output | `control/hidden-acceptance.txt` |
| independent gate verdict | `control/gate.md` |
| machine-readable envelope | `control/control-evidence.json` |
