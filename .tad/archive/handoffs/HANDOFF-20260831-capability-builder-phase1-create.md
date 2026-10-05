---
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs:
  - .claude/skills/capability-builder
  - .agents/skills/capability-builder
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Capability Builder v1 — Phase 1 Create

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-08-31  
**Project:** TAD Framework  
**Task ID:** TASK-20260831-CAPABILITY-BUILDER-CREATE  
**Handoff Version:** 3.1.0  
**Epic:** `EPIC-20260831-capability-builder-v1.md` (Phase 1/4)  
**Design:** `.tad/active/designs/DESIGN-20260831-capability-builder-phase1-create.md`  
**Supersedes:** N/A

## 🔴 Gate 2: Design Completeness

**执行时间:** 2026-08-31

| 检查项 | 状态 | 说明 |
|---|---|---|
| Expert Review Complete | ✅ | Code and architecture reviewers completed design and handoff review; evidence paths are recorded. |
| All P0 Resolved | ✅ | Both formal handoff reviewers reported no P0. |
| Architecture Complete | ✅ | Ownership, state machine, component boundaries, and failure paths are specified. |
| Components Specified | ✅ | Router, protocol, compatibility entry, helper, eval alias, evidence driver are bounded below. |
| Functions Verified | ✅ | Existing functions are grounded in §5 MQ2 and §7.3; new functions are explicitly CREATE work. |
| Data Flow Mapped | ✅ | Canonical/projected Skill and evidence flows are mapped in §4.6 and §5 MQ3/MQ5. |

**Gate 2 Result:** ✅ PASS — ready for Human execution-mode selection.

## 📋 Handoff Checklist

- [ ] Read this entire handoff and the Project Knowledge section.
- [ ] Restate the intent, user flow, and success standard to the Human before editing.
- [ ] Preserve all unrelated dirty work, especially the parallel YOLO2 evidence/handoff files.
- [ ] Use explicit task paths for staging; never use `git add -A`.
- [ ] Execute every §9.1 command literally and record raw output.
- [ ] Stop if any protected TAD surface would need modification.

## 1. Task Overview

### 1.1 What We Are Building

Implement `$capability-builder create`: a TAD-native workflow that lets a downstream
project create exactly one project-owned Agent Skill, prove its behavioral value, and
safely project it from `.agents/skills/<name>/` to `.claude/skills/<name>/`.

### 1.2 Why

TAD currently contains valuable capability-building judgment but the old Capability Pack
artifact makes TAD own too much domain content and creates high maintenance cost. The
new path keeps TAD's process strengths while making each subproject own its reusable Skill.

Success means a real downstream fixture can use the new path immediately without changing
TAD's installer, Alex/Blake roles, Gates, or any existing legacy Capability Pack.

### 1.3 Intent Statement

**真正要解决的问题:** TAD 缺少一个能把子项目内已经验证的做法，渐进地变成项目自有 Agent Skill 的标准能力。

**不是要做的:**

- 不是重新设计 TAD。
- 不是批量迁移或退休旧 Capability Packs。
- 不是 Plugin、DeepSeek Harness、能力目录或自动演化系统。
- 不是把子项目能力收归 TAD。

Before editing, Blake must answer for Human confirmation:

1. This phase solves what problem?
2. Which project owns a generated Skill?
3. Which TAD surfaces are forbidden to change?

## 📚 Project Knowledge

### Files Read by Alex

| File | Relevant guidance |
|---|---|
| `.tad/project-knowledge/principles.md` | Mechanical checks stay narrow; critical execution discipline must not disappear behind a circular progressive-load trigger. |
| `.tad/project-knowledge/patterns/handoff-design.md` | Route before process; minimal producer/consumer integration; cross-platform assumptions require current grounding. |
| `.tad/project-knowledge/patterns/ac-verification.md` | Dry-run every AC; discriminative fixtures need named rules/specific thresholds and at least one structural marker. |
| `.tad/project-knowledge/patterns/pack-evaluation.md` | CONTROL/WITH evidence must be fresh and behaviorally discriminative, not vocabulary matching. |
| `.tad/evidence/pack-quality/QUALITY-BAR.md` | Existing capability-meta research supports standard `name` + `description` frontmatter and progressive disclosure. |

### Blake Must Remember

