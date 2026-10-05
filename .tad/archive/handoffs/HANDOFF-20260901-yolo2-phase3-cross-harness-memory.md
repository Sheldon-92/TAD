---
task_id: TASK-20260901-YOLO2-P3-CROSS-HARNESS
task_type: code
e2e_required: yes
research_required: no
git_tracked_dirs:
  - .tad/scripts
  - .tad/guides
skip_knowledge_assessment: no
gate4_delta: []
status: gate2_pass_execution_pending
execution_authorized: yes
execution_mode: manual_blake
provider_calls_authorized: no
---

# Handoff — YOLO2 Phase 3 Cross-Harness Progress and Memory

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-09-01  
**Epic:** `.tad/archive/epics/EPIC-20260824-yolo2-verified-orchestration.md` (Phase 3/4)  
**Design:** `.tad/archive/proposals/DESIGN-20260901-yolo2-phase3-cross-harness-memory.md`  
**Decision:** `.tad/decisions/DR-20260901-yolo2-phase3-native-cli-adapters.md`  
**Handoff Version:** 0.3.0 — Gate 2 reviewed

---

## 🔴 Gate 2: Design Completeness

**Status:** PASS. Three independent expert reviews PASS with P0=0/P1=0; MQ1–MQ6,
architecture, components, function grounding, data flow, and AC dry-run are complete.
Human selected manual Blake execution (option 1) on 2026-09-01. Local deterministic
implementation and tests are authorized. That choice does not authorize provider
calls: paid/live probes stay blocked until a later exact Phase-3 model/profile and
budget mandate is signed.

**Human amendment P3-R1 (2026-09-01):** Codex `strict` is sufficient for Phase-3
core acceptance. Claude Code, OpenCode, and OpenCode-DeepSeek are experimental and
qualified lazily on first use; their failure does not block or revoke the Codex path.
This amendment is authoritative where the older all-four release language conflicts.
See `DR-20260901-yolo2-phase3-progressive-harness-qualification.md`.

| Item | Status | Note |
|---|---|---|
| Expert review | PASS | architecture, evidence/security, and code reviews PASS |
| All P0 resolved | PASS | round-1 P0=2 resolved; final P0=0/P1=0 |
| Architecture | PASS | native CLI adapters, semantic authority, three-root isolation, atomic leases |
| Components | PASS | profiles, runner, reducer v2 integration, fixtures, evidence, guide specified |
| Functions | PASS | nine existing anchors verified; all new functions marked CREATE |
| Data flow | PASS | authority, projections, native session references, leases, and raw evidence mapped |
| AC dry-run | PASS | advisory linter 0 warnings; 12/12 round baseline; isolated pinned verifier PASS |

## 📋 Handoff Checklist

Before implementation Blake must confirm:

- [ ] read this handoff, the design, DR, and required knowledge files;
- [ ] understand that progress authority is the run journal, not any native chat;
- [ ] understand DeepSeek is an OpenCode runtime profile unless a different executable is proven;
- [ ] preserve every Phase-1/2 frozen artifact and existing default path;
- [ ] possess a human-approved execution mode before implementation;
- [ ] before any provider contact, possess the separate exact profile/model and
  live-probe budget mandate;
- [ ] stop rather than invent support for an unknown capability.

## 1. Task Overview

### 1.1 What We Are Building

Add an opt-in native-CLI adapter layer for four target identities:
`claude-code`, `codex`, `opencode`, and `opencode-deepseek`. All consume the same
bounded recovery packet and emit a common evidence record. The existing YOLO reducer
remains the single writer of verified progress.

### 1.2 Why

The maintainer should be able to stop work in one coding harness and continue in
another without re-explaining the goal, losing verified progress, retrying an unknown
side effect, or trusting a stale chat summary.

Success means the frozen Codex profile reaches live `strict` and every permitted
Codex resume passes the same semantic re-entry check before execution. Other profiles
remain honestly experimental/unverified until independently qualified on first use.

### 1.3 Intent Statement

The product is shared **progress semantics and recovery memory**, not a universal chat
database or a common model runtime.

Not in this task:

- no full transcript or hidden-reasoning sharing;
- no peer swarm or concurrent writers;
- no cloud/cross-machine state service;
- no default-on or Phase-4 quality claim;
- no requirement that all four profiles become strict;
- no reuse of the Phase-2 `3000000/600000/600000` budget or degradation approval.

## 📚 Project Knowledge

