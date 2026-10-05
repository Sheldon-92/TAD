# Capability Builder v1 — Phase 1 Create Design

**Epic:** `EPIC-20260831-capability-builder-v1`  
**Owner:** Alex  
**Status:** Gate 4 accepted; archived 2026-09-02  
**Scope:** Phase 1 only

## 1. Design Outcome

Phase 1 adds one TAD-native entry, `$capability-builder create`, for designing and materializing exactly one project-owned Agent Skill. It reuses the existing Alex → handoff → Blake → Gate chain. It does not create a new Capability Pack format, a registry, a marketplace, or a second TAD delivery system.

The capability's editable authority belongs to the downstream project:

```text
project evidence / accepted SCAND / explicit request
                    │
                    ▼
          $capability-builder create
                    │
          Alex design + Gate 2 + handoff
                    │
                    ▼
       Blake creates canonical Agent Skill
          .agents/skills/<name>/
                    │
              validate + eval
                    │
                    ▼
       safe generated Claude projection
          .claude/skills/<name>/
                    │
                    ▼
       Gate 3 evidence + human Gate 4
```

## 2. Gate 1 Result

| Requirement check | Result | Evidence |
|---|---|---|
| Problem defined | PASS | Old pack-style construction creates excessive ownership and maintenance cost; subprojects lack an immediate project-owned capability-building path. |
| User identified | PASS | A TAD-enabled subproject owner developing a reusable capability from local project evidence. |
| Scope bounded | PASS | Create only; Evolve, Plugin packaging, legacy retirement, DSH, catalog work, and TAD core changes are excluded. |
| ACs verifiable | PASS | Every Phase 1 AC below has a deterministic command or a fresh WITH/CONTROL assertion. |

**Gate 1:** PASS. No further elicitation is required.

## 3. Architecture Decisions

### D1. Capability is an outcome; Agent Skill is the Phase 1 artifact

No `CAPABILITY.md`, TAD-specific manifest, generated README, generated CHANGELOG, or per-Skill `install.sh` is introduced. The minimum valid output is one standard Agent Skill directory containing `SKILL.md`.

### D2. Two ownership directions are intentional

| Surface | Editable authority | Generated copy | Reason |
|---|---|---|---|
| TAD framework Skills, including Builder | `.claude/skills/` | `.agents/skills/` | Preserve TAD's current release invariant. |
| Builder-created downstream project Skills | `.agents/skills/` | `.claude/skills/` | Make the source project, not TAD, the owner of new capabilities. |

The Builder must state this distinction explicitly. It must not change `tad.sh`. Existing release verification already treats target-only Skills as local project Skills rather than framework-owned pack Skills.

### D3. TAD remains the process harness

The Builder is not a replacement for Alex, Blake, handoffs, Gates, Ralph, SCAND, project knowledge, journals, or evidence. It routes work through those mechanisms:

- Alex decides whether a Skill is justified, selects the smallest useful structure, defines the behavioral fixture, and writes the implementation handoff.
- Blake creates the Skill, captures CONTROL and WITH outputs, runs validation/projection, completes the Ralph Loop, and supplies Gate 3 evidence.
- Gate 4 remains human business acceptance.

### D4. Mechanical code has a deliberately narrow boundary

`.tad/scripts/capability-skill.sh` performs structure validation and safe projection only. It never generates domain instructions, decides what a capability should do, invokes an agent, edits evidence, or changes TAD configuration.

### D5. Evaluation reuse is backward-compatible and bounded

The existing single-fixture assertion path in `.tad/scripts/pack-eval-runner.sh` remains the assertion engine. Phase 1 adds support for `skill:` as an alias for the existing `pack:` subject field. Existing `pack:` fixtures, batch discovery, advisory exit behavior, thresholds, and legacy output remain unchanged.

### D6. Deep research becomes conditional progressive disclosure

The current `capability-upgrade` deep-research material is preserved in a reference file. `$capability-upgrade` becomes a thin compatibility route to `$capability-builder`; Builder loads the legacy research reference only when local evidence is insufficient and a real research gap is identified.

## 4. Public Workflow Contract

### 4.1 Entry conditions

`create` may start from either:

1. an explicit human request backed by project-local materials; or
2. one accepted SCAND and its linked evidence.

It must stop without creating a Skill when:

- the requested behavior is a one-off task with no plausible reuse;
- the intended behavior cannot be stated as a discriminative fixture;
- the proposed Skill duplicates an existing project Skill without a concrete gap;
- the request requires changing TAD core, retiring legacy packs, packaging a Plugin, or introducing DSH.

Stopping here is a design result, not a failure of the helper script.

### 4.2 Create state machine

