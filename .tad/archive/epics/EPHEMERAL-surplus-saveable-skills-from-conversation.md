# EPHEMERAL Epic: Saveable Skills from Conversation — *save-workflow Command

> Ephemeral Epic created by Surplus Burn Mode (source: ideas backlog).
> Single-phase, auto-executed. Archive with handoff on completion.

- **Task ID**: saveable-skills-from-conversation
- **Created**: 2026-07-05
- **Mode**: surplus-auto (YOLO)
- **Status**: Active

## Goal

Let users save a reusable workflow directly from conversation context with a single
`*save-workflow` command: extract the current conversation's workflow steps into a
structured `.claude/skills/local/{workflow-name}.md` file with auto-detected trigger
keywords and usage instructions. UX inspired by Linear Agent's Skills system —
one-click capture, complementing the `*save-skill` pattern capture
(local-skill-capture task) with a workflow-shaped, more discoverable flow.

## Value Rationale

Natural in-conversation skill emergence lowers the barrier to knowledge capture vs
the formal Gate 4 KA cycle. Workflows (ordered multi-step procedures) evaporate even
faster than patterns; capturing them at the moment they were just executed preserves
step order, tool commands, and gotchas while context is hot.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | save-workflow-command (single phase) | Active |

## Scope

**In scope:**
- New skill file `.claude/skills/save-workflow.md` defining the `*save-workflow` capture flow
- Output convention: `.claude/skills/local/<workflow-name>.md` with frontmatter
  (`local: true`, auto-detected trigger keywords in `description`)
- Extraction spec: ordered workflow steps from conversation context + usage instructions
- Confirm-before-write + overwrite guard (reuse local-skill-capture conventions)

**Out of scope:**
- Changes to tad.sh / derive-sync-set.sh / *publish (isolation is by directory convention)
- Promotion pipeline local workflow → framework skill / capability pack
- Modifying alex/blake SKILL.md command tables or CLAUDE.md routing
- Linear MCP integration (pattern inspiration only, no API usage)

## Handoff

- `.tad/active/handoffs/HANDOFF-surplus-saveable-skills-from-conversation.md`
