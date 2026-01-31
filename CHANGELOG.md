# Changelog

All notable changes to the TAD Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.2] - 2026-01-31

### Removed

- **`/tad-learn` command**: Deprecated framework-level learning recorder
  - TAD methodology improvements now made directly in the TAD mother repository
  - Existing learnings archived to `.tad/archive/learnings-archived/`
  - Project Knowledge system (`.tad/project-knowledge/`) remains unchanged
  - Cleaned up references in CLAUDE.md, README.md, tad-help.md, tad.sh

### Changed

- CLAUDE.md section numbering updated (removed Section 7, renumbered 8→7, 9→8)
- `tad.sh` install script no longer creates `.tad/learnings/` directories
- README.md contributing section updated to direct users to TAD repo

---

## [2.1.1] - 2026-01-31

### Added

- **`/tad-maintain` Command**: Document health check and synchronization
  - Three modes: CHECK (read-only), SYNC (scoped writes), FULL (comprehensive)
  - Handoff lifecycle audit with 4 detection criteria (A/B/C/D)
  - NEXT.md automatic size monitoring and archival
  - PROJECT_CONTEXT.md sync and creation
  - Document consistency checks (version alignment, orphan detection)
  - Auto-triggers on agent activation (`*exit`) and `*accept`

- **Handoff Stale Detection** (Criterion C/D)
  - Criterion C (AGE_STALE): Flags active handoffs older than `stale_age_days` (default 7)
  - Criterion D (TOPIC_SUPERSEDED): Cross-references archived handoffs by topic keyword overlap
  - Interactive user confirmation via AskUserQuestion (never auto-archives)
  - Configurable thresholds in `config.yaml` under `handoff_lifecycle`

- **New Configuration**: `handoff_lifecycle` section in `config.yaml`
  - `stale_age_days`, `cross_reference_window_days`, `topic_match_threshold`
  - `common_words_exclude` list for topic matching

- **New Templates**
  - `.tad/templates/AGENTS.md.template` - Codex CLI project instructions template
  - `.tad/templates/GEMINI.md.template` - Gemini CLI project instructions template

- **CLAUDE.md Section 8**: Document maintenance rules with Criterion 1-4

### Changed

- **Simplified Adapter Architecture**: Removed `.tad/adapters/` directory
  - All platform conversion logic consolidated into `/tad-init` command
  - Removed `adapter-schema.yaml`, `platform-codes.yaml`, per-platform adapter files
  - Removed `.tad/templates/command-converters/` (to-codex.template, to-gemini.template)
  - Simpler, more maintainable multi-platform support

- **config.yaml**: Updated to v2.1.1 with `handoff_lifecycle` and simplified `multi_platform` section

### Removed

- `.tad/adapters/` directory (replaced by `/tad-init` inline logic)
- `.tad/templates/command-converters/` directory (replaced by `/tad-init` inline logic)

---

## [2.1.0] - 2026-01-26

### Added

- **Agent-Agnostic Architecture**: Multi-platform support for AI coding assistants
  - Claude Code (primary): Full subagent support
  - Codex CLI (secondary): Self-check mode with native SKILL.md support
  - Gemini CLI (secondary): Self-check mode with TOML commands

- **Platform-Agnostic Skills System** (`.tad/skills/`)
  - 8 P0 skills: testing, code-review, security-audit, performance, ux-review, architecture, api-design, debugging
  - YAML frontmatter with platform compatibility info
  - Checklist format executable by any AI assistant
  - Pass criteria with severity levels (P0-P3)

- **Platform Adapter System** (`.tad/adapters/`)
  - `adapter-schema.yaml` - Adapter interface contract
  - `platform-codes.yaml` - Platform definitions and detection
  - Platform-specific adapters for Claude, Codex, and Gemini

- **Multi-Platform Installation Script** (`tad.sh` v2.1)
  - Auto-detection of installed AI CLI tools
  - Automatic generation of platform-specific configs
  - `AGENTS.md` generation for Codex CLI
  - `GEMINI.md` generation for Gemini CLI
  - TOML command conversion for Gemini
  - Automatic rollback on failure