```text
REQUESTED
   │ inspect local evidence + existing Skills
   ├── not reusable / duplicate / out of scope ──► STOPPED_WITH_REASON
   ▼
JUSTIFIED
   │ define name, boundary, fixture, CONTROL/WITH threshold
   ▼
DESIGNED
   │ Gate 2 + approved handoff
   ▼
MATERIALIZED_CANONICAL
   │ validate
   ├── invalid ──► BLOCKED_CANONICAL_UNCHANGED
   ▼
BEHAVIOR_PROVEN
   │ CONTROL fails and WITH passes
   ├── nondiscriminative ──► RETURN_TO_FIXTURE_OR_SKILL
   ▼
PROJECTED
   │ verify byte identity
   ├── divergent target ──► BLOCKED_BOTH_TREES_UNCHANGED
   ▼
GATE_3_READY ──► Gate 4 human acceptance
```

Projection happens only after canonical validation and behavioral proof. A pre-existing divergent Claude target is never overwritten.

## 5. Component Specifications

### C1. `$capability-builder` Skill router

**Framework source:** `.claude/skills/capability-builder/SKILL.md`  
**Framework mirror:** `.agents/skills/capability-builder/SKILL.md`

Responsibilities:

- detect `create`, `evolve`, or `package` intent;
- execute only `create` in Phase 1;
- label `evolve` and `package` as future Epic phases without pretending they exist;
- declare the Alex/Blake role boundary and mandatory Gates;
- load `references/create-protocol.md` whenever `create` is selected;
- load legacy deep-research guidance only after a named evidence gap is found;
- never directly author a downstream Skill while Alex is active.

The `create` trigger must be present in the main SKILL body so progressive loading is non-circular.

### C2. Create protocol reference

**Path:** `.claude/skills/capability-builder/references/create-protocol.md`, mirrored to `.agents`.

Responsibilities:

- evidence intake and duplicate check;
- reusable-capability justification;
- canonical name and minimal resource selection;
- behavioral fixture design;
- Alex handoff requirements;
- Blake materialization order;
- CONTROL/WITH evidence capture;
- safe projection and Gate transitions;
- explicit out-of-scope routes.

Minimal structure is adaptive:

```text
.agents/skills/<name>/
└── SKILL.md                 # always required
    references/              # only when supporting knowledge is too large or conditional
    scripts/                 # only when deterministic reusable execution is required
    assets/                  # only when the Skill consumes stable project-owned assets
```

Empty directories and speculative files are forbidden.

### C3. Compatibility route

**Path:** `.claude/skills/capability-upgrade/SKILL.md`, mirrored to `.agents`.

The file becomes a thin compatibility Skill that:

- explains that new capability work uses `$capability-builder`;
- routes new creation to `create` and existing project Skill changes to the future `evolve` phase;
- loads preserved legacy research material only for an evidenced research gap;
- does not produce the old Capability Pack scaffold for new work.

An explicit request to maintain an existing legacy Capability Pack must return a named
`LEGACY_PACK_OUT_OF_SCOPE` stop result with no writes. It explains that Phase 1 neither
retires nor edits legacy packs and asks the human to choose a separately scoped legacy
maintenance task or a new project-owned Skill. It must never silently reinterpret an
existing-pack upgrade as Skill creation.

The current long-form research material moves without semantic loss to:

`capability-upgrade/references/legacy-pack-research.md`

The reference is an exact byte copy of the pre-change `capability-upgrade/SKILL.md`.
The thin compatibility entry is authored only after its baseline hash has been captured;
the acceptance driver compares that baseline to the preserved reference.

### C4. Skill validation/projection helper

**Path:** `.tad/scripts/capability-skill.sh`

Public commands:

```text
bash .tad/scripts/capability-skill.sh validate <project-root> <skill-name>
bash .tad/scripts/capability-skill.sh project  <project-root> <skill-name>
bash .tad/scripts/capability-skill.sh verify   <project-root> <skill-name>
```

The helper resolves one physical project root and derives both paths itself:

```text
<project-root>/.agents/skills/<skill-name>  # canonical
<project-root>/.claude/skills/<skill-name>  # projection
```

Arbitrary source/target pairs are not part of the API. The command rejects `..`/absolute
skill names, basename mismatch, any derived path escaping the resolved project root, and
symlinks in the canonical tree or in the existing `.agents/skills` and `.claude/skills`
path chain. This prevents a safe-looking projection from writing through an external link.

#### `validate`

Must fail non-zero unless all conditions hold:

- argument is a directory containing `SKILL.md`;
- frontmatter starts on line 1 and has a closing fence;
- frontmatter contains exactly `name` and `description`, once each;
- `name` matches `^[a-z0-9]+(-[a-z0-9]+)*$` and equals the directory basename;
- `description` is non-empty;
- no deliberate scaffold marker appears in `SKILL.md` (`{{...}}`, `[TODO]`, or `[TBD]`);
- no forbidden generated artifact exists at the Skill root: `CAPABILITY.md`, `README.md`, `CHANGELOG.md`, `install.sh`.

