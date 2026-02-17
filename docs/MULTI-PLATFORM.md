# TAD Specialized Tools Guide

**Version 2.3.0**

> TAD runs on Claude Code as its primary runtime. Codex CLI and Gemini CLI can serve as
> specialized execution tools for specific tasks via the Handoff mechanism.

---

## Architecture

| Platform | Role | How It Works |
|----------|------|--------------|
| **Claude Code** | Full TAD Runtime | Alex (design) + Blake (implement) + Gates |
| **Codex CLI** | Specialized Executor | Receives Handoff → executes task → human returns result to Alex |
| **Gemini CLI** | Specialized Executor | Receives Handoff → executes task → human returns result to Alex |

## When to Use Codex/Gemini

| Tool | Best For | Workflow |
|------|----------|---------|
| **Codex CLI** | Code review, security audit | Alex creates Handoff → human gives to Codex → Codex reviews → human brings findings back |
| **Gemini CLI** | Frontend design, UI prototyping | Alex creates Handoff or /playground output → human gives to Gemini → Gemini designs → human brings result back |

## Workflow

1. **Alex (Claude)** designs task and creates Handoff as usual
2. **Human** decides which tool to use for execution (Claude Blake / Codex / Gemini)
3. **Human** copies Handoff content to the chosen tool
4. **Tool** executes the task
5. **Human** brings results back to Alex for acceptance (Gate 4)

## Tips

- Give Codex/Gemini the full Handoff content — it contains all context needed
- Reference `.tad/skills/{skill}/SKILL.md` for quality checklists they can follow
- Evidence files should still go to `.tad/evidence/reviews/` for Gate verification
- Alex does NOT need to know which tool executed — acceptance is based on results

## Skills Reference

The `.tad/skills/` directory contains platform-agnostic quality checklists:

| Skill | Use Case |
|-------|----------|
| code-review | Code quality, type safety, structure |
| security-audit | Security vulnerabilities, data protection |
| testing | Test coverage, test quality |
| performance | Performance bottlenecks, optimization |
| ux-review | UI/UX quality, accessibility |
| architecture | System design, data flow |
| api-design | API contracts, RESTful patterns |
| debugging | Bug diagnosis, root cause analysis |

---

*TAD v2.3.0 — Claude Code primary, Codex/Gemini as specialized tools.*
