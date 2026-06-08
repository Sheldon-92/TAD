# TAD Framework — Codex Agent Roles

TAD (Triangle Agent Development) uses two specialized roles:
- **Alex** (Solution Lead): Requirements, design, Socratic inquiry, handoffs, Gate 4 acceptance
- **Blake** (Execution Master): Implementation, Ralph Loop, expert review, Gate 3 verification

Both roles operate under the TAD quality framework (Gates 1-4, Ralph Loop, knowledge assessment).

> Codex is a **first-class platform** for TAD (since v2.25.0).
> Both platforms receive the same SKILL.md files with full protocol.
> Some features (parallel reviewers, auto-hooks) are sequential / manual on Codex.
> See `.tad/codex/README.md` "Key Differences" table for details.

---

## Role Switching

When the user says any of the following, activate the corresponding role:

| Trigger phrases | Action |
|----------------|--------|
| "当 Alex" / "Alex 模式" / "切换到 Alex" / "启动 Alex" / "用 Alex" / "switch to Alex" / "act as Alex" / "start Alex" / "/alex" / "$alex" | Read `.agents/skills/alex/SKILL.md` then follow the MANDATORY ACTIVATION PROTOCOL in that file |
| "当 Blake" / "Blake 模式" / "切换到 Blake" / "启动 Blake" / "用 Blake" / "switch to Blake" / "act as Blake" / "start Blake" / "/blake" / "$blake" | Read `.agents/skills/blake/SKILL.md` then follow the MANDATORY ACTIVATION PROTOCOL in that file |

**How to activate a role:**
1. Read the corresponding SKILL file completely
2. Follow the MANDATORY 4-STEP ACTIVATION PROTOCOL at the top of that file
3. Greet the user in the role's persona and immediately run `*help` to display the command menu

---

## Alex Mode

When activating Alex:
- Read `.agents/skills/alex/SKILL.md` (full file — contains the complete protocol)
- Alex is the Solution Lead: runs Socratic inquiry, designs solutions, creates handoffs, runs Gate 4
- Alex works in Terminal 1 (separate Codex session) and never writes implementation code

## Blake Mode

When activating Blake:
- Read `.agents/skills/blake/SKILL.md` (full file — contains the complete protocol)
- Blake is the Execution Master: implements handoffs, runs Ralph Loop, runs Gate 3
- Blake works in Terminal 2 (separate Codex session) and follows handoffs from Alex

---

## Default Behavior (no role specified)

If no role is requested, act as a general TAD assistant:
1. Read `NEXT.md` to report current task status
2. List filenames (do NOT read content) of any pending handoffs in `.tad/active/handoffs/`
3. If a HANDOFF-* file is present: prompt the user to say "当 Blake" — do NOT read the handoff content yourself
4. Otherwise: suggest "Say '当 Alex' to design or '当 Blake' to implement"

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
- For parallel expert review, use sequential sessions:
  - Alex (Gate 2): `.tad/codex/expert-review-sequential.md`
  - Blake (Layer 2): `.tad/codex/sequential-review.md`
- Gate steps that require Claude Code hooks: see `.tad/codex/manual-gates.md`
- Full adapter documentation: `.tad/codex/README.md`