### Required reads

| File | Why |
|---|---|
| `.tad/project-knowledge/principles.md` | real behavior outranks validation artifacts; preserve role/Gate authority |
| `.tad/project-knowledge/patterns/memory-and-learning.md` | four memory layers, durable re-entry rules, authority vs summaries |
| `.tad/project-knowledge/patterns/handoff-design.md` | minimum cross-cutting slice, capability claims need live probes |
| `.tad/project-knowledge/patterns/ac-verification.md` | runnable ACs and discriminative red controls |

### Blake must remember

1. **A Recovery Capsule Must Carry the Run's Decision Rules, Not Just Its Facts**
   (`memory-and-learning.md`) — every profile receives verification rules,
   prohibitions, and next-action rationale, not a facts-only summary.
2. **Two-Layer Compact Recovery Pattern** (`memory-and-learning.md`) — native session
   persistence is not sufficient; the persistent run state remains independently
   readable.
3. **Platform Capability Assumptions Decay Fast** (`handoff-design.md`) — docs and
   `--help` seed a probe but never establish current support.
4. **Alex Handoff AC Design Rules / AC Verification Drift** (`ac-verification.md`) —
   every classifier claim needs a negative case; command syntax must be dry-run.
5. **YOLO Epic Execution: Cross-Model Audit Findings** (`principles.md`) — a green
   protocol artifact is not evidence of useful recovery; live behavior is mandatory.
6. **Native Tool Boundary Requires Raw-Event Enforcement** (`security.md`) — native
   policy claims must be checked against raw events and independent filesystem
   observation, not only agent prose.

Stale-knowledge output contains unrelated frontend/release advisories. The matching
YOLO entries above were re-read against the current scripts; none blocks this task.

## 2. Background Context

### 2.1 Accepted base

Phase 2 is Gate-4 accepted at:

```text
main:        38839370403b0fb5eee177c97f6d7e75f9612bc0
candidate:   3ce202b4b15250f33654828fcf4708a9a285807c
attestation: b2ec8dd7ed6db5b92f12d7d89ecb60ba1ad0630595e2c6d17e59d76c746826b1
```

These values and their frozen carriers are compatibility inputs, not files to update.

### 2.2 Existing assets

- `yolo-recovery.mjs`: immutable goal, journal reducer, run lock, status/resume/stop,
  re-entry and round validation.
- `yolo-reference-runner.mjs`: Codex-only native JSONL/session/worktree evidence.
- `yolo-recovery.test.mjs`: accepted recovery and scope-proof suite.
- `yolo-round.test.mjs`: accepted bounded-round and native-record suite.

### 2.3 Local targets at design time

| Target | Observed |
|---|---|
| Claude Code | 2.1.239 |
| Codex | 0.151.0 |
| OpenCode | 1.18.25 |
| DeepSeek | no standalone CLI; OpenCode provider credential presence and `deepseek/*` model enumeration |

Versions are observations only. Implementation must record the versions actually
probed and classify drift honestly.

## 3. Requirements

### 3.1 Functional

- **FR1 Profiles:** versioned profiles separate runtime, provider, model, model family,
  executable, and invocation template.
- **FR2 Probe:** each profile probes start, fresh context, exact-session resume,
  structured output, permission enforcement, timeout/cancel, worktree observation,
  hooks/events, and reviewer independence.
- **FR3 Records:** every turn emits a hash-bound `yolo-harness-turn-v2` record. Raw
  carriers first land in a conductor-only non-repository root; only secret-scanned,
  sanitized projections enter repository evidence.
- **FR4 Re-entry:** all resume paths inject the current packet and require the same
  schema-bound assertion before execution.
- **FR5 Classification:** deterministic `strict | degraded | blocked`; unknown/error
  load-bearing capabilities cannot become supported.
- **FR6 Isolation:** active authority, product worktree, and host-only raw evidence are
  separate roots. The harness cannot reach goal/journal/receipts/leases/raw carriers.
- **FR7 Lease:** reducer issues one journal-sequence/state-digest-bound lease before
  every native invocation, including every live-probe subcall; physical execution
  cannot race on an old packet.
- **FR7a Claim:** the adapter atomically claims `issued → claimed` under the run lock
  before provider spawn; an identical lease replay loses with zero provider calls.
- **FR8 Safety:** write execution records pending action before spawn; pending/unknown
  side effects block every target and are never retried.