- **Command Conversion Templates**
  - `.tad/templates/command-converters/to-codex.template`
  - `.tad/templates/command-converters/to-gemini.template`

- **New Configuration**
  - `multi_platform` section in `.tad/config.yaml`
  - Platform-specific skill execution modes

### Changed

- Installation script now detects and configures multiple platforms
- Skills now have YAML frontmatter for platform compatibility
- Evidence directory structure supports multi-platform reviews

### Research Findings

- Codex CLI has native SKILL.md support (similar to TAD skills design)
- Codex CLI uses TOML for config (not JSON as initially assumed)
- Gemini CLI uses JSON settings + TOML commands
- Both support hierarchical instruction loading

### Backward Compatibility

- Existing Claude Code users: No changes required
- All `.claude/` configurations preserved
- subagent calls unchanged for Claude Code

### Documentation

- Platform research evidence: `.tad/evidence/reviews/20260126-phase0-research-validation.md`
- Skills README: `.tad/skills/README.md`

---

## [2.0.0] - 2026-01-26

### Added

- **Ralph Loop Integration**: Iterative quality mechanism with expert-driven exit conditions
  - Layer 1: Self-check (build, test, lint, tsc) with circuit breaker
  - Layer 2: Expert review with priority groups
  - State persistence for crash recovery
  - Automatic escalation to human/Alex when stuck

- **New Configuration Files**
  - `.tad/ralph-config/loop-config.yaml` - Ralph Loop configuration
  - `.tad/ralph-config/expert-criteria.yaml` - Expert pass conditions
  - `.tad/schemas/loop-config.schema.json` - Schema validation
  - `.tad/schemas/expert-criteria.schema.json` - Schema validation

- **New Blake Commands**
  - `*develop [task-id]` - Start Ralph Loop development cycle
  - `*ralph-status` - Show current Ralph Loop state
  - `*ralph-resume` - Resume from last checkpoint
  - `*ralph-reset` - Reset loop state
  - `*layer1` - Run Layer 1 self-check only
  - `*layer2` - Run Layer 2 expert review only

- **New Evidence Directories**
  - `.tad/evidence/ralph-loops/` - Ralph Loop state and summaries
  - `.tad/evidence/reviews/_iterations/` - Iteration-specific evidence

- **Documentation**
  - `docs/RALPH-LOOP.md` - Ralph Loop documentation
  - `docs/MIGRATION-v2.md` - Migration guide

### Changed

- **Gate 3 v2 (Expanded)**: Now includes all technical quality checks
  - Layer 1 self-check verification
  - Layer 2 expert review verification
  - Evidence file verification
  - Knowledge Assessment
  - Owned entirely by Blake

- **Gate 4 v2 (Simplified)**: Now pure business acceptance
  - Business requirement verification
  - Human approval
  - Archive handoff
  - No technical review (moved to Gate 3 v2)
  - Owned by Alex

- **Gate Responsibility Matrix**: Clear separation of technical (Blake) vs business (Alex) experts

### Deprecated

- `*implement` command in Blake (use `*develop` instead)

### Migration

See `docs/MIGRATION-v2.md` for detailed migration instructions.

---

## [1.8.0] - 2026-01-25

### Added

- Human-in-the-Loop Excellence
- Terminal isolation rules for Alex and Blake
- Enhanced handoff creation protocol

---

## [1.6.0] - 2026-01-24

### Added

- Unified install/upgrade script
- Improved sync capabilities

---

## [1.5.1] - 2026-01-23

### Fixed

- Sync improvements from menu-snap project

---

## [1.5.0] - 2026-01-22

### Added

- Project knowledge trigger integration
- Knowledge bootstrap workflow

---

## [1.1.0] - 2026-01-15

### Added

- TAD Framework initial release
- Alex (Solution Lead) agent
- Blake (Execution Master) agent
- 4-gate quality system
- Handoff-based workflow
