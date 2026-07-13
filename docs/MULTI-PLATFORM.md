# TAD Multi-Platform Runtime Guide

**Version**: 2.34.0 (Dual-Platform Architecture — Runtime Freshness Active)

TAD runs on **two first-class runtimes**: Claude Code and Codex. Both platforms receive the same SKILL.md files and follow the same shared TAD protocol. Each platform also has its own native adapter layer for hooks, config, subagents, and tooling.

---

## Current Status

| Platform | Runtime Status | SKILL Install | Active Config | Active Custom Agents |
|----------|---------------|---------------|---------------|---------------------|
| **Claude Code** | First-class | `.claude/skills/` | `.claude/settings.json` | Agent tool with subagent_type |
| **Codex** | First-class (since v2.25.0) | `.agents/skills/` | `.codex/hooks.json` only | Built-in default/worker/explorer |

Codex native config (`.codex/config.toml`) and custom agents (`.codex/agents/`) are **draft-only** — candidate files exist under `.tad/evidence/designs/codex-runtime-candidates/` but are **not active** until activation criteria are met (see below).

---

## Runtime Model

```
TAD Shared Protocol (invariant across platforms)
├── Alex/Blake role contracts
├── Gates 1-4
├── Handoff protocol
├── Layer 2 review semantics
├── Ralph Loop structure
├── Completion/evidence/trace requirements
└── Knowledge assessment

Claude Code Adapter                    Codex Adapter
├── .claude/skills/                    ├── .agents/skills/
├── .claude/settings.json              ├── AGENTS.md routing
├── Skill tool (slash commands)        ├── $skill invocation
├── Agent tool (subagent_type)         ├── Subagents (custom .toml agents)
├── .claude/workflows/                 ├── (no workflow equivalent)
├── Hooks (settings.json)              ├── Hooks (.codex/hooks.json)
├── MCP (settings.json)                ├── MCP (.codex/config.toml)
└── Compact (auto, session-state.md)   └── Compact (auto, /compact)

Runtime Freshness Layer (Active — 21/21 PASS)
├── .tad/runtime-compat/codex.md       (active)
├── .tad/runtime-compat/claude-code.md (active)
└── Release/sync freshness gate        (active)
```

---

## Shared TAD Protocol

These elements are **invariant** across both platforms. They live in SKILL.md body (not in platform config) and must not be forked:

| Element | Description |
|---------|-------------|
| Alex/Blake roles | Solution Lead + Execution Master identity and command set |
| Gates 1-4 | Quality checkpoints with blocking criteria |
| Handoff protocol | Alex → Blake document format, checklists, ACs |
| Layer 2 review | Expert review groups (spec-compliance → code-reviewer → parallel experts), pass/fail criteria, escalation |
| Ralph Loop | Iterative Layer 1 + Layer 2 quality cycle with circuit breaker |
| Completion/evidence | Completion report format, `.tad/evidence/` structure, trace requirements |
| Knowledge assessment | Triple-question KA (knowledge + skillify + workflow) |
| Execution discipline | MUST/MANDATORY/VIOLATION rules in SKILL body |

---

## Active Pack System

SKILL.md Capability Packs are the only active pack system for both Claude Code and Codex.

- **Source of truth**: `.tad/capability-packs/{pack}/SKILL.md` (prebuilt, framework-owned)
- **Claude Code**: installed to `.claude/skills/{pack}/SKILL.md`
- **Codex**: installed to `.agents/skills/{pack}/SKILL.md`
- **Symmetry**: framework-owned skills must be byte-identical across both platforms
- **Local skills**: project-only skills may exist on one or both platforms and are reported as INFO by the verifier (`release-verify.sh platform-skills`)
- **YAML Domain Packs**: retired 2026-06-11, archived to `.tad/archive/domains/`

---

## Claude Code Adapter

Claude Code has the deepest current TAD integration.

| Surface | Implementation |
|---------|---------------|
| Skill loading | `.claude/skills/` via Skill tool; full SKILL.md loaded on invocation |
| Hooks | `.claude/settings.json` hooks; PreToolUse, PostToolUse, SessionStart, etc. |
| Workflows | `.claude/workflows/*.workflow.js`; deterministic agent/parallel/pipeline/phase |
| Subagents | Agent tool with 16+ built-in subagent_type options; isolation: worktree |
| MCP | `.claude/settings.json` MCP server config; project-scoped |
| Permissions | `.claude/settings.json` allow/deny lists |
| Compact | Auto-compact with summary; session-state.md for TAD recovery |
| Release/sync | `*publish` / `*sync` commands; `tad.sh` installer; deny-list derivation |

---

## Codex Adapter

Codex is a first-class TAD runtime with native skill loading, hooks, subagents, and MCP support.

| Surface | Implementation |
|---------|---------------|
| Skill loading | `.agents/skills/` via `$skill` or implicit matching; progressive disclosure (2% context budget cap) |
| Role activation | `AGENTS.md` routes `$alex` / `$blake` to `.agents/skills/{role}/SKILL.md` |
| Hooks | `.codex/hooks.json`; 10 events (PreToolUse, PostToolUse, SessionStart, PreCompact, PostCompact, UserPromptSubmit, SubagentStart, SubagentStop, PermissionRequest, Stop); trust-review required |
| Subagents | Built-in default/worker/explorer; custom agents via `.codex/agents/*.toml` (not yet active for TAD) |
| MCP | `.codex/config.toml` `[mcp_servers.*]` with STDIO/HTTP support (not yet active for TAD) |
| Sandbox | Permission profiles with filesystem (read/write/deny) + network (domain rules) |
| Compact | Auto-compact with summary; `/compact` manual; custom compact prompt file |
| Cloud | Codex Cloud: container-based tasks, environment config, GitHub integration |
| Install | `tad.sh --platform codex --yes` installs skills to `.agents/skills/` |

