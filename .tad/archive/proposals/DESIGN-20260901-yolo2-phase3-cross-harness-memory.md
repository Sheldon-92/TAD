# Design — YOLO2 Phase 3 Cross-Harness Progress and Memory

**Status:** Limited core Gate 4 accepted; archived 2026-09-01  
**Epic:** `.tad/archive/epics/EPIC-20260824-yolo2-verified-orchestration.md`  
**Decision:** `.tad/decisions/DR-20260901-yolo2-phase3-native-cli-adapters.md`  
**Release amendment:** `.tad/decisions/DR-20260901-yolo2-phase3-progressive-harness-qualification.md`  
**Phase-2 accepted tuple:** main `38839370403b0fb5eee177c97f6d7e75f9612bc0`,
candidate `3ce202b4b15250f33654828fcf4708a9a285807c`, external attestation
`b2ec8dd7ed6db5b92f12d7d89ecb60ba1ad0630595e2c6d17e59d76c746826b1`

## 1. Design Outcome

Phase 3 adds an opt-in adapter boundary around the accepted YOLO2 state machine so
one local maintainer can stop in one harness and safely continue in another. The
shared memory is deliberately small and semantic:

- frozen goal, success criteria, non-goals, forbidden scope, and handoff revision;
- verified and unverified progress with evidence pointers;
- decisions, rejected alternatives, blockers, pending/unknown side effects;
- legal next action and its rationale.

It does not share full chats, hidden reasoning, native session databases, or byte-
identical tool traces.

Release threshold: the primary Codex profile is live-probed `strict`. Claude Code,
OpenCode, and OpenCode-DeepSeek remain experimental opt-in adapters and are qualified
on first use; their unverified or failed state does not block the Codex-backed core.

## 2. Gate 1 Result

**PASS.** The human confirmed:

- primary user: the repository maintainer using several local coding harnesses;
- problem: progress and memory continuity across harness changes;
- targets: Claude Code, Codex, OpenCode, and DeepSeek;
- boundaries: single writer, no transcript/hidden-reasoning sharing, no default-on,
  no cross-machine/cloud sync, no promise that every target reaches strict;
- DeepSeek is required as a target, but no independent CLI was specified;
- revised release threshold is Codex strict; other profiles stay honestly marked
  experimental/unverified until first-use qualification.

## 3. Architecture Decisions

### D1. Share episodic state, not working memory

`goal.json` and `journal.jsonl` remain authoritative. `checkpoint.json` and
`recovery.md` remain derived. Native sessions are optional execution accelerators.

### D2. One canonical writer requires three isolation zones

Phase 3 separates three real paths:

1. **control root** — `goal.json`, `journal.jsonl`, receipts, and leases; writable
   only by the conductor/reducer and never mounted or exposed to the harness;
2. **product worktree** — the isolated task worktree visible to the harness, with
   writes limited to the lease's exact allowlist;
3. **raw root** — conductor-created `0700` directory outside both repositories;
   stdout/trace/records are created `0600`, no-follow, and unknown to the harness.

The current in-repository run layout remains valid for v1/v2 history. A Phase-3 run
adds an additive control/product split: the reducer runs against the control root
while observing the frozen product worktree. A strict adapter is never launched from
a tree containing its active goal, journal, receipt, lease, or raw evidence paths.
After the process is gone, sanitized carriers may be copied into the repository
evidence bundle and bound by a manifest. The original raw root is never Git-staged.

### D2b. A reducer-issued execution lease precedes every physical invocation

The reducer issues exactly one active lease under the run lock. A lease binds:

- run ID, round ID, journal sequence and journal-prefix/semantic-state digest;
- packet, slice-contract, profile-tuple, capability-probe, and budget-approval hashes;
- turn kind/role, conductor-minted invocation nonce, allowed paths/effect manifest;
- expected prior native session (or explicit fresh), action nonce when write-capable;
- issued time and deadline.