- **FR9 Compatibility:** v1 records and Phase-1/2 suites remain valid without conversion.
- **FR10 UX:** status/resume/stop explain profile classification, blocker, consequence,
  and safe next action in ordinary language.
- **FR11 Budget:** every provider call consumes a human-approved, tuple-bound budget
  reservation before spawn; missing/mismatched/exhausted approval means zero call.
- **FR12 Opt-in:** existing public behavior is unchanged without an explicit profile.

### 3.2 Non-functional

- Node built-ins only; no new package or lockfile.
- raw evidence stays only in a conductor-created host directory outside every Git
  repository; only secret-scanned sanitized projections enter the explicit Phase-3
  evidence directory.
- control/product/raw roots are mutually outside one another by realpath; all creation
  is no-follow with restrictive permissions; invocation arguments and child env are
  allowlisted and sanitized.
- all subprocesses run in a managed process group with TERM/KILL, wait, and a frozen
  post-exit quiet period; no automatic retry.
- live probes run only in disposable worktrees against harmless fixtures.
- a capability record binds executable/version/profile/model and expires on drift.

### 3.3 Conflict matrix

| Requirements | Potential conflict | Resolution |
|---|---|---|
| preserve v1 bytes × add v2 adapters | rewriting the Codex runner would invalidate evidence | create additive runner; only add v2 validation to reducer |
| experimental adapters × paid probe authority absent | synthetic support temptation | mark unqualified adapters experimental/unverified; do not block Codex core |
| native resume × cross-harness equality | session history cannot transfer | compare semantic assertion, never session bytes |
| permission proof × platform flag differences | flag-name parity is false evidence | behaviorally probe read/write escape and filesystem delta |
| Codex core release × future adapter parity | optional adapters become critical path | qualify Codex now; qualify each other adapter lazily and independently |
| reducer lock × physical side effects | append lock alone acts too late | issue one active execution lease before spawn; stale/contending turns never launch |
| product writes × authority integrity | same-repo harness can rewrite journal | control, product, and raw evidence use disjoint inaccessible roots |

All pairs can be satisfied simultaneously.

## 4. Technical Design

The design authority is
`DESIGN-20260901-yolo2-phase3-cross-harness-memory.md`. Blake must implement that
contract without independently redesigning transport or state authority.

### 4.1 Components

1. **Profiles JSON** — declarative non-secret identity and invocation templates,
   including frozen timeout/grace/quiet-period policy.
2. **Harness runner** — executable realpath/digest freezing, profile resolution,
   probe/turn spawning, child-env allowlist, raw carrier capture,
   worktree observation, normalization, and final record.
3. **Reducer integration** — additive v2 record validation plus lease issue/close/
   reconcile commands and a v2-only external control-root resolver; control root and
   product worktree identities are distinct while legacy `resolveRunDir` is unchanged.
4. **Fixture suite** — fake CLIs plus deterministic classifier/security controls.
5. **Live probe driver/evidence** — frozen tuples and final four-profile aggregate.
6. **Guide** — human status/resume/stop usage and classification meanings.

### 4.2 Record authority

```text
native output + filesystem observation
        → adapter record (candidate evidence)
        → reducer validation under run lock
        → journal event (authority)
        → derived checkpoint/recovery/status
```

An adapter record is never self-authenticating progress.

### 4.3 Strict classifier

The versioned matrix is exhaustive:

| Class | Capabilities | unsupported | unknown/error/stale |
|---|---|---|---|
| load-bearing | start, fresh, schema, permission containment, credential/tool isolation, process-tree termination, worktree observation, re-entry | blocked | blocked |
| strict-only | exact native resume, fresh-session reviewer independence | degraded | blocked |
| optional | hooks/events | recorded only | recorded only |

Any blocked wins; else any degraded wins; else strict. Model/provider identity must
be observed in native metadata; an input model string is not proof. Missing reviewer
independence can only produce shadow candidates and can never complete a phase.

### 4.4 Conductor lease envelope

Every invocation requires a reducer-issued lease binding run/round/journal sequence,
journal-prefix and semantic-state digests, packet/contract/profile/probe/budget hashes,
role/kind, allowed effects, expected session, nonce, and deadline. Re-entry and
execution are separate leases. State drift, timeout, second lease, or crash blocks
spawn/reissue until explicit close/reconciliation. Deadline expiry is not automatic
permission to run again.

