# Dual-Platform Native Runtime Architecture

Phase 1 Architecture Decision Document for TAD's dual-platform native runtime.

---

## YAML Summary

```yaml
epic: EPIC-20260609-dual-platform-native-runtime-architecture
phase: 1
artifact_type: architecture_decision
generated: 2026-06-09
status: proposed
platforms:
  - claude_code
  - codex
source_policy:
  codex_claims_require_current_verification: true
  claude_code_claims_require_local_or_doc_verification: true
outputs:
  capability_matrix: true
  architecture_decisions: true
  runtime_freshness_loop: true
phase_2_ready: true
blocked_by:
  - EPIC-20260609-skill-body-reference-boundary until Phase 3 acceptance unless Human override
```

**Process note**: Human explicitly overrode the P0 blocker on 2026-06-09 by selecting this handoff during Blake activation.

---

## Executive Decision

TAD treats Claude Code and Codex as **first-class, co-equal runtimes** sharing a single TAD protocol layer. Neither platform is subordinate. The architecture separates concerns into three layers:

1. **Shared TAD Protocol** — invariant across platforms: Alex/Blake role contracts, Gates 1-4, handoff discipline, Layer 2 review semantics, execution-discipline rules, completion/evidence requirements, knowledge assessment.
2. **Platform Adapters** — native capabilities of each runtime, implemented using platform-native primitives: Claude Code (hooks, workflows, subagents, MCP, Skill tool) and Codex (AGENTS.md, `.agents/skills/`, `.codex/config.toml`, `.codex/agents/`, hooks, MCP, subagents, plugins).
3. **Runtime Freshness Layer** — compatibility ledgers tracking each platform's capabilities, verified against current sources, with release/sync gates and drift-response policies.

The key architectural judgment: **execution-discipline content (MUST/MANDATORY/VIOLATION rules) stays in SKILL body or strong-load paths on BOTH platforms.** Platform adapters may add mechanics (e.g., Codex custom agents for reviewers, Claude Code workflow scripts) but must not move quality-chain constraints into optional/unloaded paths.

---

## Source Verification Log

All Codex capability claims verified 2026-06-09 against local Codex manual (codex-cli 0.137.0, fetched via `fetch-codex-manual.mjs`).

| # | Codex Claim | Source Route | Result | Status |
|---|-------------|-------------|--------|--------|
| V1 | Skills via `.agents/skills/` with SKILL.md | Manual L6526-6673 (Agent Skills) | Confirmed: progressive disclosure, explicit/implicit invocation, REPO/USER/ADMIN/SYSTEM scopes | **verified** |
| V2 | AGENTS.md as project instructions | Manual L6764-6895 (Custom instructions) | Confirmed: discovery chain (global → project root → CWD), 32KiB default, override support | **verified** |
| V3 | Hooks (10 events) | Manual L10298-10541 (Hooks) | Confirmed: PreToolUse, PostToolUse, PreCompact, PostCompact, UserPromptSubmit, SessionStart, SubagentStart, SubagentStop, PermissionRequest, Stop. JSON or inline TOML. Trust-review flow. | **verified** |
| V4 | Subagents (parallel, custom agents) | Manual L9808-9899 + L11444-11606 (Subagents) | Confirmed: explicit trigger, custom `.codex/agents/*.toml`, built-in default/worker/explorer, max_threads=6, max_depth=1 default, model/reasoning per-agent | **verified** |
| V5 | MCP support | Manual L7107-7280 (MCP) | Confirmed: STDIO + Streamable HTTP, per-server enabled_tools/disabled_tools, approval_mode, CLI + IDE + app | **verified** |
| V6 | Context compaction | Manual L506 | Confirmed: automatic compact with summary, `/compact` manual command, `model_auto_compact_token_limit` config, PreCompact/PostCompact hooks, custom compact prompt | **verified** |
| V7 | Cloud/offload tasks | Manual L3889-3974 (Cloud environments) | Confirmed: container-based, setup scripts, caching, env vars, secrets (removed before agent phase), internet access config | **verified** |
| V8 | Code review (GitHub integration) | Manual L6674-6763 | Confirmed: `@codex review` in PR comments, automatic reviews, customizable via AGENTS.md Review guidelines, `@codex fix` follow-up | **verified** |
| V9 | `.codex/config.toml` project config | Manual L7159-7280 (MCP config), L2040-2243 (Config basics) | Confirmed: project-scoped `.codex/config.toml` in trusted projects, user `~/.codex/config.toml`, model/sandbox/permissions/MCP/hooks | **verified** |
| V10 | Permission profiles & sandbox | Manual L10750-10981 (Permissions) | Confirmed: filesystem (read/write/deny), network (domain rules), permission profiles, `:workspace_roots`, glob deny patterns | **verified** |
| V11 | Automations (recurring tasks) | Manual L3753-3888 | Confirmed: standalone + thread automations, cron scheduling, worktree isolation, sandbox inheritance, skill integration | **verified** |
| V12 | Worktrees | Manual L6160-6308 | Confirmed: Git worktrees for parallel tasks, handoff between local/worktree, auto-cleanup, branch management | **verified** |
| V13 | Plugins (skill distribution) | Manual L9900-10111 + L10982-11116 | Confirmed: `.codex-plugin/plugin.json`, marketplace, bundled MCP/hooks/skills, install/update/remove | **verified** |
| V14 | Rules (command policy) | Manual L7281-7416 | Confirmed: `.rules` files, prefix_rule, regex_rule, approval/deny/prompt actions, experimental | **verified** |
| V15 | Memories | Manual L10542-10644 | Confirmed: opt-in, local markdown files, per-thread control, off by default | **verified** |
| V16 | Chronicle (screen context) | Manual L10112-10238 | Confirmed: opt-in research preview, macOS only, Pro subscribers, screen capture → memory | **verified** |
| V17 | Session logging/traces | Manual L6880 (audit), L3349 (trace_exporter OTEL) | Partial: session-*.jsonl logging available, OTEL trace exporter configurable, but no built-in structured evidence/trace format matching TAD's `.tad/evidence/` convention | **verified_partial** |
| V18 | Codex SDK / Agents SDK integration | Manual L7932-8063 / L8428-8627 | Confirmed: programmatic Codex sessions, Agents SDK orchestration with hand-offs and traces | **verified** |
| V19 | Non-interactive mode | Manual L8064-8427 | Confirmed: `codex exec` for scripted runs, `--full-auto` / `--ask-for-approval never`, stdin piping | **verified** |
| V20 | `ask_user_question` capability | Not found as explicit tool name in manual | Codex uses standard approval/prompt flow; no exact `AskUserQuestion` tool equivalent found. Agent can ask via conversation. | **unknown_current_behavior** |

