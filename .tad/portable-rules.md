# TAD Portable Metadata Rules

Defines which TAD files are portable to Codex CLI vs Claude Code-only.

## Classification Table

| Category | Files | Classification | Rationale |
|----------|-------|----------------|-----------|
| SKILL files | `.claude/skills/*/SKILL.md` | Transform | Strip Claude Code-only tools (AskUserQuestion, Agent, hooks), keep all protocol logic and constraint rules |
| Config | `.tad/config*.yaml` | Portable | Pure YAML config, no tool dependency |
| Templates | `.tad/templates/*.md` | Portable | Markdown templates, no tool dependency |
| Hooks lib | `.tad/hooks/lib/*.sh` | Portable | Bash scripts — run manually on Codex, auto-triggered on Claude Code |
| Hooks root | `.tad/hooks/*.sh` (root-level) | CC-only | Auto-triggered by Claude Code `settings.json` — Codex users run manually |
| Domains | `.tad/domains/*.yaml` | Portable | Domain Pack knowledge files, no tool dependency |
| Evidence | `.tad/evidence/` | Portable | File structure, no tool dependency — create manually on Codex |
| Settings | `.claude/settings.json` | CC-only | Claude Code hook registration, no Codex equivalent |
| Codex adapters | `.tad/codex/` | CC-only (source) | Pre-generated Codex-edition files — already adapted, no extraction needed |

## Transform Rules for SKILL Files

When generating a Codex-edition SKILL from a Claude Code SKILL, apply these rules:

### Strip → Replace

| Pattern (section/key) | Replace With |
|-----------------------|--------------|
| `AskUserQuestion` tool calls | "List options as numbered text (1. ... / 2. ... / 3. ...). User types number or free text to respond." |
| `Agent` tool / sub-agent parallel spawning | "Start a new `codex exec` session with the reviewer persona prompt. Run sessions sequentially." |
| `Skill` tool / `/command` syntax | "Read the relevant file and follow its protocol." |
| `ToolSearch` references | Remove |
| `Monitor` references | Remove |
| `SendMessage` references | Remove |
| `EnterPlanMode` | Keep prohibition text, remove "(Claude Code tool)" explanation |
| Hook references (`PreToolUse`, `PostToolUse`, `SessionStart`, `UserPromptSubmit`) | "Run bash script manually when needed: `bash .tad/hooks/lib/{script}.sh`" |
| `settings.json` configuration | Remove (CC-only config) |
| "Run in background" | "Run sequentially (Codex has no background agents)" |
| Session state auto-update by hook | "Update manually or launcher script appends" |

### Preserve — NEVER Delete

- All lines containing: `MUST`, `MANDATORY`, `VIOLATION`, `forbidden`, `BLOCKING`
- `anti_rationalization_registry` (all entries — byte-exact)
- `honest_partial_protocol`
- `forbidden_implementations` lists (all items)
- Ralph Loop protocol logic (Layer 1 + Layer 2)
- Gate 3 v2 checklist structure
- Evidence directory structure and slug contract
- Knowledge Assessment protocol
- Completion report protocol
- Handoff reading and paraphrasing protocol
- Socratic inquiry protocol (Alex)
- Adaptive complexity protocol (Alex)
- Intent router protocol routing logic (Alex)
- Handoff creation protocol (Alex)
- Acceptance protocol (Alex)
- All `path_transitions` / `forbidden` rules

### Strip Whole Protocol → Omit from Codex Edition

Some source protocols are Conductor/automation-only (require Claude Code Agent tool, hook
orchestration, or multi-agent parallel spawning that Codex cannot replicate). These are
stripped entirely from the Codex edition — not adapted, not stubbed, just absent.

### Expected-Absent-in-Codex Allowlist

The following source `*_protocol:` blocks are **legitimately absent** from the Codex edition.
A parity check MUST NOT flag these as drift. Any source protocol NOT on this list that is
missing from the Codex edition IS drift and MUST be flagged.

| Protocol Key | Reason for Absence |
|---|---|
| `yolo_execution_protocol` | Conductor orchestration — requires Agent tool for multi-phase parallel sub-agent spawning |
| `optimize_protocol` | Auto-optimize — Conductor-side autonomous loop |
| `evolve_protocol` | Auto-evolve — Conductor-side knowledge extraction |
| `dream_protocol` | Auto-dream — Conductor-side trace scanning |
| `publish_protocol` | Release automation — hooks + Agent parallel reviewers + registry scripts |
| `sync_protocol` | Multi-project sync — Agent + hooks + registry automation |
| `sync_add_protocol` | Sub-protocol of sync — registry manipulation |
| `sync_list_protocol` | Sub-protocol of sync — registry query |
| `lsp_provision_protocol` | LSP tool is Claude Code-only — no Codex equivalent |

**Nested/inline protocol references** (not standalone blocks — always ignored by parity check):
`per_phase_protocol`, `blocking_in_alex_protocol`, `fallback_protocol`, `honest_partial_protocol`
(these are inline YAML fields or sub-sections, not top-level protocol units).

### Size Targets

- Codex-edition Blake SKILL: ≤40KB (≤40,960 bytes)
- Codex-edition Alex SKILL: ≤100KB (≤102,400 bytes)

When source SKILL files are updated, regenerate Codex-edition files using these rules.
