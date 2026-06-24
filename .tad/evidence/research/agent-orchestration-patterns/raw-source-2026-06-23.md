# AI Tinkerers Issue #32 — Agent Orchestration Demos (June 22, 2026)

Source: AI Tinkerers newsletter, curated by Joe Heitzeberg

## 1. SPEAR: Autonomous Agent Framework
**Author:** Ryan Waliany, CEO at Ambiguous AI (Seattle)
**Date:** Jun 08, 2026
**Tech Stack:** Claude Code

SPEAR (Scope, Plan, Execute, Assess, Resolve) is a management framework for AI agents. Each phase functions as a gate requiring specific conditions to pass.

- **Scope**: Surfaces and resolves ambiguity. Passes when clarity is achieved.
- **Plan**: Produces an ordered, visible, approved sequence before execution. Catches wrong assumptions early.
- **Execute**: Completes the work. Passes when deliverables are finished.
- **Assess**: Scores results against a MECE rubric (mutually exclusive, collectively exhaustive). Binary pass/fail — anything below 10/10 fails.
- **Resolve**: Closes the run after Assess passes.

Inner loop: Plan → Execute → Assess. When Assess fails, narrows the Plan to address the specific gap, re-executes, and reassesses. Repeats until rubric passes.

Cost: 2-3 seconds overhead per run. Savings: cleanup time eliminated.

Testing on 3D house generation: zero-shot had structural failures (floating windows, doors on ground). SPEAR runs progressively refined across three assessment rounds with increasingly critical rubrics.

Ryan's team used SPEAR for 24/7 coding loops producing 500k+ lines of near-production code. Grounded in David Marr's three levels of analysis (computational cognitive science, 1982).

Source: https://www.edge.ceo/p/introducing-spear-the-management

## 2. Gryter: AI Skill File Orchestration
**Author:** Abid Waqar, Founder/CEO at Gryter (Islamabad/Rawalpindi)
**Date:** Jun 12, 2026
**Tech Stack:** Claude Opus 4, Claude Code, MCP connectors, Flutter, Firebase

Solo-built AI fitness coach. Key architecture:
- 12 skill files for maintainability
- Subagents with scoped context
- CLAUDE.md so Claude reloads codebase correctly
- MCP connectors driving real Firebase-backed Flutter app
- CI tests on-device

Key insight: Clear symptom-to-fix story from code drift. The orchestration harness made a solo developer produce team-level output.

No public GitHub repo or documentation found.

## 3. Inhabited-design: Claude Code UI Skills
**Author:** Shimin Zhang (Seattle)
**Date:** Jun 08, 2026
**Tech Stack:** Claude 4, Claude Code, MCP

Adversarial Claude Code skill for UI design. Takes "build me an X for Y" prompt and iterates toward presentation-ready page design with clear point of view for a specific named user.

Architecture:
- claude_designer.md — designer persona/constraints
- claude_icp.md — ideal customer profile definition
- Inspiration-bank protocol — curated reference designs
- Iteration loop that continues past typical one-shot outputs until convergence
- Adversarial critique to prevent design from drifting into "generic slop"

Key insight: Feedback loop and adversarial self-checking keeps output distinctive. Matches trend toward tighter agent self-checking.

No public GitHub repo found. Author site: shimin.io, wolfpeachlabs.com

## 4. Maestro: MCP Separation of Concerns
**Author:** Ady Ngom (Dubai/Doha)
**Date:** Jun 13/15, 2026
**Tech Stack:** MCP, Fast MCP, LiveKit Agents

Voice-first generative UI using MCP as a separation of concerns layer. Composes independent packages:
- **Pandini**: Compresses screenshots in-browser without installs or APIs
- **Avatar Generator**: Full avatar lifecycle via Fast MCP wrapped around REST
- **Avatar Locales**: Adds new languages through Skill-MD and on-demand tool calls (Arabic added live without redeployment)

Key pattern: "Swap-in tools, don't rebuild agents." Each package is independent, composed via MCP orchestration. Fast MCP wraps REST so tool surfaces materialize quickly.

Key insight: Boundaries add real reliability tradeoffs. Modular agent packaging becomes practical product toolkit. Maps to shift toward cheaper, more modular agentic systems.

No public GitHub repo found. Demo: hqiq-ai-dev.netlify.app

## Cross-Cutting Patterns

1. **Skill files as orchestration primitive**: Both Gryter (12 skill files) and Inhabited-design (claude_designer.md, claude_icp.md) use markdown skill files to scope agent behavior.
2. **Loop-until-quality**: SPEAR (Plan→Execute→Assess loop) and Inhabited-design (iteration loop until convergence) both iterate until a quality bar is met, not one-shot.
3. **MCP as composition layer**: Maestro uses MCP to compose independent packages without rebuilding agents.
4. **Anti-slop mechanisms**: SPEAR (MECE rubric), Inhabited-design (adversarial critique) both explicitly fight generic/low-quality output.
5. **Solo → team output**: Gryter demonstrates one developer producing team-level output through skill orchestration.
