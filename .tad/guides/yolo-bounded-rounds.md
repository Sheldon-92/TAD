# YOLO Bounded Rounds — operator guide (Phase 2, opt-in, experimental)

> Reference harness: **codex** via `.tad/scripts/yolo-reference-runner.mjs`.
> Phase-1 recovery recorder remains the authority: `goal.json + journal.jsonl +
> bound evidence`. This guide covers ONLY the Phase-2 round contract.

## 0. When to use

Only for runs whose `goal.json` carries an `execution_policy`
(`yolo-bounded-policy-v1`). Phase-1 runs without that block behave exactly as
before; Phase-2 commands are refused there.

## 1. Freeze a run

```bash
node .tad/scripts/yolo-recovery.mjs init --run <run-dir> \
  --handoff <handoff.md> --goal-file <goal-spec.json>
```

The goal-spec may carry:

```json
{
  "execution_policy": {
    "format": "yolo-bounded-policy-v1",
    "max_rounds": 8, "max_retries_per_slice": 2, "max_actions": 40,
    "max_wall_seconds": 14400, "max_tokens": 240000,
    "audit_reserve_tokens": 48000, "max_executor_tokens_per_round": 24000,
    "align_every_verified_slices": 3, "packet_token_budget": 3500
  },
  "quality_policy": {
    "phase_candidate_requires_hidden_acceptance": true,
    "phase_candidate_requires_alignment": true,
    "wrong_or_unauthorized_next_action_max": 0,
    "repeated_verified_action_max": 0
  }
}
```

Rules: positive integers; `audit_reserve_tokens < max_tokens`;
`max_executor_tokens_per_round <= max_tokens - audit_reserve_tokens`;
`align_every_verified_slices` is 2 or 3. Policy is frozen at init — increasing
it requires a NEW human-authorized run from the last verified commit.

## 2. One bounded round (repeat)

```bash
node .tad/scripts/yolo-recovery.mjs round-prepare --run <run> \
  --contract <slice-contract.json>
```

The Supervisor writes a slice contract (`yolo-slice-contract-v1`): one coherent
outcome mapped onto frozen success IDs, hash-bound necessary evidence, a small
allowed-path list (never Handoff/goal/journal/receipts/hidden acceptance),
tool allowlist WITHOUT Shell/Bash/Agent, declared deterministic checks, and the
frozen forbidden-scope hash. `round-prepare` validates it, derives the executor
packet at `<run>/rounds/<round-id>/execution.md` (≤ `packet_token_budget`,
anchors never trimmed), and appends `round_prepared`.

```bash
node .tad/scripts/yolo-reference-runner.mjs turn \
  --host-evidence <host-evidence-root> \
  --packet <run>/rounds/<round-id>/execution.md \
  --prompt <assertion-prompt.txt> --role executor --turn-kind assertion \
  --sandbox read-only
```

The fresh executor writes its H1–H8 + S1–S4 assertion and STOPS (read-only
sandbox; no shell). An independent reviewer scores it against the frozen
oracle (hard 8/8, soft ≥ 0.90, reviewer identity ≠ executor identity).

```bash
node .tad/scripts/yolo-recovery.mjs round-authorize --run <run> \
  --assertion <assertion.json> --review <review.json> \
  --turn-record <reference-turn.json>
```

Authorization pins the native session id and reserves
`max_executor_tokens_per_round` (denied if the audit reserve would be eaten).
Only then may the SAME session execute.

```bash
node .tad/scripts/yolo-reference-runner.mjs turn ... --turn-kind execution \
  --session <pinned-session-id> --nonce <action-nonce> --sandbox workspace-write
node .tad/scripts/yolo-recovery.mjs action-start --run <run> --action A1 ... \
  --round <round-id> --outcome-id <frozen-id> --tool Edit \
  --args-json <args.json> --effect-manifest <effects.json>
node .tad/scripts/yolo-recovery.mjs reconcile --run <run> --action A1 ...
node .tad/scripts/yolo-recovery.mjs round-close --run <run> \
  --outcome candidate --report <report.json> --usage <usage.json> \
  --turn-record <execution-turn.json>
node .tad/scripts/yolo-recovery.mjs verify --run <run> --slice S1 --receipt <receipt.json>
```

Side effects must be pre-declared (`action-start` mints an `action_nonce`) and
reconciled before close. The runner's native trace is reconciled one-to-one
against `action_started` events; unreceipted mutations fail closed. Duplicate
work is detected by observed-effect fingerprint (content digests only —
renaming outcome/slice/labels cannot hide it).

## 3. Alignment and phase candidate

Every `align_every_verified_slices` verified slices (and always before phase
closure):

```bash
node .tad/scripts/yolo-recovery.mjs align --run <run> --receipt <alignment-receipt.json>
```

The receipt binds the current verified digest, every success criterion
(`met|unmet|not_yet_due`), non-goal checks, and an independent reviewer PASS.

When ALL success criteria are verified-backed and closure invariants hold:

```bash
node .tad/scripts/yolo-recovery.mjs phase-candidate --run <run> --receipt <receipt.json>
```

This is a run-level candidate — TAD Gate 3/4 and human acceptance remain
authoritative.

## 4. Budgets and honest stops

Round/retry/action/wall-time/token/audit-reserve exhaustion produces exit 1,
`HONEST_PARTIAL` naming the exhausted budget, unchanged verified state, and a
recovery packet with exact counters. There is no evaluator loop and no policy
increase mid-run. Recovery = new human-authorized run from the last verified
commit with a fresh frozen policy.

## 5. Known limitation (honest)

Capability probe verdict on this machine is **degraded**: codex read-only
sandbox enforces writes but NOT host-side reads, so the hidden-acceptance
namespace boundary (capability 9) cannot be proven. See
`.tad/evidence/yolo/yolo2-verified-orchestration/phase2/reference-harness-capability.json`.
Running the paired dogfood under degraded isolation requires an explicit human
decision; otherwise the mechanism work stands and dogfood waits.