The conductor mints the lease nonce before the adapter is called; the adapter echoes
it and independently records the post-spawn native invocation ID. Probe subcalls use
`turn_kind=probe` leases and consume one reserved invocation each. Init freezes a
v2 run-ID → product-worktree mapping under an explicit host control parent and rejects
symlinked/overlapping control, product, or raw roots. Legacy `resolveRunDir` and legacy
commands keep their current repository-bounded behavior.

The claim is an atomic conductor-only `issued → claimed` transition binding the
conductor nonce, adapter PID, planned process group, and budget reservation. Provider
spawn happens only after a claim receipt exists. The adapter then records the actual
child PID/process group and the reducer rejects any mismatch. A copied identical lease
therefore cannot authorize two calls.

### 4.5 Resume, permission, identity, and secret proof

- resume requires native session metadata plus a session-only nonce absent from the
  new prompt; copying `--session` into a record is rejected;
- strict executable identity binds resolved realpath, binary/package digest, version
  output, profile hash, and restricted argv template;
- sentinel probes attempt read-only writes and workspace escapes through `..`,
  symlink, absolute path, control/raw roots, journal, receipt, and lease targets;
- timeout probe includes a delayed child writer and proves the process group is dead
  and the worktree is quiet after the grace period;
- child environment is allowlisted; raw output/trace/record must pass secret-canary
  scanning before sanitized repository projection;
- strict also requires behavioral proof that agent tool subprocesses receive no
  provider credential, cannot read provider secret files/keychain material, and have
  no arbitrary network egress. Authentication stays in the native transport through
  a provider-native/OS channel or equivalent isolated parent channel. Post-run
  scanning is defense in depth, not permission to expose credentials.

## 5. Mandatory Questions

### MQ1 — Historical code search

**Yes.** The user asked for the next phase of the existing YOLO Epic. Code graph was
queried first; because the index did not expose the ignored `.tad/scripts/*.mjs`
surface, scoped text search was then used.

Findings: existing reducer/state authority is reusable; Codex runner is platform-
specific; OpenCode/Claude judge invocation is not a recovery adapter.

### MQ2 — Existing function verification

| Function | Existing location | Design use |
|---|---|---|
| `readGoal` | `yolo-recovery.mjs:385` | preserve goal authority |
| `readJournal` | `yolo-recovery.mjs:424` | preserve journal authority |
| `reduceRun` | `yolo-recovery.mjs:464` | preserve single state reducer |
| `semanticCheckpoint` | `yolo-recovery.mjs:1228` | compare canonical state |
| `renderStatus` | `yolo-recovery.mjs:1287` | extend human profile status |
| `renderRecovery` | `yolo-recovery.mjs:1325` | shared recovery packet |
| `withRunLock` | `yolo-recovery.mjs:1430` | sole journal write boundary |
| `cmdResume` | `yolo-recovery.mjs:2336` | profile-aware re-entry bridge |
| `validateNativeTurn` | `yolo-recovery.mjs:2601` | additive v2 dispatch point |
| runner `main` | `yolo-reference-runner.mjs:106` | prior art only; preserve v1 |

All Phase-3 runner/profile/test functions are explicit CREATE work.

### MQ3 — Data flow completeness

| Produced field | Consumer | User-visible? |
|---|---|---|
| profile tuple/hash | probe classifier + reducer | profile label/version |
| raw output/trace hash | test/reviewer/reducer | no; evidence pointer only |
| native session/resume binding | resume validator | yes when resume is degraded/blocked |
| permission observations | strict classifier | consequence summary |
| worktree pre/post manifest | side-effect validator | changed-path summary |
| capability rows | aggregate classifier | strict/degraded/blocked reasons |
| re-entry assertion | oracle checker/reducer | pass/failure reason |

No frontend exists. Human output is CLI text plus final JSON status.

### MQ4 — Visual hierarchy

N/A for graphical UI. CLI state words are fixed and prominent:
`STRICT`, `DEGRADED`, `BLOCKED`, `HONEST_PARTIAL`.

### MQ5 — State synchronization

| State | Authority | Derived/projection | Direction |
|---|---|---|---|
| run progress | control-root `goal.json + journal.jsonl` | checkpoint/recovery/status | one-way derive |
| platform capability | raw probe carriers | capability + aggregate JSON | one-way verify |
| native session | harness-owned storage | session ID in adapter record | reference only |
| active turn | reducer-issued lease event | host-only lease file/adapter binding | one active, explicit close |
| product worktree | isolated Git/filesystem | pre/post/quiet manifest | observation only |
| raw trace | host-only `0700` root | secret-scanned sanitized bundle | one-way projection |

