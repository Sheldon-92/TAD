# Lite Authority Model v2 — Runtime and Composition Contract

**Date**: 2026-08-10  
**Status**: GATE 2 APPROVED — implements accepted decision
`.tad/decisions/DR-20260809-lite-authority-model-v2.md`  
**Epic**: `.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md`
Phase 3b  
**Supersedes prospectively**: the per-action approval portions of
`.tad/evidence/designs/full-capability-extraction/skill-composition-contract.md`  
**Historical rule**: the Phase 2 contract and archived evidence remain unchanged.

## 1. Outcome

Lite asks the human to decide understandable outcomes and consequences at contract time. During
execution, the agent owns commands, ordering, diagnosis, verified-not-started retry, deterministic
rollback, and idempotent recovery. The effective authority is:

```text
Lite role boundary ∩ capability-skill constraints ∩ accepted Execution Mandate
```

A skill may narrow or refuse that authority. It cannot expand it, create a second task state, or
manufacture a command-level approval ceremony.

## 2. Execution Mandate

Every new LITE handoff carries one mandate. Alex-Lite drafts it from the already clarified request;
the human does not fill YAML. The normal L3 contract decision accepts the plan and mandate together,
so mandate acceptance is not a separate interaction.

```yaml
execution_mandate:
  mandate_id: "<stable task-scoped id>"
  revision: 1
  authority_mode: contract-mandate
  status: proposed | accepted | superseded | expired
  desired_outcome: "<human-readable result>"
  authorized_consequence_classes: []
  target_scope:
    repositories:
      - id: "<stable id>"
        physical_root: "<exact path>"
        origin: "<exact URL or local-only>"
        refs: []
        pathspecs: []
    projects:
      - id: "<stable id>"
        physical_root: "<exact path>"
        managed_write_surface: []
    environments:
      - id: "<stable id>"
        identity: "<exact account/project/environment>"
  consequence_bindings:
    - consequence_class: "<one listed class>"
      target_ids: []
      bounds: "<exact ref/path/MWS/data/amount boundary>"
  max_blast_radius: "<bounded human-readable limit>"
  explicit_exclusions: []
  recovery_policy:
    not_started: retry_automatically
    partial: rollback_if_verified_else_stop
    unknown: inspect_then_apply_policy
  expires_when: task_complete_or_contract_changed
  acceptance:
    decision: pending | accepted
    decided_at: "<timestamp or empty>"
    source: "L3 contract decision"
```

Rules:

- Empty target lists mean no target of that type, not “all targets.”
- Unlisted consequence classes are not authorized.
- Every authorized consequence class has at least one binding; every binding names only declared
  target IDs and gives the applicable exact ref, pathspec, Managed Write Surface, environment, data,
  or amount bound. Repository effects bind the exact origin/ref/pathspec; sync effects bind the exact
  project and Managed Write Surface; payment effects bind payer/payee/currency/maximum amount; identity
  effects bind the exact account, credential handle, owner, and allowed operation. A class list and a
  target list never imply their Cartesian product.
- An accepted mandate is valid only when `status=accepted`, `acceptance.decision=accepted`,
  `decided_at` is non-empty, `source=L3 contract decision`, `revision` is positive, and all required
  outcome/class/target/binding/blast-radius/recovery fields are internally consistent. Any mismatch is
  INVALID and returns to Alex-Lite before mutation; a spoken ad-hoc approval cannot waive it.
- A material change to outcome, targets, consequence classes, blast radius, exclusions, or recovery
  outcomes supersedes the mandate and returns to Alex-Lite for a reviewed contract amendment.
- Typo-only edits and additional technical evidence do not supersede the mandate.
- Compaction, terminal change, command failure, and verified-not-started retry do not expire it.
- Read-only diagnosis is allowed only when it stays inside the role/skill data-access boundary. It
  never becomes implied mutation authority.

### 2.1 Consequence-class vocabulary

Use the smallest task-relevant set. Names describe user-visible effects, not commands.

| Class | Meaning |
|---|---|
| `workspace_write` | Change the handoff-listed files in the current workspace |
| `local_commit` | Create a local commit containing only the contracted paths |
| `remote_branch_update` | Update an exact remote branch/ref within target scope |
| `annotated_tag` | Create the contracted annotated release tag locally |
| `remote_tag_update` | Publish the exact contracted tag ref |
| `framework_sync` | Write the managed TAD surface to named registered targets |
| `source_registry_update` | Update the source sync registry for verified targets |
| `downstream_commit` | Commit the managed surface in a named downstream repository |
| `downstream_push` | Push an exact downstream commit/ref |
| `dependency_lockfile_change` | Change declared dependency pins or lockfiles |
| `global_instruction_change` | Change hooks/settings/instructions with session-wide effect |
| `production_deploy` | Change a named production environment |
| `payment` | Create a financial charge or transfer |
| `identity_or_credential_change` | Create, rotate, grant, or revoke identity/credential authority |
| `destructive_data_change` | Delete or irreversibly transform bounded data |
| `history_rewrite` | Rewrite or delete published version-control history |