---

## Current State Inventory

### Where Current Docs Agree

| Claim | AGENTS.md | .tad/codex/README.md | Consistent? |
|-------|-----------|---------------------|-------------|
| Codex is first-class since v2.25.0 | ✅ (L9) | ✅ (L1: "unified SKILL.md") | Yes |
| Unified SKILL.md files for both platforms | ✅ (L10-11) | ✅ (L9-10) | Yes |
| Skills installed to `.agents/skills/` on Codex | ✅ (L71) | ✅ (L14) | Yes |
| Hooks via `.codex/hooks.json` | ✅ (L70) | ✅ (L15) | Yes |
| Compressed editions removed in v2.26 | N/A | ✅ (L19-27) | Yes (correct) |

### Stale Conflicts

| File | Line(s) | Stale Claim | Current Reality |
|------|---------|------------|-----------------|
| `docs/MULTI-PLATFORM.md` | L3 | "Codex CLI and Gemini CLI can serve as specialized execution tools" | Codex is now a first-class runtime, not a specialized tool. This is the dominant framing of the entire document. |
| `docs/MULTI-PLATFORM.md` | L12-15 | Architecture table: Claude Code = "Full TAD Runtime", Codex = "Specialized Executor" | Both should be "First-Class TAD Runtime" with different native primitives |
| `docs/MULTI-PLATFORM.md` | L58 | "TAD v2.8.0 — Claude Code primary (hooks + 20 Domain Packs + 78 tools), Codex/Gemini as specialized tools" | Stale version reference and subordinate framing |
| `docs/MULTI-PLATFORM.md` | L18-25 | "When to Use Codex/Gemini" — frames Codex as only for "Code review, security audit" | Codex can do full TAD workflows (design, implement, review, gate) |
| `docs/MULTI-PLATFORM.md` | L27-33 | Workflow: "Human copies Handoff content to the chosen tool" | Codex reads `.agents/skills/` and `AGENTS.md` natively; human doesn't need to copy handoff content |
| `AGENTS.md` | L68-69 | "Some features (parallel reviewers, auto-hooks) are sequential / manual on Codex" | Codex now has native parallel subagents and hook automation. This claim needs re-verification (may be partially stale). |

### Active Epic Dependency

- **P0**: `EPIC-20260609-skill-body-reference-boundary` — Phase 1 (audit) complete, Phase 2 (inline) active, Phase 3 (verify+sync) planned. This P0 directly affects the body/reference boundary decisions in this architecture.
- **Relationship**: This architecture (P1) builds on the assumption that P0 will inline execution-discipline content back into SKILL body. Phase 2+ of this architecture should validate against the post-P0 SKILL structure.

---

## Capability Matrix