1. **Circular Trigger Pattern** (`handoff-design.md`): the main Builder body must know that
   `create` exists and explicitly load `create-protocol.md`; the reference cannot define its
   own undiscoverable trigger.
2. **Behavioral-Fixture Discrimination** (`ac-verification.md`): generic domain words do not
   distinguish WITH from CONTROL. Use named rules, specific thresholds, and output shape.
3. **AC Verification Drift** (`ac-verification.md`): run literal commands, including failure
   fixtures; do not mentally simulate regex or markdown-escaped shell.
4. **Minimal Viable Cross-Cutting Enhancement** (`handoff-design.md`): touch the Builder
   producer and existing eval consumer only. Do not widen into installer/catalog/core roles.
5. **Parallel-work attribution** (`ac-verification.md`): the worktree is already dirty from a
   separate YOLO2 task. Scope proof must inspect this task's explicit commit, not global status.

Staleness advisory was run on 2026-08-31. Some unrelated historical entries were WARN/STALE;
none invalidates the grounded files above. The capability-meta notebook already has findings,
so no new research run is required.

## 2. Background Context

### 2.1 Existing Assets to Reuse

- `.claude/skills/capability-upgrade/SKILL.md`: current deep pack construction knowledge.
- `.tad/scripts/pack-eval-runner.sh`: advisory single-fixture discriminative assertion engine.
- TAD's existing Alex → handoff → Blake → Gate chain.
- Existing framework `.claude → .agents` release mirror and target-only local-Skill handling.

### 2.2 Current vs Target

| Current | Target after Phase 1 |
|---|---|
| New capability work produces old pack scaffolding | New work produces one standard project-owned Agent Skill |
| `capability-upgrade` is a monolithic pack builder | It is a compatibility route; deep research is conditional reference content |
| Eval fixtures identify only `pack:` | Single-fixture mode also identifies `skill:` while legacy behavior stays stable |
| No safe project Skill projection helper | One bounded helper validates, projects, and verifies paired project paths |

### 2.3 Dependencies

No new external package or service. Use repository shell conventions and standard macOS/Linux
CLI tools already assumed by TAD. Agent output production remains Conductor-side.

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 — Router:** Add `$capability-builder` with an explicit Phase 1 `create` route.
- **FR2 — Protocol:** Define Alex and Blake create responsibilities, stop states, fixture design,
  materialization order, and Gate transitions.
- **FR3 — Minimal Skill:** Create exactly one canonical `.agents/skills/<name>/`; require only
  `SKILL.md`, adding resources only when evidence justifies them.
- **FR4 — Mechanical helper:** Validate, project, and verify from `<project-root> + <skill-name>`;
  derive paired paths and reject traversal, symlinks, invalid frontmatter, placeholders, forbidden
  root artifacts, and divergent targets.
- **FR5 — Eval compatibility:** Accept `skill:` in single-fixture assertions without changing
  legacy `pack:` behavior; dual-field or missing-verification fixtures must SKIP and cannot prove AC5.
- **FR6 — Behavioral proof:** Capture one byte-identical prompt, fresh CONTROL and WITH outputs,
  invocation/model/state provenance, hashes, and recomputed FAIL/PASS verdicts.
- **FR7 — Compatibility entry:** Make `$capability-upgrade` a thin route to Builder, preserve
  its useful long-form research intact, and return `LEGACY_PACK_OUT_OF_SCOPE` for existing-pack edits.
- **FR8 — Framework parity:** Keep new/modified framework Skills byte-identical across
  `.claude` and `.agents` using the existing framework direction.
- **FR9 — Routing:** Change only the capability routing row in `CLAUDE.md`.

### 3.2 Non-Functional Requirements

- Fail closed on ambiguous/destructive projection states; alter neither tree on failure.
- BSD/macOS-safe Bash; no `grep -P`; no dependency installation.
- No hidden marketplace/config writes and no background synchronization.
- No generated TAD manifest/catalog and no obsolete pack scaffold.
- Evidence must be attributable and recomputable.

### 3.3 Conflict Matrix

| Constraint triple | Simultaneously satisfiable? | Resolution |
|---|---|---|
| canonical preservation × projection byte identity × drift refusal | Yes | Project only when target absent or already identical; divergent target blocks with both trees unchanged. |
| legacy eval byte behavior × `skill:` support × invalid dual-field rejection | Yes | Branch only when `skill:` is present; preserve pack-only output; dual-field is a new invalid input. |
| fresh agent output × deterministic replay × no shell agent spawning | Yes | Conductor produces raw outputs once; shell recomputes hashes and verdict deterministically. |

