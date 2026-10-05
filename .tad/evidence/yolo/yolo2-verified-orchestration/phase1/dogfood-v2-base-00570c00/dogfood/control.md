# Dogfood run — control (uninterrupted baseline)

| field | value |
|---|---|
| worktree | `/private/tmp/tad-yolo2-p1/wt-control` |
| base commit | `00570c00bb4cbe8b4df45e38971a11429b5bd2cf` |
| input (`task.md`) sha256 | `1ab2d799ae608478145e09f6558ddb29c3fd2c3beb437668c4209b8c431d8e05` |
| interruption | none — this run was never interrupted |
| executor | `exec-control-1/2/3` (fresh Task sub-agents, opencode) |
| slice reviewer | independent opencode reviewer (S1 round 2 PASS, S2 round 3 PASS, S3 round 2 PASS) |
| gate reviewer | `gate-control` (independent) |

## Purpose

The control establishes that the same frozen base commit and the same frozen
input produce a completed, Gate-passing result **without any recovery machinery
being exercised**. It carries no recovery score and is excluded from the
recovery-rate numerator/denominator; its role is baseline parity. If the control
were missing, or started from a different base or input, the dogfood gate fails.

## What happened

- `e058933e` + `1ef6a4f5` S1: add §10 Command Reference (round-1 review FAIL → fix commit → round-2 PASS)
- `63542438` + `b1932d2a` + `9f69406e` S2: add §11 Troubleshooting (two review FAIL rounds → fixes → round-3 PASS)
- `2a3f5799` + `656bc92d` S3: add §12 Worked Example (review FAIL → fix → round-2 PASS)

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
| S1 | `GATE_VERDICT=PASS (5/5)` | PASS — round 1 FAIL (`reconcile --observed-sha256` mislabeled) → fix → PASS |
| S2 | `GATE_VERDICT=PASS (5/5)` | PASS — round 1 FAIL (journal_* `details.path` vs `details.line`), round 2 FAIL (`details.actual`, tamper remedy) → fix → PASS |
| S3 | `GATE_VERDICT=PASS (4/4)` | PASS — round 1 FAIL (gitignored evidence commit in transcript) → fix → PASS |

All three slice reviews were written by an independent reviewer distinct from
the executors; every receipt is `written_by: conductor`, `written_by_id !=
executor_id`.

## Hidden acceptance

`HIDDEN_ACCEPTANCE=PASS (13/13)` — all three headings, all commands, real
reasons (≥8), nothing invented, transcript executable, preserved warning +
authority order, no truncation, balanced fences, only the guide changed.

## Gate

`GATE_VERDICT: PASS` — Q1 all sections substantively correct; Q2 guide-only
scope (275 insertions / 0 deletions); Q3 no existing content deleted or
reworded; Q4 no slice verified twice; Q5 no fabricated flags/exit codes/reasons.

## Result

Baseline parity established at base `00570c00bb4cbe8b4df45e38971a11429b5bd2cf`.
This run carries no recovery score and is excluded from the recovery-rate
denominator.