| Surface | Shared TAD Protocol | Claude Code Native | Codex Native | Current TAD Usage | Gap | Fallback | Volatility | Verification Source | Proposed Owner |
|---------|---------------------|--------------------|--------------|-------------------|-----|----------|------------|---------------------|----------------|
| **Role activation** | Alex/Blake identity, persona, commands, STEP 1-4 protocol | `/alex`, `/blake` via Skill tool; SessionStart hook can inject context | `$alex`, `$blake` via AGENTS.md → `.agents/skills/{role}/SKILL.md`; implicit/explicit skill invocation | Both platforms activate roles from SKILL.md | None (v2.26 unified) | If skill fails to load: manual `Read SKILL.md` | Low | V1, V2 | shared_protocol |
| **Skill loading** | SKILL.md format, name/description frontmatter, progressive disclosure | `.claude/skills/` directory; Skill tool loads full SKILL.md on invocation | `.agents/skills/` directory; Codex loads name+desc initially, full SKILL.md on invocation (2% context budget cap) | Both platforms scan skill dirs; Codex has a context-budget cap Claude Code does not | Codex may omit skills from initial list if too many installed; Claude Code doesn't have this limit | Explicit `$skill-name` invocation bypasses the cap | Medium (Codex skill loading heuristics may change) | V1 (L6537-6538) | shared_protocol (format), platform adapters (loading mechanics) |
| **Reference/progressive loading** | `load_when` stubs in SKILL body pointing to references/ | Skill tool integration reads full SKILL.md; model decides whether to Read references | Codex loads SKILL.md body but does NOT auto-follow `load_when` stubs during execution (proven by dogfood) | P0 Epic fixing this: must-body content being inlined back | **Critical gap on Codex**: execution-discipline references not loaded → quality chain silently skipped | Inline must-body content into SKILL body (P0 fix) | High (this is the active P0) | Codex dogfood 2026-06-09, V1 | shared_protocol (must-body in body), codex_adapter (reference loading behavior) |
| **Hooks** | Hook events as integration points for quality checks, traces, routing | `.claude/settings.json` hooks; PreToolUse/PostToolUse/SessionStart etc.; shell scripts | `.codex/hooks.json` or `config.toml` inline; same event names (PreToolUse/PostToolUse/SessionStart/PreCompact/PostCompact/UserPromptSubmit/SubagentStart/SubagentStop/PermissionRequest/Stop); trust-review flow | TAD uses SessionStart hook for context injection on Claude Code; Codex has `hooks.json` auto-generated by `tad.sh` | Hook parity is structurally similar but not identical: Claude Code uses settings.json format, Codex uses hooks.json/config.toml TOML format. Different trust model. | Manual gate pre-checks (`pre-accept-check.sh`, `pre-gate-check.sh`) on Codex | Medium (Codex hook API evolving, new events added) | V3 | claude_code_adapter + codex_adapter (format), shared_protocol (which hooks TAD requires) |
| **Workflows** | Orchestration patterns: Ralph Loop, parallel execution, YOLO Conductor | `.claude/workflows/*.workflow.js`; deterministic agent/parallel/pipeline/phase; background execution | No direct equivalent to `.workflow.js` files. Codex uses subagent spawning + prompting for orchestration. Cloud tasks for offloaded work. Automations for recurring. | Claude Code workflows are native; Codex doesn't execute `.workflow.js` | **Gap**: Codex has no workflow script runtime. Complex orchestration must be done via prompt-driven subagent spawning or Agents SDK. | Sequential execution with explicit prompting on Codex; or use Codex SDK/Agents SDK for programmatic orchestration | Medium (Codex Agents SDK is maturing) | V4, V7, V18 | shared_protocol (Ralph Loop pattern definition), claude_code_adapter (workflow scripts), codex_adapter (subagent-driven orchestration) |
| **Subagents / custom agents** | Layer 2 expert review as sub-agent pattern (spec-compliance, code-reviewer, test-runner, security, performance) | Agent tool with subagent_type; 16+ agent types built-in; isolation: worktree; background execution | Custom agents via `.codex/agents/*.toml` (name, description, developer_instructions, model, reasoning_effort); built-in default/worker/explorer; max_threads=6, max_depth=1 | Claude Code uses Agent tool for Layer 2 reviewers; Codex delegates via prompt | **Gap**: Codex custom agents are TOML config, not the same as Claude Code's rich subagent_type system. TAD reviewer agents need to be mapped to Codex custom agent definitions. | Sequential expert review sessions on Codex (current workaround per AGENTS.md L69: "Parallel expert review: run sequential sessions") | Medium (Codex custom agents are relatively new) | V4 | shared_protocol (review semantics), claude_code_adapter (Agent tool), codex_adapter (`.codex/agents/` TOML) |
| **MCP** | External tool access pattern | `mcp__*` tools via settings.json MCP server config; built-in and user-configured | `config.toml` `[mcp_servers.*]` with STDIO/HTTP support; enabled_tools/disabled_tools; approval_mode per-tool; plugin-bundled MCP | Claude Code has project-level MCP in settings.json; Codex has project-level in `.codex/config.toml` | Config format differs but capability is equivalent. Codex requires trusted project for project-scoped MCP. | Both support user-level MCP config as fallback | Medium | V5 | platform adapters (config format), shared_protocol (which MCP servers TAD recommends) |
| **Tool permissions / sandbox / approvals** | TAD quality model requires certain tools to be allowed for execution | `.claude/settings.json` allow/deny lists; user approval prompts | Permission profiles (filesystem read/write/deny, network domains, `:workspace_roots`); Rules (`.rules` files with prefix_rule/regex_rule); sandbox modes; approval_policy | Claude Code uses settings.json permissions; Codex has richer permission profiles with filesystem + network granularity | Codex permission model is MORE granular than Claude Code's. Different config surface. | Default sandbox policies on both platforms | Medium | V10, V14 | platform adapters |
| **Code review / expert review** | Layer 2 review groups (spec-compliance → code-reviewer → parallel experts); P0/P1 blocking criteria | Agent tool spawns reviewer sub-agents with TAD prompt templates | GitHub PR review (`@codex review`); custom agents for reviewer roles; prompt-driven subagent review | Claude Code: native sub-agent review. Codex: sequential sessions or subagent review. GitHub integration adds automated PR review. | Codex GitHub review is a different surface than TAD Layer 2 review. TAD Layer 2 needs to map to Codex subagent/custom-agent pattern, not just GitHub review. | Sequential manual review on Codex (current AGENTS.md guidance) | Medium | V4, V8 | shared_protocol (review criteria), platform adapters (execution mechanism) |
| **Cloud / offload tasks** | not_applicable for protocol; useful for heavy compute | not_applicable (Claude Code is local-only) | Codex Cloud: container-based, environment config, secrets management, GitHub integration, PR creation from cloud | Not used by TAD currently | **Opportunity**: Codex Cloud could run TAD regression/review in CI-like environments | Claude Code has no cloud equivalent; Codex-only capability | High (cloud features actively evolving) | V7 | codex_adapter (Codex Cloud), deferred (TAD CI integration) |
| **Context compaction / resume** | Compact-sensitive execution discipline must survive compaction | Auto-compact with summary; custom compact prompts possible; Session-state.md for recovery | Auto-compact with summary; `model_auto_compact_token_limit` config; PreCompact/PostCompact hooks; `/compact` manual; custom `compact_prompt`/`experimental_compact_prompt_file` | Claude Code: TAD uses session-state.md + post-compact recovery protocol. Codex: not yet tested. | **Gap**: TAD's post-compact recovery protocol (§4.5 in CLAUDE.md) is Claude Code-specific. Codex compact behavior needs equivalent testing. | session-state.md is platform-agnostic (file-based); hook-based compact notification differs | Medium | V6 | shared_protocol (session-state.md recovery), platform adapters (compact mechanics) |
| **Trace / evidence capture** | `.tad/evidence/` directory structure; trace-step.sh; Ralph Loop state files; completion reports | Hook-driven traces (SessionStart, PostToolUse); `.tad/hooks/trace-step.sh`; native tool result logging | Session JSONL logging (`session-*.jsonl`); OTEL trace export; no built-in `.tad/evidence/` convention | Claude Code: TAD hooks capture traces to `.tad/evidence/traces/`. Codex: no equivalent TAD trace integration yet. | **Gap**: Codex can produce session logs but doesn't write to TAD's evidence structure. Trace-step.sh relies on bash hooks which need Codex hook wiring. | Manual evidence collection on Codex; or wire trace-step.sh into Codex hooks.json | Medium | V17 | shared_protocol (evidence format), platform adapters (capture mechanism) |
| **Release / sync behavior** | `tad.sh` installer, `*sync`/`*publish` commands, deny-list derivation, release-verify.sh, structural diff | Claude Code: Alex runs `*publish`/`*sync` natively | Codex: `tad.sh --platform codex --yes` installs to `.agents/skills/`; no native `*publish`/`*sync` execution | TAD release/sync is Claude Code-driven; Codex is a sync target | Codex cannot run `*publish`/`*sync` independently (these are Alex commands requiring Claude Code skill infrastructure) | Always run release/sync from Claude Code terminal | Low (release process is TAD-controlled, not platform-controlled) | Current tad.sh, AGENTS.md | shared_protocol (release criteria), claude_code_adapter (execution), codex_adapter (install target) |
| **Runtime freshness / drift detection** | Freshness ledger, last_verified, volatility, drift response | Claude Code: lower volatility but still tracked — compact behavior, Skill tool, Agent tool, hook contract changes need ledger entries (per D7) | Codex CLI version changes, config schema evolution, new features/deprecations, sandbox behavior changes | No formal freshness tracking exists | **Gap**: No mechanism to detect platform capability changes between TAD releases | Manual re-check before each release | High (Codex), Low-Medium (Claude Code) | V1-V20 | runtime_freshness (new layer) |

