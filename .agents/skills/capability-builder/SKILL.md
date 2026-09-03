---
name: capability-builder
description: TAD-native project-owned Agent Skill creation via create with behavioral proof and safe projection to Claude runtime.
---

# $capability-builder — Project-Owned Agent Skill Builder (Phase 1 Create + Phase 2 Evolve + Phase 3 Package)

Use for creating exactly one project-owned Agent Skill that is validated, behavior-proven, and safely projected from `.agents/skills/<name>/` to `.claude/skills/<name>/`; for signal-driven evolution; and for explicit one-Skill/one-Plugin packaging.

## Ownership Directions

- **Framework Skills (this Builder, alex, blake, gate):** editable authority `.claude/skills/` → generated mirror `.agents/skills/` (existing framework release direction).
- **Builder-created downstream Skills:** editable authority `.agents/skills/<name>/` → generated projection `.claude/skills/<name>/` via explicit `capability-skill.sh project`. Only `capability-skill.sh project` owns this direction. `release-verify.sh parity --fix` is `Claude→Codex` only and must not be used for downstream projection.

## Router — Phase Selection

On activation, detect intent:

- `$capability-builder create` — Phase 1 (this handoff). Valid. Execute create protocol below.
- `$capability-builder evolve` — Phase 2. Valid. You MUST read `references/evolve-protocol.md` before any design or file work, then follow the protocol.
- `$capability-builder package` — Phase 3. Valid. You MUST read `references/package-openai-plugin.md` before any design or file work, then follow the protocol.

If no explicit phase is given, ask via AskUserQuestion: `create | evolve | package`, then route.

## Create — Mandatory Protocol Load (non-circular trigger)

**When `create` is selected, you MUST read `references/create-protocol.md` before any design or file work.** This load is mandatory. The protocol defines Alex/Blake boundaries, state machine, fixture design, materialization order, and Gate transitions. The trigger lives in this body (circular-trigger safe): without this line, `create` would be undiscoverable.

Progressive disclosure:
- `references/create-protocol.md` — always on `create` (state machine + roles + evidence).
- `references/evolve-protocol.md` — always on `evolve` (trigger enum + fixture-first + stops).
- `references/package-openai-plugin.md` — always on `package` (scaffold/validate/install/drift).
- `../capability-upgrade/references/legacy-pack-research.md` — only after a named evidence gap is found (deep research conditional). See protocol for when.

## Role Boundary (Alex vs Blake)

- **Alex:** decides if a Skill is justified, selects minimal structure, defines discriminative fixture + CONTROL/WITH threshold, writes handoff. Never directly authors a downstream Skill while active.
- **Blake:** authors canonical `.agents/skills/<name>/SKILL.md`, captures CONTROL/WITH with identical prompt, runs `capability-skill.sh validate` and eval, projects only after `BEHAVIOR_PROVEN`, verifies byte identity, completes Ralph Loop, supplies Gate 3 evidence.
- **Gates:** Gate 2 before handoff, Gate 3 after Ralph Loop, Gate 4 human acceptance.

## Out-of-Scope Stops

Return `STOPPED_WITH_REASON` (no writes) when:
- one-off task with no plausible reuse;
- behavior cannot be stated as discriminative fixture;
- duplicates existing Skill without concrete gap;
- requests TAD core change, legacy pack retirement, Plugin/marketplace work, catalog, or DSH.

Return `LEGACY_PACK_OUT_OF_SCOPE` for existing Capability Pack maintenance (route to `capability-upgrade` compatibility path).

## Entry Conditions

`create` may start from:
1. explicit human request with project-local materials; or
2. one accepted SCAND plus linked evidence.

## Minimal Structure (adaptive)

```
.agents/skills/<name>/
└── SKILL.md                 # always required
    references/              # only when knowledge too large/conditional
    scripts/                 # only when deterministic execution required
    assets/                  # only when Skill consumes stable assets
```

No empty directories. No speculative files. No `CAPABILITY.md`, root `README.md`/`CHANGELOG.md`, or per-Skill `install.sh`.

## References

- `references/create-protocol.md` — create state machine and evidence flow (mandatory on create).
- `references/evolve-protocol.md` — evolve state machine and evidence flow (mandatory on evolve).
- `references/package-openai-plugin.md` — package scaffold/validate/install/drift (mandatory on package).
