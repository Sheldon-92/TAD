# TAD Multi-Platform Runtime Guide

**Version**: 3.1 (Codex hook-enabled + OpenCode/Cursor supported; Claude Code path removed)

TAD runs on **Codex, OpenCode, and Cursor as supported harnesses**, with a shared protocol.
Since v3.1 there is a single skill tree
(`.agents/skills/`, the shared source of truth) and three install targets (`codex|opencode|cursor`, default `codex`).
Codex is the **hook-enabled** runtime; OpenCode and Cursor get skills + routing + packs but no lifecycle hooks (Platform Adapters P2 — known gap).
The Claude Code runtime path (install target, hooks, workflows, model bindings) was
removed in v3.0.0 — see `CHANGELOG.md` (`### Removed`) and the retired ledger
`.tad/runtime-compat/claude-code.md`. Upgrading never deletes a pre-existing
downstream `.claude/` tree (user hooks / MCP / permission config stay byte-identical).

---

## Current Status

| Platform | Runtime Status | SKILL Install | Active Config | Active Custom Agents |
|----------|---------------|---------------|---------------|---------------------|
| **Codex** | Hook-enabled (since v2.25.0; hooks via `.codex/hooks.json`) | `.agents/skills/` | `.codex/hooks.json` only | Built-in default/worker/explorer |
| **OpenCode** | Supported (skills + AGENTS.md + packs; hooks P2 — not yet) | `.agents/skills/` | `.opencode/commands/tad-update.md` updater-only; hooks P2 | Built-in |
| **Cursor** | Supported (skills + AGENTS.md + packs; hooks P2 — not yet) | `.agents/skills/` | — (hooks P2) | Built-in |
| **Claude Code** | Removed in v3.0.0 (was first-class ≤2.44.6) | — (no longer installed; pre-existing downstream trees are left untouched) | — | — |

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

Claude Code Adapter (removed in v3.0.0)   Codex Adapter
├── (install target deleted)               ├── .agents/skills/
├── (settings.json hooks deleted)          ├── AGENTS.md routing
├── (workflows deleted — no equivalent)    ├── $skill invocation
├── (opus/sonnet/haiku pins deleted)       ├── Subagents (custom .toml agents)
├── (skill mirror deleted)                 ├── Hooks (.codex/hooks.json)
                                           ├── MCP (.codex/config.toml)
                                           └── Compact (auto, /compact)

Runtime Freshness Layer
├── .tad/runtime-compat/codex.md       (active)
├── .tad/runtime-compat/claude-code.md (RETIRED in v3.0.0 — retained as historical record, not gated)
└── Release/sync freshness gate        (active)
```

---

## Shared TAD Protocol

These elements are **invariant** across harnesses. They live in SKILL.md body (not in platform config) and must not be forked:

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

SKILL.md Capability Packs are the only active pack system.

- **Source of truth**: `.agents/skills/` (sole source since v3.0.0; no mirror)
- **Codex**: installed to `.agents/skills/` by `tad.sh --platform codex`
- **Local skills**: project-only skills under `.agents/skills/local/` are reported as INFO by the verifier (`release-verify.sh structural`)
- **YAML Domain Packs**: retired 2026-06-11, archived to `.tad/archive/domains/`

---

## Claude Code Adapter (removed in v3.0.0)

The Claude Code runtime path — install target (`.claude/skills/`, `.claude/settings.json`
hooks, `.claude/workflows/`, `.claude/agents/` model pins) — was removed in v3.0.0
(see `CHANGELOG.md` `### Removed`). The retired compatibility ledger
`.tad/runtime-compat/claude-code.md` records the removal rationale and is retained as a
historical record. Downstream upgrades never delete a pre-existing `.claude/` tree.

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
- `.agents/skills/` — Unified SKILL.md files (sole source of truth since v3.0.0)
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

Platform capabilities change over time. Codex is high-volatility.

Runtime freshness ledgers:
- `.tad/runtime-compat/codex.md` — compatibility ledger with `last_verified`, volatility, recheck triggers (**active**)
- `.tad/runtime-compat/claude-code.md` — **RETIRED in v3.0.0** (retained as historical record, not gated)
- Release/sync freshness gate: `runtime-freshness-verify.sh`

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

| Workflow | Codex | Notes |
|----------|-------|-------|
| Alex activation | `$alex` (AGENTS.md → `.agents/skills/alex/SKILL.md`) | Loads full SKILL.md |
| Blake activation | `$blake` (AGENTS.md → `.agents/skills/blake/SKILL.md`) | Loads full SKILL.md |
| Layer 2 review | Subagent spawning or sequential sessions | Codex custom agents not yet activated |
| Gate pre-checks | `pre-accept-check.sh` / `pre-gate-check.sh` run manually | Codex hooks require trust review |
| Workflows | No equivalent; use prompt-driven subagent orchestration | The `.claude/workflows/` script runtime was removed in v3.0.0 (accepted limitation) |
| Release/sync | `*publish` / `*sync` run from the repo with the Codex harness | Install targets `codex\|opencode\|cursor` (default `codex`) |
| Evidence capture | Hook-driven (same scripts via `.codex/hooks.json`) | `ask_user_question`: accepted limitation — `codex exec` batch mode lacks interactive `request_user_input`; interactive Codex can ask via text |

---

## Current Limitations

| Limitation | Impact | Resolution |
|-----------|--------|------------|
| `.codex/config.toml` not active | Codex uses default model/sandbox, not TAD-optimized | Activate after human approval + final secrets audit |
| `.codex/agents/` not active | Layer 2 review uses prompt-driven spawning, not dedicated reviewer agents | Activate after human approval + final secrets audit |
| `ask_user_question` in `codex exec` batch mode | `request_user_input` unavailable in batch mode (by design — no interactive user); interactive Codex can ask via text normally | Accepted limitation — text-based fallback is documented pattern |
| No workflow script runtime on Codex | Complex orchestration (YOLO Conductor, parallel workflows) uses prompt-driven subagent spawning | Accepted limitation (the Claude-only workflow runtime was removed in v3.0.0) |

---

## Source Artifacts

| Artifact | Path | Phase |
|----------|------|-------|
| Architecture decisions | `.tad/evidence/designs/dual-platform-native-runtime-architecture.md` | Phase 1 |
| Runtime policy | `.tad/evidence/designs/codex-native-runtime-policy.md` | Phase 2 |
| Draft candidates | `.tad/evidence/designs/codex-runtime-candidates/` | Phase 2 |
| Docs upgrade evidence | `.tad/evidence/designs/dual-platform-docs-upgrade.md` | Phase 3 |
| Epic | `.tad/archive/epics/EPIC-20260609-dual-platform-native-runtime-architecture.md` | All |

---

*TAD v3.1 — Codex hook-enabled + OpenCode/Cursor supported, single skill tree (`.agents/skills/`), Claude Code path removed, runtime freshness active.*
