# YOLO Multi-Harness Guide — Phase 3 Cross-Harness Memory

**Status:** Phase 3 opt-in adapter layer (local, no provider calls without explicit budget mandate)
**Authority:** `goal.json + journal.jsonl` is progress; `recovery.md` is bounded navigation aid
**Profiles:** `claude-code`, `codex`, `opencode`, `opencode-deepseek` (all via native CLI adapters)

## 1. What Is Shared Across Harnesses

Not a transcript. The shared object is **semantic run state**:

- frozen goal, success criteria, non-goals, forbidden scope, handoff revision
- verified / unverified slices with evidence pointers
- decisions, rejected alternatives, blockers, `outcome_unknown`
- legal next action and its rationale

Native chat history, hidden reasoning, and provider session DB are never authority.

## 2. Isolation Roots (FR6)

Three mutually-disjoint realpaths, verified no-follow:

| Root | Contains | Writable by |
|------|----------|-------------|
| **control** | `goal.json`, `journal.jsonl`, receipts, leases | conductor/reducer only |
| **product** | isolated worktree visible to harness | harness (lease-bound) |
| **raw** | host-only `0700` `stdout/trace/record` carriers `0600` | conductor only |

A harness never resolves its own `control` or `raw` paths. `v2-init` freezes the `run-id → product worktree` mapping under an explicit host-parent and checks disjointness.

## 3. Lease Lifecycle (FR7/FR7a)

Every physical invocation requires a reducer-issued lease binding:

```
run/round/journal_seq + journal_prefix/semantic digests
packet/contract/profile/probe/budget hashes
role/kind, nonce, allowed_paths, expected_session, deadline
```

- `lease-issue` under run lock creates `issued`
- Adapter atomically claims `issued → claimed` (nonce+PID+PGID+budget) before provider spawn; replay of identical lease loses with zero provider calls
- `lease-close` / `lease-reconcile` after termination + quiet period

Expired, stale, or second concurrent lease blocks spawn until explicit close/reconcile. Expiry never auto-reissues.

## 4. Profile Classification

Each profile probes: start, fresh context, exact-session resume, structured output, permission containment, credential/tool isolation, process-group termination, worktree observation, re-entry, plus reviewer independence and hooks.

| Class | Capabilities | supported | unsupported | unknown/error/stale |
|-------|--------------|-----------|-------------|---------------------|
| load-bearing | start, fresh, schema, permission, credential/tool isolation, process-tree termination, worktree observation, re-entry | continue | **blocked** | **blocked** |
| strict-only | exact native resume, reviewer independence | continue | **degraded** | **blocked** |
| optional | hooks/events | record only | record only | record only |

Any `blocked` wins; else any `degraded` wins; else `strict`.

- **STRICT** — may execute and complete a phase.
- **DEGRADED** — may execute fresh-packet re-entry only with explicit human approval; missing reviewer may produce shadow candidates but never complete a phase.
- **BLOCKED** — cannot execute; shows missing capability and a safe alternative profile.
- **HONEST_PARTIAL** — honest stop (budget, pending side-effect, binding drift); resumable from last verified checkpoint.

Missing reviewer independence can only produce shadow candidates, never a completed phase.

## 5. Commands

### Existing YOLO (unchanged without profile)

```
node .tad/scripts/yolo-recovery.mjs init --run <dir> --handoff <path> --goal-file <json>
node .tad/scripts/yolo-recovery.mjs status --run <dir>
node .tad/scripts/yolo-recovery.mjs resume --run <dir>
node .tad/scripts/yolo-recovery.mjs stop --run <dir> --reason "..."
```

### Phase-3 V2 Control (additive)

```
# freeze external control/product/raw mapping (once per run)
node .tad/scripts/yolo-recovery.mjs v2-init --control-root <host-dir> --host-parent <host-parent> --product-worktree <worktree> --run <run-id> [--raw-root <host-raw>]

# lease lifecycle (conductor only, under run lock)
node .tad/scripts/yolo-recovery.mjs lease-issue --run <dir> --role <executor|reviewer> --kind <reentry|execution|review|probe> [--packet-sha256 <sha>] [--profile-hash <sha>]
node .tad/scripts/yolo-recovery.mjs lease-claim --lease <lease.json>
node .tad/scripts/yolo-recovery.mjs lease-close --lease <lease.json> --outcome <success|failed|reconciled>
node .tad/scripts/yolo-recovery.mjs lease-reconcile --lease <lease.json>
node .tad/scripts/yolo-recovery.mjs budget-reserve --approval <approval.json> --profile-hash <sha>
```

### Harness Adapter (opt-in)