Read-only re-entry and write-capable execution use separate leases. A successful
re-entry is appended before the execution lease is issued. Write-capable execution
also records the governed `action_started`/pending state before the harness starts.
Any state drift, second lease request, deadline, crash, or timeout blocks another
invocation until the first lease is explicitly closed or reconciled with stable
worktree/process evidence. Expiration never auto-authorizes a replacement lease.
The adapter must echo the conductor nonce from the lease and mint a separate native
invocation ID after spawn; nonce substitution or reuse is rejected before spawn.
Capability probes use the same lifecycle with `turn_kind=probe`: one reducer-issued
probe lease and one budget reservation per physical provider invocation, including
fresh/resume/permission/timeout subprobes.

Before provider spawn, the already-running adapter atomically claims the issued
lease through a conductor-only command under the run lock. Claim changes
`issued → claimed` and binds the conductor nonce, adapter PID, planned process-group
identity, and budget reservation. Provider spawn is illegal before the claim receipt
exists. The identical lease cannot be claimed twice; a losing claimant exits with
zero provider calls and zero product/control mutation. The actual child PID/process
group is appended immediately after spawn and must match the planned identity before
the resulting record can be accepted.

Phase 3 introduces a new v2-only control-root resolver and lease command family. Its
host parent is explicit conductor configuration; init freezes the run-ID → product
worktree mapping and verifies control/product/raw realpaths are pairwise disjoint,
non-symlink roots. The legacy `resolveRunDir`, legacy `--run`, and all commands without
an explicit Phase-3 profile remain unchanged and continue rejecting external roots.

### D3. Runtime identity and model identity are separate

Every profile probe freezes the resolved executable absolute realpath, executable
or package-tree digest, version output hash, restricted argument template, and
profile hash. PATH or byte drift invalidates the probe before invocation. Every
record binds:

```json
{
  "profile_id": "opencode-deepseek",
  "runtime": "opencode",
  "runtime_version": "1.18.25",
  "provider": "deepseek",
  "model": "<explicit model>",
  "model_family": "deepseek"
}
```

No profile may infer provider/model from a friendly label. Strict requires provider
and model identity observed in native metadata. An invalid-model negative probe is
also required to detect silent fallback, but cannot replace native identity evidence.
An unresolved or unobserved model/provider/executable/version is blocked; a runtime
that cannot expose native model identity cannot be strict.

Reviewer independence in Phase 3 means a runner-minted fresh invocation identity and
native session distinct from the executor, bound to the same packet/contract but a
separate read-only lease. It does not require a different account or model family.

### D4. Native resume never bypasses semantic re-entry

For both native resume and fresh-session recovery, the adapter supplies the current
bounded recovery packet and requests a schema-bound recovery assertion. The
assertion is checked against the same frozen oracle before any next action is
authorized. Native history may help performance; it is not trusted.

### D5. Capability claims are live and per profile

Documentation and `--help` output seed probes but do not establish support. Each
profile independently probes start, fresh context, exact-session resume, structured
output, worktree observation, permission enforcement, timeout/cancel, hooks/events,
and reviewer independence.

### D6. Phase-1/2 evidence is immutable compatibility input

The Phase-2 Codex runner and v1 turn records remain readable. Phase 3 adds v2 records
and parsers; it does not rewrite or relabel historical artifacts.

## 4. Target Profiles

| Profile | Runtime | Provider/model | Formal target? | Notes |
|---|---|---|---|---|
| `claude-code` | `claude` | explicit Claude model | yes | native print/resume/schema/permission probe |
| `codex` | `codex` | explicit OpenAI model | yes | generalizes the proven reference-runner behavior |
| `opencode` | `opencode` | explicit non-DeepSeek model | yes | CLI transport; ACP is not required in Phase 3 |
| `opencode-deepseek` | `opencode` | `deepseek/<explicit model>` | yes | separate evidence, budget, and classification from OpenCode profile |

Profiles are versioned data, not user-global configuration. Secrets, account names,
and credential values are forbidden in profile or evidence files.

## 5. Adapter Contract

### 5.1 Commands

