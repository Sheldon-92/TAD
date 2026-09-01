---
name: capability-upgrade
description: Compatibility route to $capability-builder for project-owned Agent Skill creation; deep research preserved as conditional reference.
---

# /capability-upgrade — Compatibility Route (Phase 1)

This Skill is a thin compatibility entry for the **old** Capability Pack flow. New capability work uses **`$capability-builder create`**. The deep research material from the previous version is preserved as a conditional reference and is not loaded by default.

## Routing

- **New capability work** (new domain, new pack-style request, YAML domain pack mention) → **use `$capability-builder create`** per `.claude/skills/capability-builder/SKILL.md` and its mandatory `references/create-protocol.md`. That path creates exactly one project-owned Agent Skill at `.agents/skills/<name>/`, validates, behavior-proves, and projects to `.claude/skills/<name>/`.
- **Existing project Skill change** (you already have `.agents/skills/<name>/` and want to evolve it) → **future `$capability-builder evolve`** (Phase 2, not in this release). Record `STOPPED_WITH_REASON: evolve is Phase 2` and stop. No writes.
- **Existing legacy Capability Pack edit** (`.tad/capability-packs/<name>/` maintenance, retiring, converting, or editing a pack in the old tree) → **STOP `LEGACY_PACK_OUT_OF_SCOPE`**. Phase 1 neither retires nor edits legacy packs. No writes. Ask the human to choose a separately scoped legacy-maintenance task or a new project-owned Skill. Do not silently reinterpret a pack upgrade as Skill creation.
- **General capability routing question** (which pack for a task? `pack-collisions.yaml` gap) → read pack registry / collision file inside the Builder flow, not here.

## What This Skill No Longer Produces

New work does NOT produce the old Capability Pack scaffold:
- no `CAPABILITY.md`
- no generated `README.md` / `CHANGELOG.md` at Skill root
- no per-Skill `install.sh`
- no `checklists/` / `tools/` / `references/` / `examples/` pack tree
- no TAD manifest/catalog

The minimal output on the new path is one canonical Agent Skill directory with `SKILL.md` only; optional `references/`, `scripts/`, `assets/` only when evidence justifies.

## Conditional Deep Research

The preserved legacy research remains available at:
- `.claude/skills/capability-upgrade/references/legacy-pack-research.md` (and `.agents` mirror)

Load it **only** when a named research gap is identified and local project evidence is insufficient. Record the gap name when you load it. Do not load it speculatively.

## Failure Modes

- If a request requires changing TAD core, installer, roles, Gates, or framework Skills → `STOPPED_WITH_REASON`.
- If an `evolve` or `package` request is made → visible stop per Builder router (no pretend execution).
- If `LEGACY_PACK_OUT_OF_SCOPE` would be widened → return to Alex instead of widening scope.

## References

- `references/legacy-pack-research.md` — exact byte copy of pre-Phase-1 `capability-upgrade/SKILL.md` (conditional, evidence-gap only).
- Builder router: `.claude/skills/capability-builder/SKILL.md`
- Builder protocol: `.claude/skills/capability-builder/references/create-protocol.md`