No bidirectional state synchronization is introduced.

### MQ6 — Current technical research

**Yes.** Alex performed current primary-source and installed-runtime research before
choosing the adapter transport. Full notes are in
`.tad/evidence/research/yolo2-phase3/2026-09-01-harness-capability-research.md`.

| Search / observation | Candidate | Benefit | Cost or gap | Adopted |
|---|---|---|---|---|
| Claude Code CLI print/resume/schema/permissions | native Claude CLI profile | installed and exposes relevant controls | capability still requires live behavioral proof | yes |
| Codex CLI exec/resume/JSON/sandbox | native Codex CLI profile | already has Phase-2 reference-runner prior art | preserve v1 and prove v2 additively | yes |
| OpenCode CLI run/session/model | native OpenCode CLI profile | one installed transport covers OpenCode and DeepSeek provider | provider/model identity must be proven separately | yes |
| DeepSeek OpenAI-compatible API | direct API adapter | explicit provider API | replaces harness behavior and duplicates transport | no, Phase 3 |
| Agent Client Protocol | ACP-first common transport | standardized editor/agent boundary | not demonstrated across all four installed targets | no, deferred |
| provider SDK replacement | unified programmatic runtime | potentially uniform records | changes the runtime and permission boundary | no |

Decision: native CLI adapters behind one semantic-state contract. Documentation and
`--help` only seed probes; live evidence determines each profile classification.

## 6. Implementation Steps

### 6.1 Micro-tasks

| # | Target | Operation | Verification |
|---|---|---|---|
| 1 | Phase-3 evidence | capture Phase-2 protected baseline manifest | manifest hashes recompute |
| 2 | profiles JSON | create four explicit non-secret profiles + schema/version | profile fixture mode |
| 3 | runner | implement safe profile resolution and subprocess wrapper | failure/timeout fixtures |
| 4 | runner | add raw carriers, sanitization, manifests, v2 records | record fixture mode |
| 5 | reducer | implement control/product split and single active lease lifecycle | lease race fixtures |
| 6 | runner | implement process-group termination, raw-root isolation, env/secret controls | security fixtures |
| 7 | runner | implement per-profile probes and exhaustive classifier inputs | classifier matrix |
| 8 | reducer | add v2 validation without altering v1 dispatch | pinned compatibility mode |
| 9 | reducer/runner | require re-entry then new execution lease/action pending | semantic/safety modes |
| 10 | guide/status | add profile-aware plain-language commands | usability snapshots |
| 11 | live probes | run exact four frozen profile tuples in disposable worktrees | capability evidence |
| 12 | aggregate | classify all four and check release threshold | aggregate checker |
| 13 | reviews | Group 0, code/security/test reviews, Gate 3 | bound PASS reports |

### 6.2 Required order

1. Capture the Phase-2 protected manifest before product edits.
2. Build fake CLIs, control/product/raw isolation, and profile resolver before any
   paid/live invocation.
3. Implement lease lifecycle and prove stale/contending turns never spawn or mutate.
4. Implement identity, resume, permission, process-tree, secret, and budget controls.
5. Implement the exhaustive classifier and make all negative fixtures pass.
6. Add v2 reducer integration and prove v1 compatibility in the pinned candidate worktree.
7. Add human-facing guide/status.
8. Stop for a Codex-only human mandate if its live-probe budget is not authorized.
9. Run only the frozen Codex profile through the minimum bounded capability probe;
   retries are zero.
10. Record the other profiles as experimental/unverified and evaluate the Codex-strict threshold.
11. Run reviews and Gate 3; stop there for Alex Gate 4.

## 7. File Structure

### 7.1 Create

```text
.tad/scripts/yolo-harness-runner.mjs
.tad/scripts/yolo-harness-profiles.json
.tad/scripts/yolo-harness-runner.test.mjs
.tad/guides/yolo-multi-harness.md
.tad/evidence/yolo/yolo2-verified-orchestration/phase3/**
```

### 7.2 Modify

```text
.tad/scripts/yolo-recovery.mjs
.tad/scripts/yolo-round.test.mjs
.tad/active/epics/EPIC-20260824-yolo2-verified-orchestration.md
NEXT.md
```

Process artifacts may add the matching completion and review reports. No other path
is authorized.

