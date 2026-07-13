# EPHEMERAL Epic: 6-Line openai.yaml Capability Pack Codex Adapter

> Ephemeral Epic created by Surplus Burn Mode (source: next / IDEA-20260527-codex-adapter-yaml).
> Single-phase, auto-executed. Archive with handoff on completion.

- **Task ID**: codex-adapter-yaml
- **Created**: 2026-07-06
- **Mode**: surplus-auto (YOLO)
- **Status**: Active

## Goal

Give capability packs zero-cost Codex CLI compatibility: define a minimal (~6-line)
`codex-adapter.yaml` format (ECC `agents/openai.yaml` style: display_name,
short_description, default_prompt, allow_implicit_invocation, ...), extend the pack
`install.sh` codex path to generate and write it to `.agents/skills/{pack}/`, and prove
it end-to-end on one demo pack (web-backend) verified via `codex exec`.

## Value Rationale

Reduces friction for Codex users to consume capability packs. Small, concrete artifact
(spec + installer extension + demo) with broad downstream impact: the same pattern
replicates mechanically across all 24 packs without maintaining a per-pack AGENTS.md
routing table.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | codex-adapter-yaml (single phase) | Active |

## Scope

**In scope:**
- `codex-adapter.yaml` format spec (fields, semantics, generation rule from SKILL.md frontmatter)
- `install.sh` extension for the demo pack: `--agent=codex` path writes the adapter to `.agents/skills/{pack}/`
- One demo pack (web-backend) with a generated, working adapter
- Verification via `codex exec` (or documented honest-partial if Codex CLI unavailable in session)

**Out of scope:**
- Rolling the adapter out to the other 23 packs (follow-up mechanical task)
- Changing the existing AGENTS.md routing or Codex strip-only SKILL rules
- Any Claude Code install-path behavior changes

## Handoff

- `.tad/active/handoffs/HANDOFF-surplus-codex-adapter-yaml.md`
