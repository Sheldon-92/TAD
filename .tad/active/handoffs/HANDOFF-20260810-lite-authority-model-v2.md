---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
baseline_commit: c851046dc41b65f89dbe0acfbb51cc198d016c81
---

# Handoff: Lite Authority Model v2

**From:** Alex  
**To:** Blake  
**Date:** 2026-08-10  
**Task ID:** FULL-RETIRE-P3B-LITE-AUTHORITY-V2  
**Priority:** P0  
**Epic:** `.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md`
(Phase 3b/8)  
**Status:** Gate 2 Revision-2 Amendment PASS — Ready for Repair 2
**Execution boundary:** revision 2 permits only §5.5 workspace writes and task-scoped append-only local
commit(s) on the exact repository/ref/path policy after Gate 3; commit count is agent-owned technical
cardinality, not a human authorization field. Push, tag, publish, sync, registered-target writes,
dependency mutation, deploy, payment, credential mutation, destructive data change, and history rewrite
are prohibited.

## 0. Human Decision Already Made

This handoff implements an accepted direction; it does not reopen it as another approval question.

> “这个在最开始澄清需求的时候就该完成而不是等过程中授权，这是虚假授权，我根本判断不了。”

> “不只是这个handoff，而是整个lite体系的设计。”

The human then answered “我同意” and asked to continue. The accepted decision is recorded in
`.tad/decisions/DR-20260809-lite-authority-model-v2.md`.

### Socratic Inquiry Summary (recovered from the completed conversation)

| Dimension | Result |
|---|---|
| User / scenario | The TAD owner using Lite for real work, especially high-consequence release/dependency/global-surface tasks |
| Problem | Design-time outcome is already clear, but runtime asks the human to judge Bash/Git/tool details the human cannot meaningfully assess |
| Positive scope | The complete live Lite authority layer: Alex-Lite, Blake-Lite, capability composition, release-runbook, cross-platform routing, and authoritative Lite gate knowledge |
| Exclusions | No cleanup of full-only configs/templates; no history rewrite; no live release dogfood; no new runtime/hook/permission service |
| Human risk | “Fake authorization” produces rubber-stamping and transfers technical responsibility to the human |
| Alex risk | Removing prompts could be misread as broad autonomy; the replacement must remain target/consequence bounded and fail closed on real boundary changes |
| Success | Mandate-internal execution/recovery has zero avoidable prompts; only a new outcome/target/consequence/human-domain trade-off returns to the human |

## 1. Objective

Replace command-level and safety-class-level human approval in the entire live Lite path with an
accepted outcome-level Execution Mandate. Preserve strict role boundaries, target/consequence bounds,
independent review, technical gates, idempotency, recovery evidence, and fail-closed behavior.

After this phase:

- Alex-Lite drafts one human-readable mandate as part of the ordinary design contract.
- The human accepts the plan and mandate together once; no separate authorization ceremony exists.
- Blake-Lite executes and recovers within `Lite ∩ Skill ∩ Mandate` without technical approval prompts.
- A real boundary change is presented as an outcome/impact choice and returns through Alex-Lite for a
  reviewed mandate amendment.
- Final business acceptance remains human; archive follows that acceptance without a second archive
  prompt.
- Phase 3c can perform the first real Lite-only release dogfood.

## 2. Design Authority

Blake must read these before editing:

1. `.tad/decisions/DR-20260809-lite-authority-model-v2.md`
2. `.tad/evidence/designs/full-capability-extraction/authority-model-v2-contract.md`
3. `.tad/project-knowledge/principles.md` — AI/Human Judgment Domain Awareness
4. `.tad/project-knowledge/patterns/gate-design.md`
5. `.tad/project-knowledge/patterns/handoff-design.md`
6. `.tad/project-knowledge/patterns/ac-verification.md`
7. `.agents/skills/ai-agent-architecture/SKILL.md` and its D1–D10 references cited by the design

The Phase 2 composition contract is historical input only. When it conflicts on per-action approval,
the accepted DR and the Phase 3b design contract win.

## 3. Architecture Contract

### 3.1 Effective authority

```text
Lite role boundary ∩ capability-skill constraints ∩ accepted Execution Mandate
```

No fourth runtime “current human approval” token exists. A skill narrows or refuses; it never expands.

### 3.2 State ownership

The current LITE handoff/Progress is the only canonical task state. Skills must not create an approval
store, nonce directory, second handoff, permission database, hook, wrapper, daemon, or runtime service.
Every LITE handoff contains a mandatory `## Execution Transactions` subsection. Alex-Lite writes the
planned skeleton before acceptance; Blake-Lite persists action IDs, exact bindings, pre/post state,
evidence, `mandate_revision`, and monotonic `state_version` there before launch and after every
reconciliation. Completion summarizes this state but never becomes its first or canonical record.

### 3.3 Human/agent ownership

Human owns desired outcome, exact target repositories/projects/environments and writable surfaces,
authorized consequence classes, external reach, bounded ref/path/MWS/data/amount/identity impact,
exclusions, visible recovery preferences, business/legal/financial/identity trade-offs, and final
business acceptance.

Agent owns commands, parameters, order, pre/post checks, tool/exit/wiring diagnosis,
verified-not-started retry, deterministic rollback, idempotent recovery, reviewer repairs inside the
contract, local commit/retry/reviewer/evidence cardinality inside the exact boundary, and technical Gate
truth.

### 3.4 Legal runtime re-decision reasons

The closed enum is:

```text
outcome_change
target_change
consequence_change
blast_radius_change
business_legal_financial_identity_tradeoff
divergent_visible_recovery
new_external_identity_or_credentials
```

Technical failure, tool unavailability, exit codes, wiring errors, retry, rollback, commit/push command
selection, local commit count, reviewer/evidence count, and archive confirmation are not legal prompt
reasons. A `blast_radius_change` means a change to exact target/surface, external reach, bounded
ref/path/MWS/data/amount/identity impact, or visible recovery—not a change in technical work count.

### 3.5 Transaction model

Consume-once identity applies to one user-meaningful transaction, not each CLI command. A release
transaction can contain branch update, annotated tag, tag publication, sync, registry advancement, and
named downstream updates when the accepted mandate contains every consequence and target.

States are `planned | launched | completed | not-started | partial | unknown`. `not-started` retries
automatically; `completed` never repeats; deterministic `partial` recovery is automatic; `unknown`
continues read-only diagnosis and then blocks without mutation if it cannot be proven safe. Only
distinct user-visible recovery outcomes cause a human decision.

Before first task mutation, Blake-Lite acquires exclusive write ownership of the LITE handoff and
compare-and-swaps the exact `planned/state_version=N` record to `launched/N+1`. All later transitions use
the same held re-read/write discipline. A stale version, changed file identity, duplicate ID, or already
completed action loses the launch race and must reconcile without mutation. The ephemeral lock is not
permission and cannot retain task state.

The operation is concrete, not an abstract claim: the fixed lock is literal `<handoff>.txn-lock` and is
acquired only by atomic `mkdir`; its owner record contains unique token, host, PID, process-start
fingerprint, acquisition time, expected handoff digest, transaction ID, and state version. While holding
it, re-read all admission fields; render a validated full handoff to a same-directory temporary file;
re-check the original digest; replace by same-filesystem atomic rename; remove the lock only when the
owner token still matches. A crash before rename leaves the old version and after rename leaves the new
version. An orphan lock may be cleared only when local host + PID + process-start fingerprint prove the
exact owner dead and the handoff digest/version still match its expected pre-state; otherwise
`GATE FAIL / BLOCK` with no mutation or approval prompt. If atomic `mkdir` or same-directory atomic rename
is unavailable, fail closed. The full five-step normative procedure is design contract §4.

