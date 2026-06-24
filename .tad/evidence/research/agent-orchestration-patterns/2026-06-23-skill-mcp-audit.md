# Skill-MCP Complementarity Audit

**Date**: 2026-06-23
**Source**: EPIC-20260623-community-pattern-adoption Phase 3
**Analyst**: Alex (Solution Lead)

## Principle

**Skill = Judgment (when/why), MCP = Capability (how)**

Skill files encode decision rules, quality criteria, anti-patterns, and process steps — they tell the agent WHEN and WHY to take an action. MCP tools provide APIs, data access, and external integrations — they tell the agent HOW to execute. They are complementary:
- Skill without MCP = knows what to do but can't do it
- MCP without Skill = can do anything but doesn't know what's appropriate
- Together = informed action (Maestro pattern validates this split works in production)

## Classification Criteria

- **Judgment**: Pack content is decision rules, quality criteria, process steps. References tools by name but doesn't teach invocation (e.g., "use Playwright when X" but not `npx playwright test --config=...`).
- **Tool-wrapping**: Pack contains CLI commands, API call patterns, configuration syntax. Teaches HOW to invoke specific tools.
- **Mixed**: Both judgment rules and tool invocation guides.

## Audit Table (25 packs)

| # | Pack | Type | Classification | Rationale |
|---|------|------|---------------|-----------|
| 1 | academic-research | reference-based | Mixed | Methodology rules + PubMed/Scholar search commands |
| 2 | agent-computer-interface | reference-based | Mixed | Tool selection judgment + Browser Use/Stagehand/Playwright invocation |
| 3 | agent-memory | reference-based | Judgment | CoALA/Mem0/Letta architecture decisions — no tool commands |
| 4 | agent-orchestration | reference-based | Judgment | Framework selection rules — no invocation details |
| 5 | ai-agent-architecture | reference-based | Judgment | 10 architectural decisions — pure judgment |
| 6 | ai-evaluation | reference-based | Judgment | Eval methodology + framework selection rules |
| 7 | ai-guardrails | reference-based | Judgment | Defense rules — references Presidio/NeMo but doesn't teach invocation |
| 8 | ai-podcast-production | reference-based | Mixed | Production judgment + TTS/BGM tool commands |
| 9 | ai-prompt-engineering | reference-based | Mixed | Prompt design rules + promptfoo/DSPy tool invocation |
| 10 | ai-tool-integration | reference-based | Mixed | MCP design judgment + SDK code patterns |
| 11 | ai-voice-production | reference-based | Mixed | Voice judgment + TTS tool selection/commands |
| 12 | code-security | reference-based | Tool-wrapping | Primarily CLI commands: Semgrep, Nuclei, Gitleaks, Checkov |
| 13 | data-engineering | reference-based | Judgment | Pipeline architecture decisions — tool selection not invocation |
| 14 | knowledge-graph | reference-based | Judgment | GraphRAG design decisions — references Neo4j but doesn't teach Cypher |
| 15 | llm-observability | reference-based | Judgment | Observability architecture rules — tool selection |
| 16 | ml-training | reference-based | Mixed | Fine-tuning judgment + cloud GPU platform commands |
| 17 | product-thinking | deep-skill | Judgment | Product decision framework — pure thinking, no tools |
| 18 | rag-retrieval | reference-based | Judgment | Retrieval engineering decisions — chunking/embedding selection |
| 19 | research-methodology | orchestration-router | Tool-wrapping | Research pipeline + NotebookLM/WebSearch commands |
| 20 | synthetic-data | reference-based | Judgment | Dataset curation rules — references tools but doesn't teach invocation |
| 21 | video-creation | reference-based | Mixed | Storytelling judgment + HyperFrames/Remotion commands |
| 22 | web-backend | reference-based | Judgment | Backend engineering judgment — 43 decision rules |
| 23 | web-deployment | reference-based | Mixed | Platform selection judgment + CI/CD config patterns |
| 24 | web-frontend | reference-based | Judgment | Component/state/styling judgment — references React patterns |
| 25 | web-testing | reference-based | Judgment | Testing strategy rules — references Playwright/Vitest but judgment-level |
| 26 | web-ui-design | reference-based | Mixed | Design pipeline + bash+jq token compiler commands |