```text
node .tad/scripts/yolo-harness-runner.mjs probe
  --profile <id> --profiles <json> --raw-root <host-only-dir>
  --lease <conductor-issued-probe-lease.json>
  --budget-approval <approval.json> --evidence-dir <sanitized-bundle-dir>

node .tad/scripts/yolo-harness-runner.mjs turn
  --profile <id> --profiles <json> --raw-root <host-only-dir>
  --lease <conductor-issued-lease.json> --budget-approval <approval.json>
  --evidence-dir <sanitized-bundle-dir>
  --packet <recovery.md> --prompt <prompt.md>
  --role <executor|reviewer> --turn-kind <reentry|execution|review>
  [--session <native-id>] [--policy <read-only|workspace-write>]
```

The last stdout line is a small machine-readable result. Raw harness output and
traces are files referenced by SHA-256; they are not embedded into the journal.

### 5.2 Turn record

New records use `format: yolo-harness-turn-v2` and bind at least:

- frozen executable realpath/digest, profile/runtime/provider/model identity and
  versions, plus native-observed provider/model evidence;
- profile file hash and latest capability-probe hash;
- lease hash and every conductor-only binding field listed in D2b;
- budget approval hash, reserved invocation number, and pre/post counters;
- packet and prompt hashes;
- role, turn kind, runner-minted invocation ID, native session ID, and independently
  derived `resume_evidence`; an input `--session` value is never evidence by itself;
- requested permission policy and observed enforcement result;
- sanitized invocation argument vector (never environment values);
- exit status, timeout/cancel outcome, duration, and native usage when available;
- host-only raw output/trace locators and hashes, secret-scan result, and sanitized
  repository projection hashes;
- pre/post worktree manifests and exact changed paths;
- parsed structured response plus its schema/version;
- native event summary when available, otherwise an explicit degraded reason;
- process-group termination evidence and a post-exit quiet-period manifest.

The runner passes a minimum allowlisted child environment. Provider credentials are
available only to the native transport through a proven provider-native/OS credential
channel or equivalent isolated parent channel. Agent tool subprocesses must receive
a scrubbed environment, be denied provider secret-file/keychain access, and be denied
arbitrary network egress while the transport retains only its required provider
connection. A profile that cannot prove this split is blocked for strict workspace-
write execution. Credential values never enter argv/profile/record.
Before repository projection, a canary/secret scanner checks stdout, trace, record,
and sanitized invocation. Detection fails closed, deletes the projection candidate,
and prevents strict. Tests include environment echo, trace echo, and Git-staging
secret canaries; secret-file reads and silent non-provider network exfiltration are
also sentinel-tested. Post-run scanning is defense in depth, not isolation proof.

### 5.3 Recovery assertion

The assertion schema carries only the semantics already present in the recovery
packet: goal ID, handoff revision, verified/unverified slice IDs, blockers,
`outcome_unknown`, pending action, decisions/rejected alternatives, legal next
action, owner, and rationale. The harness never receives the scoring oracle.

The existing hard-anchor rule remains 100%. Soft rationale remains at least 90%.
A failure or malformed assertion closes the read-only lease as failed and prevents
an execution lease. The assertion record must bind the current lease sequence/digest;
an assertion from an older packet or journal prefix is rejected.

## 6. Capability Probe and Classification

### 6.1 Probe result

Each target writes `capability.json` with one row per capability:

```text
supported | unsupported | unknown | error | stale
```

Every `supported` row must name a raw evidence carrier and checker result. Help text
alone can only yield `unknown` before a live probe.

### 6.2 Versioned aggregate classification matrix

The classifier uses this exhaustive matrix; no free-form override exists:

| Capability class | Capabilities | supported | unsupported | unknown/error/stale |
|---|---|---|---|---|
| load-bearing | start, fresh context, schema output, permission containment, credential/tool isolation, process-tree termination, worktree observation, semantic re-entry | continue | blocked | blocked |
| strict-only | exact native resume, fresh-session reviewer independence | continue | degraded | blocked |
| observational optional | hooks/native lifecycle events | record only; other observation still required | record only | record only |

After all rows: any blocked wins; otherwise any degraded wins; otherwise strict.
`degraded` due to missing resume may execute through fresh packet re-entry only with
an exact human approval. `degraded` due to missing reviewer may produce shadow
candidates but can never complete a phase or replace Gate review, even with approval.

### 6.3 Strict requirements

`strict` requires all of the following on the frozen profile tuple:

1. start and fresh-context invocation succeed;
2. exact-session resume is demonstrated, not inferred;
3. structured output is parsed and schema-validated;
4. read-only and workspace-write policies are observably enforced;
5. tool subprocesses cannot access provider credentials/secret files or arbitrary
   network egress while the native transport retains only its required provider path;
6. timeout or cancel terminates the complete process group, waits a frozen grace and
   quiet period, and observes no late mutation/event;
7. pre/post worktree state and changed paths are independently observable;
8. reviewer identity is distinct from executor identity/session;
9. semantic re-entry passes before execution.

The classifier is deterministic. It may lower a claim after capability drift but
may never preserve `strict` by falling back to stale evidence.

### 6.4 Resume evidence

Exact resume must be derived from native output/session metadata plus a session-only
nonce planted in the prior turn and absent from the new prompt/packet. “CLI accepted
the resume flag” and copying the requested ID into the record are insufficient.
If native evidence cannot prove continuation, the profile is degraded at best.

### 6.5 Permission and termination sentinel protocol

In a disposable product worktree, probes must demonstrate: read-only write denial;
one allowlisted workspace write; denial for `..`, symlink, absolute outside path,
control root, raw root, journal, goal, receipt, and lease targets; exact pre/post
manifest agreement. Timeout tests spawn a delayed child writer, exercise TERM then
KILL of the process group, wait the frozen quiet period, and require no late file,
event, or output. Failure is blocked, never strict.

### 6.6 Budget gate

Every live probe binds a human-approved JSON carrier to the exact profile tuple. It
contains maximum invocations, per-call and total wall time, total tokens and/or USD
when the runtime exposes them, the fallback enforcement mode when native usage is
unavailable, and zero automatic retries. The runner reserves an invocation under
lock before spawn and refuses before provider contact if the approval is missing,
mismatched, or exhausted. Unknown post-call usage stops all further calls. Budget
fixtures prove missing approval and every exceeded dimension cause zero invocation.

### 6.7 Hooks

Hooks/native lifecycle events are recorded separately from the strict minimum.
Their absence is degraded only when another required observation cannot be obtained.
Worktree manifests and explicit runner records are valid observational fallbacks;
hooks never become progress authority.

## 7. State and Recovery Flow

```text
control root: goal + journal
          │ issue read-only lease under lock
          ▼
packet + binding envelope → adapter assertion in isolated product worktree
          │ close lease + append reentry_verified
          ▼
issue execution lease + action_started/pending under lock
          │
          ▼
bounded native turn → host-only raw root → secret scan/sanitized projection
          │ process group dead + quiet manifest + record validates
          ▼
close/reconcile lease → reducer appends outcome
```

Switching harnesses always follows the same path. There is no “copy native session
to another provider” operation.

## 8. User Contract

- `status` continues to show goal, verified/unverified progress, blockers, pending
  actions, legal next action, owner, and resume command in ordinary language.
- `resume` accepts an explicit profile and reports its classification before launch.
- `stop` records the reason and leaves the run resumable from its last verified
  checkpoint.
- A blocked/degraded-without-approval profile prints the exact missing capability
  and a safe alternative profile; it does not silently select another model.
- Existing v1/Y1–Y4/Y7–Y8 behavior and default routing remain unchanged.

## 9. Files

### Create

```text
.tad/scripts/yolo-harness-runner.mjs
.tad/scripts/yolo-harness-profiles.json
.tad/scripts/yolo-harness-runner.test.mjs
.tad/guides/yolo-multi-harness.md
.tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/**
.tad/evidence/yolo/yolo2-verified-orchestration/phase3/fixtures/**
```

### Modify

```text
.tad/scripts/yolo-recovery.mjs       # additive v2 record validation/integration only
.tad/scripts/yolo-round.test.mjs     # cross-version and strict-rejection integration
NEXT.md                              # verified lifecycle status only
.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md
```

### Protected

- Phase-1 archives and all Phase-2 frozen carriers/attestation;
- `.claude/workflows/**`, `.codex/**`, `.tad/hooks/**`, installer and release files;
- user credential/config stores and native session databases;
- Y1–Y4 and Y7–Y8 authority.

## 10. Acceptance Contract

### AC1 — Four honest profile identities