## Execution Mandate

```yaml
execution_mandate:
  mandate_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-mandate
  revision: 2
  authority_mode: contract-mandate
  status: accepted
  desired_outcome: "Replace fake command-level Lite authorization with one outcome-level mandate while preserving bounded, fail-closed execution."
  authorized_consequence_classes:
    - workspace_write
    - local_commit
  target_scope:
    repositories:
      - id: tad-source
        physical_root: "/Users/sheldonzhao/01-on progress programs/TAD"
        origin: "https://github.com/Sheldon-92/TAD.git"
        refs:
          - refs/heads/main
        pathspecs:
          - AGENTS.md
          - CLAUDE.md
          - .claude/skills/alex-lite/SKILL.md
          - .agents/skills/alex-lite/SKILL.md
          - .claude/skills/blake-lite/SKILL.md
          - .agents/skills/blake-lite/SKILL.md
          - .claude/skills/release-runbook/SKILL.md
          - .agents/skills/release-runbook/SKILL.md
          - .claude/skills/release-runbook/references/publish-ops.md
          - .agents/skills/release-runbook/references/publish-ops.md
          - .claude/skills/release-runbook/references/sync-ops.md
          - .agents/skills/release-runbook/references/sync-ops.md
          - .tad/project-knowledge/patterns/gate-design.md
          - .tad/evidence/audits/lite-constraint-ledger.md
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/live-surface-inventory.tsv
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/authority-fixtures.jsonl
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/verification-results.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-paths.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-tracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-untracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-index.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-tracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-untracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-index.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-targets.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-targets.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-controls.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-tracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-untracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-index.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-targets.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-tracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-untracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-index.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-targets.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-controls.txt
          - .tad/evidence/reviews/blake/lite-authority-model-v2/spec-compliance-reviewer.md
          - .tad/evidence/reviews/blake/lite-authority-model-v2/implementation-reviewer.md
          - .tad/evidence/reviews/blake/lite-authority-model-v2/security-reviewer.md
          - .tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md
          - .tad/active/handoffs/COMPLETION-20260810-lite-authority-model-v2.md
          - .tad/decisions/DR-20260809-lite-authority-model-v2.md
          - .tad/evidence/designs/full-capability-extraction/authority-model-v2-contract.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/architecture-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/security-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate2-verdict.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-acceptance.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-code-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-performance-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-security-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-acceptance.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-code-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-performance-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-security-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-repair2-architecture-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-repair2-security-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate2-amendment-verdict.md
          - .tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md
          - .tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md.txn-lock
          - .tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md
    projects: []
    environments: []
  consequence_bindings:
    - consequence_class: workspace_write
      target_ids: [tad-source]
      bounds: "For repair 2, Blake may modify/create only the §5.5 live/evidence/Blake-review paths through gate3-verdict.md plus Completion; in this handoff only Execution Transactions and final evidence references. DR, design contract, Alex reviews, and other handoff text are immutable design inputs. The adjacent .txn-lock is ephemeral CAS coordination and must be absent at Completion. Preserve unrelated dirty-worktree state."
    - consequence_class: local_commit
      target_ids: [tad-source]
      bounds: "Append-only task-scoped local commit(s) on refs/heads/main containing only §5.5 exact paths. Closed purposes: Gate-3-passing repair delivery, recorded Gate-4/reviewer-directed repair, factual evidence reconciliation, deterministic recovery. Explicit pathspec only; no git add -A, amend, rebase, reset, squash, deletion, or history rewrite. Stop at Gate 4 PASS, mandate supersession/expiry, or technical block."
      local_history_policy:
        mode: append_only_task_scoped
        authorized_purposes: [gate3_passing_delivery, recorded_gate_or_reviewer_repair, factual_evidence_reconciliation, deterministic_recovery]
        staging: explicit_pathspec_only
        history_rewrite: prohibited
        external_reach: none
        terminates_when: gate4_pass_or_mandate_superseded_expired_or_blocked
  max_blast_radius: "One exact TAD source workspace and refs/heads/main append-only local task history over §5.5 paths; external_reach=none; no downstream, registry, dependency, deployment, payment, credential, destructive-data, or history-rewrite effect."
  explicit_exclusions:
    - "All §5.4 zero-touch paths and unrelated dirty-worktree state"
    - "Push, tag, publish, sync, downstream write, dependency mutation, deploy, payment, credential mutation, destructive data change, and history rewrite"
  recovery_policy:
    not_started: retry_automatically
    partial: rollback_if_verified_else_stop
    unknown: inspect_then_apply_policy
  expires_when: task_complete_or_contract_changed
  acceptance:
    decision: accepted
    decided_at: "2026-08-10T17:04:37Z"
    source: "L3 contract decision"
```

Revision history is evidence, not a second live carrier:

| Revision | Lifecycle | Meaning |
|---|---|---|
| 1 | superseded prospectively at `2026-08-10T17:04:37Z` | It incorrectly encoded “one local commit” as human blast radius. Commit `77479a0` consumed that bound; repair commit `c851046` therefore exceeded revision 1. This is recorded as a protocol deviation with `external_mutation_count=0`, not retroactively authorized and not precedent. |
| 2 | current accepted revision | The user's accepted four-step Gate 4 repair direction: human boundary is exact target/surface/consequence/external reach; technical cardinality belongs to the agent under the closed append-only policy above. |

The quoted user decisions in §0 and the accepted repair plan are the completed outcome-level decision.
Blake must not turn this recorded mandate into another Git-level approval prompt.
Completed revision-1 transactions are immutable `VERIFY_ONLY` history and do not satisfy or block the
revision-2 launch check. Every planned/new action must cite the current accepted revision 2.

## Execution Transactions

