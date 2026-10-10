# TAD Multi-Platform Runtime Guide

**Version**: 3.3.0 (Claude Code, Codex, OpenCode and Cursor are install targets)

TAD runs on **Claude Code, Codex, OpenCode, and Cursor as supported install targets**, with a shared protocol.
There is a single skill tree (`.agents/skills/`, the shared source of truth) and four install targets
(`claude-code|codex|opencode|cursor`, default `codex`). Codex, OpenCode and Cursor read `.agents/skills/` natively.
Claude Code does not: it reads `.claude/skills/`, so `tad.sh --platform claude-code` creates one link per skill
(`.claude/skills/<name>` into `.agents/skills/<name>`). Claude Code loads `AGENTS.md` by itself only while the
project has no `CLAUDE.md`; for a project that already has one, the installer keeps a marked `@AGENTS.md`
reference block inside it and never creates a `CLAUDE.md`.

Every harness gets a lifecycle-hook configuration over the same `.tad/hooks/*.sh` scripts (for Claude Code only when the project has no `.claude/settings.json`; Codex wires no PreCompact hook; on Codex the hook configuration did not take effect in a default-trust run and did in a run with the hook trust review bypassed (codex-cli 0.159.3, one machine, `codex exec`); a run through a completed trust review was not tested). Coverage and verification
differ per harness; the status table below is the one place that records them.

With `--platform codex|opencode|cursor` the installer does not change your `CLAUDE.md` or `.claude/settings.json`, and it leaves your own files under `.claude/` alone. One exception: in a project that already carries a TAD Claude Code projection, it keeps the `.claude/skills/` links current (adds links for new skills, removes dangling ones) and does nothing else there; `TAD_CLAUDE_STICKY=off` turns that off.
With `--platform claude-code` it archives (outside the project, restorable) and replaces only files it can prove
byte-for-byte were shipped by an earlier TAD; everything else, including your own hooks, permissions, MCP config and
`CLAUDE.md` text, stays byte-identical. An existing `.claude/settings.json` is kept and TAD's hooks are not added to it.

---

## Current Status

| Platform | Install target | Skill discovery | Lifecycle hooks (shipped) | Workflow tool | Verification status |
|----------|----------------|-----------------|---------------------------|---------------|---------------------|
| **Claude Code** | `--platform claude-code` | `.claude/skills/<name>` links into `.agents/skills/` | `.claude/settings.json`: SessionStart, PostToolUse, PreCompact, commands anchored to `$CLAUDE_PROJECT_DIR`; written when the project has no `settings.json` (an existing file that differs from the template is kept untouched) | Yes, main session only (`.tad/workflows/claude/`, `scriptPath`) | Headless only. 2026-10-08 ledger probes (claude 2.1.295, machine not recorded) and 2026-10-09 local run (claude 2.1.295): `AGENTS.md` (project without a `CLAUDE.md`), SessionStart, write-time trace row, sub-agent definition visible, skill answer with only the Skill tool enabled (absent in an empty-directory control); fixed-task chain PASS (1). Compaction (3) and an existing `settings.json` (4) as noted; interactive surface, subdirectory sessions and ask-user capture not measured |
| **Codex** | `--platform codex` (default) | `.agents/skills/` | `.codex/hooks.json`: SessionStart, PostToolUse; PreCompact not wired; did not run under default trust in the one run measured, ran with the trust review bypassed; completed trust review untested | No (sequential sub-agent path) | 2026-10-06: schema review against vendor documentation and help output (codex-cli 0.149.0); a live full-chain attempt on the remote host (codex-cli 0.159.3) failed on the provider usage limit before any tool use. 2026-10-09 local (codex-cli 0.159.3): fixed-task chain PASS, two runs (1). Hooks: see (2). Not tested: completed trust review, interactive use, compaction delivery |
| **OpenCode** | `--platform opencode` | `.agents/skills/` | `.opencode/plugins/tad-hooks.ts`: session start, post write/edit, compacting, compacted | No | Two sets of evidence, kept apart. 2026-10-06 remote host (opencode 1.18.33): live full-chain PASS (on v3.1.0; compaction hooks proven at handler level only, no live compaction; session start proven by fixture capture). 2026-10-09 local machine (opencode 1.18.32, an older version): fixed-task chain PASS (one agent runs the task and reviews itself); `AGENTS.md` returned; write-time trace row with a control file; the skill check was the model reading `SKILL.md` itself, not a harness skill load; session start could not be measured. No session-start context injection, ask-user capture not available |
| **Cursor** | `--platform cursor` | `.agents/skills/` | `.cursor/hooks.json` + shims: sessionStart, postToolUse(Write), preCompact | No | Two sets of evidence, kept apart. 2026-10-06 remote host (agent 2026.10.01-e373342): live full-chain PASS (on v3.1.0; preCompact envelope proven, no live compaction). 2026-10-09 local machine (agent 2026.09.26, an older version): fixed-task chain PASS (one agent runs the task and reviews itself); `AGENTS.md` returned; session-start summary recited; write-time trace row with a control file; a skill answer, one run, where an empty-directory control reached the text only through visible searches. Compaction not run; ask-user capture not available |