The aggregate contains exactly the four target profile IDs. DeepSeek resolves to
OpenCode runtime plus an explicit `deepseek/*` model. Missing executable, provider,
model, version, or live evidence cannot classify as supported/strict.

### AC2 — Contract, isolation, identity, and termination fixtures

Fake-CLI fixtures additionally cover stale packet, journal drift after assertion,
two-adapter lease contention, expired lease, late child mutation, PATH/binary
replacement, same-version fake CLI, model fallback, reused reviewer identity,
authority/raw carrier write/delete/symlink attacks, environment/trace secret echo,
secret-file read and silent non-provider egress attempts, identical-lease double
claim, nonce substitution/reuse, unleased live probe, external v2 control-root lifecycle,
legacy external-root rejection, and missing/exhausted budget approval. Every rejected pre-spawn case proves zero
provider invocation and zero extra worktree/authority mutation.

### AC3 — Same semantic recovery across targets

All four profile fixtures receive the same packet hash and produce assertions that
map to the same canonical semantic fields. Platform-only fields are excluded from
the assertion comparison. Full transcript equality is neither tested nor claimed.

### AC4 — Resume and fresh-context proof

For every live profile, probe start, fresh invocation, and exact-session resume.
The record must prove whether native resume occurred. A fresh session mislabeled as
resume is rejected.

### AC5 — Classification is exhaustive and discriminative

Every capability row is tested across supported/unsupported/unknown/error/stale and
must land in the exact matrix result. The resume/reviewer/permission mutations are
also repeated 3/3 as drift controls. No stale prior probe can rescue the claim.

### AC6 — Single-writer and side-effect safety

Adapters cannot reach the control/raw roots. A reducer lease prevents concurrent
physical execution, not merely concurrent journal events. A pending or
`outcome_unknown` action blocks every profile. Stale-packet, post-assertion drift,
lease contention (including two adapters claiming the identical lease), timeout, and
retry controls produce zero unauthorized mutations; the losing claimant proves zero
provider calls.

### AC7 — Compatibility

Frozen v1 turn records validate without conversion and Phase-2 protected bytes do
not change. Recovery/round compatibility runs in the self-contained accepted
candidate worktree at candidate `3ce202b4...`, with the pinned scope verifier using
base `96bbfada...`, main `38839370...`, and external attestation
`b2ec8dd7...`. Shared-root HEAD is explicitly not the Phase-2 acceptance oracle.

### AC8 — Live classification evidence

Each target has a sanitized invocation, host-only raw output/trace hash, capability rows, and
aggregate classification. If a paid/authenticated probe is not authorized or cannot
run, that target is `blocked`, not synthetically passed.

### AC9 — Opt-in only

Without an explicit Phase-3 profile flag, existing YOLO paths behave byte-for-byte
as before at their public boundary. No default config, workflow, hook, or installer
is changed.

### AC10 — Human-readable lifecycle

For strict, degraded, blocked, drifted, timeout, and re-entry-failed cases,
`status/resume/stop` output states what is true, why execution can/cannot continue,
and the safe next command without requiring JSONL inspection.

### AC11 — Release threshold

Gate 3 may PASS when the frozen Codex profile is live-probed `strict`, deterministic
safety/compatibility/scope checks pass, Group 0 reports no NOT_SATISFIED item, and
independent code/test reviews contain no P0/P1. Claude Code, OpenCode, and
OpenCode-DeepSeek may remain explicitly `experimental_unverified`, `degraded`, or
`blocked`; they are qualified independently on first use and do not block the core.

## 11. Verification Strategy

1. Deterministic fake-CLI fixtures run without credentials or network.
2. Compatibility suites run in a disposable local clone detached at the accepted
   candidate, with its local `main` ref explicitly pinned to the accepted main before
   replay and external attestation carriers copied read-only from the accepted bundle.
   Phase-2 carrier hashes and attestation are compared pre/post. Neither shared-root
   HEAD nor a linked worktree's shared refs are acceptance oracles because unrelated
   active Epics intentionally advance them.
3. Live probes use frozen executable/version/profile/model tuples and isolated
   disposable worktrees with harmless fixture files.