### 7.3 Protected

```text
.tad/evidence/yolo/yolo2-verified-orchestration/phase1/**
.tad/evidence/yolo/yolo2-verified-orchestration/phase2/**
.tad/evidence/reviews/blake/yolo2-phase2/**
.tad/active/handoffs/COMPLETION-20260825-yolo2-phase2-bounded-quality-loop.md
.claude/workflows/**
.codex/**
.tad/hooks/**
tad.sh
package*.json
```

### 7.4 Grounded against

Alex inspected current definitions and interfaces on 2026-09-01:

- `.tad/scripts/yolo-recovery.mjs` header, authority contract, reducer exports,
  status/recovery, resume, native-turn validation, CLI dispatch;
- `.tad/scripts/yolo-reference-runner.mjs` complete invocation/record path;
- `.tad/scripts/phase2-pair-driver.mjs` judge-only OpenCode/Claude path;
- `.tad/scripts/yolo-recovery.test.mjs` and `yolo-round.test.mjs` current suite shape;
- current CLI `--help` and versions for Claude Code, Codex, and OpenCode.

## 8. Testing and Friction

### 8.1 Deterministic fixtures

Required negative cases: executable missing, provider/model unresolved, malformed
JSON/JSONL, wrong schema, non-zero exit, timeout, wrong native session, fake resume,
permission escape, worktree mutation mismatch, raw carrier missing/tampered, profile
drift, version drift, stale capability hash, reviewer/executor identity collision,
journal-write attempt, pending action, and outcome_unknown retry; plus stale packet,
post-assertion journal drift, dual-adapter lease race, deadline/reissue, PATH/binary
replacement, same-version fake CLI, silent model fallback, control/raw root write/
delete/symlink attack, child environment/trace secret echo, late child mutation, and
missing/exhausted budget approval; also nonce substitution/reuse, an unleased probe,
a successful external-v2-control-root lifecycle, and legacy external-root rejection.
Required cases also include an identical-lease double claim, tool environment/secret-
file reads, and silent non-provider network exfiltration.
Pre-spawn rejections prove zero invocation and all
authority/product hashes unchanged.

### 8.2 Live E2E

Each live profile uses a disposable worktree and harmless fixture task. It performs:

1. frozen executable/profile/model identity and start/fresh assertion;
2. exact-session resume assertion;
3. read-only denial and bounded workspace-write observation;
4. process-group timeout/cancel plus late-child quiet-period probe;
5. fresh independent reviewer probe.

If authentication, quota, or a paid-probe mandate is absent, persist the failure and
classify blocked. Do not substitute a fake live PASS.

### 8.3 Friction preflight

| Friction | Required step | Fix path | Substitute | Gate impact |
|---|---|---|---|---|
| DeepSeek is a profile, not CLI | freeze explicit `deepseek/*` model | OpenCode native CLI profile | none that changes identity | unresolved model → blocked |
| paid/authenticated live calls | human-approved Phase-3 mandate | bounded tuple/token/time ceiling | blocked classification | one strict still required |
| platform output drift | raw carrier + strict parser fixture | update only matching profile parser and re-probe | no stale PASS | drift lowers classification |
| permission semantics differ | behavioral escape probes | profile-specific safe flags/config | degraded approval only if consequence accepted | unproven containment → blocked |
| authority exposure | three disjoint realpaths + sentinel attacks | isolate control/product/raw roots | none for strict | exposure blocks strict/execution |
| dirty shared worktree | exact protected/task manifests | isolate implementation worktree | documented external attribution | unexplained delta blocks Gate 3 |
| Layer-2 independence | fresh reviewer session/identity | invoke required reviewers | equivalent independent reviewer | missing evidence blocks Gate 3 |

### 8.4 Proposed live-probe ceiling (not yet authorized)

```text
per profile: <= 50,000 total tokens, <= 15 minutes wall time, 0 automatic retries
             <= 6 provider invocations
all profiles: <= 200,000 total tokens, <= 60 minutes wall time,
              <= 24 provider invocations
```

The implementation mandate must explicitly accept or amend this ceiling, maximum
invocations, cost enforcement mode, and exact profile/model tuples before any paid
call. The runner reserves budget before spawn. Native usage missing after a call
stops all later calls unless the mandate explicitly chose invocation/wall-only mode.
It is unrelated to Phase-2 budgets.

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/alex/yolo2-phase3/code-reviewer.md
  - .tad/evidence/reviews/alex/yolo2-phase3/architecture-reviewer.md
  - .tad/evidence/reviews/alex/yolo2-phase3/evidence-security-reviewer.md