```yaml
transactions:
  - transaction_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-implementation
    mandate_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-mandate
    mandate_revision: 1
    lock_path: .tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md.txn-lock
    state_version: 5
    state: completed
    launched_at: "2026-08-10T12:25:09Z"
    observed_pre_state:
      repository_root: "/Users/sheldonzhao/01-on progress programs/TAD"
      origin: "https://github.com/Sheldon-92/TAD.git"
      ref: refs/heads/main
      baseline_commit: cabe28755c581c1bddfdfe1a490471888d9f26df
      handoff_pre_cas_sha256: be21e8c9b6dce8efd65daffa569f38d0b70629bdc6c559e6d3542e64c318193c
    targets:
      - TAD source workspace; only handoff §5.1 and §5.2 paths
    consequence_classes:
      - workspace_write
      - local_commit
    actions:
      - action_id: freeze-zero-touch-pre-state
        state: completed
        launched_at: "2026-08-10T12:25:09Z"
        completed_at: "2026-08-10T12:41:56Z"
        manifest_sha256: a330b817725fe3ed45d755afbefc0044273d2747e970555dac44aa481ad01ee7
        observed_result: "14 registered targets frozen (12 present, 2 MISSING); source tracked/index deltas 0; ignored and untracked content identities sealed."
        evidence_paths:
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-paths.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-tracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-untracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-index.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-targets.txt
      - action_id: migrate-live-authority-carriers
        state: completed
        launched_at: "2026-08-10T12:41:56Z"
        completed_at: "2026-08-10T12:57:21Z"
        observed_result: "13-path live surface migrated; five canonical/mirror pairs exact; obsolete per-command approval fields absent; budgets within bounds."
      - action_id: create-read-only-evidence
        state: completed
        launched_at: "2026-08-10T12:57:21Z"
        completed_at: "2026-08-10T13:05:23Z"
        observed_result: "AC1-AC12 full replay PASS; 30 fixtures, 2/2 controls, 9/9 probes; three independent reviews final P0/P1/P2=0; Gate 3 PASS."
      - action_id: scoped-local-commit-after-gate3
        state: completed
        launched_at: "2026-08-10T13:05:23Z"
        completed_at: "2026-08-10T13:07:09Z"
        commit_sha: 77479a0a4ada086f65930a2b1502c5713c49aad3
        push: NOT_PERFORMED
        exact_path_policy: "Only §5.1, §5.2, and the first seven §5.3 governance artifacts; no git add -A."
    final_evidence:
      - .tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
      - .tad/evidence/acceptance-tests/lite-authority-model-v2/verification-results.txt
      - .tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md
      - .tad/active/handoffs/COMPLETION-20260810-lite-authority-model-v2.md
  - transaction_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-gate4-repair-1
    mandate_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-mandate
    mandate_revision: 1
    lock_path: .tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md.txn-lock
    state_version: 4
    state: completed
    mandate_conformance: historical_protocol_deviation
    deviation: "Revision 1 authorized one local commit, already consumed by 77479a0; c851046 was a second local commit. external_mutation_count=0. Revision 2 is prospective and does not retroactively authorize this transaction."
    launched_at: "2026-08-10T16:00:16Z"
    observed_pre_state:
      repository_root: "/Users/sheldonzhao/01-on progress programs/TAD"
      origin: "https://github.com/Sheldon-92/TAD.git"
      ref: refs/heads/main
      baseline_commit: 77479a0a4ada086f65930a2b1502c5713c49aad3
      handoff_pre_cas_sha256: daf62c29de19e5e1efefc7b0837226f97cd98bcbd6482cbb6991039c221d5b9b
    targets:
      - TAD source workspace; only Gate 4 repair evidence/governance paths already bound by the accepted mandate
    consequence_classes:
      - workspace_write
      - local_commit
    actions:
      - action_id: repair-semantic-oracle-and-ac10-evidence
        state: completed
        launched_at: "2026-08-10T16:00:16Z"
        completed_at: "2026-08-10T16:06:19Z"
        observed_result: "Independent 30-case outcome oracle exact; recomputed-digest consequence/lifecycle and prompt/replay semantic mutations fail closed; AC10 emits recorded-window persistent endpoint equality only after all four comparisons pass."
      - action_id: rerun-ac1-ac12-and-independent-reviews
        state: completed
        launched_at: "2026-08-10T16:06:19Z"
        completed_at: "2026-08-10T16:17:22Z"
        observed_result: "AC1-AC12 PASS in 3/3 deterministic runs; strict JSONL and semantic mutation controls PASS; three fresh independent reviews final P0/P1/P2=0."
      - action_id: scoped-local-repair-commit-after-gate3
        state: completed
        launched_at: "2026-08-10T16:17:22Z"
        completed_at: "2026-08-10T16:18:44Z"
        commit_sha: c851046dc41b65f89dbe0acfbb51cc198d016c81
        push: NOT_PERFORMED
        exact_path_policy: "Ten explicit Authority v2 repair evidence/governance paths; no git add -A, no amend."
    final_evidence:
      - .tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
      - .tad/evidence/acceptance-tests/lite-authority-model-v2/verification-results.txt
      - .tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md
      - .tad/active/handoffs/COMPLETION-20260810-lite-authority-model-v2.md
  - transaction_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-gate4-repair-2
    mandate_id: FULL-RETIRE-P3B-LITE-AUTHORITY-V2-mandate
    mandate_revision: 2
    lock_path: .tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md.txn-lock
    state_version: 3
    state: launched
    launched_at: "2026-08-10T17:49:21Z"
    commit_shas: []
    observed_pre_state:
      repository_root: "/Users/sheldonzhao/01-on progress programs/TAD"
      origin: "https://github.com/Sheldon-92/TAD.git"
      ref: refs/heads/main
      baseline_commit: c851046dc41b65f89dbe0acfbb51cc198d016c81
      handoff_pre_cas_sha256: 7bd9a9475dd7e19066a3a31bbedd9085b610926009cb1cfe08c4bf007f76579f
    targets:
      - TAD source workspace; only §5.5 exact repair-2 paths
    consequence_classes:
      - workspace_write
      - local_commit
    actions:
      - action_id: close-jsonl-schema-and-assert-revision2-boundary
        state: completed
        launched_at: "2026-08-10T17:49:21Z"
        completed_at: "2026-08-10T18:17:58Z"
        observed_result: "Closed-world JSONL schema rejects unknown/missing/mistyped/misplaced keys; recomputed-digest unknown-key probe fails closed; Lite carriers publish revision-2 effect boundary and agent-owned append-only local-history cardinality; repair-2 zero-touch endpoints equal 4/4."
        evidence_paths:
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-tracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-untracked.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-index.txt
          - .tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-targets.txt
        finding_refs:
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-code-review.md
          - .tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-security-review.md
      - action_id: rerun-ac1-ac12-three-times-and-independent-reviews
        state: completed
        launched_at: "2026-08-10T18:17:58Z"
        completed_at: "2026-08-10T18:21:07Z"
        observed_result: "AC1-AC11 and repair-2 revision/zero-touch checks pass; three independent pre-commit reviews found no implementation defect, with spec/security recording only the expected pre-commit AC12 history stop."
        evidence_paths:
          - .tad/evidence/reviews/blake/lite-authority-model-v2/spec-compliance-reviewer.md
          - .tad/evidence/reviews/blake/lite-authority-model-v2/implementation-reviewer.md
          - .tad/evidence/reviews/blake/lite-authority-model-v2/security-reviewer.md
      - action_id: create-explicit-path-append-only-repair2-commit
        state: launched
        launched_at: "2026-08-10T18:21:07Z"
        exact_path_policy: "Only §5.5 exact paths with actual task deltas; no git add -A, amend, rebase, reset, squash, deletion, or push."
```

This planned skeleton becomes executable only with a valid accepted mandate and exact binding. Blake
must enrich it with observed pre-state and evidence paths before the first corresponding mutation.

## 4. Implementation Work

### P1 — Freeze and classify the live authority surface

Create `live-surface-inventory.tsv` with exactly these 13 live paths and their disposition:

```text
AGENTS.md
CLAUDE.md
.claude/skills/alex-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.claude/skills/release-runbook/SKILL.md
.agents/skills/release-runbook/SKILL.md
.claude/skills/release-runbook/references/publish-ops.md
.agents/skills/release-runbook/references/publish-ops.md
.claude/skills/release-runbook/references/sync-ops.md
.agents/skills/release-runbook/references/sync-ops.md
.tad/project-knowledge/patterns/gate-design.md
```

Also record these groups without editing them:

- `FULL_ONLY_RETIRE_LATER`: `.tad/config-*.yaml`, full handoff templates, full Gate documents.
- `HISTORY_ONLY`: Phase 2 composition contract, archive, completed evidence.
- `ZERO_TOUCH`: hooks, settings, installers, runtime/verifiers, sync registry, registered targets.

The inventory must say why: Lite explicitly does not load configs, but it does read matched project
knowledge, so `gate-design.md` is live and cannot be omitted.

