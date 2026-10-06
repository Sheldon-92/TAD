# Runtime Compatibility Ledger: Codex

**Platform:** codex
**Ledger Version:** 2
**Last Updated:** 2026-10-06
**Source:** local codex-cli 0.149.0 probes/help + official Codex docs retrieved 2026-10-06 (10 of 12 entries re-verified; context_compaction and trace_evidence_capture hung on vendor usage limit — vendor message: try again Oct 10th, 2026 — see .tad/evidence/self-review-r2-20261006/g2-ledger-reverify/)

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
| skill_loading | codex_adapter | Skills load from .agents/skills; declared references resolve from each skill directory; direct-read probe PASS | local codex-cli 0.149.0 features list (skill_search stable) + https://learn.chatgpt.com/docs/build-skills (retrieved 2026-10-06) + g2-ledger-reverify/skill_loading.md | codex-cli 0.149.0 | 2026-10-06 | high | 2026-11-05 | no | Read references relative to the active skill directory | verified |
| agents_guidance_AGENTS_md | codex_adapter | Repository AGENTS.md guidance is available to the Codex session; project guidance remains the adapter contract | local codex-cli 0.149.0 + https://learn.chatgpt.com/docs/config-file/config-basic (retrieved 2026-10-06) + g2-ledger-reverify/agents_guidance_AGENTS_md.md | codex-cli 0.149.0 | 2026-10-06 | medium | 2026-12-05 | no | Direct file read if discovery fails | verified |
| hooks | codex_adapter | Top-level hooks schema is description plus hooks; SessionStart and PostToolUse mappings parse and load; trust review remains required | local codex-cli 0.149.0 features list (hooks stable) + repo .codex/hooks.json + https://learn.chatgpt.com/docs/hooks (retrieved 2026-10-06) + g2-ledger-reverify/hooks.md | codex-cli 0.149.0 | 2026-10-06 | high | 2026-11-05 | no | Manual gate pre-checks (pre-accept-check.sh) | verified |
| subagents_custom_agents | codex_adapter | Built-in subagents are available; the platform now documents custom agents (.codex/agents/*.toml), but this adapter ships and activates none (repo .codex/ holds hooks.json only), so TAD custom agents remain inactive in this adapter | local codex-cli 0.149.0 features list (multi_agent stable) + repo .codex/ listing + https://learn.chatgpt.com/docs/agent-configuration/subagents (retrieved 2026-10-06) + g2-ledger-reverify/subagents_custom_agents.md | codex-cli 0.149.0 | 2026-10-06 | high | 2026-11-05 | yes | Sequential prompt-driven review sessions | accepted_limitation |
| mcp | codex_adapter | STDIO and Streamable HTTP MCP configuration remains project-scoped for trusted projects | local codex-cli 0.149.0 mcp list probe + https://learn.chatgpt.com/docs/config-file/config-basic (retrieved 2026-10-06) + g2-ledger-reverify/mcp.md | codex-cli 0.149.0 | 2026-10-06 | medium | 2026-12-05 | no | User-level MCP config fallback | verified |
| config_toml | codex_adapter | Project and user config remain distinct; explicit CLI settings take precedence over project and user defaults | local codex-cli 0.149.0 --help + https://learn.chatgpt.com/docs/config-file/config-basic (retrieved 2026-10-06) + g2-ledger-reverify/config_toml.md | codex-cli 0.149.0 | 2026-10-06 | medium | 2026-12-05 | no | User-level config only (no project config) | verified |
| sandbox_approval_permissions | codex_adapter | Read-only, writable, and bypass/trust boundaries remain explicit; Spike A used isolated read-only execution | local codex-cli 0.149.0 sandbox/exec --help + https://learn.chatgpt.com/docs/sandboxing (retrieved 2026-10-06) + g2-ledger-reverify/sandbox_approval_permissions.md | codex-cli 0.149.0 | 2026-10-06 | medium | 2026-12-05 | no | Default sandbox (read-only) | verified |
| codex_cloud | codex_adapter | Cloud tasks are a separate remote execution surface; this TAD adapter makes no cloud-parity claim and runs local-only | local codex-cli 0.149.0 (cloud subcommand EXPERIMENTAL) + https://developers.openai.com/codex/cloud/ (retrieved 2026-10-06) + g2-ledger-reverify/codex_cloud.md | codex-cli 0.149.0 | 2026-10-06 | high | 2026-11-05 | no | Local-only execution | accepted_limitation |
| context_compaction | codex_adapter | Automatic compaction remains a session recovery concern; Spike D reached no authenticated Codex turn, delivered PreCompact fire is unmeasured, and no PreCompact hook is wired; session-state.md remains the fallback | spike-d.md + local codex exec --json (2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | high | 2026-09-02 | yes | session-state.md file-based recovery (platform-agnostic); re-probe with a trusted authenticated scratch session | verified_partial |
| trace_evidence_capture | codex_adapter | JSONL session output is capturable with codex exec --json; TAD acceptance evidence remains an explicit repository artifact | spike-a-report.md + local codex exec --json (2026-08-03) | codex-cli 0.146.0 | 2026-08-03 | medium | 2026-09-02 | yes | Manual evidence collection; hook-driven trace-step.sh via hooks.json | verified_partial |
| release_sync_install | codex_adapter | tad.sh --platform codex --yes installs to .agents/skills/ and generates the current hooks schema; .agents/skills is the sole source of truth (v3.0.0) | local codex-cli 0.149.0 --help + tad.sh + repo .codex/hooks.json structure (re-verified 2026-10-06) + g2-ledger-reverify/release_sync_install.md | codex-cli 0.149.0 | 2026-10-06 | low | 2027-04-04 | no | Manual file copy | verified |
| ask_user_question_hook | codex_adapter | Codex has no exact AskUserQuestion tool equivalent; the retained hook mapping may not fire and the evidence gap is explicit | local codex-cli 0.149.0 features list + https://learn.chatgpt.com/docs/hooks event set (retrieved 2026-10-06) + g2-ledger-reverify/ask_user_question_hook.md | codex-cli 0.149.0 | 2026-10-06 | high | 2026-11-05 | yes | Conversational questioning + manual decision evidence; evidence-completeness gap documented; runtime binding: numbered-options text fallback per role-SKILL 平台绑定交互决策条款 (2026-08-03) | accepted_limitation |