4. Paid probes require the bound budget carrier described in §6.6. Phase-2
   `3000000/600000/600000` does not carry.
5. Expert reviewers read raw capability evidence and negative controls, not only the
   aggregate classification.

## 12. Risks and Controls

| Risk | Control |
|---|---|
| model mistaken for harness | split profile/runtime/provider/model identity; DeepSeek is an OpenCode profile |
| stale capability remains strict | probe hash/version binding; drift lowers claim before invocation |
| native history overrides verified state | packet + re-entry assertion required on every resume |
| adapter self-certifies progress | adapters are evidence producers only; reducer is sole writer |
| workspace-write reaches authority | disjoint control/product/raw roots; strict sentinel attacks must fail |
| two old packets execute concurrently | reducer-issued one-active lease before spawn; state digest and nonce binding |
| transcript/secret leakage | no transcript sharing; sanitized argv; no env values; raw carriers stay local |
| permission flags differ semantically | behavioral read/write escape probes, not flag-name comparison |
| timeout leaves a late writer | process-group TERM/KILL/wait plus frozen quiet-period manifest |
| overbuilt universal protocol | native CLI façade only; ACP/SDK replacement deferred |
| repeat of Phase-2 budget escalation | pre-spawn reservation bound to a separate approval; no inherited budget |

## 13. Explicit Non-Goals

- concurrent multi-harness writers or peer swarm;
- cloud/cross-machine sync;
- full transcript, compact-summary, or hidden-reasoning replication;
- byte-identical traces or equal model quality;
- default-on or Phase-4 quality/non-regression claims;
- new MCP service, workflow engine, agent SDK migration, or universal ACP gateway;
- guaranteeing that every target is strict.

## 14. Open Design Issues

None that changes the approved architecture. The Codex-only live probe still needs
an exact model and bounded mandate. Exact models and budgets for Claude Code,
OpenCode, and DeepSeek are deferred until their first real use; absence of those
mandates keeps those adapters experimental/unverified rather than blocking Phase 3.

## 15. Expert Review Audit Trail

Round 1 used three independent reviewers. Their initial verdicts were FAIL because
the draft did not yet prove physical single-writer execution, inaccessible authority
and raw roots, frozen runtime/model identity, complete process-tree termination, or
pre-call budget enforcement.

| Reviewer | Initial severity | Finding | Resolution in revision |
|---|---:|---|---|
| architecture | P0 | run lock guarded journal append but not old-packet/concurrent physical execution | D2/D2b and AC6 add reducer-issued re-entry/execution leases, pending-before-spawn, drift checks, and no automatic reissue |
| architecture | P1 | executable/model/reviewer identity could be asserted rather than observed | D3, §5.2, AC1/AC2 freeze executable bytes/template/profile and require native model/session evidence |
| architecture | P1 | raw carriers and timeout descendants were not isolated strongly enough | D2, §5.2, §6.5 add host-only raw root, process-group termination, quiet-period and late-writer controls |
| evidence/security | P1 | classification, native resume proof, secret handling, permissions, and budgets had incomplete negative controls | §6.1–§6.6 and AC2/AC4/AC5/AC8/AC14 add exhaustive states, nonce-based resume, env/canary scanning, sentinel paths, and pre-spawn reservation |
| evidence/security | P1 | compatibility could accidentally use dirty shared HEAD as oracle | AC7 and §11 pin the accepted Phase-2 candidate/main/attestation tuple |
| code | P0 | a workspace-write harness inside the repository could rewrite journal authority | D2 makes control/product/raw mutually inaccessible and AC2/AC6 require write/delete/symlink attack fixtures |
| code | P1 | v2 record, timeout, and compatibility contracts were underspecified | §5.2, §6.5, AC2, and AC7 now specify the missing bindings and pinned replay path |

Round-2 verdicts are recorded in the matching Alex review evidence files and Gate-2
report; no finding is considered closed solely by this producer-authored table.

Round 2 and focused closure checks returned PASS from all three reviewers with
remaining P0=0 and P1=0. Additional closures introduced atomic identical-lease
claim, per-subcall probe leases, a v2-only external control-root resolver, pinned-
clone compatibility replay, and credential/tool isolation as a load-bearing strict
capability.
