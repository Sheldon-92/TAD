# EPHEMERAL Epic: Local Skill Capture — *save-skill Command

> Ephemeral Epic created by Surplus Burn Mode (source: ideas backlog).
> Single-phase, auto-executed. Archive with handoff on completion.

- **Task ID**: local-skill-capture
- **Created**: 2026-07-05
- **Mode**: surplus-auto (YOLO)
- **Status**: Active

## Goal

Enable bottom-up, in-the-moment skill capture: a new `*save-skill` command that turns a
reusable pattern from the current conversation into a structured local skill file under
`.claude/skills/local/`, isolated from `*sync`/install overwrite, without waiting for a
Gate 4 Knowledge Assessment cycle.

## Value Rationale

Knowledge compounds at the moment of discovery. Today reusable patterns are only captured
via the Gate 4 KA / distill loop; small tactical patterns evaporate. A local skills dir
gives them a durable, discoverable home with zero framework-release overhead.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | save-skill-command (single phase) | Active |

## Scope

**In scope:**
- New skill file `.claude/skills/save-skill.md` defining the `*save-skill` capture flow
- Skill output convention: files written to `.claude/skills/local/<name>.md` with
  frontmatter marking them `local: true` (local-only, never synced/published)
- LLM-draft + user-edit loop (draft from conversation context, confirm before write)
- `.claude/skills/local/` directory creation (with `.gitkeep` or on-demand)

**Out of scope:**
- Changes to tad.sh / derive-sync-set.sh / *publish (isolation is by directory convention;
  verify only that local/ is not in any existing sync copy path)
- Promotion pipeline from local skill → framework skill or capability pack
- Modifying alex/blake SKILL.md command tables

## Handoff

- `.tad/active/handoffs/HANDOFF-surplus-local-skill-capture.md`