The vocabulary is not an allow-list that grants these effects. High-consequence classes require
precise targets, blast-radius bounds, exclusions, and recovery outcomes in the mandate.

## 3. Decision Ownership and Runtime Classifier

| Condition | Owner | Runtime result |
|---|---|---|
| Valid action within role, skill, accepted mandate, target, and blast radius | Agent | Execute, verify, and record evidence without asking |
| Command/tool/wiring/exit-code failure within the same outcome | Agent | Diagnose, repair, retry, or block technically; no human decision prompt |
| Verified `not_started` action | Agent | Retry automatically under the same transaction and mandate |
| Deterministic rollback with one user-visible result | Agent | Roll back, verify, and record evidence |
| Outcome, target, consequence class, or blast radius would change | Human | `boundary_change`; describe outcome/impact, then return amendment to Alex-Lite |
| New business/legal/financial/identity trade-off | Human | `boundary_change`; present consequence choices, not commands |
| Partial state has multiple legitimate, user-visible recovery outcomes | Human | `boundary_change`; present result choices |
| New external identity, credential ownership, or financial authority is needed | Human | `boundary_change`; request the missing human-domain decision/action |
| State remains unknown after read-only diagnosis | Agent | Fail closed and report a technical block; do not guess mutation or ask for command approval |

The only legal runtime prompt reasons are:

```text
outcome_change
target_change
consequence_change
blast_radius_change
business_legal_financial_identity_tradeoff
divergent_visible_recovery
new_external_identity_or_credentials
```

`technical_failure`, `tool_unavailable`, `exit_code`, `wiring_error`, `retry`, `rollback`,
`commit_command`, `push_command`, and `archive_confirmation` are never legal prompt reasons.

## 4. Transaction Semantics

Consume-once semantics apply to a user-meaningful transaction, not each CLI command. A release
transaction may contain branch update, annotated tag, tag publication, framework sync, registry
advancement, and named downstream updates when all are listed in one mandate.

```yaml
transaction:
  transaction_id: "<stable task-scoped id>"
  mandate_id: "<matching mandate>"
  mandate_revision: 1
  lock_path: "<exact handoff path>.txn-lock"
  state_version: 0
  state: planned | launched | completed | not-started | partial | unknown
  targets: []
  consequence_classes: []
  actions:
    - action_id: "<technical correlation id>"
      consequence_class: "<one authorized class>"
      target: "<one in-scope target>"
      pre_state: "<observed hash/ref/manifest>"
      post_state: "<observed hash/ref/manifest or empty>"
      state: pending | launched | completed | not-started | partial | unknown
      evidence_path: "<path>"
```

Every new LITE handoff has one mandatory `## Execution Transactions` subsection. Alex-Lite writes the
planned transaction skeleton there before contract acceptance. Before launch, Blake-Lite fills its
exact action IDs, bindings, observed pre-state, and evidence paths. That subsection—not Completion,
chat memory, a skill, or a sidecar—is the sole durable transaction state; Completion only summarizes
its final records.

The LITE handoff/Progress remains the sole canonical task-state owner. Skills must not create nonce
stores, approval stores, second handoffs, or permission services. Every transaction uses this concrete
ephemeral CAS protocol:

1. The fixed lock is the literal adjacent path `<handoff>.txn-lock`, declared in the transaction and
   mandate. Atomic `mkdir` on the local filesystem is the only acquisition primitive. If local atomic
   directory creation or same-directory atomic rename is unavailable, fail closed before mutation.
2. The winner writes an owner record containing a unique owner token, host, PID, process-start
   fingerprint, acquisition time, expected handoff digest, transaction ID, and expected state version.
   Cleanup traps remove the lock only after re-reading and matching that owner token.
3. While holding the lock, re-read the handoff digest, mandate/revision, unique IDs, transaction state,
   and expected version. A mismatch, duplicate/completed action, or stale version loses without task
   mutation.
4. Render the complete updated handoff to a validated temporary file in the handoff's directory,
   re-check the original digest while the lock is held, then replace it with a same-filesystem atomic
   rename. Crash before rename leaves the old version; crash after rename leaves the new version. On
   resume, the persisted version/action state is authoritative and is reconciled before work continues.
5. An existing lock never authorizes force removal. It may be cleared automatically only when the owner
   record is valid, the recorded host is local, PID plus process-start fingerprint prove that exact
   owner is dead, and the handoff digest/version still equal the owner's expected pre-state. Clear it,
   reacquire with atomic `mkdir`, and re-run all comparisons. If any proof is unavailable or disagrees,
   report `GATE FAIL / BLOCK` with no new task mutation and no command-approval prompt.