Notes to the table:
1. Fixed-task chain: one agent runs the fixed task and reviews itself; there is no Alex to Blake dispatch. On Codex a default-trust run left no write-time trace row; a second run with the trust review bypassed did.
2. Codex hooks, all through `codex exec` (non-interactive): the default-trust run got no session-start summary; the run with `--dangerously-bypass-hook-trust` did. After the `apply_patch` path fix the write-time trace row was seen in two sandbox runs with the review bypassed. The bypass flag is not the interactive trust review, and a run through a completed trust review was not tested.
3. Claude Code compaction: a manual `/compact` made the PreCompact hook write a snapshot, but the CLI reported too few messages to compact, so nothing was compacted; natural compaction was not measured.
4. Claude Code with an existing `.claude/settings.json`: tested with a file that differs from the template (no hook registered, file untouched); an identical file was not tested.

The OpenCode and Cursor hook files are written by every platform install; only `.codex/hooks.json` and the Claude Code projection depend on the platform flag.

The 2026-10-09 results come from one local machine and the CLI versions named in the table. The 2026-10-06 results come from a different machine (the remote host for the live runs); their CLI versions are named in the table, and for Codex the live attempt used the same codex-cli 0.159.3 as 2026-10-09. The two sets are not merged. Interactive sessions were not measured on any harness.

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

Claude Code Adapter                     Codex Adapter
├── .claude/skills/<name> links         ├── .agents/skills/
│   into .agents/skills/                ├── AGENTS.md routing
├── .claude/settings.json hooks         ├── $skill invocation
├── .claude/agents (sub-agent defs)     ├── Subagents (built-in; custom .toml agents not active)
├── Workflow scripts (main session)     ├── Hooks (.codex/hooks.json)
└── marked @AGENTS.md block in          ├── MCP (.codex/config.toml, not active)
    an existing CLAUDE.md               └── Compact (auto, /compact)

Runtime Freshness Layer
├── .tad/runtime-compat/codex.md       (active)
├── .tad/runtime-compat/claude-code.md (active)
├── .tad/runtime-compat/opencode.md    (active)
├── .tad/runtime-compat/cursor.md      (active)
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
- **Codex, OpenCode, Cursor**: installed to `.agents/skills/` by `tad.sh --platform codex|opencode|cursor`
- **Claude Code**: `tad.sh --platform claude-code` installs `.agents/skills/` and adds `.claude/skills/<name>` links to it
- **Local skills**: project-only skills under `.agents/skills/local/` are reported as INFO by the verifier (`release-verify.sh structural`)
- **YAML Domain Packs**: retired 2026-06-11, archived to `.tad/archive/domains/`

---

## Claude Code Adapter

`tad.sh --platform claude-code` installs TAD for Claude Code. The compatibility ledger
`.tad/runtime-compat/claude-code.md` records what has been measured (rows `skill_loading`, `hooks`, `workflows`,
`legacy_adoption`, `release_sync_install`).

| Surface | Implementation |
|---------|---------------|
| Skill loading | Claude Code does not read `.agents/skills/`; the installer creates one relative link per skill under `.claude/skills/` (a generated pointer `SKILL.md` is the fallback). A project that already carries this projection keeps its links current when the installer runs for another platform (opt out with `TAD_CLAUDE_STICKY=off`) |
| Instructions | `AGENTS.md` is read natively only while no `CLAUDE.md` is in the directory chain; for an existing `CLAUDE.md` the installer maintains a marked `@AGENTS.md` block and does not create one |
| Hooks | `.claude/settings.json` registers SessionStart, PostToolUse (Write or Edit; AskUserQuestion) and PreCompact, none blocking. Each command is anchored to `$CLAUDE_PROJECT_DIR`. The file is written only when the project has none; an existing one is kept and hooks are not merged into it. A session started in a subdirectory loads no project hooks |
| Workflows | Ten scripts in `.tad/workflows/claude/`, run with the Workflow tool via `scriptPath` from the main session only; the installer does not project them |
| Sub-agents | `.tad/agents/claude/spec-compliance-reviewer.md` is projected to `.claude/agents/` (create only, never overwrites) |
| Existing installs | An earlier TAD install is adopted by default: files provably shipped by TAD are archived outside the project and replaced; `--claude-adopt=plan` lists them without changing anything, `--claude-adopt=off` skips adoption |
| Updates | The updater does not auto-detect this platform: pass `--platform claude-code`. An already-installed project at the same version needs `--force` to gain the projection |

Evidence level is in the status table above: headless runs only; the 2026-10-09 fixed-task run passed on the local machine, and the interactive surface is not measured.

---

## Codex Adapter

Codex is a supported install target (`--platform codex`, the default) with native skill loading, hooks, subagents, and MCP support.

