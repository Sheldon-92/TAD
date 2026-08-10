---
name: release-runbook
description: Progressive TAD release operations for publish, sync, sync-add, sync-list, version bumps, recovery, and read-only release verification. Use whenever Lite plans, executes, or verifies a release/distribution action.
---

# TAD Release Operations

This skill carries release judgment for Lite. It does not grant permission, create task state, or replace
the current LITE handoff/Progress. Load only this entry first, then one relevant reference.

## Trigger and reference routing

Use for `publish`, `sync`, `sync-add`, `sync-list`, version release preparation, release recovery, or
questions about whether TAD is ready to release/distribute.

After a trigger matches, run the source identity guard below before selecting or loading a reference,
reading release/registry/target state, planning, verifying, listing, or rendering any command.

- Publish, version bump, tag/push, or publish recovery: read
  [references/publish-ops.md](references/publish-ops.md).
- Sync, registration, listing, downstream verification, or sync recovery: read
  [references/sync-ops.md](references/sync-ops.md).
- A release spanning both: load publish first; load sync only after publish verification. Loading both
  does not combine their approvals.

Do not load unrelated skill references. The selected reference and this entry form one contract.

## Effective permission and task-state owner

Effective permission is the intersection:

```text
Lite role ∩ this skill's declaration ∩ current human approval
```

The smallest set wins. Skill text is never authority by itself. The current LITE handoff/Progress is the
single task-state owner and must pin skill/version/mode. This skill must not create a second handoff,
Progress file, nonce store, task state, release runtime, or permission system.

On resume, re-read the LITE contract, pinned skill version, mode, approval state, and last observed
external state before choosing an action.

## Roles and modes

| Mode | Caller | Allowed | Forbidden |
|---|---|---|---|
| `plan` | Alex-Lite | read state, choose version/scope, record intent and required approvals | product/release writes, push/tag/sync, target or registry writes |
| `execute` | Blake-Lite | handoff-listed writes, exactly one approved command launch, evidence | redesign, widen scope, consume absent/replayed approval, blind retry |
| `verify` | Blake-Lite or independent reviewer | detect-only gates, state comparison, evidence | auto-heal or perform the release action |

Full Blake migrating this skill may build and test it, but gains no publish/sync authority.

## Source identity guard

For every `publish`, `sync`, `sync-add`, or `sync-list` request—including plan, verify, and read-only
listing—resolve and verify the physical source root immediately after trigger matching:

```bash
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
repo_root=$(cd "$repo_root" && pwd -P) || exit 1
cwd_physical=$(pwd -P) || exit 1
test "$cwd_physical" = "$repo_root" || exit 1
origin=$(git -C "$repo_root" remote get-url origin 2>/dev/null) || exit 1
case "$origin" in
  https://github.com/Sheldon-92/TAD|https://github.com/Sheldon-92/TAD.git|git@github.com:Sheldon-92/TAD.git|ssh://git@github.com/Sheldon-92/TAD.git) ;;
  *) exit 1 ;;
esac
```

Substring matches, forks, nested cwd, unreadable origin, and unknown forms fail closed. A symlinked cwd
passes only when `pwd -P` equals the physical git root. Every later path and git command is rooted at
`repo_root` (`git -C "$repo_root"`), never inherited `$PWD`. If this guard fails, stop before reference
loading, registry access, target inspection, planning, listing, approval claims, or command rendering.

## Human approval: consume once before launch

Push/tag, any registered-project write, source registry write, downstream commit, and downstream push
each require an explicit human approval scoped to that action. The sole LITE task state records:

```yaml
approval_id: <unique id>
scope_digest: <exact command class + targets + version/ref + write scope>
approval_state: unused | consumed-before-launch
consumed_at: <timestamp or empty>
action_state: pending | launched | completed | not-started | partial | unknown
```

Immediately before launching the exact command, Blake-Lite atomically changes `unused` to
`consumed-before-launch`, sets `consumed_at`, and sets `action_state: launched`. Missing approval,
digest mismatch, replay, resume/concurrent attempt with non-`unused` state, or a changed command is DENY.
Never reset a consumed approval to unused.

The single task-state owner implements that transition with an atomic claim, not a read-then-write:
after validating the unused record and digest, create
`$task_state_dir/approval-claims/$approval_id` with one `mkdir` operation. Exactly one consumer can
succeed. A failed `mkdir` is DENY; never remove or reuse a claim. The winning consumer writes the
validated digest and `consumed-before-launch`/`launched` metadata inside its owned claim before invoking
the command. A crash after the claim succeeds remains consumed with an ambiguous action result and must
follow reconciliation below. If durable task state or atomic `mkdir` is unavailable, stop as BLOCKED.

An interaction decision is a human gate. If the harness cannot obtain a real answer, stop as BLOCKED;
do not select a default.

## Ambiguous-result recovery

Timeout, disconnect, truncated output, or unknown exit after launch means stop, not retry. Inspect the
remote ref/tag or target content/structural state and classify `completed`, `not-started`, `partial`, or
`unknown`. `partial`/`unknown` return to Alex-Lite. `not-started` may be retried only with a new approval
ID and digest; the original stays consumed. Evidence must distinguish observed absence from unobserved.

## Seven-phase release overview

1. Preflight: physical-root guard, derive current state, explain dirty/unpushed scope.
2. Version: derive versions; update only contracted files; run authoritative gates.
3. CHANGELOG: require the proposed version's user-facing entry.
4. Publish: local preparation, then separately approved main push, annotated tag, and tag push.
5. Sync plan: read registry, derive live sync set, capture target pre-state, select explicit scope.
6. Sync execute: target-specific approval, copy within the Managed Write Surface, migration, verification.
7. Verify: compare remote/targets with their own pre-state; advance only verified targets; report recovery.

Do not skip a phase. A publish-only task stops after publish verification; a sync-only task still runs the
source guard and sync preflight. Detailed gate order lives in the selected reference.

## Mechanical authority and exit codes

Use current public interfaces directly:

- `.tad/hooks/lib/release-verify.sh`
- `.tad/hooks/lib/derive-sync-set.sh`
- `.tad/hooks/lib/migration-engine.sh`

Do not create a wrapper, inline migration engine, hardcoded framework directory authority, hook, router,
installer change, or new runtime. For verifier modes, `0` is pass, `1` is a named domain result handled by
the selected reference, and `2` is usage/wiring and always hard-blocks. Never combine `1|2` into one warn
branch. Historical `TAD_RELEASE_GATE=warn` instructions are superseded and inactive.

## Global safety stops

Stop before mutation when any of these holds:

- physical root/origin guard is not exact;
- role, mode, handoff scope, pinned version, or human approval is absent/inconsistent;
- approval is consumed/replayed or external action outcome is ambiguous;
- a required tool/interface is absent or returns wiring/usage failure;
- selected target, registry, managed-surface derivation, merge marker, or pre-state is unreadable;
- proposed paths exceed the selected reference's authority;
- the operation would touch zero-touch project data, full source carriers, or unrelated dirty files.

In `plan` and `verify`, do not heal. In `execute`, a remediation must be explicitly listed in the handoff
and independently authorized when it mutates an external surface.

## Evidence and completion

Record commands, exact roots/targets, stdout/stderr, exit codes, approval ID/digest/state transitions,
pre/post hashes or refs, and recovery classification. Compare every target to its own pre-state, never to
an assumed clean/source state. A release/sync is complete only when required verification is green and
all partial/unknown states are resolved or explicitly returned to Alex-Lite.