## 4. Technical Design

### 4.1 Architecture

```text
explicit request or accepted SCAND
            │
            ▼
 capability-builder/SKILL.md router
            │ mandatory load on create
            ▼
 references/create-protocol.md
    Alex design → Gate 2 → handoff
            │
            ▼
    Blake canonical Skill authoring
 .agents/skills/<name>/ (authority)
            │ validate + behavioral proof
            ▼
 capability-skill.sh project
            │ derives target, never caller-selected
            ▼
 .claude/skills/<name>/ (projection)
            │ verify + Gate 3
            ▼
       Gate 4 human acceptance
```

### 4.2 Builder Router and Protocol

The main Builder Skill must contain the create trigger, explicit Alex/Blake boundary, and
mandatory load instruction. `evolve` and `package` are visible only as future phases and must
stop without pretending to run.

The create protocol must implement these states:

`REQUESTED → JUSTIFIED → DESIGNED → MATERIALIZED_CANONICAL → BEHAVIOR_PROVEN → PROJECTED → GATE_3_READY`

Named stop/block states:

- `STOPPED_WITH_REASON`: one-off, duplicate, nondiscriminative, or out-of-scope request.
- `LEGACY_PACK_OUT_OF_SCOPE`: existing pack maintenance request; no writes.
- `BLOCKED_CANONICAL_UNCHANGED`: validation failed.
- `RETURN_TO_FIXTURE_OR_SKILL`: CONTROL/WITH discrimination failed.
- `BLOCKED_BOTH_TREES_UNCHANGED`: target drift, symlink, path, or I/O problem.

### 4.3 Helper Command Contract

```text
bash .tad/scripts/capability-skill.sh validate <project-root> <skill-name>
bash .tad/scripts/capability-skill.sh project  <project-root> <skill-name>
bash .tad/scripts/capability-skill.sh verify   <project-root> <skill-name>
```

The helper resolves the physical project root and derives:

- canonical: `<root>/.agents/skills/<name>`
- projection: `<root>/.claude/skills/<name>`

It rejects non-normalized names, traversal, absolute names, path escape, symlink path chains,
symlinks anywhere in the canonical tree, and mismatched frontmatter/directory names.

`project` validates first. If target is absent, it creates one unique temporary sibling inside
the derived `.claude/skills` parent, verifies the copy, and renames it into place. If target is
identical it no-ops. If target differs it exits non-zero without merge/overwrite/delete.

For a Codex-only project where `.claude/skills` does not exist, `project` may create the missing
`.claude` and `skills` directories only after containment and symlink checks. The happy-path
fixture must start in this state. If projection later fails, remove only empty parent directories
created by this invocation and assert that neither a target Skill nor helper temp sibling remains.
Never remove a pre-existing directory.

The helper documents and tests distinct exit classes for usage, invalid canonical/path,
divergent target, and I/O failure. Exact numeric assignments are implementation-owned, stable,
shown by `--help`, and asserted by the acceptance driver.

### 4.4 Skill Validation Contract

`SKILL.md` must:

- start with a closed YAML frontmatter block;
- contain exactly one `name` and one `description`, both one-line scalars;
- use `^[a-z0-9]+(-[a-z0-9]+)*$` for name and match the directory basename;
- contain a non-empty description;
- contain none of `{{...}}`, `[TODO]`, `[TBD]`.

The Skill root must not contain `CAPABILITY.md`, `README.md`, `CHANGELOG.md`, or `install.sh`.
Generic TODO/TBD vocabulary in optional references/scripts/assets is not rejected.

### 4.5 Eval Fixture Contract

New fixtures use `skill:` plus existing `name`, `discriminative_pattern`,
`min_discriminative`, and `## Verification Command`. The verification command retains the
existing `grep -oE ... | sort -u | wc -l` shape. Subject resolution is `skill → pack → path`.

- `skill` only: valid new fixture.
- `pack` only: unchanged legacy fixture.
- neither: unchanged path fallback.
- both: `SKIP (bad fixture: conflicting subject fields)`.
- missing Verification Command: existing bad-fixture SKIP.

Since runner exit remains advisory 0, Gate 3 judges the literal verdict text and rejects SKIP.