Do not confuse product/domain HITL guidance with TAD runtime authority. For example, a deployment pack
may recommend GitHub Environment reviewers, a hardware pack may reserve physical measurements for a
human, and an AI-guardrails pack may tell a product designer to insert HITL against untrusted inputs.
Those rules govern the system being built or require genuinely human observation; they do not ask the
current TAD user to approve Blake's Bash/Git decisions. Record this classification boundary in the
inventory and scan only instructions that direct Lite itself to prompt/stop for the current action.

### P2 — Migrate Alex-Lite contract design

Modify canonical `.claude/skills/alex-lite/SKILL.md`, then regenerate the exact `.agents` mirror.

Required behavior:

1. Replace blanket SAFETY/irreversibility “stop and ask” with an outcome/consequence boundary router.
   High-consequence work requires a precise mandate; it does not automatically require another prompt.
2. Add the compact Execution Mandate schema from the design contract to the LITE embedded template.
   Every new LITE handoff carries a mandate plus the mandatory `## Execution Transactions` planned
   skeleton; empty target lists mean none.
3. Reuse goal/scope clarification already present. Ask only when outcome, targets, consequence classes,
   blast radius, exclusions, or visible recovery preference are genuinely unknown.
   Define blast radius only by exact target/surface, external reach, bounded ref/path/MWS/data/amount/
   identity effect, and visible recovery. Explicitly exclude command, local-commit, retry, reviewer,
   evidence, and repair-round counts from the human decision domain.
4. The existing L3 plan decision accepts contract + mandate together. After acceptance, Alex-Lite
   records a positive revision, `status: accepted`, `acceptance.decision: accepted`, a nonempty timestamp,
   and exact `source: L3 contract decision`. Any cross-field mismatch is invalid before mutation.
5. A human-domain material mandate change returns through contract review. Technical cardinality and
   recorded gate-directed repair inside the same exact boundary do not; typo/evidence-only edits do not.
6. Contract reviewer checks mandate completeness, least authority, target closure, exclusions, recovery,
   and AC-to-mandate alignment. Remove command-principal/approval questions.
7. Keep design-only role separation, knowledge bounds, AC dry-run, independent contract review, and
   final business decision intact.

Do not duplicate the full design contract into the skill. Keep the runtime-critical schema,
classifier, and ownership rules in the skill body; detailed vocabulary/fixtures stay linked through
this handoff and design evidence.

Lite reference-loading exception: publish the narrow release rule in both Lite skills. A release task
loads the release entry plus exactly one selected named reference; combined publish+sync may load the
entry, then `publish-ops.md`, then `sync-ops.md`, and no more than those three documents. This exception
does not permit unrelated skill references or tool documentation.

### P3 — Migrate Blake-Lite admission, recovery, and completion

Modify canonical `.claude/skills/blake-lite/SKILL.md`, then regenerate the exact `.agents` mirror.

Required behavior:

1. Admission verifies one accepted mandate, its stable unique `mandate_id`, positive matching revision,
   acceptance/status/timestamp/source invariant, exact repository origin/ref/pathspec, project MWS,
   environment/account/credential/financial binding, target/consequence bounds, and alignment with the
   Contract Review. Missing/malformed/duplicate/superseded/expired mandate returns to Alex-Lite; it
   cannot be waived by an ad-hoc human approval in Blake.
2. Add the effective-authority intersection and the closed runtime prompt-reason enum.
3. Technical failures enter bounded repair/recovery or `GATE FAIL / BLOCK`; they never become questions
   asking the human to approve a command, evidence downgrade, retry, or rollback.
4. `PARTIAL-GO` only asks the human when recovery has multiple legitimate visible outcomes. A
   deterministic partial follows the mandate; an unresolved unknown blocks mutation without prompting.
5. Scope expansion that changes a mandate field is `boundary_change`, expressed in human-readable
   outcome/consequence terms, and routed back to Alex-Lite for an amended reviewed contract.
6. Completion records `mandate_id`, transaction(s), consequence/target/pre/post/recovery evidence,
   `avoidable_runtime_prompt_count`, `boundary_change_prompt_count`, and every
   `runtime_prompt_reason`.
7. L5 remains business acceptance only. Acceptance triggers archive automatically; there is no separate
   archive confirmation. Task-scoped append-only local commit(s) are automatic only when `local_commit`
   and the exact local-history policy are in the mandate. Their count is agent-owned; otherwise report
   `uncommitted` without asking a new question.
8. Remove the blanket `git push` stop-and-ask rule. Push remains impossible unless role, skill, exact
   mandate consequence, target, blast radius, and preconditions all allow it.
9. Delegated reviewers/workers receive `mandate_id` plus the smallest target/consequence/path excerpt.
   Reviewers are read-only; workers default to no external mutation unless Blake explicitly assigns one
   in-mandate action. Blake remains the sole state owner and validates the result before advancing.
10. Persist transaction/action state in the LITE handoff's mandatory `## Execution Transactions`
    subsection. Before launch and after reconciliation, use the contract's exclusive compare-and-swap
    discipline. A completed action never repeats; duplicate IDs, stale versions, and concurrent losers
    fail before mutation.
11. Publish the exact five-step CAS protocol from design contract §4: adjacent `.txn-lock`, atomic
    `mkdir`, owner fingerprint, digest/version re-read, same-directory temporary file + atomic rename,
    owner-token cleanup, and proof-gated orphan recovery. No harness may substitute an in-memory claim.

Keep role separation, reviewer, AC evidence, repair limits, scope checks, and no-evidence-no-PASS rules.

### P4 — Migrate release-runbook authority and transaction semantics

Modify the canonical release entry and two references, then regenerate exact mirrors.

Entry skill:

- Replace `Lite ∩ Skill ∩ current human approval` with `Lite ∩ Skill ∩ accepted Contract Mandate`.
- Remove `approval_id`, `scope_digest`, `approval_state`, `consumed-before-launch`, atomic approval-claim
  directories, per-command approvals, and “new approval after not-started.”
- Add transaction/action correlation state, precondition re-read, outcome classifier, and observability.
- Keep source identity guard, role/mode boundaries, no second runtime, exact exit-code handling, managed
  surfaces, and fail-closed unknown state.
- Re-read the accepted mandate revision and exact consequence binding before every mutation; verify
  origin/ref/pathspec/MWS/account or credential bounds as applicable, then compare-and-swap the handoff
  transaction state before launch.

Publish reference:

- One accepted release transaction may contain exact main update, annotated tag, tag update, and later
  sync when all are in the mandate.
- Preserve separate commands, exact refspecs, no force/unscoped refs, and post-state verification. Their
  separation is a technical safety property, not separate human gates.
- Verified-not-started retry uses the same transaction and no prompt.
- Remote-ahead is diagnosed. Deterministic recovery inside the same outcome is agent-owned; a semantic
  or visible-result fork is a boundary change. Never auto-force.

Sync reference:

- Target identity, Managed Write Surface, migration engine, post-copy gates, registry advancement,
  downstream commit, and downstream push remain separate technical actions inside the transaction.
- Every action needs an authorized consequence class and named target, not its own approval.
- Partial/unknown recovery follows the shared classifier. No blind retry and no continuing a batch after
  a systemic partial.

### P5 — Align routing and authoritative knowledge

Update `CLAUDE.md` and `AGENTS.md` so their cross-harness interaction clauses distinguish:

- initial contract/mandate outcome decision;
- real runtime boundary change using the closed reason enum;
- final business acceptance;
- technical block/report with no fake decision question.

