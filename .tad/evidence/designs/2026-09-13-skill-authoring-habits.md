# Design pointer: skill authoring habits (docs-only)

**Date:** 2026-09-13  
**Task:** `TASK-20260913-SKILL-AUTHORING-HABITS`  
**Channel:** Cursor / cursor-grok-4.6-medium. NO Gemini. NO Blake on the Alex turn.  
**Human lock:** Q1=② Q2=② Q3=①  
**Not:** wholesale `mattpocock/skills` import; Gate 2 dual / Alex≠Blake cut; pack file edits; publish.

Blake pastes the blocks below. Do not invent extra files.

## Pathspec

Modify only:

1. `.tad/project-knowledge/patterns/pack-build-rules.md` — append the `###` (do not rewrite older entries).
2. `.tad/project-knowledge/patterns/_index.md` — replace the Pack Build Rules hook line only.
3. `.tad/templates/skillify-candidate-template.md` — four bullets under `## Proposed Skill Outline`.

Commit may also include the handoff. Design file: do not force-add.  
Commit **subject must contain** `TASK-20260913-SKILL-AUTHORING-HABITS` (AC12/AC13 this-knife identity).

## `_index.md` replacement line (hook 110 chars)

```
- [Pack Build Rules](pack-build-rules.md) — Pack architecture, pointer/freeze/escalate, invocation-split, hard-vs-soft setup, docs-cache-env, skill-vs-MCP
```

Keep the rest of `_index.md` byte-identical.

## `pack-build-rules.md` append (after last `###` entry)

```
### Skill Authoring Habits: Invocation Split, Hard/Soft Setup, Docs-as-Env-Cache — 2026-09-13
- **Context**: Thin authoring habits from discuss `.tad/evidence/discuss/2026-09-13-mattpocock-borrow-deltas.md` (human lock 2026-09-13 Q1=② Q2=② Q3=①). Research: `.tad/evidence/research/2026-09-13-mattpocock-skills-deep.md` §8 / §8.1 (`mattpocock/skills` @ `3cca18b`). This is **not** a catalog import.
- **Discovery**: TAD already splits human-fired commands (`/alex`, `/blake`, `$capability-builder`) from keyword-recruited packs (pointer max-2 → escalate). Authoring surfaces did not name that **invocation class**, did not say when a setup nag is load-bearing, and did not tell writers that SKILL.md caches live CLI/`--help` rather than becoming a second SSOT.
- **Action**: When writing a pack SKILL, skillify outline, or capability-builder Skill: (1) **D1 Invocation split** — declare **user-invoked orchestrator** (human-typed command) vs **model-invoked / keyword-recruited** discipline (pointer ≠ load; escalate only human-named or recorded failure-retry). Never wrap `/alex` or `/blake` as Skill-tool calls. Loader entry **Pack Loader Thin On-Demand** in this file stays unchanged. (2) **D2 Hard vs soft setup** — a "run X if missing" line only if the skill **cannot function** without that setup (example: `tad.sh` install; research CLI only when `*research` is the task). Soft surfaces (`*discuss`, tax-cut paste, pack pointer) omit the nag. **Forbidden:** calling Gate 2 dual independent disk reviews or Alex≠Blake "soft setup." Those are **teeth** (`docs/process-tax-cut.md`). Friction protocol unchanged: missing hard deps BLOCK, never skip. (3) **D4 Docs-as-env-cache** — SKILL.md is a **cache** of `package.json` / `--help` / live CLI, not a second SSOT (L1 Never Hand-Write What an Existing Tool Already Does). Constraint rules (MUST/MANDATORY/VIOLATION) stay in the SKILL body (Judgment-Only Skill Files / v2.7). (4) **D3 Facts vs decisions** — facts the agent may gather; product and technical decisions wait for the human via existing Socratic inquiry and Gate 1, citing `principles.md` ### AI/Human Judgment Domain; do not add a grilling protocol.
- **Later (not this knife):** DR-20260712 裁决 4 `disable-model-invocation` pack-frontmatter triage stays deferred; do not edit pack files here.
- **failure_mode**: Naive default: cargo-cult Matt's grill→spec→`/implement` as TAD, or treat Gate 2 dual review / Alex≠Blake as skippable setup. Why wrong: that collapses the two-agent gate OS into a skill-tool graph (designer-implements-accepts).
- **Grounded in**: `.tad/evidence/discuss/2026-09-13-mattpocock-borrow-deltas.md`; `.tad/evidence/research/2026-09-13-mattpocock-skills-deep.md` §8 / §8.1
```

## Skillify — append under `## Proposed Skill Outline`

Keep existing name/description/triggers/Body bullets. Add these four:

```
- Invocation class: user-invoked orchestrator (human-typed) vs model-invoked / keyword-recruited (pointer then escalate). Never Skill-tool-call `/alex` or `/blake`.
- Hard vs soft setup: "run X if missing" only if the skill cannot function without X. Gate 2 dual review and Alex≠Blake are teeth, not setup nags.
- Docs-as-env-cache: SKILL.md caches live CLI / `package.json` / `--help`; do not restate those as a second SSOT. MUST/MANDATORY stay in the body.
- Facts vs decisions: gather facts; wait for the human on product/tech decisions (cite L1 AI/Human Judgment Domain + existing Socratic / Gate 1). No grilling protocol.
```

## Out

Role SKILL bodies, `docs/process-tax-cut.md` body, `principles.md`, KEEP packs, `capability-packs/**`, hooks, publish, v2.44.5 absorb.
