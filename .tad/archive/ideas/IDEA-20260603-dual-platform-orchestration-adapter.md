# IDEA: Dual-Platform Orchestration Adapter (Claude Code + Codex)

**Date:** 2026-06-03
**Status:** promoted
**Scope:** framework-architecture
**Source:** *discuss session — Thariq article on dynamic workflows + Codex subagent research

---

## Context

Thariq (Anthropic) published "A harness for every task: dynamic workflows in Claude Code" (2026-06-03). Article describes 6 composable workflow patterns (classify-and-act, fan-out-and-synthesize, adversarial verification, generate-and-filter, tournament, loop-until-done) executed via a JS runtime (`agent()` / `parallel()` / `pipeline()`).

Separately, Codex CLI has had subagents since 2026-03 GA: TOML agent definitions in `~/.codex/agents/`, `codex --team` for named team spawn, MCP server mode for Agents SDK orchestration, built-in trace recording.

## Core Idea

TAD currently encodes BOTH judgment rules (WHAT to do) AND orchestration logic (HOW to do it) in massive SKILL.md files. The two platforms (Claude Code, Codex) now both support Tier 1 multi-agent orchestration but with different APIs. TAD should decouple:

```
TAD Judgment Layer (SKILL.md — thin, WHAT to do)
        |
        v
Orchestration Adapter Layer (HOW — platform-specific)
   /              \
Claude Code       Codex CLI
Workflow tool     TOML agents + --team
agent()           subagent spawn
parallel()        MCP server orchestration
pipeline()        Agents SDK hand-offs
```

This is the "thin protocol, thick tools" direction (see IDEA-20260602-sac-thin-protocol-thick-tools.md) applied to cross-platform.

## Degradation Tiers

| Tier | Environment | Orchestration | Quality |
|------|------------|---------------|---------|
| 1a | Claude Code + Workflow | JS deterministic control flow + schema + resume | Highest |
| 1b | Codex CLI + Agents SDK | TOML agents + MCP server + team spawn | Equivalent, different API |
| 2 | Claude Code no Workflow / Codex no team | Agent tool / single exec spawn | Parallel but no deterministic loop |
| 3 | Gemini CLI | Read-only, no sub-agent | Research/review only |

Runtime detection: check tool availability at session start, announce tier, select adapter.

## Validation

Ran a 7-agent workflow experiment (fan-out + adversarial + synthesis) auditing 3 parked Epics. Challengers found real blind spots in all 3 analyst reports that a single sequential agent would likely miss. Evidence: `.tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md` (full article) + workflow transcript.

## Related

- IDEA-20260602-sac-thin-protocol-thick-tools.md (thin protocol direction)
- `.tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md` (source article)
- Codex subagent docs: https://developers.openai.com/codex/subagents
- Codex Agents SDK: https://developers.openai.com/codex/guides/agents-sdk

## Open Questions

- How to express the same orchestration intent in both JS (Workflow) and TOML (Codex)? Shared schema? Code-gen?
- What's the minimum SKILL.md surface that needs to stay as prompt text vs move to workflow scripts?
- Which TAD mechanisms benefit most from workflow-ification? (Gate review, YOLO execution, research pipeline)
