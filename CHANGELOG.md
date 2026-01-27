# Changelog

All notable changes to the TAD Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