gate_verdicts:
  - .tad/evidence/reviews/gate2/yolo2-phase3.md
  - .tad/evidence/reviews/gate3/yolo2-phase3.md
completion:
  - .tad/active/handoffs/COMPLETION-20260901-yolo2-phase3-cross-harness-memory.md
blake_reviews:
  - .tad/evidence/reviews/blake/yolo2-phase3/spec-compliance.md
  - .tad/evidence/reviews/blake/yolo2-phase3/code-reviewer.md
  - .tad/evidence/reviews/blake/yolo2-phase3/security-auditor.md
  - .tad/evidence/reviews/blake/yolo2-phase3/test-runner.md
perf_evidence:
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/live-probe-budget.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/live-probe-approval.json
fixture_results:
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/fixtures/results.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/fixtures/classification-matrix.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/fixtures/lease-race.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/fixtures/termination-secret-isolation.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/phase2-protected-before.sha256
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/phase2-protected-after.sha256
dogfood:
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/claude-code/capability.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/codex/capability.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/opencode/capability.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/opencode-deepseek/capability.json
  - .tad/evidence/yolo/yolo2-verified-orchestration/phase3/capabilities/aggregate.json
knowledge_updates:
  - .tad/evidence/journal/yolo2-phase3-cross-harness-2026-09-01.md
