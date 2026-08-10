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
- A release spanning both: load publish first, then sync after publish verification. Entry +
  `publish-ops.md` + `sync-ops.md` is the hard three-document maximum and may describe one transaction;
  a fourth or unrelated reference is denied.

Do not load unrelated skill references. The selected reference and this entry form one contract.

## Effective permission and task-state owner

Effective permission is the intersection:

```text
Lite role boundary ∩ this skill's constraints ∩ accepted Execution Mandate
```

The smallest set wins. Skill text is never authority by itself. The current LITE handoff/Progress is the
single task-state owner and must pin skill/version/mode. This skill must not create a second handoff,
Progress file, nonce store, task state, release runtime, or permission system.

On resume and before every mutation, re-read the accepted mandate revision, exact consequence/target
binding, transaction version, preconditions, and last observed external state.

## Roles and modes

| Mode | Caller | Allowed | Forbidden |
|---|---|---|---|
| `plan` | Alex-Lite | read state; record outcome, exact scope/consequences/recovery in mandate | product/release writes, push/tag/sync, target or registry writes |
| `execute` | Blake-Lite | mandate-bound transaction actions, recovery, evidence | redesign, widen mandate, replay completed action, blind retry |
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
loading, registry access, target inspection, planning, listing, transaction launch, or command rendering.

## Handoff-owned transaction and CAS

The accepted mandate is the human permission carrier; commands inside its exact outcome are technical
actions, not new approval gates. The sole LITE handoff `## Execution Transactions` records unique
transaction/action IDs, mandate revision, target/consequence bindings, pre/post/recovery evidence,
monotonic `state_version`, and `planned|launched|completed|not-started|partial|unknown`.

Before each mutation, re-read root/origin/ref/pathspec/MWS and any environment/account/credential binding,
then CAS the action to launched: atomic `mkdir <handoff>.txn-lock`; owner fingerprint (token, host, PID,
process-start, time, expected digest, transaction ID/version); locked admission re-read; validated
same-directory temporary file + digest re-check + atomic rename; owner-token cleanup. An orphan clears
only when exact local owner death and unchanged digest/version are proven. Stale version, duplicate ID,
concurrent loser, replay, unavailable atomic primitive, or unsafe orphan is `GATE FAIL / BLOCK` before
mutation. The lock is coordination, not permission or state.

## Ambiguous-result recovery

Timeout, disconnect, truncated output, or unknown exit after launch means inspect, not blind retry. Read
the remote/target pre/post state and classify
`completed`, `not-started`, `partial`, or `unknown`. Completed never repeats; verified not-started retries
in the same transaction; deterministic partial recovery is agent-owned; a semantic/visible-result fork is
a boundary change; unresolved unknown stays read-only then blocks. Evidence distinguishes absence from unobserved.

## Seven-phase release overview

1. Preflight: physical-root guard, derive current state, explain dirty/unpushed scope.
2. Version: derive versions; update only contracted files; run authoritative gates.
3. CHANGELOG: require the proposed version's user-facing entry.
4. Publish: local preparation, then exact main push, annotated tag, and tag push as separate safe commands
   inside one mandate-bound release transaction.
5. Sync plan: read registry, derive live sync set, capture target pre-state, select explicit scope.
6. Sync execute: named target actions within the Managed Write Surface, migration, verification.
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
- role, mode, handoff scope, accepted mandate, exact binding, or transaction version is absent/inconsistent;
- an action is completed/replayed, CAS is lost, or external outcome remains unknown after read-only diagnosis;
- a required tool/interface is absent or returns wiring/usage failure;
- selected target, registry, managed-surface derivation, merge marker, or pre-state is unreadable;
- proposed paths exceed the selected reference's authority;
- the operation would touch zero-touch project data, full source carriers, or unrelated dirty files.

In `plan` and `verify`, do not heal. In `execute`, remediation must stay inside the accepted outcome,
target, consequence, blast radius, recovery policy, and skill guard; otherwise deny or route a real
boundary change. Tool/exit/retry/rollback failures never become command-approval questions.

## Evidence and completion

Record mandate ID/revision, transaction/action correlation, commands, exact roots/targets/consequences,
stdout/stderr, exit codes, CAS state transitions, avoidable/boundary prompt counts and reasons,
pre/post hashes or refs, and recovery classification. Compare every target to its own pre-state, never to
an assumed clean/source state. A release/sync is complete only when required verification is green and
all partial/unknown states are resolved or explicitly returned to Alex-Lite.