---

## Architecture Decisions

### D1: TAD Protocol Invariants vs Platform Adapters

- **Decision:** The following are invariant TAD protocol and MUST be present in SKILL body on both platforms: Alex/Blake role contracts, Gates 1-4 semantics, handoff protocol, Layer 2 review criteria (expert groups, pass/fail rules), Ralph Loop structure, completion report requirements, evidence directory conventions, knowledge assessment protocol, execution-discipline keywords (MUST/MANDATORY/VIOLATION), honest_partial protocol, and post-compact recovery. Everything else is a platform adapter or runtime freshness concern.
- **Owner Layer:** shared_protocol
- **Rationale:** The Codex dogfood (2026-06-09) proved that quality-chain rules placed in reference files were silently skipped. The protocol invariants are the rules whose absence causes unknowing violation. Platform-specific mechanics (how hooks fire, how subagents spawn, how config is formatted) are adapter concerns.
- **Codex impact:** SKILL.md body content is the authoritative protocol source. Codex-specific mechanics (TOML config, `.codex/agents/`) are documented in adapter layers, not protocol body.
- **Claude Code impact:** No change to existing protocol. Claude Code adapter details (Skill tool, workflow scripts, settings.json hooks) remain outside protocol body.
- **Quality-chain impact:** Gates, Layer 2, and evidence requirements are explicitly protocol-layer, ensuring neither platform can bypass them.
- **Freshness handling:** Protocol layer is TAD-version-controlled; changes require TAD Epic.
- **Phase 2 implication:** Phase 2 should validate that Codex adapter additions don't move any protocol invariant into an adapter-only path.