```

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---|---|---|---|---|
| AC1 | Profiles contain exactly four honest identities | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case profiles` | PASS; DeepSeek runtime=opencode and explicit deepseek model | post-impl |
| AC2 | Adapter isolation, identity, termination, secret, and red fixtures are discriminative | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case fixtures` | every §8.1 negative rejected; pre-spawn cases invoke zero providers and hashes stay fixed; RESULT=PASS | post-impl |
| AC3 | Canonical recovery semantics match across profiles | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case semantic-equivalence` | same packet hash/canonical fields; RESULT=PASS | post-impl |
| AC4 | Fresh and exact-session resume are independently proven | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case resume` | resume flag without native metadata/session nonce rejected; RESULT=PASS | post-impl |
| AC5 | Classification matrix is exhaustive | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case strict-rejection` | every capability × supported/unsupported/unknown/error/stale maps exactly; named drift controls 3/3; RESULT=PASS | post-impl |
| AC6 | Lease, single-writer, authority, and side-effect prohibitions hold before physical execution | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case state-safety` | stale/drift/race/timeout/retry attempts make zero unauthorized mutations; RESULT=PASS | post-impl |
| AC7 | v1 and Phase-2 frozen tuple remain compatible | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case compatibility --candidate 3ce202b4b15250f33654828fcf4708a9a285807c --main 38839370403b0fb5eee177c97f6d7e75f9612bc0 --attestation-sha256 b2ec8dd7ed6db5b92f12d7d89ecb60ba1ad0630595e2c6d17e59d76c746826b1` | disposable local clone detaches candidate and pins its own main ref; v1 suite + 12-case round suite + pinned verifier PASS; protected bytes equal | post-impl |
| AC8 | Codex live profile has a hash-bound classification; other adapters are honestly experimental | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case live-evidence --evidence-dir .tad/evidence/yolo/yolo2-verified-orchestration/phase3` | Codex sanitized capability record recomputes; unqualified profiles are not claimed supported | post-impl |
| AC9 | Existing default path is unchanged | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case opt-in` | no profile flag follows existing behavior; protected paths unchanged | post-impl |
| AC10 | CLI lifecycle is understandable in six failure/success states | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case usability` | strict/degraded/blocked/drift/timeout/re-entry snapshots contain truth, reason, safe next command | post-impl |
| AC11 | Codex core release threshold is met | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case release-threshold --evidence-dir .tad/evidence/yolo/yolo2-verified-orchestration/phase3` | Codex=strict; other profiles may be experimental_unverified/degraded/blocked; RESULT=PASS | post-impl |
| AC12 | Current base functions and suites exist before implementation | pre-impl-verifiable | `rg -n 'export function (readGoal\|readJournal\|reduceRun\|semanticCheckpoint\|renderStatus\|renderRecovery)|function (withRunLock\|cmdResume\|validateNativeTurn)' .tad/scripts/yolo-recovery.mjs` | all nine existing anchors found | PASS at design dry-run |
| AC13 | Change scope is bounded and Phase-2 evidence is byte-stable | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case scope --evidence-dir .tad/evidence/yolo/yolo2-verified-orchestration/phase3` | only §7 paths; before/after protected manifests equal | post-impl |
| AC14 | Budget gate refuses before provider contact | post-impl-verifiable | `node .tad/scripts/yolo-harness-runner.test.mjs --case budget` | missing/mismatch/invocation/time/token/cost exhaustion all show invocation_count=0; RESULT=PASS | post-impl |

### AC Dry-Run Log

- AC1–AC11/AC13/AC14 require implementation artifacts and are marked post-impl. Their
  literal command shapes were parsed by the advisory AC linter before Gate 2.
- AC12 executed on 2026-09-01 and found all nine anchors at lines 385, 424, 464, 1228,
  1287, 1325, 1430, 2336, and 2601 (six exported functions plus three local functions).
- Accepted candidate baseline: `yolo-round.test.mjs` is 12/12 PASS. The default
  recovery aggregate is 10 PASS + scope-proof FAIL solely because linked worktrees
  share the advanced `main=bf6b3812...` ref; no Phase-2 allowlist change is allowed.
- In a disposable local clone detached at candidate `3ce202b4...`, after pinning that
  clone's own `main` ref to `38839370...` and supplying external attestation
  `b2ec8dd7...`, the exact Phase-2 scope verifier returned `RESULT=PASS` / exit 0.

## 9.2 Expert Review Status and Audit Trail

Round 1 used independent architecture, evidence/security, and code reviewers. The
architecture and code reviewers each found one P0: physical invocation was not
leased before side effects, and a same-repository workspace-write harness could
reach authority files. P1 findings covered identity proof, raw evidence isolation,
process-tree termination, exhaustive classification, nonce-based native resume,
secret/env controls, sentinel escapes, budget enforcement, and pinned compatibility.

The revision resolves those findings in design D2/D2b/D3, §5–§7, AC2, AC4–AC8,
AC14, handoff FR3/FR6–FR8/FR11, §4.4–§4.5, and §8.1–§8.4. Round 2 is restricted to
verifying the prior P0 closures and checking that these changed sections integrate
without a new blocking defect. Final reports are written to the three paths in the
Required Evidence Manifest; no P0 may remain open at Gate 2.

Round 2 plus focused closure checks returned PASS from all three reviewers with
remaining P0=0/P1=0. Reports:

- `.tad/evidence/reviews/alex/yolo2-phase3/architecture-reviewer.md`
- `.tad/evidence/reviews/alex/yolo2-phase3/evidence-security-reviewer.md`
- `.tad/evidence/reviews/alex/yolo2-phase3/code-reviewer.md`

## 10. Important Warnings

- Never print or persist credential values, full environment dumps, or unsanitized
  auth-bearing URLs/arguments.
- Never edit Phase-2 evidence to make compatibility pass.
- Never silently replace a requested profile/model or resume a “latest” session when
  an exact ID was required.
- Never use native chat history as a fallback when packet/assertion validation fails.
- Never let adapter output directly mutate verified progress.
- Never launch a harness that can resolve the active control root or host-only raw root.
- Never treat lease expiry as permission to reissue; prove the old process tree dead
  and reconcile its worktree first.
- Never run paid probes without the exact human mandate and ceiling.
- If a new transport (ACP/SDK/standalone DeepSeek CLI) appears, return to Alex; do not
  expand the accepted architecture during implementation.

## 11. Decision Summary

| Decision | Options | Chosen | Why |
|---|---|---|---|
| shared object | transcript / native session / semantic run state | semantic run state | portable, minimal, and already authoritative |
| adapter transport | native CLI / ACP-first / SDK replacement | native CLI | covers the installed four targets without replacing runtimes |
| DeepSeek identity | standalone label / OpenCode profile | OpenCode profile | matches observed executable/provider reality |
| release threshold | all-four upfront / Codex core + lazy adapters / all strict | Codex core + lazy adapters | preserves momentum while keeping claims honest and per-adapter |

## 12. Open Questions for Blake

None. If implementation appears to require a transcript database, concurrent writer,
new dependency, protected-path edit, new transport, or budget increase, stop and return
to Alex rather than redesigning.

**Status:** GATE 2 PASS — manual Blake local implementation authorized; provider calls remain blocked.