```
# probe (one lease+budget per subcall, no retries)
node .tad/scripts/yolo-harness-runner.mjs probe \
  --profile <id> --profiles <json> --raw-root <host-only> \
  --lease <probe-lease.json> --budget-approval <approval.json> \
  --evidence-dir <sanitized-bundle>

# turn (reentry/execution/review, same packet, same assertion oracle)
node .tad/scripts/yolo-harness-runner.mjs turn \
  --profile <id> --profiles <json> --raw-root <host-only> \
  --lease <lease.json> --budget-approval <approval.json> \
  --evidence-dir <sanitized-bundle> \
  --packet <recovery.md> --prompt <prompt.md> \
  --role <executor|reviewer> --turn-kind <reentry|execution|review> \
  [--session <native-id>] [--policy <read-only|workspace-write>]
```

Last stdout line is JSON; raw carriers stay `0600` under `raw-root` and are secret-scanned before any sanitized projection enters the repo.

## 6. Status / Resume / Stop (human-readable)

- `status` shows profile classification, blocker, consequence, and safe next command in ordinary language; no JSONL inspection required.
- `resume` with a profile reports that profile's `STRICT|DEGRADED|BLOCKED` classification before launch; a `blocked` or `degraded-without-approval` profile prints the exact missing capability and a safe alternative, never silently picks another model.
- `stop` records reason and leaves the run resumable from its last verified checkpoint.

**Six states you will see:**

| State | What it means | Next safe command |
|-------|---------------|-------------------|
| STRICT | profile passed all load-bearing + strict probes | `resume --profile <that>` |
| DEGRADED | missing resume or reviewer; fresh-packet re-entry possible only with explicit approval; shadow candidates only | `resume --profile <other-strict>` or approve degraded with rationale |
| BLOCKED | missing load-bearing or credential/termination/isolation proof | switch profile, fix isolation, or obtain budget mandate |
| DRIFT | executable/contract/profile/model drift vs frozen tuple | re-probe that profile |
| TIMEOUT | previous run left a process group alive; quiet period not yet clean | wait + reconcile worktree before new lease |
| RE-ENTRY FAILED | assertion hard 8/8 soft ≥0.90 not met, or journal drift | rebuild packet from current journal and retry re-entry lease |

## 7. Budget & Live Probes

Live probes run only in disposable worktrees against harmless fixtures.

```
# approval carrier (human-signed)
{
  "profile_id": "opencode-deepseek",
  "profile_hash": "<sha of frozen profile tuple>",
  "max_invocations": 6,
  "max_tokens": 50000,
  "max_wall_ms": 900000
}
```

- Runner reserves one invocation under lock before spawn; missing/mismatched/exhausted approval → zero provider call.
- Probe subcalls each consume one `turn_kind=probe` lease and one reserved invocation.
- If a mandate is absent, that profile is classified `blocked` (honest), not synthetically passed.
- Proposed ceiling (not yet authorized): ≤6 calls / 50K tokens / 15 min per profile; ≤24 calls / 200K tokens / 60 min total; zero retries.

## 8. Recovery Assertion (same for every harness)

On every resume (native or fresh) the adapter injects the **current bounded recovery packet** and requires a schema-bound assertion before execution:

- goal ID, handoff revision, verified/unverified slice IDs, blockers, `outcome_unknown`, pending action, decisions/rejected alternatives, legal next action, owner, rationale.

The harness never receives the scoring oracle. Hard anchors 100%, soft rationale ≥90%. An assertion from an older packet/journal prefix is rejected before spawn. State drift, timeout, second lease, or crash blocks reissue until `lease-close`/`lease-reconcile` with stable worktree/process evidence.

## 9. Security

- Child env is allowlisted; `API_KEY/SECRET/TOKEN/CREDENTIAL` never reaches agent tool subprocesses.
- Tool subprocesses must not read provider secret files/keychain or have arbitrary network egress; native transport retains only its required provider path. Inability to prove this blocks `strict` for workspace-write execution.
- Sentinel probes attempt writes via `..`, symlink, absolute outside path, control/raw roots, journal/receipt/lease targets; denials are observed via filesystem manifest, not flag names.
- Raw output/trace/record must pass canary scan (`CANARY_SECRET_*`, `sk-…`, `AKIA…`, etc.) before sanitized projection; detection fails closed and deletes the projection candidate.

## 10. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `lease_already_claimed` | two adapters raced on identical lease | wait for winner to close/reconcile; re-issue new lease |
| `budget_exhausted` | max invocations/tokens/wall time hit | obtain new human-approved carrier with higher ceiling |
| `packet_mismatch` | packet hash != lease packet hash | rebuild packet from current `checkpoint.json` |
| `worktree_identity_mismatch` | frozen product worktree moved | verify `v2-init` mapping and realpath |
| `secret_detected` | raw output contained canary | inspect raw carrier, rotate credential, never commit projection |