### D2: Execution-Discipline Content Placement

- **Decision:** Execution-discipline content (Gate 3 checklist, Layer 2 requirements, completion report format, Ralph Loop structure, circuit breaker rules) MUST remain in SKILL body or a strong-load path that fires without agent opt-in on both platforms. The "circular trigger" discriminant (EPIC-20260609-skill-body-reference-boundary Phase 1) determines placement: if the `load_when` trigger cannot fire without the agent having read the reference, the content is must-body.
- **Owner Layer:** shared_protocol
- **Rationale:** P0 Epic finding: Codex's progressive loading loads SKILL body on activation but does NOT auto-follow `load_when` stubs during execution. References with circular triggers become invisible. principles.md safety entry: "Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical."
- **Codex impact:** After P0 inline fix, Codex Blake will have all execution discipline in SKILL body. No Codex-specific workaround needed.
- **Claude Code impact:** Same inline fix applies. Claude Code's tighter Skill tool integration made the gap less visible but the principle applies equally.
- **Quality-chain impact:** Directly prevents the v2.26 quality chain failure class.
- **Freshness handling:** last_verified per P0 Epic Phase 3 dogfood. Volatile: false (this is a TAD design decision, not a platform behavior).
- **Phase 2 implication:** Phase 2 must NOT move execution-discipline content into `.codex/agents/` or `.codex/config.toml`. Those are adapter mechanics, not protocol placement.

### D3: Codex Config Policy Scope

