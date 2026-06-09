# Runtime Compatibility Ledger: Codex

**Platform:** codex
**Ledger Version:** 1
**Last Updated:** 2026-06-09
**Source:** local Codex manual via fetch-codex-manual.mjs, codex-cli 0.137.0

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
| skill_loading | codex_adapter | Progressive disclosure; 2% context budget cap; explicit/implicit invocation | Codex manual L6526-6538 | codex-cli 0.137.0 | 2026-06-09 | high | 2026-07-09 | no | Explicit $skill-name invocation bypasses cap | verified |
| agents_guidance_AGENTS_md | codex_adapter | Discovery chain: global AGENTS.md → project root → CWD; 32KiB default; override support | Codex manual L6764-6895 | codex-cli 0.137.0 | 2026-06-09 | medium | 2026-08-09 | no | Direct file read if discovery fails | verified |
| hooks | codex_adapter | 10 events; JSON or TOML; trust-review required; timeout default 600s; concurrent matching | Codex manual L10298-10541 | codex-cli 0.137.0 | 2026-06-09 | high | 2026-07-09 | no | Manual gate pre-checks (pre-accept-check.sh) | verified |
| subagents_custom_agents | codex_adapter | Built-in default/worker/explorer; custom .codex/agents/*.toml; max_threads=6 max_depth=1 | Codex manual L11444-11606 | codex-cli 0.137.0 | 2026-06-09 | high | 2026-07-09 | yes | Sequential prompt-driven review sessions | verified |
| mcp | codex_adapter | STDIO + Streamable HTTP; per-server enabled/disabled tools; approval_mode; project-scoped in trusted projects | Codex manual L7107-7280 | codex-cli 0.137.0 | 2026-06-09 | medium | 2026-08-09 | no | User-level MCP config fallback | verified |
| config_toml | codex_adapter | Project .codex/config.toml in trusted projects; user ~/.codex/config.toml; precedence: CLI > project > profile > user > system | Codex manual L2040-2243 | codex-cli 0.137.0 | 2026-06-09 | medium | 2026-08-09 | no | User-level config only (no project config) | verified |
| sandbox_approval_permissions | codex_adapter | Permission profiles: filesystem read/write/deny; network domain rules; :workspace_roots; glob deny; approval_policy on-request/untrusted/never | Codex manual L10750-10981 | codex-cli 0.137.0 | 2026-06-09 | medium | 2026-08-09 | no | Default sandbox (read-only) | verified |
| codex_cloud | codex_adapter | Container-based cloud tasks; setup scripts; env vars; secrets removed before agent phase; 12h container cache | Codex manual L3889-3974 | codex-cli 0.137.0 | 2026-06-09 | high | 2026-07-09 | no | Local-only execution | verified |
| context_compaction | codex_adapter | Auto-compact with summary; model_auto_compact_token_limit config; PreCompact/PostCompact hooks; custom compact_prompt file | Codex manual L506 + L10521-10522 | codex-cli 0.137.0 | 2026-06-09 | medium | 2026-08-09 | yes | session-state.md file-based recovery (platform-agnostic) | verified |
| trace_evidence_capture | codex_adapter | Session JSONL logging; OTEL trace_exporter configurable; no built-in .tad/evidence/ convention | Codex manual L6880 + L3349 | codex-cli 0.137.0 | 2026-06-09 | medium | 2026-08-09 | yes | Manual evidence collection; hook-driven trace-step.sh via hooks.json | verified_partial |
| release_sync_install | codex_adapter | tad.sh --platform codex --yes installs to .agents/skills/; Codex is sync target not source | tad.sh + AGENTS.md | codex-cli 0.137.0 | 2026-06-09 | low | 2026-12-09 | no | Manual file copy | verified |
| ask_user_question_hook | codex_adapter | Codex has no exact AskUserQuestion tool equivalent; askuser-capture.sh hook may never fire; decision provenance lost | Phase 1 V20 + Phase 2 hooks policy | codex-cli 0.137.0 | 2026-06-09 | high | 2026-07-09 | yes | Conversational questioning + manual decision evidence; evidence-completeness gap documented | accepted_limitation |
