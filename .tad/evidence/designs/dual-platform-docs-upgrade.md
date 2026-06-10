# Dual-Platform Docs Upgrade Evidence

Phase 3 documentation upgrade for the dual-platform native runtime architecture.

## Files Changed

| File | Action | Summary |
|------|--------|---------|
| `docs/MULTI-PLATFORM.md` | Rewritten | v2.8.0 "Specialized Tools Guide" → v2.26 Phase 3 "Multi-Platform Runtime Guide" with 12 sections |
| `.tad/codex/README.md` | Expanded | Migration-only notice → Codex adapter guide with 8 sections |
| `AGENTS.md` | Minimal update | L9-12 Codex note updated; L66-71 Codex-specific notes updated |

## Stale Claims Removed

| Old Claim | Location | Replacement |
|-----------|----------|------------|
| "TAD Specialized Tools Guide" | MULTI-PLATFORM.md L1 | "TAD Multi-Platform Runtime Guide" |
| "Version 2.8.0" | MULTI-PLATFORM.md L3 | "Version 2.26.0 (Phase 3 — Dual-Platform Architecture)" |
| "Codex CLI = Specialized Executor" | MULTI-PLATFORM.md L13-17 | First-class runtime status table |
| "Claude Code primary" | MULTI-PLATFORM.md L5-7 | Both platforms listed as first-class |
| "human copies handoff to tool" | MULTI-PLATFORM.md L26-32 | Native SKILL loading workflow |
| "20 Domain Packs + 78 tools" | MULTI-PLATFORM.md L58 | Removed (stale count) |
| ".tad/skills/" references | MULTI-PLATFORM.md L43-54 | Removed (old path) |
| "sequential / manual on Codex" | AGENTS.md L11 | Codex native subagents+hooks noted; custom agents draft-only |

## Active-vs-Draft Config Status

- **Active**: `.codex/hooks.json`, `.agents/skills/`, `AGENTS.md`
- **Draft-only**: `.tad/evidence/designs/codex-runtime-candidates/` (config.toml.draft + 3 agent TOML drafts)
- **Not created**: `.codex/config.toml`, `.codex/agents/`

## Phase 4/5 Carry-Forward

| Item | Phase | Status |
|------|-------|--------|
| Runtime freshness ledger | Phase 4 | Not started |
| `ask_user_question` hook verification | Phase 5 | Unknown on Codex |
| Custom-agent review quality parity | Phase 5 | Untested |
| Full-cycle Codex regression | Phase 5 | Not run |
| Draft-to-active config activation | Phase 5+ | Requires Human approval |