Remove blanket statements that SAFETY approval, archive confirmation, publish, sync, or ordinary push
always require a fresh answer. Retain role switching as human-triggered.

In `CLAUDE.md`, publish the same bounded release-reference exception as both Lite skills: entry plus one
selected named reference, or entry + publish + sync for a combined transaction, hard maximum three
named release documents and no unrelated reference loading. `AGENTS.md` must not contradict it.

Append a dated amendment to `.tad/project-knowledge/patterns/gate-design.md` rather than erasing the old
entry. The amendment must state that the accepted mandate is the permission carrier; SAFETY classes
require stronger scope/recovery evidence, not automatic runtime prompting or full routing. Preserve the
“no carrier, no grant” principle: an absent/unaccepted mandate grants nothing.

### P6 — Update the constraint ledger

Before appending, run the ledger's exact overdue scan. Append, do not delete history:

1. A disposition row saying the per-command/blanket stop-and-ask model is superseded by the accepted DR.
2. A priced row for the mandate admission/classifier rule, including per-task cost, concrete prevented
   failure, grep anchor, and real carrier path.

The new rule replaces multiple runtime prompts with one contract field group. Report net interaction
cost, not only added YAML lines.

### P7 — Build read-only executable fixtures and evidence

Create under `.tad/evidence/acceptance-tests/lite-authority-model-v2/`:

- `live-surface-inventory.tsv`
- `authority-fixtures.jsonl`
- `verify-authority-model-v2.sh`
- `verification-results.txt`
- `acceptance-verification-report.md`
- `zero-touch-paths.txt`
- `zero-touch-pre-tracked.txt`
- `zero-touch-pre-untracked.txt`
- `zero-touch-pre-index.txt`
- `zero-touch-post-tracked.txt`
- `zero-touch-post-untracked.txt`
- `zero-touch-post-index.txt`
- `zero-touch-pre-targets.txt`
- `zero-touch-post-targets.txt`
- `zero-touch-controls.txt`

The very first Blake implementation action, before editing a live carrier, is to freeze the exact
§5.4 pathspecs in `zero-touch-paths.txt` and capture both tracked and untracked pre-state. Use the same
unchanged pathspec file for post-state; never rebaseline or widen it after work starts. Capture tracked
worktree state with pinned-baseline `git diff --raw` plus filesystem content identity. Capture the index
separately using both `git diff --cached --raw <baseline>` and `git ls-files --stage`, recording mode and
staged blob SHA for every protected path. A worktree hash never substitutes for the cached blob. Build
the non-tracked candidate set by the union of `git ls-files --others --exclude-standard` and
`git ls-files --others --ignored --exclude-standard`; the second command is mandatory because ignored
settings are still protected. For every resolved path record type, mode, size, and SHA-256 (or symlink
target); fail closed if no SHA-256 implementation is available. Scope all three Git queries by the same
loaded literal pathspec array and sort normalized records. This seals both the pre-existing untracked
`.claude/settings.local.json.bak-20260806-082549` and ignored `.claude/settings.local.json`; a path-only
list is insufficient because content could change without membership changing. If concurrent work
changes a protected path, retain the failure and attribute it with path, diff, timestamp, and
task/commit evidence; do not silently absorb it.

`zero-touch-paths.txt` is a sorted typed manifest: `source_pathspec<TAB><literal pathspec>` plus one
`registered_target<TAB><physical root>` row per target resolved from the registry at freeze time. The
transaction CAS that launches `freeze-zero-touch-pre-state` may update only the handoff transaction
record; the manifest and four pre snapshots are then the first evidence writes. All pre and post files
use sorted normalized records. The verifier compares the manifest identity as well as every snapshot,
so a changed registry expansion or altered allowlist fails rather than being silently accepted.

For every frozen registered-target root, `zero-touch-{pre,post}-targets.txt` records `MISSING`, or runs
read-only commands rooted explicitly with `git -C "<physical root>"`: resolved toplevel/origin/HEAD,
index tree, refs, full tracked/untracked status, and content identity for the registered Managed Write
Surface (including ignored files inside that surface). Never run a source-repository pathspec command and
claim it covers a target. Pre/post target records must match byte-for-byte unless an independently
attributed concurrent change is retained as a Gate failure.

The verifier is test-only and read-only. It must:

1. validate the exact 13-path inventory and dispositions;
2. validate all five canonical/mirror pairs with `cmp`;
3. assert required mandate/classifier/transaction/observability anchors in live carriers;
4. assert obsolete per-command approval fields/phrases are absent from operational Lite carriers;
5. validate all 30 design-contract fixtures against a closed JSON object schema, accepted-mandate
   cross-field invariants, exact bindings, replay/CAS behavior, lifecycle cases, and the closed
   prompt-reason enum; unknown/missing keys, wrong types, or illegal optional fields fail even after
   fixture digest recomputation;
6. calculate `avoidable_runtime_prompt_count=0` across fixtures;
7. compare pre/post tracked and untracked zero-touch snapshots, retain the pinned baseline check, and
   prove with scratch controls that clean state passes while tracked-worktree, cached/index,
   untracked, ignored, and registered-target changes fail;
8. assert the bounded release-reference exception and reject a fourth/unrelated loaded document;
9. assert revision 2 blast-radius semantics, the append-only local-history policy, and the honest
   revision 1 deviation carrier; reject any live “one commit” cardinality authorization;
10. emit nonzero on any failure and a final machine-readable summary.

Do not implement a production authorization evaluator in evidence. The verifier checks the published
protocol, fixture mapping, and file invariants; independent reviewers test the reasoning/adversarial
cases.

Repair-2 zero-touch override: before its first live-carrier edit, reuse the existing immutable
`zero-touch-paths.txt` and capture the four `repair2-zero-touch-pre-*` carriers from current base
`c851046`; never overwrite or rebaseline the original window. After the repair and before Gate 3, write
the four matching `repair2-zero-touch-post-*` carriers plus `repair2-zero-touch-controls.txt`. Current
AC10 and `--check zero-touch` must evaluate the repair-2 files; the original files remain historical
evidence. The same four-plane identity, registered-target, and transient-command disclaimer rules apply.

### P8 — Independent implementation review and local commit

After ACs pass, run three independent read-only reviews:

1. spec-compliance reviewer: every AC and every live-surface disposition;
2. implementation/architecture reviewer: state ownership, recovery, cross-file consistency, stale
   carrier closure, and interaction-budget regression;
3. security reviewer: privilege expansion, missing carrier, target escape, transaction replay,
   concurrent/resume ambiguity, credential/financial boundary, and fail-closed behavior.

Every proposed P0/P1 must have an executable scratch probe or exact text/path evidence. Resolve all
P0/P1/P2, rerun affected ACs, and obtain final PASS with P0=P1=P2=0. Then create only the task-scoped,
append-only, explicit-path local commit(s) needed for the transaction. Count is not a human authorization
boundary; every commit must satisfy revision 2's closed purpose/path/history policy. Do not push.

## 5. Files

### 5.1 Modify

```text
AGENTS.md
CLAUDE.md
.claude/skills/alex-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.claude/skills/release-runbook/SKILL.md
.agents/skills/release-runbook/SKILL.md
.claude/skills/release-runbook/references/publish-ops.md
.agents/skills/release-runbook/references/publish-ops.md
.claude/skills/release-runbook/references/sync-ops.md
.agents/skills/release-runbook/references/sync-ops.md
.tad/project-knowledge/patterns/gate-design.md
.tad/evidence/audits/lite-constraint-ledger.md
```

### 5.2 Create

