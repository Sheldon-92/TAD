# Capability Builder — Create Protocol (Phase 1)

This reference is **mandatory** when `$capability-builder create` is selected. Read via the non-circular load in `SKILL.md`.

## 1. Entry Conditions

`create` starts from:
- explicit human request backed by project-local materials; or
- one accepted SCAND with linked evidence.

Stop without creating a Skill when:
- one-off with no plausible reuse → `STOPPED_WITH_REASON`;
- nondiscriminative behavior → `STOPPED_WITH_REASON`;
- duplicate without concrete gap → `STOPPED_WITH_REASON`;
- requires TAD core / legacy retirement / Plugin / marketplace / catalog / DSH → `STOPPED_WITH_REASON` or `LEGACY_PACK_OUT_OF_SCOPE` for existing pack edits.

## 2. State Machine

```
REQUESTED
  │ inspect evidence + existing Skills
  ├── not reusable / duplicate / out-of-scope ──► STOPPED_WITH_REASON
  ▼
JUSTIFIED
  │ define name, boundary, fixture, threshold
  ▼
DESIGNED
  │ Gate 2 + approved handoff
  ▼
MATERIALIZED_CANONICAL
  │ capability-skill.sh validate
  ├── invalid ──► BLOCKED_CANONICAL_UNCHANGED
  ▼
BEHAVIOR_PROVEN
  │ CONTROL fails, WITH passes (same prompt)
  ├── nondiscriminative ──► RETURN_TO_FIXTURE_OR_SKILL
  ▼
PROJECTED
  │ capability-skill.sh project + verify byte identity
  ├── divergent target ──► BLOCKED_BOTH_TREES_UNCHANGED
  ▼
GATE_3_READY ──► Gate 3 → human Gate 4
```

Named stops/blocks: `STOPPED_WITH_REASON`, `LEGACY_PACK_OUT_OF_SCOPE`, `BLOCKED_CANONICAL_UNCHANGED`, `RETURN_TO_FIXTURE_OR_SKILL`, `BLOCKED_BOTH_TREES_UNCHANGED`.

## 3. Alex Responsibilities

1. Evidence intake + duplicate check (existing `.agents/skills/` + `.claude/skills/`).
2. Reusable-capability justification (why not one-off).
3. Canonical name (`^[a-z0-9]+(-[a-z0-9]+)*$`) and minimal resource selection (`SKILL.md` required; references/scripts/assets only when evidence justifies).
4. Behavioral fixture design — frontmatter `skill: <name>`, `name:`, `discriminative_pattern`, `min_discriminative`, `## Verification Command` (`grep -oE | sort -u | wc -l`). Markers are named rules / thresholds / output shapes, not generic vocabulary. Require ≥1 structural marker.
5. CONTROL/WITH threshold (e.g., `min_discriminative: 3`).
6. Handoff with implementation steps, file structure, and literal acceptance checks (§9.1).
7. Gate 2.

Deep research: load `capability-upgrade/references/legacy-pack-research.md` only after a named evidence gap is identified and local project evidence is insufficient. Record gap name.

## 4. Blake Materialization Order

1. Author canonical `.agents/skills/<name>/SKILL.md` per validation contract (frontmatter, name==dir, no `{{...}}`/`[TODO]`/`[TBD]`, no forbidden root artifacts).
2. `bash .tad/scripts/capability-skill.sh validate <project-root> <skill-name>` — must exit 0.
3. Behavioral proof — one canonical prompt file, fresh outputs:
   - `CONTROL` (no Skill) → `SKIP` is not `FAIL`; `FAIL` required.
   - `WITH` (Skill enabled) → `PASS` required.
   - `prompt` byte-identical, Skill state is the only delta. Record prompt hash, Skill-tree hash, harness/model identity, invocation description, timestamps, output hashes, fixture hash in `run-manifest.json`. Recompute hashes + verdicts.
4. `bash .tad/scripts/capability-skill.sh project <project-root> <skill-name>` — only after 2+3 pass.
5. `bash .tad/scripts/capability-skill.sh verify <project-root> <skill-name>` + `diff -rq` canonical vs projection — must pass.
6. Ralph Loop + Gate 3. Projection of a divergent target must never overwrite; helper refuses with non-zero and alters neither tree.

## 5. Skill Validation Contract

`SKILL.md` must:
- start at line 1 with closed YAML frontmatter (`---`);
- contain exactly one `name` and one `description`, both one-line scalars;
- `name` matches `^[a-z0-9]+(-[a-z0-9]+)*$` and equals directory basename;
- non-empty `description`;
- contain none of `{{...}}`, `[TODO]`, `[TBD]` in `SKILL.md`;
- root must not contain `CAPABILITY.md`, `README.md`, `CHANGELOG.md`, `install.sh`.

References/scripts/assets are not scanned for generic `TODO:`/`TBD:`.

## 6. Eval Fixture Contract

- `skill:` only → valid new fixture.
- `pack:` only → legacy.
- neither → path fallback (unchanged).
- both `skill:` + `pack:` → `SKIP (bad fixture: conflicting subject fields)` — cannot satisfy AC.
- missing `## Verification Command` → `SKIP (bad fixture)` (existing runner semantics).

Runner exit 0 is advisory; Gate checks verdict text. `SKIP` never satisfies `FAIL`/`PASS` proof.

## 7. Evidence Flow

| Data | Authority | Consumer | Direction |
|---|---|---|---|
| Downstream Skill | `.agents/skills/<name>/` | `.claude/skills/<name>/` | explicit `project` only |
| Builder framework Skill | `.claude/skills/capability-builder/` | `.agents/skills/capability-builder/` | framework release `.claude → .agents` |
| Prompt + raw outputs | `.tad/evidence/.../prompt + raw` | hashes + verdicts | capture then recompute |
| Legacy packs | `.tad/capability-packs/` | existing TAD consumers | unchanged |

No UI, API, DB, registry, or background sync.

## 8. Out-of-Scope

- Retirement/conversion of existing Capability Packs.
- Plugin/marketplace mutation.
- DeepSeek Harness.
- Multi-Skill bundles.
- Central catalog / registry.
- Scheduled refresh / autonomous evolution.
- Edits to TAD roles, Gates, Ralph Loop, hooks, installer, or release direction.

## 9. Gate Transitions

- Alex: Gate 2 PASS → handoff.
- Blake: `MATERIALIZED_CANONICAL` validates, `BEHAVIOR_PROVEN` discriminates, `PROJECTED` verifies, then Gate 3. Any block state prevents Gate 3 PASS.
- Human Gate 4 acceptance closes the phase.