References, scripts, and assets are not searched for generic `TODO:`/`TBD:` vocabulary,
because those strings can be legitimate domain content. The Phase 1 contract intentionally
supports simple one-line YAML scalar values only. A richer YAML validator is not required
for the minimal standard frontmatter.

#### `project`

Preconditions: canonical `validate` passes.

| Projection state | Result |
|---|---|
| target absent | create a uniquely named temporary sibling under the derived `.claude/skills/` parent, verify it, then rename into place; exit 0 |
| target byte-identical | no-op; exit 0 |
| target exists and differs | print a drift error; exit non-zero; alter neither tree |
| target parent unavailable / copy fails | clean temporary sibling if created; exit non-zero; canonical remains unchanged |

If `.claude/skills/` is absent, `project` may create the missing `.claude` and `skills`
directories only after containment and symlink checks. The happy-path fixture begins in
this Codex-only state. On later failure, the helper removes only empty parent directories
that this invocation created and proves no temporary sibling remains. No merge, overwrite,
deletion of pre-existing paths, reverse sync, caller-selected target, or symlink traversal
is permitted.

#### `verify`

Runs `validate` on canonical and then recursively compares canonical and projection. Missing or differing projection exits non-zero. It never modifies files.

Exit codes must distinguish at least usage error, invalid canonical, divergent target, and I/O failure; exact numeric values are implementation-owned but documented in `--help` and tested.

### C5. Behavioral assertion compatibility

**Path:** `.tad/scripts/pack-eval-runner.sh`

Only the fixture subject parsing changes:

````markdown
---
name: representative-task
skill: example-skill
discriminative_pattern: 'marker-a|marker-b|marker-c'
min_discriminative: 3
---

## Verification Command

```bash
grep -oE 'marker-a|marker-b|marker-c' "${OUTPUT_FILE}" | sort -u | wc -l
```
````

The fixture retains the existing compatible combined assertion shape;
`discriminative_pattern` remains the primary verdict source.

Resolution order for the displayed subject is `skill:` → `pack:` → directory fallback. A fixture must not declare both fields; the Builder protocol forbids that ambiguity. Legacy fixtures need no edits.

The runner also detects this ambiguity mechanically: a fixture containing both `skill:`
and `pack:` reports `SKIP (bad fixture: conflicting subject fields)`. A fixture missing
`## Verification Command` remains `SKIP (bad fixture)` under current runner semantics.
Neither SKIP result may be used as Phase 1 behavioral evidence.

The assertion engine remains advisory because the Conductor, not shell, produces agent outputs. Gate 3 blocks through its §9.1 ACs based on the recomputed verdict and raw evidence.

## 6. Evidence Model

No new registry or manifest is introduced. Evidence uses the existing TAD boundary:

```text
.tad/evidence/acceptance-tests/capability-builder-create/
├── fixture-project/                 # isolated downstream-project simulation
├── fixtures/example-skill.md        # behavioral assertion fixture
├── prompt/task.md                    # one canonical prompt used for both runs
├── run-manifest.json                 # harness/model/command/state + hashes
├── raw/control.md                   # fresh no-Skill output
├── raw/with-skill.md                # fresh Skill-enabled output
├── verdict/control.txt              # recomputed assertion: FAIL
├── verdict/with-skill.txt           # recomputed assertion: PASS
├── structural/                      # validation/projection cases
├── regression/                      # legacy pack fixture results
└── scope/                           # task-commit allowlist + protected before/after hashes
```

The raw CONTROL and WITH outputs must come from the byte-identical canonical prompt.
Their difference is Skill availability, not a changed prompt or hidden hints. The run
manifest records the prompt hash, canonical Skill-tree hash, harness and model identity,
exact enabled/disabled invocation description, run timestamps, output hashes, and fixture
hash. The fixture's discriminative markers must represent capability-specific behavior
rather than generic quality language. The manifest is evidence for this run, not a new
Capability registry or artifact manifest.

## 7. Data and State Flow

| Data | Authority | Derived consumer | Write direction |
|---|---|---|---|
| Skill instructions/resources | `.agents/skills/<name>/` in downstream project | `.claude/skills/<name>/` | canonical → projection only |
| Framework Builder protocol | `.claude/skills/capability-builder/` in TAD | `.agents/skills/capability-builder/` | framework release mirror only |
| Behavioral fixture and outputs | `.tad/evidence/...` | Gate 3 §9.1 verdict | evidence → gate |
| Legacy pack definitions | `.tad/capability-packs/` | existing installer/eval flows | unchanged |

There is no database state, registry state, marketplace state, or background synchronization.