### 4.6 State and Evidence Flow

| Data | Authority | Derived/consumer | Direction |
|---|---|---|---|
| Downstream Skill | `.agents/skills/<name>/` | `.claude/skills/<name>/` | one-way on explicit project command |
| Builder framework Skill | `.claude/skills/capability-builder/` | `.agents/skills/capability-builder/` | existing framework release direction |
| Prompt and run outputs | `.tad/evidence/.../prompt + raw` | hashes and verdicts | capture then read-only recompute |
| Legacy packs | `.tad/capability-packs/` | existing TAD pack consumers | unchanged |

No UI, API, database, registry, marketplace, or background state exists.

Generic global `release-verify.sh parity --fix` is not a downstream project projection tool;
its documented repair direction is framework Claude → Codex. Only `capability-skill.sh project`
owns the reverse project-local `.agents → .claude` projection. Do not modify the verifier.

## 5. Mandatory Questions

### MQ1 — Historical Code Search

**Answer:** Yes. The user explicitly referred to current Capability Packs and TAD mechanisms.

Grounded findings:

- `capability-upgrade/SKILL.md` currently produces `CAPABILITY.md`, `install.sh`, and a full pack tree.
- `pack-eval-runner.sh` already provides discriminative single-fixture assertion.
- `tad.sh:is_pack_skill` identifies framework-owned pack Skills through the legacy registry.
- `release-verify.sh platform-skills` reports target-only Skills as informational local Skills.

Decision: reuse TAD's role/Gate/eval/release distinctions; add only the missing Builder surface
and safe project projection helper.

### MQ2 — Existing Function Verification

| Function | Location | Verified behavior | Design use |
|---|---|---|---|
| `parse_pack()` | `.tad/scripts/pack-eval-runner.sh:56` | reads `pack:` then skill-path fallback | Modify narrowly to subject resolution and dual-field detection. |
| `parse_pattern()` | `.tad/scripts/pack-eval-runner.sh:103` | extracts grep pattern from Verification Command | Preserve; new fixtures must keep compatible section. |
| `assert_one()` | `.tad/scripts/pack-eval-runner.sh:191` | emits PASS/FAIL/SKIP with advisory semantics | Preserve verdict engine and legacy outputs. |
| `count_matches()` | `.tad/scripts/pack-eval-runner.sh:170` | distinct ERE matches with BSD-safe pipeline | Preserve unchanged. |
| `is_pack_skill()` | `tad.sh:359` | registry decides framework pack ownership | Grounding only; DO NOT MODIFY or call from helper. |
| `platform-skills` branch | `.tad/hooks/lib/release-verify.sh:969` | framework parity + local-Skill INFO | Grounding only; DO NOT MODIFY. |

New helper functions in `capability-skill.sh` do not exist yet and are explicit CREATE work;
Blake must not invent dependencies on other TAD internals.

### MQ3 — Data Flow Completeness

There is no backend/frontend. All produced fields/artifacts are consumed as follows:

| Produced data | Consumer | Missing-display concern |
|---|---|---|
| canonical Skill tree | helper validation and agent runtime | N/A |
| projected Skill tree | Claude-compatible local runtime | N/A |
| prompt/output/fixture hashes | evidence verifier and Gate 3 | none; reconcile all manifest fields |
| CONTROL/WITH verdict text | Gate 3 §9.1 | SKIP is never accepted as FAIL/PASS proof |
| helper exit/error class | Blake/test driver | documented by `--help` and asserted by cases |

### MQ4 — Visual Hierarchy

N/A. This phase has no UI.

### MQ5 — State Synchronization

| State | Authority | Projection | Trigger | Failure behavior |
|---|---|---|---|---|
| downstream Skill | `.agents/skills/<name>` | `.claude/skills/<name>` | explicit `project` after proof | refuse drift; no overwrite |
| Builder Skill | `.claude/skills/capability-builder` | `.agents/skills/capability-builder` | framework implementation/release mirror | byte-diff blocks AC |
| run evidence | raw files + manifest | recomputed verdicts | explicit acceptance driver | mismatch blocks Gate 3 |

## 6. Implementation Steps

### 6.1 Micro-Tasks