```text
.tad/evidence/acceptance-tests/lite-authority-model-v2/live-surface-inventory.tsv
.tad/evidence/acceptance-tests/lite-authority-model-v2/authority-fixtures.jsonl
.tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh
.tad/evidence/acceptance-tests/lite-authority-model-v2/verification-results.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-paths.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-tracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-untracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-index.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-tracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-untracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-index.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-targets.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-targets.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-controls.txt
.tad/evidence/reviews/blake/lite-authority-model-v2/spec-compliance-reviewer.md
.tad/evidence/reviews/blake/lite-authority-model-v2/implementation-reviewer.md
.tad/evidence/reviews/blake/lite-authority-model-v2/security-reviewer.md
.tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md
.tad/active/handoffs/COMPLETION-20260810-lite-authority-model-v2.md
```

### 5.3 Governance artifacts and design inputs

```text
.tad/decisions/DR-20260809-lite-authority-model-v2.md
.tad/evidence/designs/full-capability-extraction/authority-model-v2-contract.md
.tad/evidence/reviews/alex/lite-authority-model-v2/architecture-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/security-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate2-verdict.md
.tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md
.tad/active/epics/EPIC-20260809-full-capability-extraction-retirement.md
.tad/evidence/designs/full-capability-extraction/skill-composition-contract.md
.tad/evidence/designs/full-capability-extraction/composition-negative-fixtures.yaml
```

`governance_artifacts` included in the scoped task commit are the first seven paths above. They are
read-only for Blake except the current handoff's `## Execution Transactions` state and final evidence
references. The last two Phase 2 inputs are historical read-only inputs and are not part of the task
commit.

### 5.4 Zero-touch

```text
.tad/hooks/**
.claude/settings*.json
.codex/hooks.json
.codex/agents/**
tad.sh
bin/**
package.json
.tad/config*.yaml
.tad/templates/**
.tad/gates/**
.tad/sync-registry.yaml
.tad/hooks/lib/release-verify.sh
.tad/hooks/lib/derive-sync-set.sh
.tad/hooks/lib/migration-engine.sh
.tad/archive/**
all registered downstream targets
```

### 5.5 Gate 4 repair-2 exact executable scope

Only these paths may receive task-attributable deltas in repair 2. Earlier §5.1–§5.3 paths not listed
here are historical scope, not a new grant. Blake may modify the live/evidence/Blake-review paths through
`gate3-verdict.md` plus Completion; in this handoff Blake may modify only Execution Transactions and
final evidence references. The DR, design contract, all Alex review files, and all other handoff text
are immutable design inputs: Blake may include their existing deltas in an explicit-path commit but may
not edit them.

```text
.claude/skills/alex-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.tad/project-knowledge/patterns/gate-design.md
.tad/evidence/acceptance-tests/lite-authority-model-v2/authority-fixtures.jsonl
.tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh
.tad/evidence/acceptance-tests/lite-authority-model-v2/verification-results.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-tracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-untracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-index.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-pre-targets.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-tracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-untracked.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-index.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-post-targets.txt
.tad/evidence/acceptance-tests/lite-authority-model-v2/repair2-zero-touch-controls.txt
.tad/evidence/reviews/blake/lite-authority-model-v2/spec-compliance-reviewer.md
.tad/evidence/reviews/blake/lite-authority-model-v2/implementation-reviewer.md
.tad/evidence/reviews/blake/lite-authority-model-v2/security-reviewer.md
.tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md
.tad/active/handoffs/COMPLETION-20260810-lite-authority-model-v2.md
.tad/decisions/DR-20260809-lite-authority-model-v2.md
.tad/evidence/designs/full-capability-extraction/authority-model-v2-contract.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-acceptance.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-code-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-performance-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-security-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-acceptance.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-code-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-performance-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-rerun-security-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-repair2-architecture-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate4-repair2-security-review.md
.tad/evidence/reviews/alex/lite-authority-model-v2/gate2-amendment-verdict.md
.tad/active/handoffs/HANDOFF-20260810-lite-authority-model-v2.md
```

## 6. Required Fixture Matrix

Use the 30 fixture IDs and expected outcomes exactly as defined in the design contract §7. The JSONL
record for every fixture must include:

```json
{"id":"...","mandate_state":"...","condition":"...","expected_result":"...","human_prompt":false,"runtime_prompt_reason":null,"mutation_before_verdict":false}
```

The seven displayed keys are required on every row and no other base key is allowed. Optional
`control` is legal only with value `positive` on `mandate-happy-release` and `mandate-happy-local`;
optional `decision_class` is legal only with value `final_business_acceptance` on
`final-business-acceptance`. Every other unknown key, missing key, wrong type, or misplaced optional key
is invalid. For prompt-true runtime rows, `runtime_prompt_reason` must be one legal enum value. For
prompt-false rows it must be null. `final-business-acceptance` is separately classified as a final
business decision and is not counted as a runtime prompt.

Add two clean positive controls and ten mutation probes in scratch copies:

- broaden a target or consequence without changing the fixture expectation: verifier must fail;
- inject an unknown field into a valid row and recompute any fixture digest: verifier must fail;
- replace `tool-failure-no-prompt` with a technical approval prompt: verifier must fail.
- make a completed transaction/action replayable or duplicate its ID: verifier must fail;
- create an untracked file under a scratch zero-touch path: the snapshot comparator must fail;
- modify a tracked file under a scratch zero-touch path: the snapshot comparator must fail;
- stage a different protected blob while restoring the worktree bytes: the index comparator must fail;
- modify an ignored file under a scratch zero-touch path without changing membership: comparator fails;
- modify a scratch registered target's Managed Write Surface: target comparator fails;
- let the losing/stale CAS executor claim a launch or mutation: verifier must fail.

Clean source zero-touch and clean registered-target pre/post comparisons must pass. Mutation probes
operate only in temporary fixture repositories; they must not touch this repository's §5.4 paths.

## 7. Acceptance Criteria

- AC1: Live surface inventory is exact: 13 paths, no omission, no extra operational carrier, and all
  excluded groups have a disposition.
- AC2: Alex-Lite and Blake-Lite publish the same compact mandate schema, accepted-state invariant,
  exact-binding rules, boundary classifier, mandatory Execution Transactions subsection, and retain
  role/reviewer/technical-gate protections. Both define human blast radius by exact effect/surface/
  external reach and exclude technical work counts; Blake-Lite uses task-scoped append-only local
  commit(s), never a human-authorized “one commit” limit.
- AC3: The initial L3 decision accepts contract+mandate once; no command, retry, rollback, commit, push,
  archive, or evidence-downgrade approval question remains in the live Lite runtime path.
- AC4: Release-runbook entry and references use one mandate-scoped business transaction, persist
  monotonic transaction/action state in the LITE handoff, enforce single-writer CAS/replay protection,
  preserve exact technical guards, and implement recovery without per-command nonce.
- AC5: `CLAUDE.md`, `AGENTS.md`, and the current gate-design amendment agree with the skill semantics;
  the release reference exception is bounded to entry + selected reference(s), hard maximum three for
  combined publish+sync; full-only/history/zero-touch carriers are not misrepresented as migrated.
- AC6: Five canonical/mirror pairs are byte-identical.
- AC7: All 30 fixtures pass under an exact closed-world JSON schema; the two optional fields are legal
  only on their named rows; unknown keys fail after recomputed digest; prompt reasons are closed;
  `avoidable_runtime_prompt_count=0`; both clean controls pass and all ten adversarial mutations fail.