## 8. Files in Phase 1

### Create

- `.claude/skills/capability-builder/SKILL.md`
- `.claude/skills/capability-builder/references/create-protocol.md`
- `.agents/skills/capability-builder/SKILL.md` (generated framework mirror)
- `.agents/skills/capability-builder/references/create-protocol.md` (generated framework mirror)
- `.claude/skills/capability-upgrade/references/legacy-pack-research.md`
- `.agents/skills/capability-upgrade/references/legacy-pack-research.md` (generated framework mirror)
- `.tad/scripts/capability-skill.sh`
- `.tad/evidence/acceptance-tests/capability-builder-create/*`

### Modify

- `.claude/skills/capability-upgrade/SKILL.md`
- `.agents/skills/capability-upgrade/SKILL.md` (generated framework mirror)
- `.tad/scripts/pack-eval-runner.sh`
- `CLAUDE.md` — capability routing line only

### Protected / no modification

- `tad.sh`
- `.claude/skills/alex/` and `.agents/skills/alex/`
- `.claude/skills/blake/` and `.agents/skills/blake/`
- `.claude/skills/gate/` and `.agents/skills/gate/`
- `.tad/capability-packs/`
- pack registry, installer, collision scan, drift scan, and marketplace state

## 9. Phase 1 Acceptance Contract

| AC | Criterion | Verification shape |
|---|---|---|
| AC1 | Valid canonical Skill passes | run `capability-skill.sh validate` on isolated fixture; exit 0 |
| AC2 | Canonical projects byte-identically | run `project`, then `verify` and `diff -rq`; all exit 0 |
| AC3 | Invalid structure fails safely | table-driven cases for malformed frontmatter, name mismatch, placeholder, forbidden root artifact, outside-root name, and symlink path/tree; each non-zero |
| AC4 | Existing divergent Claude target is preserved | hash both trees before/after failed `project`; hashes unchanged |
| AC5 | Behavior is discriminative and attributable | fresh CONTROL reports FAIL and fresh WITH reports PASS; prompt/output/fixture/Skill hashes and enabled-state invocation provenance reconcile |
| AC6 | Eval compatibility and invalid-fixture behavior are explicit | pinned academic-research `pack:` fixture produces a non-SKIP frozen verdict/output/exit unchanged; `skill:` works; fallback works; dual-field and missing-verification fixtures SKIP and cannot satisfy AC5 |
| AC7 | Compatibility entry routes safely and preserves knowledge | routing fixtures confirm new work routes to Builder while legacy maintenance stops with no writes; pre-change Skill hash equals preserved legacy reference hash |
| AC8 | Framework mirrors are identical | `diff -rq` for both modified/created framework Skill trees exits 0 |
| AC9 | Protected TAD surfaces are untouched | task-commit allowlist plus start/end content manifests for every protected path |
| AC10 | No obsolete scaffold is emitted | isolated output lacks `CAPABILITY.md`, root README/CHANGELOG, and `install.sh` |
| AC11 | Shell behavior is portable and syntactically valid | `bash -n` plus repository shell portability checks applicable to the new/modified scripts |

## 10. Explicit Non-Goals

- No retirement or conversion of the existing 25 Capability Packs.
- No Plugin scaffold or marketplace mutation.
- No DeepSeek Harness adapter.
- No multi-Skill bundle creation.
- No central capability catalog or lifecycle database.
- No scheduled refresh or autonomous evolution.
- No edit to TAD role semantics, Gate definitions, Ralph Loop, hooks, installer, or release direction.
- No Voice Studio file changes in this phase.

## 11. Risks and Controls

| Risk | Control |
|---|---|
| Dual-tree drift | one-way ownership declaration; refuse divergent target; byte-identity verification |
| Validation theater | fresh same-prompt CONTROL/WITH outputs; capability-specific discriminative markers |
| Builder becomes another heavy pack system | one Skill per run; minimal adaptive structure; no manifest/catalog/scaffold extras |
| Progressive loading silently skips create protocol | create trigger and mandatory reference load live in main SKILL body |
| Compatibility alias loses useful knowledge | move legacy research content intact to a conditional reference |
| TAD core regression | protected-path scope proof and legacy eval regression fixture |
| Shell portability regression | BSD/macOS-safe constructs, `bash -n`, and applicable portability lint |
| Arbitrary path or symlink write | derive paired paths from project root/name; containment checks; reject symlink chains |
| Fabricated or incomparable behavior evidence | canonical prompt plus per-run command/state/model and content hashes |

## 12. Open Design Issues

None requiring a product decision. Expert review may refine implementation details, but any proposal that adds a registry, changes `tad.sh`, rewrites role behavior, or widens beyond Phase 1 is out of bounds and must return to Alex rather than being integrated.