| # | Target | Operation | Local verification |
|---|---|---|---|
| 1 | `.claude/skills/capability-builder/SKILL.md` | Create small router with non-circular create load and future-mode stops | frontmatter parse + trigger grep |
| 2 | `capability-builder/references/create-protocol.md` | Encode state machine, roles, fixture/evidence flow, and exclusions | protocol anchor checks |
| 3 | `.agents/skills/capability-builder/` | Generate byte-identical framework mirror | `diff -rq` |
| 4 | `capability-upgrade/references/legacy-pack-research.md` | Capture baseline, then copy current SKILL byte-for-byte | baseline/reference SHA-256 equality |
| 5 | `capability-upgrade/SKILL.md` | Replace entry with compatibility router and legacy stop | routing fixtures/static checks |
| 6 | `.agents/skills/capability-upgrade/` | Generate byte-identical framework mirror | `diff -rq` |
| 7 | `.tad/scripts/capability-skill.sh` | Implement validate/project/verify and bounded path rules | `bash -n` + structural cases |
| 8 | `.tad/scripts/pack-eval-runner.sh` | Add skill subject and conflict detection only | frozen pack + new/invalid fixtures |
| 9 | `CLAUDE.md` | Replace only capability routing row | one-line diff assertion |
| 10 | acceptance evidence driver | Add isolated fixture project and mode-based replay script | each driver mode PASS |
| 11 | behavioral runs | Capture identical-prompt CONTROL/WITH and provenance | hashes reconcile; FAIL/PASS |
| 12 | reviews/completion | Run Ralph Loop, required reviews, commit explicit paths, Gate 3 | all §9.1 rows PASS |

### 6.2 Required Execution Order

1. Capture a content manifest of every protected path, the SHA-256 of the current
   `capability-upgrade/SKILL.md`, and a non-SKIP baseline from the pinned legacy fixture.
2. Create framework Builder source, protocol, and compatibility reference/source.
3. Generate their `.agents` mirrors from `.claude`; never hand-diverge them.
4. Implement helper and its structural negative cases.
5. Modify eval subject parsing and run legacy/new/invalid compatibility cases.
6. Update only the capability row in `CLAUDE.md`.
7. Create isolated downstream fixture, canonical Skill, and canonical prompt.
8. Run fresh CONTROL, then WITH, recording manifest and content hashes.
9. Project only after validation and behavior proof; verify byte identity.
10. Run all acceptance modes and required independent reviews.
11. Recompute the protected-path manifest, require zero delta, inventory the projection parent
    for leftover helper temp siblings, stage only explicit §7 task paths, commit once, record the
    commit hash, and run scope mode against both the commit and manifests.
12. Write completion report and Gate 3 evidence without absorbing unrelated dirty work. If a
    protected manifest differs due to another actor, stop for explicit attribution; never silently
    re-baseline or widen the allowlist.

## 7. File Structure

### 7.1 Files to Create

```text
.claude/skills/capability-builder/SKILL.md
.claude/skills/capability-builder/references/create-protocol.md
.agents/skills/capability-builder/SKILL.md
.agents/skills/capability-builder/references/create-protocol.md
.claude/skills/capability-upgrade/references/legacy-pack-research.md
.agents/skills/capability-upgrade/references/legacy-pack-research.md
.tad/scripts/capability-skill.sh
.tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh
.tad/evidence/acceptance-tests/capability-builder-create/fixture-project/**
.tad/evidence/acceptance-tests/capability-builder-create/fixtures/**
.tad/evidence/acceptance-tests/capability-builder-create/prompt/task.md
.tad/evidence/acceptance-tests/capability-builder-create/run-manifest.json
.tad/evidence/acceptance-tests/capability-builder-create/raw/**
.tad/evidence/acceptance-tests/capability-builder-create/verdict/**
.tad/evidence/acceptance-tests/capability-builder-create/structural/**
.tad/evidence/acceptance-tests/capability-builder-create/regression/**
.tad/evidence/acceptance-tests/capability-builder-create/scope/**
```

### 7.2 Files to Modify

```text
.claude/skills/capability-upgrade/SKILL.md
.agents/skills/capability-upgrade/SKILL.md
.tad/scripts/pack-eval-runner.sh
CLAUDE.md
.tad/active/epics/EPIC-20260831-capability-builder-v1.md  # phase status only
```

Process artifacts also include this handoff, its completion report, review evidence, and Gate reports.

### 7.3 Grounded Against

Alex read the first 50 lines or relevant function ranges on 2026-08-31:

- `.claude/skills/capability-upgrade/SKILL.md` — current old-pack output and five-stage entry.
- `.agents/skills/capability-upgrade/SKILL.md` — byte-identical current mirror.
- `.tad/scripts/pack-eval-runner.sh` — safety header and parser/assertion functions at lines 56–225.
- `CLAUDE.md` — routing table; capability row currently at line 40.
- `tad.sh` lines 358–368 — `is_pack_skill`; grounding only, protected.
- `.tad/hooks/lib/release-verify.sh` lines 969–1018 — framework parity/local-Skill handling; grounding only, protected.

## 8. Testing Requirements

### 8.1 Structural Cases

The acceptance driver must cover valid minimal Skill plus malformed/missing frontmatter,
extra frontmatter key, duplicate key, folder/name mismatch, invalid name, empty description,
SKILL scaffold token, forbidden root artifact, traversal/absolute name, symlink path chain,
symlink inside source tree, missing source, divergent target, copy failure, identical no-op,
absent-target success, absent `.claude/skills` parent success, and each documented exit class.

For every failing projection case, compare before/after tree hashes plus the projection-parent
directory inventory and prove no mutation and no helper temporary sibling remains.

### 8.2 Eval Compatibility Cases

- pinned fixture `.claude/skills/academic-research/examples/systematic-review-depth.md` plus a
  frozen output containing enough discriminative markers to produce a non-SKIP verdict: capture
  exact pre-change verdict text and advisory exit 0, then require byte-identical post-change result;
- new `skill:` fixture: CONTROL FAIL, WITH PASS;
- no-subject path fallback: unchanged;
- `skill + pack`: bad-fixture SKIP;
- no Verification Command: bad-fixture SKIP;
- SKIP cannot satisfy the behavior acceptance mode.

### 8.3 Integration / E2E

Use the isolated fixture project to validate → behavior-prove → project → verify one Skill.
CONTROL and WITH use one prompt file; the manifest must reconcile prompt, Skill, fixture,
output hashes, harness/model identity, and enabled-state invocation descriptions.

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| Fresh agent CONTROL/WITH requires harness execution | two equivalent runs with Skill state isolated | Conductor runs and records exact invocation/state | none; hand-authored outputs are not equivalent | missing provenance blocks AC5 |
| Dirty worktree from parallel YOLO2 task | stage and inspect explicit task paths only | use this task's commit manifest | documented attribution for external changes | global status cannot be used to fail/pass scope |
| Shell portability | run syntax and repository portability checks | fix helper/eval shell within scope | no dependency-based replacement | unresolved shell defect blocks Gate 3 |
| Required Layer 2 reviews | code, security, spec, test review | invoke independent reviewers | equivalent independent reviewer with evidence | missing review blocks Gate 3/4 |

### 8.5 Feedback Collection

N/A — code/protocol task; `feedback_required: false`.

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/alex/capability-builder-create/code-reviewer.md
  - .tad/evidence/reviews/alex/capability-builder-create/architecture-reviewer.md
gate_verdicts:
  - .tad/evidence/reviews/gate2/capability-builder-create.md
  - .tad/evidence/reviews/gate3/capability-builder-create.md
completion:
  - .tad/active/handoffs/COMPLETION-20260831-capability-builder-phase1-create.md
blake_reviews:
  - .tad/evidence/reviews/blake/capability-builder-create/code-reviewer.md
  - .tad/evidence/reviews/blake/capability-builder-create/security-auditor.md
  - .tad/evidence/reviews/blake/capability-builder-create/spec-compliance.md
  - .tad/evidence/reviews/blake/capability-builder-create/test-runner.md
perf_evidence: []
fixture_results:
  - .tad/evidence/acceptance-tests/capability-builder-create/run-manifest.json
  - .tad/evidence/acceptance-tests/capability-builder-create/raw/control.md
  - .tad/evidence/acceptance-tests/capability-builder-create/raw/with-skill.md
  - .tad/evidence/acceptance-tests/capability-builder-create/verdict/control.txt
  - .tad/evidence/acceptance-tests/capability-builder-create/verdict/with-skill.txt
  - .tad/evidence/acceptance-tests/capability-builder-create/regression/legacy-pack.txt
  - .tad/evidence/acceptance-tests/capability-builder-create/scope/implementation-commit.txt
  - .tad/evidence/acceptance-tests/capability-builder-create/scope/protected-before.sha256
  - .tad/evidence/acceptance-tests/capability-builder-create/scope/protected-after.sha256
