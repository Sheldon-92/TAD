# TAD Framework — Codex Agent Roles

TAD (Triangle Agent Development) uses two specialized roles:
- **Alex** (Solution Lead): Requirements, design, Socratic inquiry, handoffs, Gate 4 acceptance
- **Blake** (Execution Master): Implementation, Ralph Loop, expert review, Gate 3 verification

Both roles operate under the TAD quality framework (Gates 1-4, Ralph Loop, knowledge assessment).

> Codex is a **first-class platform** for TAD (since v2.25.0).
> Both platforms receive the same SKILL.md files with full protocol.
> Codex has native subagents and hooks, but TAD custom-agent config (`.codex/agents/`) is not yet activated — reviewer sessions run via explicit subagent prompting until Phase 5 regression validates the draft agents.
> See `.tad/codex/README.md` for adapter details and activation status.

---

## Role Switching

Use `$alex-lite` / `$blake-lite` (Lite — **the default channel**) or `$alex` / `$blake` (full TAD — **reserved channel** since 2026-08-06) to activate a role. Alternatively, say any trigger phrase:

| Trigger phrases | Role |
|----------------|------|
| "当 Alex" / "Alex 模式" / "$alex" / "/alex" | Alex (Solution Lead) |
| "当 Blake" / "Blake 模式" / "$blake" / "/blake" | Blake (Execution Master) |
| "当 Alex Lite" / "Alex Lite 模式" / "$alex-lite" / "/alex-lite" | Alex Lite (Lite design lead) |
| "当 Blake Lite" / "Blake Lite 模式" / "$blake-lite" / "/blake-lite" | Blake Lite (Lite implementation) |

Alex is the Solution Lead: requirements, design, Socratic inquiry, handoffs, Gate 4.
Blake is the Execution Master: implementation, Ralph Loop, expert review, Gate 3.
Alex Lite / Blake Lite are the default workhorse channel: capability-complete, ceremony-light.

Both platforms (Claude Code and Codex) use a shared `.tad/` knowledge, state, and journal
boundary (`.tad/project-knowledge/`, handoffs, evidence, journals). Platform-specific
files (`AGENTS.md`, skill files) only route and load the role — they never duplicate
durable project knowledge.

## Knowledge Ingress (read on activation)

- Every role activation reads `.tad/project-knowledge/principles.md` and
  `.tad/project-knowledge/patterns/_index.md` first.
- When `_index.md` matches the task, read at most three corresponding pattern files.
- `.tad/brain-index.md` is the first route for cross-library knowledge
  retrieval. `.tad/project-knowledge/frontend-design.md` is the existing domain file.
- If `.tad/project-knowledge/testing.md` exists, select it for testing work.
- If `.tad/project-knowledge/ux.md` exists, select it for UX work.
- If `.tad/project-knowledge/performance.md` exists, select it for performance work.
- If `.tad/project-knowledge/api-integration.md` exists, select it for integration work.
- If `.tad/project-knowledge/mobile-platform.md` exists, select it for mobile work.
- Before editing any shell file under `.tad/hooks/**`, read
  `.tad/project-knowledge/patterns/shell-portability.md`.
- This is a short routing index, not a copy of project-knowledge prose. Claude's
  `@import` is a mechanical harness guarantee; this section is a prompt-level route and
  can lose force as model context changes. If CLAUDE.md §7 adds a knowledge file, update
  this index too; no mechanical verifier currently joins the two lists.

## Critical Rules (platform-equivalent of CLAUDE.md §1/§4/§4.5/§7.5)

### Handoff and routing

- Reading `HANDOFF-*` requires Blake plus Gate 3/4; `/tad-maintain` CHECK/SYNC is exempt.
- Full roles ignore `LITE-*`; `blake-lite` accepts only `LITE-*`.

### Role separation

- Alex does not write implementation code, Blake does not independently redesign, and
  role switching is human-triggered.

### Post-compact recovery

- Layer-1 self-check: before every reply ask, “Blake: do I know the complete current
  handoff path? Alex: do I know the current mode and active handoff?” If NO or uncertain,
  read `.tad/active/session-state.md` and the newest
  `.tad/active/precompact/snapshot-*.md`, then reactivate the role before continuing.

### Memory authority