- AC8: Always-loaded Lite cost remains bounded: canonical Alex-Lite + Blake-Lite total ≤52,200 bytes;
  release entry ≤9,500 bytes; two on-demand release references total ≤17,400 bytes; no new always-loaded
  file is added.
- AC9: Constraint ledger overdue scan is clean and both disposition/pricing entries are present with a
  real carrier.
- AC10: The immutable zero-touch manifest has matching pre/post tracked-worktree, cached/index,
  untracked+ignored, and per-registered-target snapshots with blob/content identity; no task-attributable
  persistent endpoint delta in the recorded repair-2 window; all source/target scratch controls prove
  detection. Report `recorded_window_persistent_endpoint_equality=4/4`; do not infer continuous
  monitoring or absence of transient external commands.
- AC11: Independent spec, architecture, and security reviews each end PASS with P0=0, P1=0, P2=0.
- AC12: Required evidence is complete and replayable; repair-2 local commit(s) are append-only and
  contain only actual §5.5 deltas with explicit pathspecs; no history rewrite or push occurred. The
  revision 1 `c851046` excess-commit deviation remains explicitly recorded and is not retroactively
  presented as authorized. The repair-2 transaction records every commit SHA in order; that list equals
  the complete linear Git range from `c851046` exclusive through the recorded tip, and every commit in
  the range contains only §5.5 paths. The post-commit SHA list remains the handoff state carrier and is
  not required to be inside the tip it names; do not create a self-referential extra commit for it.

## 8. §9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| AC1 | Exact live-surface closure | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check inventory` | `inventory_paths=13`, no omission/extra | post-impl; invocation syntax validated |
| AC2 | Lite mandate/classifier semantics | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check lite-core` | PASS; accepted-state/binding/transaction anchors plus revision-2 blast-radius/local-history semantics present; live one-commit authority absent | post-impl; invocation syntax validated |
| AC3 | No fake runtime approval questions | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check prompt-closure` | PASS; closed reason enum; illegal technical reasons absent | post-impl; invocation syntax validated |
| AC4 | Release transaction/recovery model | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check release` | PASS; handoff state/CAS/replay rules present; no per-command approval fields; guards retained | post-impl; invocation syntax validated |
| AC5 | Routing/knowledge/disposition alignment | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check routing` | PASS; current amendment present; reference max=3; fourth/unrelated reference denied; full-only excluded | post-impl; invocation syntax validated |
| AC6 | Canonical/mirror parity | pre-impl + post-impl | `for p in alex-lite/SKILL.md blake-lite/SKILL.md release-runbook/SKILL.md release-runbook/references/publish-ops.md release-runbook/references/sync-ops.md; do cmp -s ".claude/skills/$p" ".agents/skills/$p" || exit 1; done; echo mirror_pairs=5` | `mirror_pairs=5` | pre-impl output: `mirror_pairs=5`; rerun post-impl |
| AC7 | Fixture and adversarial matrix | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check fixtures` | `fixtures=30 closed_schema=PASS unknown_key_probe=PASS avoidable_runtime_prompt_count=0 positive_controls=2/2 mutation_probes=10/10` | post-impl; invocation syntax validated |
| AC8 | Context cost bounded | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check budget` | Lite core ≤52200; entry ≤9500; refs ≤17400 bytes | baseline measured: `47398 / 8483 / 15050` |
| AC9 | Ledger current and priced | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check ledger` | overdue=0; disposition=1; priced mandate carrier=1 | pre-impl overdue output empty; entries post-impl |
| AC10 | Zero-touch recorded-window endpoint equality | pre-impl + post-impl | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check zero-touch` | immutable manifest; source worktree+index+untracked+ignored and per-target pre/post equal; source/target controls pass; emit `recorded_window_persistent_endpoint_equality=4/4` only after all four stored comparisons pass; do not claim real-time proof that no transient external command ran | pre-impl tracked diff exit 0; known untracked backup and ignored settings identified; Blake freezes full snapshots before edits |
| AC11 | Independent reviews clean | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --check reviews` | 3 final PASS; P0/P1/P2 all 0 | post-impl; invocation syntax validated |
| AC12 | Full replay and scoped append-only history | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh --all`; verifier compares the transaction's ordered nonempty `commit_shas` to `git rev-list --reverse c851046..<recorded-tip>`, rejects merge commits, and runs `git diff-tree --no-commit-id --name-only -r <sha>` for every listed SHA against the §5.5 allow-list | exit 0 and final `RESULT: PASS`; list equals the complete linear range; every repair-2 commit path is in §5.5; no amend/rewrite/push; historical deviation text retained | post-impl; invocation syntax dry-run requires post-commit carrier |

### AC Dry-Run Log (Alex step1d, 2026-08-10)

- Checks AC1–AC5, AC7, AC9, AC11, AC12 — future evidence/script required. Raw invocation form was checked;
  each is a single `bash <path> --check <mode>` command with no Markdown pipe/escape hazard.
- Check AC6 — executed on the current five pairs; output `mirror_pairs=5`, exit 0.
- Check AC8 — executed current byte measurement; output `47398 / 8483 / 15050`.
- Check AC9 precondition — exact ledger overdue scan emitted no rows.
- Check AC10 precondition — pinned tracked diff exited 0; broad status inspection identified the
  pre-existing untracked `.claude/settings.local.json.bak-20260806-082549`, and reviewer probing found
  ignored `.claude/settings.local.json`; staged blobs are a distinct state plane even when worktree bytes
  match. Blake must freeze worktree, index, untracked, ignored, and per-target content before edits.
- No future artifact was mocked.

### AC Conflict Matrix

| Invariants considered together | Simultaneously satisfiable? | Resolution |
|---|---|---|
| Canonical/mirror byte parity × semantic migration × Lite-core byte budget | Yes | Author canonical files once, replace obsolete approval prose instead of layering a second model, then regenerate mirrors |
| Fail-closed safety × zero avoidable prompts × agent-owned recovery | Yes | Deny out-of-mandate mutation without a technical approval question; prompt only for the closed boundary-change enum |
| Historical preservation × operational old-model lexical closure × current knowledge | Yes | Exclude HISTORY_ONLY evidence from operational scans and append a dated current amendment to gate-design |
| No live mutation × release recovery coverage × executable evidence | Yes | Use read-only fixtures and adversarial scratch mutations in Phase 3b; reserve external dogfood for Phase 3c |
| Sole handoff state × concurrent resume safety × no second runtime | Yes | Persist the transaction subsection in the handoff and use exclusive versioned compare/write; ephemeral coordination carries no authority or state |
| Lite bounded loading × combined release composition | Yes | Permit only release entry + publish/sync named references, loaded sequentially with a hard three-document ceiling |

## 9. Required Evidence Manifest