Every later action-state transition uses the same protocol and is persisted before another task
mutation. The lock and owner record are ephemeral coordination only: they carry no permission, must be
absent at Completion, and never replace the handoff as durable task state.

Before each mutation, the agent re-reads the mandate/revision, matches exactly one consequence binding,
and verifies the target's current state against the action precondition. A changed pre-state is
diagnosed; it is not automatically a human decision and never authorizes force.

Delegation does not create authority. Every worker/reviewer prompt carries `mandate_id`, the smallest
relevant target/consequence/path excerpt, and whether mutation is allowed. Reviewers are read-only;
workers default to no external mutation unless the parent explicitly assigns one in-mandate action.
The parent Lite role remains the state owner and validates every delegated result before advancing the
transaction. A subagent, tool description, or capability skill cannot amend the mandate.

Recovery:

- `completed`: do not repeat; continue verification.
- `not-started`: retry automatically under the same transaction.
- `partial`: apply the mandate's deterministic recovery and verify it. Ask only when distinct
  recovery choices create distinct user-visible outcomes.
- `unknown`: continue read-only reconciliation. If it cannot be classified safely, stop without a
  new mutation and report `GATE FAIL / BLOCK`.

## 5. Interaction Budget and Observability

Normal human interaction has two outcome-level points: the initial L3 contract/mandate decision and
the final business acceptance. Final acceptance authorizes the already-declared archive lifecycle;
there is no separate archive-confirmation prompt. A local commit happens automatically only when
`local_commit` is in the accepted mandate; otherwise the result remains uncommitted without asking a
new technical question.

Every external mutation records:

```text
mandate_id
transaction_id
action_id
target
consequence_class
pre_state
post_state
recovery_state
evidence_path
boundary_change
runtime_prompt_reason
```

Required counters:

- `avoidable_runtime_prompt_count`: must equal `0`.
- `boundary_change_prompt_count`: may be nonzero only with a legal reason from §3.
- Initial mandate acceptance and final business acceptance are reported separately, not hidden in
  either runtime counter.

## 6. Live Surface Disposition

Phase 3b changes the complete live Lite authority surface and nothing else.

Scope boundary: product/domain HITL advice inside a capability pack (for example, GitHub Environment
reviewers, a hardware operator reading an instrument, or an application guardrail against untrusted
input) governs the system being built or supplies genuinely human data. It is not a TAD runtime
approval instruction unless it directs Lite itself to stop and ask the current user before Blake's
technical action. Authority scans must distinguish those two categories.

| Surface | Disposition |
|---|---|
| `.claude/skills/alex-lite/SKILL.md` + exact `.agents` mirror | Add mandate drafting/acceptance; replace safety-stop prompting with consequence-boundary routing |
| `.claude/skills/blake-lite/SKILL.md` + exact `.agents` mirror | Add mandate admission/runtime classifier; remove technical/command approval prompts |
| `release-runbook/SKILL.md` + exact mirror | Replace per-command approval nonce with mandate + transaction semantics |
| `release-runbook/references/publish-ops.md` + exact mirror | One release transaction; automatic verified-not-started recovery |
| `release-runbook/references/sync-ops.md` + exact mirror | Mandate-scoped target writes/registry/downstream actions; no independent gates per command |
| `CLAUDE.md`, `AGENTS.md` | Route interaction decisions by outcome boundary, not blanket SAFETY approval/archive rules |
| `.tad/project-knowledge/patterns/gate-design.md` | Append a current amendment: mandate is the permission carrier; SAFETY classes trigger stronger contract bounds, not automatic runtime prompting or full routing |
| `.tad/config-*.yaml`, full handoff templates, full Gate documents | `FULL_ONLY_RETIRE_LATER`; Lite explicitly does not load them, so do not edit in Phase 3b |
| Phase 2 composition contract, archived handoffs/evidence | `HISTORY_ONLY`; never rewrite |
| hooks, settings, installers, `tad.sh`, release verifier/runtime | `ZERO_TOUCH`; no new runtime or enforcement hook |

Canonical authoring direction is `.claude/skills/**` to `.agents/skills/**`; every changed mirror pair
must be byte-identical.

Lite's ordinary no-reference-loading rule has one bounded capability exception. A release task may load
the release-runbook entry plus exactly the selected named operation reference. Publish-only loads
`publish-ops.md`; sync-only loads `sync-ops.md`; a combined publish+sync transaction loads the entry and
both named references sequentially, for a hard total of three release documents. It may not load any
other release reference, unrelated skill reference, or tool documentation through this exception.
Both Lite roles and `CLAUDE.md` must publish the same rule.

## 7. Required Fixture Matrix

Phase 3b is protocol migration, not live release execution. Fixtures and independent review must
cover every row below; Phase 3c owns the real publish+sync dogfood.