- **Decision:** `.codex/config.toml` at project level is appropriate for: model selection, sandbox/permission profiles, MCP server configuration, hook references, skill enable/disable, and agent settings. It MUST NOT contain: user secrets/tokens, personal auth, machine-specific paths, or API keys. Project `.codex/config.toml` requires Codex trust-review.
- **Owner Layer:** codex_adapter
- **Rationale:** Codex manual confirms project-scoped config in trusted projects. TAD's security principle (NFR5) requires separating project-owned from user-owned settings. Codex's built-in trust model (untrusted projects don't load project hooks/config) provides a safety mechanism.
- **Codex impact:** Phase 2 should design a template `.codex/config.toml` with TAD-recommended settings. Committed to repo.
- **Claude Code impact:** None. Claude Code uses `.claude/settings.json` which is already TAD-managed.
- **Quality-chain impact:** Config should enforce sandbox policies compatible with TAD's gate pre-checks.
- **Freshness handling:** last_verified: 2026-06-09. Volatility: medium (Codex config schema evolves). Recheck trigger: Codex CLI major version bump.
- **Phase 2 implication:** Phase 2 designs the actual `.codex/config.toml` content. Must include model defaults, sandbox profile, and MCP server policy.

### D4: Codex Custom-Agent Evaluation Scope

- **Decision:** Evaluate `.codex/agents/` for TAD reviewer roles (code-reviewer, spec-compliance, security-auditor, performance-optimizer, test-runner) as custom agents with specialized model/reasoning settings. Do NOT replicate full Alex/Blake personas as custom agents — SKILL.md is the authoritative persona source. Custom agents are narrow-scope task executors.
- **Owner Layer:** codex_adapter
- **Rationale:** Codex custom agents (`.codex/agents/*.toml`) allow model selection, reasoning effort, and developer_instructions per agent. TAD's Layer 2 reviewers are the natural candidates. However, making Alex/Blake full custom agents would fork the protocol (SKILL.md vs TOML instructions diverge).
- **Codex impact:** Phase 2 should prototype reviewer custom agents. Keep instructions minimal and role-specific (e.g., "Review for P0/P1 bugs. Follow TAD code-reviewer criteria.").
- **Claude Code impact:** None. Claude Code continues to use Agent tool with subagent_type.
- **Quality-chain impact:** Custom agents inherit sandbox policy. Review criteria (what counts as P0/P1) remain in shared protocol, not in the TOML instructions.
- **Freshness handling:** last_verified: 2026-06-09. Volatility: medium (custom agent schema is relatively new). Recheck: after Codex agents feature updates.
- **Phase 2 implication:** Phase 2 creates candidate `.codex/agents/` TOML files. Must validate: do custom-agent reviews produce quality comparable to Claude Code's Layer 2?

### D5: Claude Code Compatibility Preservation

- **Decision:** All existing Claude Code capabilities (skills, hooks/workflows, compact behavior, sync semantics, Skill tool, Agent tool, MCP integration) remain valid and unchanged. This architecture adds Codex-native capabilities; it does not remove or replace Claude Code mechanisms.
- **Owner Layer:** claude_code_adapter
- **Rationale:** Claude Code is the proven development platform with extensive TAD integration. Breaking compatibility would regress the primary workflow. NFR3: no protocol fork.
- **Codex impact:** None.
- **Claude Code impact:** Explicit preservation commitment. Any future change to Claude Code adapter must be validated against existing TAD test evidence.
- **Quality-chain impact:** Claude Code quality chain is the reference implementation. Codex quality chain must achieve behavioral parity, not replace it.
- **Freshness handling:** Claude Code behavior is current by definition (it's the development environment). Volatility: low for TAD-relevant behavior.
- **Phase 2 implication:** Phase 2 Codex additions must not require Claude Code changes.

### D6: Review/Layer 2 Mapping Across Platforms

- **Decision:** Layer 2 review semantics (group priority, pass/fail criteria, escalation) are shared protocol. The execution mechanism differs: Claude Code uses Agent tool with subagent_type; Codex uses subagent spawning or custom agents. Both must produce equivalent review evidence in `.tad/evidence/reviews/`. Codex GitHub PR review (`@codex review`) is a SEPARATE capability from TAD Layer 2 — it complements but does not replace it.
- **Owner Layer:** shared_protocol (semantics) + platform adapters (execution)
- **Rationale:** TAD Layer 2 has specific group ordering (spec-compliance → code-reviewer → parallel experts) and blocking criteria (P0=0, P1=0). Codex GitHub review uses its own P0/P1 heuristics and posts to PR comments. These serve different purposes.
- **Codex impact:** Codex must be instructed (via SKILL body or AGENTS.md) to follow TAD Layer 2 group ordering. Codex GitHub review can run in addition as an extra signal.
- **Claude Code impact:** No change.
- **Quality-chain impact:** Review evidence format in `.tad/evidence/reviews/` is platform-agnostic. Both platforms produce the same output structure.
- **Freshness handling:** Codex subagent/custom-agent capabilities are medium volatility. Last verified: 2026-06-09.
- **Phase 2 implication:** Phase 2 should test whether Codex custom agents can follow TAD Layer 2 group ordering reliably.

### D7: Runtime Freshness Ledger and Release Gate

- **Decision:** Create `.tad/runtime-compat/codex.md` and `.tad/runtime-compat/claude-code.md` as compatibility ledgers. Each entry records: surface, current behavior, source, last_verified, runtime version, owner, volatility, next review date, regression required, and fallback behavior. TAD release/sync must include a freshness check: any entry with `last_verified` older than 60 days triggers a WARNING; any entry marked `volatile` with `last_verified` older than 30 days triggers a BLOCK.
- **Owner Layer:** runtime_freshness
- **Rationale:** Platform capability assumptions decay fast (handoff-design.md pattern). The cost of re-research (~30 min) is trivial compared to maintaining wrong architecture. The ledger makes freshness a GATE, not a memory.
- **Codex impact:** Codex ledger entries cover all matrix surfaces. Each claim links to verification source.
- **Claude Code impact:** Claude Code ledger is lighter (less volatile) but still tracks compact behavior, Skill tool behavior, Agent tool behavior, and hook contract.
- **Quality-chain impact:** Freshness gate prevents shipping TAD versions with stale platform assumptions.
- **Freshness handling:** This IS the freshness handling mechanism. Self-referential: the ledger tracks its own last_verified date.
- **Phase 2 implication:** Phase 2 should prototype the ledger format. Phase 4 implements the full loop with release gate integration.

### D8: Full-Cycle Regression Harness

- **Decision:** Phase 5 must produce a repeatable regression test: `$alex activation → handoff → $blake implementation → Gate 3 → Gate 4 → trace/evidence`. Run on both Codex and Claude Code (where feasible). n=3 stability recommended. Regression evidence stored in `.tad/evidence/dual-platform-regression/`.
- **Owner Layer:** shared_protocol (test definition) + platform adapters (execution)
- **Rationale:** Validation theater (ac-verification.md, YOLO audit findings): static checks and grep patterns pass while live execution fails. Only a full-cycle run is ground truth. Codex dogfood (GEN food) was the first instance of this catching quality-chain failure.
- **Codex impact:** Codex full-cycle regression is the acceptance criterion for this Epic.
- **Claude Code impact:** Claude Code regression is the reference baseline.
- **Quality-chain impact:** Regression evidence is the final proof that the architecture works in practice, not just on paper.
- **Freshness handling:** Regression must be re-run after any TAD release that changes SKILL files or platform adapter config.
- **Phase 2 implication:** Phase 2 does not implement the harness but should identify the test project and minimum scenario.

### D9: Documentation Authority and Stale-Doc Update Path

- **Decision:** `docs/MULTI-PLATFORM.md` is stale and must be rewritten in Phase 3 to reflect dual-runtime architecture. `AGENTS.md` is current but has a partially stale claim (L68-69 about sequential/manual Codex features). `.tad/codex/README.md` is current (migration notice only). Phase 1 identifies stale claims; Phase 3 edits them.
- **Owner Layer:** shared_protocol (what docs must say) + deferred (Phase 3 edits)
- **Rationale:** NFR6: Phase 1 is design-only. But stale docs create confusion for anyone reading the repo between now and Phase 3.
- **Codex impact:** After Phase 3, `docs/MULTI-PLATFORM.md` will describe Codex as a first-class runtime with native capabilities, not a specialized executor.
- **Claude Code impact:** Claude Code description stays accurate. Minor: remove "primary" subordination language.
- **Quality-chain impact:** Correct docs prevent downstream projects from using stale Codex integration patterns.
- **Freshness handling:** Doc freshness is tracked in the runtime-compat ledger.
- **Phase 2 implication:** Phase 2 may add new docs (e.g., Codex config guide) but should not edit existing docs (that's Phase 3).

### D10: What Is Explicitly Deferred

- **Decision:** The following are explicitly OUT OF SCOPE for this Epic and deferred to future work:
  1. **Third platform support** (Gemini, Cursor, etc.) — architecture is designed for two but does not preclude extension.
  2. **TAD CI/CD integration** with Codex Cloud — promising but requires separate design.
  3. **Codex plugin packaging** of TAD skills — possible future distribution mechanism.
  4. **Chronicle integration** — research preview, Pro-only, macOS-only; too volatile and narrow.
  5. **Automated cross-platform test runner** — Phase 5 regression is manual/semi-automated; full automation is future.
  6. **Codex SDK/Agents SDK programmatic TAD** — interesting for enterprise but out of scope.
  7. **Migration of existing TAD hooks to Codex hook format** — hooks.json is auto-generated by tad.sh; deeper integration deferred.
- **Owner Layer:** deferred
- **Rationale:** Each deferred item is either too volatile (Chronicle), too complex (CI/CD), or unnecessary for the immediate goal (first-class runtime with quality chain intact).
- **Codex impact:** Deferred items don't block Phase 2-5.
- **Claude Code impact:** None.
- **Quality-chain impact:** None — deferred items are additive, not quality-critical.
- **Freshness handling:** Deferred items should be re-evaluated at the next TAD major version or when platform capabilities stabilize.
- **Phase 2 implication:** Phase 2 should not accidentally implement deferred items.

---

## Runtime Freshness Loop

### Compatibility Ledger Format

Each entry in `.tad/runtime-compat/{platform}.md`:

```yaml
surface: "Skill loading"
current_behavior: "Progressive disclosure; 2% context budget cap; explicit invocation bypasses cap"
source: "Codex manual L6537-6538, codex-cli 0.137.0"
last_verified: 2026-06-09
runtime_version: "codex-cli 0.137.0"
owner: "codex_adapter"
volatility: medium
next_review: 2026-07-09
regression_required: false
fallback_behavior: "Explicit $skill-name invocation"
notes: "Cap threshold may change with context window size updates"
```

### Triggers for Re-Verification

1. **Before TAD release**: `release-verify.sh` checks all ledger entries. Any entry with `last_verified` > 60 days → WARNING. Any `volatile` entry with `last_verified` > 30 days → BLOCK.
2. **Before `*sync` to downstream projects**: Same freshness check.
3. **After Codex CLI version bump**: Re-verify all `volatile` and `medium` volatility entries against new manual.
4. **After official Codex documentation changes**: Re-verify affected surfaces.
5. **Monthly maintenance cadence**: Review all entries, update `last_verified` for confirmed-unchanged.

### Drift Response Policy

When a platform capability changes:

1. **Detected** → Create `.tad/active/ideas/IDEA-{date}-{platform}-{surface}-drift.md`
2. **Evaluated** → Classify as: protocol impact (requires Epic), adapter impact (requires handoff), documentation-only (quick fix), or accepted limitation (record and move on)
3. **Adopted/Deferred** → Update ledger entry. If adopted: create handoff for implementation. If deferred: record reason and re-evaluate at next trigger.

### Fail-Closed Rules

- Unknown Codex config/agent/hook behavior that would affect safety or quality gates → BLOCK adoption until verified.
- Codex feature claiming to replace a TAD quality mechanism (e.g., "built-in code review replaces Layer 2") → BLOCK until proven equivalent via full-cycle regression.
- New Codex sandbox/permission changes that restrict TAD tool access → BLOCK sync until workaround verified.

### Feature Adoption Flow

```
New Codex Feature Detected
  ↓
Does it affect TAD protocol invariants?
  → Yes: Requires Epic-level review. BLOCK until designed.
  → No: Continue.
  ↓
Does it affect an existing adapter?
  → Yes: Create handoff for adapter update. Test on non-critical project first.
  → No: Continue.
  ↓
Is it useful for TAD?
  → Yes: Create IDEA, evaluate in next surplus/planning cycle.
  → No: Record as "monitored, not adopted" in ledger.
```

---

## Phase 2 Recommendations

### `.codex/config.toml` Evaluation

Phase 2 should design and test a project-level `.codex/config.toml` covering:

1. **Model defaults**: Recommended model for TAD work (balance quality vs cost).
2. **Sandbox profile**: Permission profile compatible with TAD gate pre-checks and evidence writing.
3. **MCP servers**: Which TAD-recommended MCP servers to configure project-scoped.
4. **Hook references**: Confirm `.codex/hooks.json` (auto-generated by tad.sh) is sufficient or needs config.toml supplement.
5. **Skill config**: Enable/disable specific skills; ensure TAD skills take priority over user-global skills.
6. **Agent settings**: `agents.max_threads` and `agents.max_depth` appropriate for TAD reviewer subagents.

**Must NOT include**: API keys, user tokens, personal paths, or auth credentials.

### `.codex/agents/` Evaluation

Phase 2 should prototype and test custom agent definitions for:

1. **spec-compliance-reviewer** — narrow focus on handoff AC satisfaction.
2. **code-reviewer** — P0/P1 bug detection, TAD code-review criteria.
3. **test-runner** — test execution and coverage verification.
4. **security-auditor** (conditional) — security scan on security-sensitive changes.
5. **performance-optimizer** (conditional) — performance review on perf-sensitive changes.

Each custom agent TOML should:
- Use minimal `developer_instructions` referencing TAD review criteria (not duplicating the full protocol).
- Set appropriate `model` and `model_reasoning_effort` for the task.
- Inherit sandbox from parent session.

**Must NOT**: Replicate full Alex/Blake personas; fork TAD protocol into TOML instructions; bypass SKILL.md as authoritative source.

---

## Phase 3 Documentation Updates Needed

| File | Current State | Required Update |
|------|---------------|----------------|
| `docs/MULTI-PLATFORM.md` | v2.8.0 "specialized executor" framing | Complete rewrite: dual-runtime architecture, capability matrix summary, adapter boundaries, freshness references |
| `AGENTS.md` L68-69 | "parallel reviewers, auto-hooks sequential/manual on Codex" | Verify against current Codex subagent/hook state; update or remove stale claim |
| `.tad/codex/README.md` | Migration notice only (accurate) | Consider expanding with adapter overview or linking to architecture decision doc |
| `CHANGELOG.md` | Does not mention dual-runtime architecture | Add entry when architecture changes land |

---

## Risks and Open Questions

### Risks

1. **P0 dependency**: This architecture assumes P0 (skill-body-reference-boundary) will inline execution-discipline content. If P0 is blocked or changes scope, some decisions here need revisiting.
2. **Codex custom-agent quality parity**: Unknown whether Codex custom agents with minimal instructions can produce Layer 2 reviews of equivalent quality to Claude Code's rich Agent tool with subagent_type. Phase 2 must validate empirically.
3. **Codex hook trust friction**: Codex requires hook trust-review. For downstream projects, first-time Codex activation may prompt trust approval for TAD hooks, adding friction.
4. **Skill context budget cap**: Codex caps skill descriptions at ~2% of context window. With 24+ capability packs + Alex + Blake skills, some may be omitted from the initial list on Codex.
5. **`ask_user_question` on Codex**: TAD uses `AskUserQuestion` for interactive decisions (Socratic inquiry, mode selection, Gate confirmations). Codex equivalent is `unknown_current_behavior`. **Degradation strategy**: On Codex, Socratic inquiry should degrade to conversational questioning (model asks in plain text, user responds in next message). This is functionally equivalent but loses the structured multi-choice UI. Phase 2 must verify whether Codex has a native structured-question tool or whether conversational fallback is sufficient for TAD's quality requirements.

### Open Questions

1. **Codex compact behavior for TAD**: Does Codex's auto-compact preserve TAD session-state.md recovery? Needs Phase 5 testing.
2. **Codex evidence writing**: Can Codex write to `.tad/evidence/` in sandbox mode, or does sandbox restrict writes outside `.agents/`? Needs Phase 2 sandbox profile design.
3. **Codex `codex exec resume --last`**: Does this reliably resume multi-turn TAD workflows across compaction? Needs empirical testing.
4. **Cross-platform trace interop**: If both platforms write to `.tad/evidence/traces/`, can traces be meaningfully compared? Format standardization needed.
5. **Codex plugin as TAD distribution**: Would packaging TAD as a Codex plugin simplify installation for downstream projects? Deferred but worth evaluating.

---

## Size / Maintenance Impact

| Artifact | Size Impact | Maintenance Burden |
|----------|-------------|-------------------|
| This architecture document | ~500 lines, one-time | Low — updates only on architecture changes |
| `.tad/runtime-compat/codex.md` (Phase 4) | ~200 lines | Medium — needs freshness updates per release |
| `.tad/runtime-compat/claude-code.md` (Phase 4) | ~100 lines | Low — Claude Code is less volatile |
| `.codex/config.toml` (Phase 2) | ~50 lines | Low — changes on Codex schema updates |
| `.codex/agents/*.toml` (Phase 2) | ~30 lines × 5 agents = ~150 lines | Medium — needs quality parity validation |
| Updated `docs/MULTI-PLATFORM.md` (Phase 3) | ~150 lines (rewrite) | Low — matches architecture doc |
| Regression evidence (Phase 5) | ~100 lines per run | Per-release cost |

**Total new TAD footprint**: ~1250 lines across ~10 files. Manageable within existing TAD structure.

**Key maintenance principle**: The runtime-compat ledger is the load-bearing maintenance artifact. If it's kept fresh, everything else follows. If it goes stale, the architecture degrades to the same failure mode it was designed to prevent.