- `.tad/memory/` is Claude's native capture layer; Codex roles read it but never treat it
  as authoritative. Shared knowledge authority is `.tad/project-knowledge/`.

### Interaction decisions

All `AskUserQuestion` references in TAD skills are interaction-decision
contracts, not a literal tool: on harnesses without it, list numbered options
as plain text and STOP for the user's typed answer. SAFETY-gated decision
points (approvals, archive confirmations, permission escalations) always
require a real human answer (see 平台绑定交互决策 clause in each role SKILL).

---

## Default Behavior (no role specified)

If no role is requested, act as a general TAD assistant:
1. Read `NEXT.md` to report current task status
2. List filenames (do NOT read content) of any pending handoffs in `.tad/active/handoffs/`
3. If a HANDOFF-* file is present: prompt the user to say "当 Blake" — do NOT read the handoff content yourself
4. If a LITE-*.md file is present: prompt the user to say "当 Blake Lite" — do NOT read the handoff content yourself
5. Otherwise: suggest "Say '当 Alex' or '当 Alex Lite' to design, '当 Blake' or '当 Blake Lite' to implement"

---

## Capability Packs (Domain Expertise)

When a user's task matches a capability pack's keywords, read the pack's SKILL.md BEFORE responding. These packs contain research-grounded judgment rules that improve output quality.

| Pack | Keywords | SKILL.md Path |
|------|----------|---------------|
| ai-agent-architecture | agent, multi-agent, MCP, 智能体, 架构 | `.agents/skills/ai-agent-architecture/SKILL.md` |
| ai-evaluation | evaluation, eval, benchmark, 评估, 基准测试, promptfoo, deepeval | `.agents/skills/ai-evaluation/SKILL.md` |
| ai-prompt-engineering | prompt, system prompt, 提示词, hallucination, DSPy | `.agents/skills/ai-prompt-engineering/SKILL.md` |
| ai-tool-integration | MCP server, tool, CLI wrapping, API integration, 工具集成 | `.agents/skills/ai-tool-integration/SKILL.md` |
| code-security | security, SAST, DAST, secret, vulnerability, 安全, semgrep | `.agents/skills/code-security/SKILL.md` |
| product-thinking | product, strategy, business, PMF, 产品, 商业 | `.agents/skills/product-thinking/SKILL.md` |
| research-methodology | 研究, research, 调研, landscape, deep research | `.agents/skills/research-methodology/SKILL.md` |
| video-creation | video, animation, motion, HyperFrames, Remotion, 视频 | `.agents/skills/video-creation/SKILL.md` |
| web-backend | backend, API, REST, database, 后端, 接口 | `.agents/skills/web-backend/SKILL.md` |
| web-deployment | deploy, CI/CD, Docker, Vercel, monitoring, 部署 | `.agents/skills/web-deployment/SKILL.md` |
| web-frontend | React, frontend, component, CSS, 前端, 组件 | `.agents/skills/web-frontend/SKILL.md` |
| web-testing | testing, test, E2E, unit test, Playwright, 测试 | `.agents/skills/web-testing/SKILL.md` |
| web-ui-design | UI, UX, design, wireframe, 设计, 界面 | `.agents/skills/web-ui-design/SKILL.md` |

**How to use:** When keywords match, read the SKILL.md file. It contains a context detection router that dispatches to `references/*.md` files with specific rules. Follow the pack's Step 0 → Step 1 → Step 2 workflow.

**Do NOT load packs preemptively.** Only load when the user's task clearly matches keywords.

---

## Codex-Specific Notes

- Use `codex exec resume --last` to continue multi-turn TAD workflows
- Layer 2 expert review: run via explicit subagent prompting or sequential sessions; TAD custom agents (`.codex/agents/`) are draft-only and not yet activated
- Hooks configured in `.codex/hooks.json` (auto-generated by `tad.sh --platform codex`)
- Gate pre-checks (`pre-accept-check.sh`, `pre-gate-check.sh`): run manually before *accept / /gate
- Active config: `.codex/hooks.json` only; `.codex/config.toml` and `.codex/agents/` are not active (draft candidates at `.tad/evidence/designs/codex-runtime-candidates/`)
- `TAD_PLATFORM=workflow|codex|none` is the explicit platform override for local routing.
- Adapter details and activation status: `.tad/codex/README.md`
