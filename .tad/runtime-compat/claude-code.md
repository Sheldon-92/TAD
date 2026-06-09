# Runtime Compatibility Ledger: Claude Code

**Platform:** claude_code
**Ledger Version:** 1
**Last Updated:** 2026-06-09
**Source:** Local runtime observation + TAD project knowledge

## Drift Response Policy

When a Claude Code capability changes:

1. **Detected** — Create `.tad/active/ideas/IDEA-{date}-claude-code-{surface}-drift.md`
2. **Evaluated** — Classify: protocol impact (Epic), adapter impact (handoff), docs-only (quick fix), accepted limitation (record)
3. **Adopted/Deferred** — Update this ledger. If adopted: handoff. If deferred: record reason, set next_review.

Claude Code is lower-volatility than Codex but NOT freshness-exempt. Compact behavior, Skill tool, Agent tool, and hook contracts all change and need tracking.

## Ledger Entries

| surface | owner | current_behavior | source | runtime_version | last_verified | volatility | next_review | regression_required | fallback_behavior | status |
|---------|-------|------------------|--------|-----------------|---------------|------------|-------------|---------------------|-------------------|--------|
| skill_loading | claude_code_adapter | .claude/skills/ via Skill tool; full SKILL.md loaded on invocation; no context budget cap | Local runtime observation | Claude Opus 4.6 | 2026-06-09 | low | 2026-12-09 | no | Manual Read of SKILL.md file | verified |
| hooks_settings | claude_code_adapter | .claude/settings.json hooks; PreToolUse/PostToolUse/SessionStart/UserPromptSubmit | Local settings.json | Claude Opus 4.6 | 2026-06-09 | low | 2026-12-09 | no | Manual script execution | verified |
| workflows | claude_code_adapter | .claude/workflows/*.workflow.js; agent/parallel/pipeline/phase/log/budget APIs; background execution | Local runtime observation | Claude Opus 4.6 | 2026-06-09 | medium | 2026-09-09 | no | Sequential Agent tool calls | verified |
| agent_tool_subagents | claude_code_adapter | Agent tool with 16+ subagent_type options; isolation: worktree; foreground/background; model override | Local runtime observation | Claude Opus 4.6 | 2026-06-09 | medium | 2026-09-09 | no | Direct tool calls without subagent delegation | verified |
| mcp | claude_code_adapter | .claude/settings.json MCP config; project-scoped; built-in + user-configured; ToolSearch for deferred tools | Local settings.json | Claude Opus 4.6 | 2026-06-09 | low | 2026-12-09 | no | Direct API/tool calls | verified |
| permissions | claude_code_adapter | .claude/settings.json allow/deny lists; user approval prompts; permission modes | Local settings.json | Claude Opus 4.6 | 2026-06-09 | low | 2026-12-09 | no | User approves each tool call | verified |
| context_compaction | claude_code_adapter | Auto-compact with summary; session-state.md for TAD recovery; post-compact recovery protocol in CLAUDE.md | Local runtime observation | Claude Opus 4.6 | 2026-06-09 | medium | 2026-09-09 | yes | Re-read session-state.md + re-invoke /blake or /alex | verified |
| trace_evidence_capture | claude_code_adapter | Hook-driven: post-write-sync.sh emits trace events on file writes; .tad/evidence/traces/*.jsonl | Local hooks + trace files | Claude Opus 4.6 | 2026-06-09 | low | 2026-12-09 | no | Manual evidence file creation | verified |
| release_sync_source | claude_code_adapter | Alex runs *publish/*sync; tad.sh installer; deny-list derivation; release-verify.sh; structural diff | Local tad.sh + release-verify.sh | Claude Opus 4.6 | 2026-06-09 | low | 2026-12-09 | no | Manual file copy + diff verification | verified |