| Fixture | Input | Expected result | Human prompt? |
|---|---|---|---|
| `mandate-happy-release` | All release/sync classes and targets are in one accepted mandate | ALLOW transaction | No |
| `mandate-happy-local` | Workspace write/local commit are declared | ALLOW | No |
| `verified-not-started-retry` | Read-only reconciliation proves no mutation started | RETRY same transaction | No |
| `deterministic-rollback` | One verified recovery result is declared | ROLLBACK_AND_VERIFY | No |
| `resume-same-mandate` | Compaction/terminal change, unchanged contract | RESUME | No |
| `accepted-field-mismatch` | `status=accepted` but acceptance/timestamp/source/binding/revision fields disagree | INVALID before mutation | No |
| `duplicate-mandate-id` | Two non-superseded mandates claim the same stable ID | INVALID before mutation | No |
| `superseded-mandate` | Transaction cites a superseded revision | RETURN_TO_ALEX_LITE | No runtime prompt |
| `expired-mandate` | Mandate lifecycle predicate is already true | RETURN_TO_ALEX_LITE | No runtime prompt |
| `concurrent-transaction-cas` | Two executors attempt the same planned transaction transition | Exactly one launches; loser reconciles | No |
| `stale-lock-proven-dead` | Valid local owner fingerprint proves a crashed owner dead and handoff pre-state unchanged | CLEAR, REACQUIRE, RECONCILE | No |
| `stale-lock-owner-unknown` | Owner liveness/fingerprint or handoff pre-state cannot be proven | BLOCK_NO_MUTATION | No |
| `post-precheck-drift` | Bound target changes after precheck but before launch | RECONCILE_OR_BLOCK; no force | No |
| `completed-do-not-repeat` | Resume sees the action or transaction already completed | VERIFY_ONLY; do not repeat | No |
| `duplicate-transaction-or-action-id` | A handoff repeats a transaction or action ID | INVALID before mutation | No |
| `unlisted-consequence` | Action class absent from mandate | BOUNDARY_CHANGE before mutation | Yes, `consequence_change` |
| `target-scope-change` | Repository/project/environment is absent from its exact binding | BOUNDARY_CHANGE before mutation | Yes, `target_change` |
| `target-alias` | Literal path is in scope but its resolved repository/environment identity differs | DENY before mutation | No |
| `ref-expansion` | Repository is listed but the requested ref/pathspec is not | BOUNDARY_CHANGE before mutation | Yes, `target_change` |
| `mws-expansion` | Project is listed but requested write escapes its Managed Write Surface | BOUNDARY_CHANGE before mutation | Yes, `target_change` |
| `financial-bound-expansion` | Payment changes payer/payee/currency/maximum amount | BOUNDARY_CHANGE before mutation | Yes, `business_legal_financial_identity_tradeoff` |
| `skill-expands-mandate` | Skill declares broader authority than mandate | DENY | No |
| `divergent-partial-recovery` | Two legitimate recoveries have different visible results | BOUNDARY_CHANGE | Yes, `divergent_visible_recovery` |
| `new-credential-owner` | New account, credential, owner, or identity authority is required | BOUNDARY_CHANGE | Yes, `new_external_identity_or_credentials` |
| `tool-failure-no-prompt` | Tool/exit/wiring failure, no boundary change | REPAIR_OR_BLOCK | No |
| `unknown-fail-closed` | Read-only diagnosis cannot classify external result | BLOCK_NO_MUTATION | No |
| `unlisted-local-commit` | Workspace write is authorized but `local_commit` is absent | LEAVE_UNCOMMITTED | No |
| `archive-before-acceptance` | Technical gate passes but final business acceptance is pending | WAIT; do not archive | No runtime prompt |
| `final-business-acceptance` | Technical gate passed | WAITING HUMAN ACCEPTANCE | Yes, business-level; not runtime |
| `archive-after-acceptance` | Human accepts final business result | ARCHIVE | No separate archive prompt |

Acceptance requires `avoidable_runtime_prompt_count=0`, all requested prompts mapped to the closed
reason enum, all negative mutations blocked before launch, and no live external mutation during this
phase.

## 8. Anti-Goals

- No generic authorization runtime, policy engine, hook, wrapper, daemon, or approval database.
- No blanket “irreversible means ask” rule and no per-command `approval_id`/`scope_digest`/nonce.
- No assumption that fewer prompts means broader authority; unknown or out-of-scope mutations remain
  fail-closed.
- No human questions about Bash, Git ref syntax, exit codes, test evidence, deterministic rollback,
  or reviewer repair details.
- No rewriting history to make the old model appear never to have existed.
- No live push, tag, publish, sync, registered-target write, dependency mutation, deploy, payment,
  credential mutation, destructive data operation, or history rewrite in Phase 3b.