| Surface | Implementation |
|---------|---------------|
| Skill loading | `.agents/skills/` via `$skill` or implicit matching; progressive disclosure (2% context budget cap) |
| Role activation | `AGENTS.md` routes `$alex` / `$blake` to `.agents/skills/{role}/SKILL.md` |
| Hooks | `.codex/hooks.json`; the Codex platform offers 10 events (PreToolUse, PostToolUse, SessionStart, PreCompact, PostCompact, UserPromptSubmit, SubagentStart, SubagentStop, PermissionRequest, Stop), of which TAD wires SessionStart and PostToolUse; trust-review required. That event list is taken from vendor documentation retrieved 2026-10-06; the codex-cli 0.159.3 help and feature-list probes of 2026-10-09 could not confirm an event list. Hook configuration is not in effect before the trust review is completed (one default-trust run against one bypass run) |
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
- `.tad/runtime-compat/claude-code.md` — compatibility ledger for the Claude Code adapter (**active**, gated by `freshness`)
- `.tad/runtime-compat/opencode.md` — compatibility ledger for the OpenCode adapter (**active**, gated by `freshness`)
- `.tad/runtime-compat/cursor.md` — compatibility ledger for the Cursor adapter (**active**, gated by `freshness`)
- Release/sync freshness gate: `runtime-freshness-verify.sh`

**Current policy**: Before any cross-platform architectural decision, do a fresh capability audit of the target platform's current state. Never rely on assumptions older than 2 months for fast-evolving CLI tools.

---

## External Specialized Tools

Gemini CLI can serve as an external specialized tool via the handoff mechanism. It is **not** a TAD install target.

| Tool | Role | Workflow |
|------|------|---------|
| **Gemini CLI** | External tool for design review, UI prototyping | Alex creates handoff → Human gives to Gemini → Gemini executes → Human brings result back |

Gemini does not receive TAD SKILL files, hooks, or config. It receives handoff content directly from the human.

---

## Workflow Matrix

| Workflow | Codex | Claude Code | OpenCode / Cursor | Notes |
|----------|-------|-------------|-------------------|-------|
| Alex activation | `$alex` (AGENTS.md → `.agents/skills/alex/SKILL.md`) | `/alex` (via `.claude/skills/alex` link) | `/alex` (`.agents/skills/` native) | Loads full SKILL.md |
| Blake activation | `$blake` (AGENTS.md → `.agents/skills/blake/SKILL.md`) | `/blake` (via `.claude/skills/blake` link) | `/blake` (`.agents/skills/` native) | Loads full SKILL.md |
| Layer 2 review | Subagent spawning or sequential sessions | Sub-agents; `spec-compliance-reviewer` definition projected to `.claude/agents/` | Built-in sub-agents or sequential sessions | Codex custom agents not yet activated |
| Gate pre-checks | `pre-accept-check.sh` / `pre-gate-check.sh` run manually | Same scripts, run manually | Same scripts, run manually | Codex hooks require trust review |
| Workflows | None; prompt-driven subagent orchestration (sequential path) | `.tad/workflows/claude/` called via `scriptPath` from the main session only (sub-agents cannot call the Workflow tool: from earlier project observation, not re-measured in Phase 3) | None; prompt-driven subagent orchestration (sequential path) | Workflow scripts are Claude Code only; see `.tad/workflows/README-claude.md` |
| Release | `*publish` runs from the repo with any harness | same | same | The former `*sync` command is retired; projects pull updates with the installer. Install targets `claude-code\|codex\|opencode\|cursor` (default `codex`) |
| Evidence capture | Hook-driven once the Codex hook trust review is completed (same scripts via `.codex/hooks.json`); the write-time trace was seen only in sandbox runs with the trust review bypassed | Hook-driven where hooks are installed; ask-user capture not measured | Hook-driven; ask-user capture not available | `ask_user_question`: accepted limitation on Codex — `codex exec` batch mode lacks interactive `request_user_input`; interactive Codex can ask via text |

---

## Current Limitations

| Limitation | Impact | Resolution |
|-----------|--------|------------|
| `.codex/config.toml` not active | Codex uses default model/sandbox, not TAD-optimized | Activate after human approval + final secrets audit |
| `.codex/agents/` not active | Layer 2 review uses prompt-driven spawning, not dedicated reviewer agents | Activate after human approval + final secrets audit |
| `ask_user_question` in `codex exec` batch mode | `request_user_input` unavailable in batch mode (by design — no interactive user); interactive Codex can ask via text normally | Accepted limitation — text-based fallback is documented pattern |
| No workflow script runtime on Codex, OpenCode, Cursor | Complex orchestration (YOLO Conductor, parallel workflows) uses prompt-driven subagent spawning | Accepted limitation: workflow scripts live in `.tad/workflows/claude/` and only Claude Code has the Workflow tool |

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

*TAD v3.3.0 — one skill tree (`.agents/skills/`), four install targets, per-harness evidence in the status table.*
