# Dogfood run — control (uninterrupted baseline)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-control` |
| base commit | `0ccd30cdf25daa3abc75cdf46ee6a98b68fbc9ec` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption | none — this run was never interrupted |
| executor | `exec-control-1/2/3` (fresh Task sub-agents, opencode) |
| slice reviewer | independent opencode reviewer (S1 PASS round 1, S2 PASS round 2, S3 PASS round 1) |
| gate reviewer | `gate-control` (independent) |

## Purpose

The control establishes that the same frozen base commit and the same frozen
input produce a completed, Gate-passing result **without any recovery machinery
being exercised**. It carries no recovery score and is excluded from the
recovery-rate numerator/denominator; its role is baseline parity. If the control
were missing, or started from a different base or input, the dogfood gate fails.

## What happened

- `0829f477` S1: add §10 Command Reference (PASS round 1 — review lessons from
  earlier rounds baked in: reconcile `--observed-sha256` contract, action-start
  and stop never exit 0)
- `90e513ec` + `5e9c0aa2` S2: add §11 Troubleshooting (round-1 review FAIL:
  receipt-binding payloads per code + intro overclaim → fix → round-2 PASS)
- `27c0b8a5` S3: add §12 Worked Example (PASS round 1 — gitignored-evidence
  lesson baked in: no evidence commit in the transcript)

Ledger (`journal.jsonl`):

```
seq  1  initialized
seq  2  checkpointed  S1 (candidate)
seq  3  verified      S1 (bound conductor receipt)
seq  4  checkpointed  S2 (candidate)
seq  5  verified      S2 (bound conductor receipt)
seq  6  checkpointed  S3 (candidate)
seq  7  verified      S3 (bound conductor receipt)
```

## Slice gates and reviews

| slice | deterministic gate | independent review (final) |
|---|---|---|
| S1 | `GATE_VERDICT=PASS (5/5)` | PASS round 1 |
| S2 | `GATE_VERDICT=PASS (5/5)` | PASS round 2 (round 1 FAIL: `receipt_verdict_not_pass`/`receipt_head_not_ancestor` payloads, intro overclaim) |
| S3 | `GATE_VERDICT=PASS (4/4)` | PASS round 1 |

All slice reviews were written by an independent reviewer distinct from the
executors; every receipt is `written_by: conductor`, `written_by_id !=
executor_id`.

## Hidden acceptance

`HIDDEN_ACCEPTANCE=PASS (13/13)` — all three headings, all commands, real
reasons (≥8), nothing invented, transcript executable, preserved warning +
authority order, no truncation, balanced fences, only the guide changed.

## Gate

`GATE_VERDICT: PASS` — Q1 all sections substantively correct; Q2 guide-only
scope (276 insertions / 0 deletions); Q3 no existing content deleted or
reworded; Q4 no slice verified twice; Q5 no fabricated flags/exit codes/reasons.

## Result

Baseline parity established at base `0ccd30cdf25daa3abc75cdf46ee6a98b68fbc9ec`.
This run carries no recovery score and is excluded from the recovery-rate
denominator.