```yaml
required_evidence:
  design_inputs:
    - .tad/decisions/DR-20260809-lite-authority-model-v2.md
    - .tad/evidence/designs/full-capability-extraction/authority-model-v2-contract.md
  fixture_results:
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/live-surface-inventory.tsv
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/authority-fixtures.jsonl
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/verify-authority-model-v2.sh
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/verification-results.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-paths.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-tracked.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-untracked.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-index.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-tracked.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-untracked.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-index.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-pre-targets.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-post-targets.txt
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/zero-touch-controls.txt
  alex_reviews:
    - .tad/evidence/reviews/alex/lite-authority-model-v2/architecture-review.md
    - .tad/evidence/reviews/alex/lite-authority-model-v2/security-review.md
    - .tad/evidence/reviews/alex/lite-authority-model-v2/gate2-verdict.md
  blake_reviews:
    - .tad/evidence/reviews/blake/lite-authority-model-v2/spec-compliance-reviewer.md
    - .tad/evidence/reviews/blake/lite-authority-model-v2/implementation-reviewer.md
    - .tad/evidence/reviews/blake/lite-authority-model-v2/security-reviewer.md
  gate_verdicts:
    - .tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260810-lite-authority-model-v2.md
  perf_evidence:
    - .tad/evidence/acceptance-tests/lite-authority-model-v2/acceptance-verification-report.md
  dogfood:
    - Phase 3c only; Phase 3b must report recorded-window persistent endpoint equality and its execution log, without claiming continuous command monitoring
  knowledge_updates:
    - .tad/project-knowledge/patterns/gate-design.md
    - .tad/evidence/audits/lite-constraint-ledger.md
```

## 10. Friction Preflight

| Friction | Status | Resolution |
|---|---|---|
| Repository already has unrelated modified/untracked files | READY | Freeze immutable typed zero-touch pre-state including untracked files before live-carrier edits; compare post-state; commit by exact mandate pathspecs only; never use `git add -A` |
| codebase-memory graph transport is unavailable | EQUIVALENT_SUBSTITUTE | This task changes Markdown/protocol surfaces; use exact literal/consumer searches and record the graph failure |
| Phase 2 evidence contains obsolete approval terms | READY | HISTORY_ONLY exclusion; verifier scans operational carriers, not historical evidence |
| Gate-design contains historical stop-and-ask prose | READY | Append a current amendment; verifier requires it rather than deleting history |
| Real external mutation cannot be tested safely here | NOT_APPLICABLE_WITH_REASON | Phase 3b uses read-only fixtures; Phase 3c owns live dogfood |

## 11. Critical Warnings

- Reducing prompts is not permission expansion. If the role, skill, mandate, target, consequence, blast
  radius, or precondition does not allow an action, mutation is denied or blocked before launch.
- Do not preserve the old approval model under renamed fields such as “confirmation token,” “operator
  ack,” or one approval per transaction action. The human carrier is the accepted mandate.
- Do not create a generic policy engine or move this into hooks/settings. The protocol is enforced by
  contract admission, technical guards, independent review, and dogfood evidence.
- Do not edit full-only configs/templates to make global grep counts look cleaner. That would falsify
  scope and destroy the ability to tell Lite migration from full retirement.
- Do not rewrite Phase 2 or archived evidence. Prospective supersession must remain auditable.
- Do not run any real push/tag/publish/sync or registered-target write in this phase.

## 12. Decision Summary

| Option | Decision | Reason |
|---|---|---|
| Keep command-level approvals | Rejected | Human cannot assess the technical question; repeated prompts create rubber-stamping |
| Remove prompts and trust the agent broadly | Rejected | It loses target/consequence bounds and repeats excessive-agency failures |
| Accepted Outcome Mandate + technical autonomy inside it | Selected | Human decides understandable consequences once; agent remains bounded and technically accountable |
| Build a permission runtime/service | Rejected | Adds a second state owner and full-like machinery without solving the decision-ownership error |

## 13. Grounded Against

- `AGENTS.md` lines 79–85, read 2026-08-10
- `CLAUDE.md` lines 14–50, read 2026-08-10
- `.claude/skills/alex-lite/SKILL.md` full file, read 2026-08-10
- `.claude/skills/blake-lite/SKILL.md` full file, read 2026-08-10
- `.claude/skills/release-runbook/SKILL.md` full file, read 2026-08-10
- `.claude/skills/release-runbook/references/publish-ops.md` full file, read 2026-08-10
- `.claude/skills/release-runbook/references/sync-ops.md` full file, read 2026-08-10
- `.tad/project-knowledge/patterns/gate-design.md`, read 2026-08-10
- `.tad/evidence/audits/lite-constraint-ledger.md`, read and overdue-scanned 2026-08-10
- New fixture/evidence files are marked create.

## 14. Gate 2

**Original revision-1 status:** PASS — independent architecture/code and security reviewers final
P0=0, P1=0, P2=0.
**Verdict:** `.tad/evidence/reviews/alex/lite-authority-model-v2/gate2-verdict.md`

**Revision-2 amendment status:** PASS — independent architecture/correctness and security reviewers
final P0=0, P1=0, P2=0.
**Amendment verdict:**
`.tad/evidence/reviews/alex/lite-authority-model-v2/gate2-amendment-verdict.md`

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| Architecture | P1: no durable pre-launch action state; round 2 required executable lock/atomic replacement/crash rules | contract §4; handoff §3.2, Execution Transactions, P2/P3/P4, AC2/AC4 | CLOSED; final PASS |
| Architecture | P1: Lite loading rule made progressive release references infeasible | contract §6; handoff P2/P5, AC5 | CLOSED; final PASS |
| Architecture | P1: zero-touch missed untracked, then ignored/targets, then cached index blobs | handoff P7, §5.2, AC10, evidence manifest | CLOSED; final PASS |
| Architecture | P1: replay/concurrent-resume negatives missing | contract §7; handoff §6, AC7 | CLOSED; final PASS |
| Security | P1: accepted-state cross-field invariant/fixtures missing | contract §2/§7; handoff P2/P3, AC2/AC7 | CLOSED; final PASS |
| Security | P1: no transaction-level single-writer/CAS replacement | contract §4; handoff §3.2, Execution Transactions, P3/P4 | CLOSED; final PASS |
| Security | P1: target bindings omitted exact ref/path/MWS/account/credential/amount | contract §2; accepted mandate; handoff P3/P4; fixtures | CLOSED; final PASS |
| Security | P2: unlisted local commit negative missing | `unlisted-local-commit` fixture | CLOSED; final PASS |
| Security | P2: archive-before-acceptance negative missing | `archive-before-acceptance` fixture | CLOSED; final PASS |
| Amendment architecture | P1: tip-only AC12 could miss an earlier out-of-scope repair commit | contract §2.2; repair-2 `commit_shas`; AC12; Completion contract | CLOSED; final PASS |
| Amendment architecture | P1: Completion still called `c851046` scoped and AC12 PASS | Completion Alex Gate 4 Override; handoff revision history | CLOSED; final PASS |
| Amendment security | P1: stale header said ready and one commit during review | handoff header + revision-2 binding | CLOSED; final PASS |
| Amendment security | P2: AC10 overstated continuous external-mutation evidence | AC10 recorded-window wording | CLOSED; final PASS |

### Experts Selected

1. Architecture/code reviewer — composition, state machine, cross-file completeness, executable ACs.
2. Security reviewer — privilege bounds, false authorization regression, recovery/replay/identity cases.

## 15. Blake Completion Contract

Completion must report:

- ordered repair-2 `commit_shas`, exact base/tip, complete-range equality, no-merge result, per-commit
  §5.5 path-subset results, and `push=NOT PERFORMED`;
- AC1–AC12 raw outputs and evidence paths;
- all 30 fixture results, both clean positive controls, and all ten mutation probes including the
  recomputed-digest unknown-key probe;
- `avoidable_runtime_prompt_count=0`, boundary prompt count/reasons, and recorded-window persistent endpoint equality (`4/4`) with no continuous-monitoring claim;
- five mirror-pair parity results and byte budgets;
- ledger overdue scan and appended row anchors;
- three independent reviewer final verdicts with P0/P1/P2;
- every unexpected finding/follow-up; no silent P2 omission.
