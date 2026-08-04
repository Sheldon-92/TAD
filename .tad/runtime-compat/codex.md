# Runtime Compatibility Ledger: Codex

**Platform:** codex
**Ledger Version:** 1
**Last Updated:** 2026-08-03
**Source:** local codex-cli 0.146.0 probes/help, isolated Spike A/B evidence, and official Codex docs retrieved 2026-08-03

## Drift Response Policy

When a Codex capability changes:

1. **Detected** — Create `.tad/active/ideas/IDEA-{date}-codex-{surface}-drift.md`
2. **Evaluated** — Classify: protocol impact (Epic), adapter impact (handoff), docs-only (quick fix), accepted limitation (record)
3. **Adopted/Deferred** — Update this ledger. If adopted: handoff. If deferred: record reason, set next_review.

**Fail-closed rule**: Unknown behavior affecting safety/quality/evidence gates → BLOCK adoption until verified.

**Recheck triggers**: Before TAD release, before `*sync`, after Codex CLI version bump, after official doc changes, monthly cadence.

## Ledger Entries

| surface | owner | current_behavior | source | runtime_version | last_verified | volatility | next_review | regression_required | fallback_behavior | status |
|---------|-------|------------------|--------|-----------------|---------------|------------|-------------|---------------------|-------------------|--------|
| skill_loading | codex_adapter | Skills load from .agents/skills; declared references resolve from each skill directory; direct-read probe PASS | spike-b-report.md + https://learn.chatgpt.com/docs/build-skills (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | no | Read references relative to the active skill directory | verified |
| agents_guidance_AGENTS_md | codex_adapter | Repository AGENTS.md guidance is available to the Codex session; project guidance remains the adapter contract | AGENTS.md + local codex --help (2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | medium | 2026-09-02 | no | Direct file read if discovery fails | verified |
| hooks | codex_adapter | Top-level hooks schema is description plus hooks; SessionStart and PostToolUse mappings parse and load; trust review remains required | spike-a-report.md + https://learn.chatgpt.com/docs/hooks (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | no | Manual gate pre-checks (pre-accept-check.sh) | verified |
| subagents_custom_agents | codex_adapter | Built-in subagents are available; TAD custom .codex/agents candidates remain inactive in this adapter | .tad/codex/README.md + https://learn.chatgpt.com/docs/agent-configuration/subagents (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | yes | Sequential prompt-driven review sessions | accepted_limitation |
| mcp | codex_adapter | STDIO and Streamable HTTP MCP configuration remains project-scoped for trusted projects | local .codex/config.toml contract + https://learn.chatgpt.com/docs/config-file/config-basic (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | medium | 2026-09-02 | no | User-level MCP config fallback | verified |
| config_toml | codex_adapter | Project and user config remain distinct; explicit CLI settings take precedence over project and user defaults | local codex --help + https://learn.chatgpt.com/docs/config-file/config-basic (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | medium | 2026-09-02 | no | User-level config only (no project config) | verified |
| sandbox_approval_permissions | codex_adapter | Read-only, writable, and bypass/trust boundaries remain explicit; Spike A used isolated read-only execution | spike-a-report.md + https://learn.chatgpt.com/docs/sandboxing (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | medium | 2026-09-02 | no | Default sandbox (read-only) | verified |
| codex_cloud | codex_adapter | Cloud tasks are a separate remote execution surface; this TAD adapter makes no cloud-parity claim and runs local-only | .tad/codex/README.md + https://developers.openai.com/codex/cloud/ (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | no | Local-only execution | accepted_limitation |
| context_compaction | codex_adapter | Automatic compaction remains a session recovery concern; Spike D reached no authenticated Codex turn, delivered PreCompact fire is unmeasured, and no PreCompact hook is wired; session-state.md remains the fallback | spike-d.md + local codex exec --json (2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | yes | session-state.md file-based recovery (platform-agnostic); re-probe with a trusted authenticated scratch session | verified_partial |
| trace_evidence_capture | codex_adapter | JSONL session output is capturable with codex exec --json; TAD acceptance evidence remains an explicit repository artifact | spike-a-report.md + local codex exec --json (2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | medium | 2026-09-02 | yes | Manual evidence collection; hook-driven trace-step.sh via hooks.json | verified_partial |
| release_sync_install | codex_adapter | tad.sh --platform codex --yes installs to .agents/skills/ and generates the current hooks schema; .claude remains source of truth | local codex --help + tad.sh + release-verify.sh parity (2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | low | 2026-09-02 | no | Manual file copy | verified |
| ask_user_question_hook | codex_adapter | Codex has no exact AskUserQuestion tool equivalent; the retained hook mapping may not fire and the evidence gap is explicit | hooks-platform-mapping.md + https://learn.chatgpt.com/docs/hooks (retrieved 2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | yes | Conversational questioning + manual decision evidence; evidence-completeness gap documented; runtime binding: numbered-options text fallback per role-SKILL 平台绑定交互决策条款 (2026-08-03) | accepted_limitation |