### Active Codex Files

Currently committed to the TAD project:

- `.codex/hooks.json` — TAD lifecycle hooks (auto-generated by `tad.sh`)
- `.agents/skills/` — Unified SKILL.md files (same content as `.claude/skills/`)
- `AGENTS.md` — Role routing and capability pack keyword table

### What Is NOT Active

- `.codex/config.toml` — draft candidate at `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft`
- `.codex/agents/*.toml` — draft candidates at `.tad/evidence/designs/codex-runtime-candidates/agents/`
- Codex-specific MCP server config — no project-scoped MCP configured for Codex yet

---

## Draft Codex Native Runtime Policy

Phase 2 produced a Codex runtime policy and draft candidate files. These are **not active** and live under `.tad/evidence/designs/codex-runtime-candidates/`.

| Draft File | Purpose | Active? |
|-----------|---------|---------|
| `config.toml.draft` | Project-level Codex config (model, sandbox, features) | No |
| `agents/spec-compliance-reviewer.toml.draft` | Layer 2 Group 0 reviewer | No |
| `agents/code-reviewer.toml.draft` | Layer 2 Group 1 reviewer | No |
| `agents/test-runner.toml.draft` | Layer 2 Group 2 test runner | No |

### Activation Criteria

Before copying any draft to active `.codex/` location, ALL must be true:

1. ~~Phase 3 documentation updated (this document)~~ ✅ Completed
2. ~~Phase 4 runtime freshness ledger created~~ ✅ Active (21/21 PASS)
3. ~~Phase 5 full-cycle regression passes on Codex~~ ✅ PASS (CONDITIONAL_GO)
4. Human explicitly approves activation
5. No P0 quality-chain failures from activated config
6. Final secrets audit passes

---

## Runtime Freshness

Platform capabilities change over time. Codex is high-volatility; Claude Code is lower-volatility but not exempt.

Runtime freshness ledgers are **active**:
- `.tad/runtime-compat/codex.md` — compatibility ledger with `last_verified`, volatility, recheck triggers
- `.tad/runtime-compat/claude-code.md` — same format, lower update frequency
- Release/sync freshness gate: `runtime-freshness-verify.sh` (21/21 PASS as of 2026-06-09)

**Current policy**: Before any cross-platform architectural decision, do a fresh capability audit of the target platform's current state. Never rely on assumptions older than 2 months for fast-evolving CLI tools.

---

## External Specialized Tools

Gemini CLI can serve as an external specialized tool via the handoff mechanism. It is **not** a first-class TAD runtime.

| Tool | Role | Workflow |
|------|------|---------|
| **Gemini CLI** | External tool for design review, UI prototyping | Alex creates handoff → Human gives to Gemini → Gemini executes → Human brings result back |

Gemini does not receive TAD SKILL files, hooks, or config. It receives handoff content directly from the human.

---

## Workflow Matrix

| Workflow | Claude Code | Codex | Notes |
|----------|------------|-------|-------|
| Alex activation | `/alex` (Skill tool) | `$alex` (AGENTS.md → `.agents/skills/alex/SKILL.md`) | Both load full SKILL.md |
| Blake activation | `/blake` (Skill tool) | `$blake` (AGENTS.md → `.agents/skills/blake/SKILL.md`) | Both load full SKILL.md |
| Layer 2 review | Agent tool spawns reviewer sub-agents | Subagent spawning or sequential sessions | Codex custom agents not yet activated |
| Gate pre-checks | hooks auto-fire | `pre-accept-check.sh` / `pre-gate-check.sh` run manually | Codex hooks require trust review |
| Workflows | `.claude/workflows/*.workflow.js` | No equivalent; use prompt-driven subagent orchestration | Gap: Codex has no workflow script runtime |
| Release/sync | `*publish` / `*sync` from Claude Code | Codex is a sync target, not a sync source | Release always runs from Claude Code |
| Evidence capture | Hook-driven (post-write-sync.sh) | Hook-driven (same scripts via `.codex/hooks.json`) | `ask_user_question`: accepted limitation — `codex exec` batch mode lacks interactive `request_user_input`; interactive Codex can ask via text |

---

## Current Limitations

| Limitation | Impact | Resolution |
|-----------|--------|------------|
| `.codex/config.toml` not active | Codex uses default model/sandbox, not TAD-optimized | Activate after human approval + final secrets audit |
| `.codex/agents/` not active | Layer 2 review uses prompt-driven spawning, not dedicated reviewer agents | Activate after human approval + final secrets audit |
| `ask_user_question` in `codex exec` batch mode | `request_user_input` unavailable in batch mode (by design — no interactive user); interactive Codex can ask via text normally | Accepted limitation — text-based fallback is documented pattern |
| No workflow script runtime on Codex | Complex orchestration (YOLO Conductor, parallel workflows) is Claude Code-only | Use prompt-driven subagent spawning on Codex |

---

## Source Artifacts

| Artifact | Path | Phase |
|----------|------|-------|
| Architecture decisions | `.tad/evidence/designs/dual-platform-native-runtime-architecture.md` | Phase 1 |
| Runtime policy | `.tad/evidence/designs/codex-native-runtime-policy.md` | Phase 2 |
| Draft candidates | `.tad/evidence/designs/codex-runtime-candidates/` | Phase 2 |
| Docs upgrade evidence | `.tad/evidence/designs/dual-platform-docs-upgrade.md` | Phase 3 |
| Epic | `.tad/active/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md` | All |

---

*TAD v2.30.0 — Claude Code + Codex dual-runtime, shared protocol, platform adapters, runtime freshness active (21/21 PASS), full-cycle regression PASS (CONDITIONAL_GO).*