dogfood: []
knowledge_updates:
  - .tad/evidence/journal/capability-builder-create-2026-08-31.md
not_applicable:
  perf_evidence: "No performance-sensitive runtime path; helper operates on one small Skill tree."
  dogfood: "Real Voice Studio dogfood is Epic Phase 4; Phase 1 uses an isolated downstream fixture."
```

## 9. Acceptance Criteria

Completion requires all §9.1 rows to pass. A SKIP verdict is not a substitute for the
required CONTROL FAIL or WITH PASS.

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---|---|---|---|---|
| AC1 | New and modified shell parses | post-impl-verifiable | `bash -n .tad/scripts/capability-skill.sh && bash -n .tad/scripts/pack-eval-runner.sh && bash -n .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh` | exit 0 | post-impl; raw command syntax-checked by Alex against existing runner shape |
| AC2 | Valid Skill validates and projects identically | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh projection` | `PASS projection` and exit 0 | post-impl |
| AC3 | Invalid/path/symlink/drift/I-O cases fail without mutation or temp residue | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh structural` | all named cases and exit classes PASS; parent inventories match; no helper temp sibling remains | post-impl |
| AC4 | Eval remains compatible and rejects ambiguous/bad fixtures | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh eval-compat` | legacy exact baseline preserved; skill/fallback valid; dual/missing-verification SKIP | post-impl |
| AC5 | Fresh attributable CONTROL fails and WITH passes | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh behavior` | hashes/provenance reconcile; verdicts are FAIL then PASS; neither SKIP | post-impl |
| AC6 | Compatibility route is bounded and legacy research is preserved exactly | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh routing` | new work routes create; legacy edit stops; no old scaffold route; baseline Skill SHA equals preserved reference SHA | post-impl |
| AC7 | Framework Skill mirrors are byte-identical | post-impl-verifiable | `diff -rq .claude/skills/capability-builder .agents/skills/capability-builder && diff -rq .claude/skills/capability-upgrade .agents/skills/capability-upgrade` | exit 0, no output | post-impl |
| AC8 | Obsolete scaffold absent in fixture output | post-impl-verifiable | `test ! -e .tad/evidence/acceptance-tests/capability-builder-create/fixture-project/.agents/skills/example-skill/CAPABILITY.md && test ! -e .tad/evidence/acceptance-tests/capability-builder-create/fixture-project/.agents/skills/example-skill/README.md && test ! -e .tad/evidence/acceptance-tests/capability-builder-create/fixture-project/.agents/skills/example-skill/CHANGELOG.md && test ! -e .tad/evidence/acceptance-tests/capability-builder-create/fixture-project/.agents/skills/example-skill/install.sh` | exit 0 | post-impl |
| AC9 | Only capability routing row changes in CLAUDE.md | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh claude-routing` | `PASS claude-routing`; exactly one authorized row differs | post-impl |
| AC10 | Task commit is bounded and protected surfaces have zero content delta | post-impl-verifiable | `bash .tad/evidence/acceptance-tests/capability-builder-create/run-acceptance.sh scope` | exact commit paths are within §7 and protected before/after manifests are identical; no unstaged protected edit can hide behind commit-only proof | post-impl |
| AC11 | Framework verification still recognizes local Skill distinction | pre-impl-verifiable | `rg -n 'local-skill:.*target-only, not framework-owned|platform-skills PASS' .tad/hooks/lib/release-verify.sh` | both existing anchors present | verified 2026-08-31: lines 1006 and 1018 |
| AC12 | Existing legacy pack ownership remains registry-based | pre-impl-verifiable | `rg -n 'is_pack_skill\(\)|pack-registry.yaml' tad.sh` | existing function and registry anchor present | verified 2026-08-31: lines 359 and 363 |

### AC Dry-Run Log

- AC1: post-implementation helper/driver do not exist; existing `pack-eval-runner.sh` passes
  `bash -n`. Command shape is valid; Blake reruns full chain.
- AC2–AC10: post-implementation artifacts required. Each raw command is shell-valid by inspection;
  Blake must execute literally after creation. No future artifacts were mocked.
- AC11: pre-implementation command executed; both anchors found at lines 1006 and 1018.
- AC12: pre-implementation command executed; anchors found at lines 359 and 363.

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| design code-reviewer | P1 arbitrary path/symlink write boundary | §4.3, FR4, AC3 | Resolved in design/handoff |
| design code-reviewer | P1 behavioral evidence lacked provenance | §4.6, FR6, AC5 | Resolved in design/handoff |
| design code-reviewer | P1 legacy-pack compatibility behavior unspecified | §4.2 stop states, FR7, AC6 | Resolved in design/handoff |
| design reviewers | P1 new fixture could SKIP and dual subject was ambiguous | §4.5, FR5, AC4 | Resolved in design/handoff |
| design code-reviewer | P2 placeholder scan too broad | §4.4 | Resolved in design/handoff |
| handoff code-reviewer | P1 commit-only scope could miss unstaged protected edit | §6.2 step 11, §8.4, AC10 | Resolved |
| handoff code-reviewer | P1 temp sibling cleanup and exit classes were not enforced | §4.3, §8.1, AC3 | Resolved |
| handoff code-reviewer | P1 legacy regression fixture could be SKIP-only | §8.2, AC4 | Resolved |
| handoff architecture-reviewer | P1 absent Claude parent behavior was unspecified | §4.3, §8.1, AC2/AC3 | Resolved |
| handoff architecture-reviewer | P1 preserved research had no acceptance check | §6.1 task 4, AC6 | Resolved |
| handoff architecture-reviewer | P2 global parity fix could be mistaken for reverse projection | §4.6 | Resolved |

### Experts Selected

1. **code-reviewer** — shell safety, executable ACs, regression and evidence quality.
2. **architecture-reviewer** — TAD core isolation, SSOT directions, state/data flow, phase boundaries.

### Overall Assessment

- Design code-reviewer: CONDITIONAL PASS, no P0; all P1 integrated.
- Design architecture-reviewer: CONDITIONAL PASS, no P0; all P1 integrated.
- Handoff code-reviewer: CONDITIONAL PASS, no P0; all P1 integrated.
- Handoff architecture-reviewer: CONDITIONAL PASS, no P0; all P1 integrated.

## 10. Important Notes and Warnings

### 10.1 Critical Warnings

- Do not modify `tad.sh`, Alex, Blake, Gate, hooks, release verifier, pack registry, collision/drift
  scanners, marketplace state, or `.tad/capability-packs/`.
- Do not run retirement, Evolve, Plugin, Voice Studio, or DSH work in this handoff.
- Do not auto-write a personal marketplace or any external project.
- Do not stage unrelated YOLO2 changes. Use explicit task paths, never `git add -A`.
- Do not treat runner exit 0 as proof of PASS; parse and assert the verdict text.
- Do not project before CONTROL/WITH proof succeeds.

### 10.2 Known Constraints

- Phase 1 frontmatter intentionally supports simple one-line `name` and `description` only.
- The helper is for project-local paired Agent Skill paths, not a general file sync tool.
- Existing legacy packs remain installed/owned exactly as before; their future retirement is separate.
- Existing project Skill evolution is not available until Epic Phase 2.

### 10.3 Reviewer Guidance for Blake

At minimum use independent code, security, spec-compliance, and test review because this task
adds a bounded filesystem writer and changes the assertion parser. Reviewers must not redesign
the task into a general sync/catalog system.

## 11. Decision Rationale

| Option | Decision | Reason |
|---|---|---|
| Continue Capability Pack as new artifact | Reject | keeps TAD as domain-content owner and preserves maintenance burden |
| Create a new Capability database/catalog | Reject | unnecessary state and ownership system before proven need |
| Project-owned Agent Skill | Select | standard carrier, local ownership, minimal artifact |
| Plugin in Phase 1 | Reject for now | packaging is a separate explicit concern in Phase 3 |
| Arbitrary source/target sync helper | Reject | expands blast radius and weakens ownership semantics |
| Project-root + name paired helper | Select | mechanically encodes the one intended direction |

## 12. Blake Questions

No open implementation choice. If any requirement appears to require a protected file or a
second ownership system, return the handoff to Alex instead of widening scope.

**Handoff Created By:** Alex  
**Date:** 2026-08-31  
**Status:** EXPERT REVIEW COMPLETE — READY FOR IMPLEMENTATION AFTER HUMAN HANDOVER
