# Gate 2 Architecture Review — Lite Authority Model v2

**Reviewer:** independent architecture/code reviewer (`/root/phase3b_architecture_review`)  
**Review round:** initial, before repair  
**Verdict:** FAIL  
**Counts:** P0=0, P1=4, P2=0

## Findings

### P1-ARCH-1 — Transaction state had no durable pre-launch representation

The draft said the LITE handoff/Progress was the state owner, but the current fixed Progress schema had
no action-state record and Completion appeared only at the end. This left consume-once/recovery state
implicit in chat or prose.

Required repair: add a mandatory `## Execution Transactions` subsection to every LITE handoff, create
the planned skeleton before launch, persist action/transaction state before mutation and after every
reconciliation, and make Completion a summary rather than the first state record.

### P1-ARCH-2 — Lite loading rules contradicted release-runbook composition

The Lite rules broadly prohibited skill references while the progressive release skill requires its
operation references. A combined publish+sync operation could not be implemented without violating one
of the two contracts.

Required repair: define one narrow exception shared by Alex-Lite, Blake-Lite, and `CLAUDE.md`: release
entry plus the selected named reference; combined publish+sync may load entry + publish + sync
sequentially, with a hard three-document maximum and no unrelated references.

### P1-ARCH-3 — Dirty-tree zero-touch proof ignored untracked state

AC10 relied on `git diff`, which cannot see untracked files. The repository already contains
`.claude/settings.local.json.bak-20260806-082549`, demonstrating the blind spot.

Required repair: freeze a shared immutable zero-touch manifest as the first implementation step;
capture pre/post tracked and untracked state; compare both; attribute concurrent deltas rather than
rebaseline; add clean, tracked-mutation, and untracked-mutation scratch controls.

### P1-ARCH-4 — Replay/concurrent-resume negatives were incomplete

The fixture set did not prove that completed actions cannot repeat, duplicate transaction/action IDs
are invalid, or a stale/concurrent executor cannot launch.

Required repair: add completed-do-not-repeat, duplicate-ID, CAS loser, and post-precheck-drift cases plus
an adversarial replay mutation.

## Repair Mapping

| Finding | Repaired in |
|---|---|
| P1-ARCH-1 | design contract §4; handoff §3.2, `## Execution Transactions`, P2/P3/P4, AC2/AC4 |
| P1-ARCH-2 | design contract §6; handoff P2/P5, AC5 |
| P1-ARCH-3 | handoff P7, §5.2, AC10, Required Evidence Manifest |
| P1-ARCH-4 | design contract §7; handoff §6, AC7 |

## Incremental Re-review

### Round 2

**Verdict:** FAIL  
**Counts:** P0=0, P1=2, P2=0

- Durable state was still OPEN: the handoff carrier existed, but “exclusive write ownership” had no
  fixed lock path, atomic primitive/replacement, cleanup, crash/orphan behavior, or fail-closed fallback.
- Release reference boundary was CLOSED.
- Zero-touch proof was still OPEN: `git ls-files --others --exclude-standard` hid ignored protected
  files; registered targets had physical-root rows but no target-rooted capture.
- Replay/concurrent fixture coverage was CLOSED.

Round-2 repairs now define the literal adjacent `.txn-lock`, atomic `mkdir`, owner fingerprint,
digest/version compare, same-directory atomic rename, owner-token cleanup, proof-gated orphan recovery,
and fail-closed fallback in design contract §4 and handoff §3.2/P3. Zero-touch capture now unions
untracked and ignored Git sets with content identity and adds explicit `git -C <target>` target snapshots,
ignored-file/target mutation controls, and two stale-lock fixtures.

### Round 3

**Verdict:** FAIL  
**Counts:** P0=0, P1=1, P2=0

- CAS and stale-lock handling were CLOSED.
- Ignored-file and registered-target capture were CLOSED.
- One P1 remained: source zero-touch evidence captured worktree files but not the Git index/cached blob.
  A partially staged protected file could therefore change the index while restored worktree bytes kept
  the filesystem hash unchanged.

Round-3 repair adds `zero-touch-{pre,post}-index.txt`, requires `git diff --cached --raw` plus
`git ls-files --stage` mode/blob identity under the immutable pathspec array, compares pre/post index
state, and adds a staged-blob/worktree-restored mutation probe.

### Round 4

**Reviewer model:** harness=codex, model=gpt-5.6-sol, route=native  
**Final verdict:** PASS  
**Counts:** P0=0, P1=0, P2=0

The reviewer confirmed the cached/index P1 CLOSED: the separate pre/post index evidence uses staged
mode/blob identity under the immutable pathspec set; the partially-staged/worktree-restored probe
isolates that state plane; AC7/AC10 and the evidence manifest agree. CAS, release reference loading,
ignored paths, registered targets, and replay/concurrency remained closed. No material regression from
the final increment was supported.