### Summary

| Classification | Count | Examples |
|---------------|-------|---------|
| **Judgment** | 14 | agent-memory, agent-orchestration, ai-agent-architecture, web-backend, product-thinking |
| **Mixed** | 10 | ai-podcast-production, ai-prompt-engineering, agent-computer-interface, web-deployment |
| **Tool-wrapping** | 2 | code-security, research-methodology |

## Decision Framework

### Rule 1: Pure Judgment → Skill File (no MCP candidate)
Content is decision rules, quality criteria, process steps, or architectural guidance.
**Example**: web-backend's "43 decision rules" are judgment — converting to MCP would lose the contextual reasoning.
**Test**: Can you remove all tool names and the pack still provides value? → Judgment.

### Rule 2: Pure Tool-wrapping → MCP Candidate (evaluate per Rule 4)
Content is CLI commands, API calls, configuration syntax.
**Example**: code-security's Semgrep/Gitleaks commands could be MCP tools with `scan(path, rules)` interface.
**Test**: Does the pack value come from the COMMANDS it teaches, not the DECISIONS about when to use them? → Tool-wrapping.

### Rule 3: Mixed → Keep Judgment in Skill, evaluate tool portion per Rule 4
If a pack has both judgment rules AND tool commands, separate them:
- Judgment stays in skill file (irreducible — can't wrap "when" in an API)
- Tool commands are MCP candidates IF they meet Rule 4 criteria

**Example**: ai-prompt-engineering has prompt design rules (judgment) + promptfoo CLI commands (tool). The design rules stay in skill; promptfoo commands COULD become an MCP tool.

### Rule 4: MCP Conversion Threshold (L1 constraint)
On single-user CLI (TAD's context), MCP adds operational overhead:
- Process startup/shutdown
- Auth management
- Configuration files
- Debugging complexity

**Convert to MCP only when:**
1. **Stateful tool** — tool has persistent connections, sessions, auth tokens (e.g., NotebookLM CLI → already a CLI wrapper; MCP would manage session state)
2. **Cross-project shared** — the same tool capability is needed across multiple projects (e.g., code-security scanning → one MCP server serves all projects)
3. **Hot-swappable** — you want to swap the tool without editing skill files (Maestro pattern: add Arabic → no redeploy)

**Do NOT convert when:**
1. **Stateless one-shot** — CLI command with no persistent state (e.g., `grep`, `jq`, `diff`)
2. **Single-project** — tool only used in this project
3. **L1 principle override** — "Mechanical Enforcement Rejected on Single-User CLI" — if the MCP adds enforcement/blocking behavior, prefer skill-level advisory instead

### Rule 5: Existing MCP Usage Validation
Current TAD MCP tools and their fit:
- **codebase-memory-mcp**: ✅ Correct — stateful (graph DB), cross-project shared, hot-swappable
- **claude-in-chrome**: ✅ Correct — stateful (browser sessions), requires persistent connection
- **NotebookLM CLI**: ⚠️ Borderline — currently CLI-wrapped, could be MCP for session management but works fine as CLI

## MCP Migration Candidates (Future Work)

| Pack | Candidate | Why | Priority |
|------|-----------|-----|----------|
| code-security | Semgrep/Gitleaks as MCP | Stateful scan results, cross-project shared | Low — CLI works fine for single-user |
| research-methodology | NotebookLM as MCP | Session state, cross-project notebooks | Low — CLI wrapper already works |
| agent-computer-interface | Browser Use as MCP | Stateful browser sessions | Already exists (claude-in-chrome) |

**Verdict**: No pack urgently needs MCP conversion. Current skill-based approach works well for single-user CLI. MCP becomes valuable when TAD scales to multi-user or when tool state management becomes a pain point.
