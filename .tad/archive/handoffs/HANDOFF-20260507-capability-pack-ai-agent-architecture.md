---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: AI Agent Architecture Capability Pack

**From:** Alex | **To:** Blake | **Date:** 2026-05-07
**Project:** Independent repo (not TAD)
**Epic:** EPIC-20260507-agent-capability-packs (Phase 1d, parallel to web-ui-design/product-thinking/web-backend)

---

## 1. Task Overview

Build an **AI Agent Architecture Capability Pack** — a decision navigator that guides any AI agent through 10 architectural decisions required to design a reliable agent system. Not a framework comparison chart. Not a rule checklist. A **decision-by-decision guide** where each decision has a selection matrix derived from 3 production systems (Claude Code, OpenClaw, Hermes) and 7 real production disasters.

**Key distinction from web-backend pack**: web-backend has 43 code-quality rules (lintable, checkable during coding). This pack has 10 **design decisions** (not lintable — requires understanding the user's constraints to answer). The format is fundamentally different: decision matrices, not rule lists.

**Audience**: AI agents designing other agent systems. The language is imperative and precise — "If your pipeline has >3 agent handoffs, add validation gates between each one" — not explanatory tutorials.

---

## 2. Research Foundation

The deepest research corpus of any capability pack:

- **4 NotebookLM notebooks**, 102+ unique sources:
  - `8da09b3b` (main, 58 sources): frameworks, failure modes, tools, anti-patterns
  - `44a28f1c` (OpenClaw, 14 sources): agent loop, routing, sandbox, plugins source files
  - `8ccf8d90` (Hermes, 16 sources): self-evolution, memory, MCP, compression source files
  - `1e86994e` (Claude Code, 14 sources): architecture analysis papers, 12-session course
- **Cross-queried**: tad-evolution notebook (45 sources) for production failures
- **5 subagents** scanned 500+ repos + 3 production system codebases
- **Research findings**:
  - `.tad/evidence/research/ai-agent-architecture-capability-pack/2026-05-07-curated-findings.md`
  - `.tad/evidence/research/ai-agent-architecture-capability-pack/2026-05-07-three-systems-deep-dive.md`

---

## 3. Architecture

### 3.1 Core Design: 10 Decisions, Not 78 Rules

The 78 rules extracted from research cluster into **10 architectural decisions** that must be made in sequence. Each decision has:
- **The question** you must answer
- **A selection matrix** (if X constraint → choose Y pattern)
- **The production disaster** that happens if you skip this decision
- **Source attribution** ([Claude Code], [OpenClaw], [Hermes], [OWASP], etc.)

### 3.2 File Structure

```
ai-agent-architecture/
├── CAPABILITY.md              # Decision navigator (<600 lines)
│                              # YAML frontmatter: name + description
│                              # Two modes: /design (new system) + /audit (existing system)
│                              # Routes to references/ based on user's current decision
│
├── references/
│   ├── need-an-agent.md           # D1: Do you even need an agent? (single call vs workflow vs autonomous)
│   ├── coordination-and-state.md  # D2: How should agents coordinate + synchronize state? (6 patterns + event sourcing/hub-spoke)
│   ├── context-memory.md          # D3: How to manage context and memory? (5 patterns with trade-offs)
│   ├── tool-management.md         # D4: How to load and manage tools? (deferred loading, MCP, ACI)
│   ├── permissions-safety.md      # D5: How to design permissions + MCP security? (graduated trust + 7-item MCP checklist)
│   ├── context-compression.md     # D6: How to handle context overflow? (graduated compression pipeline)
│   ├── cost-token-economics.md    # D7: How to manage cost and token budgets? (model routing, lazy retrieval, budget caps)
│   ├── observability.md           # D8: How to observe agent behavior in production? (traces, logging, alerts, dashboards)
│   ├── testing-evaluation.md      # D9: How to test agent systems? (stochastic fingerprinting, per-step validation)
│   └── production-disasters.md    # D10: How to prevent production disasters? (7 causal chains + scope tags)
│
├── install.sh                 # Same pattern as web-backend (--agent flag + Phase 3 stubs)
├── README.md
├── LICENSE                    # Apache 2.0
├── LICENSE-ATTRIBUTION.md     # Claude Code (Anthropic), OpenClaw (MIT), Hermes (MIT/Apache), OWASP
└── CHANGELOG.md
```

**No scripts/ directory** — this is architecture design, not code linting. The output is a decision document, not a lint report.

### 3.3 CAPABILITY.md: Two Modes

```
User says something about agent architecture
  ↓
Mode Detection:
  - "design / build / create / new agent" → /design mode
  - "review / audit / check / existing agent" → /audit mode
  - ambiguous → AskUserQuestion to confirm
  ↓
/design mode:
  Phase 0 — Scoping (3-5 upfront questions):
    1. Single agent or multi-agent?
    2. Stateful (long sessions) or stateless (single-turn)?
    3. Trusted inputs only, or untrusted external data?
    4. Context budget constraint? (small model vs 1M context)
    5. Cost sensitivity? (hobby vs production at scale)
    → Determine which of D1-D10 APPLY. Skip non-applicable decisions.
    → Output: "Decisions D1, D3, D5, D7, D9 apply. D2, D6, D8 skipped because [reason]."
  Phase 1 — Walk through applicable decisions:
    For each applicable decision:
      1. Load references/{decision}.md
      2. Apply selection matrix against user's scoping answers → recommend pattern
      3. Record decision + rationale + cost impact
    After last decision: output Architecture Decision Document
  ↓
/audit mode:
  Read user's existing agent code/design.
  For each of 10 decisions:
    1. Load references/{decision}.md
    2. Check: was this decision made? If so, does it match the selection criteria?
    3. If decision was skipped → flag + cite the production disaster it enables
  After D10: output Architecture Audit Report (findings + risk assessment)
```

### 3.4 The 10 Decisions in Detail

**references/need-an-agent.md — D1: Do you even need an agent?**
- Selection matrix: single LLM call → prompt chaining → routing → orchestrator-workers → autonomous
- Core rule: "Do not use an autonomous agent if a simpler deterministic workflow can solve the problem" [Claude Code #11]
- Anti-pattern: "Agent Everywhere trap" — replacing if/else with autonomous LLMs [Hermes]
- Disaster link: every unnecessary agent = multiplicative failure probability

**references/coordination.md — D2: How should agents coordinate?**
- 6 patterns: Prompt Chaining / Routing / Parallelization / Orchestrator-Workers / Evaluator-Optimizer / Autonomous [Anthropic Building Effective Agents]
- Selection criteria: fixed subtasks → chain; distinct categories → routing; simultaneous → parallel; unpredictable → orchestrator; clear eval criteria → evaluator-optimizer; open-ended → autonomous
- Anti-pattern: "Bag of Agents" — flat topology, no hierarchy, agents echo each other's hallucinations
- Expert mistake: "Polling Tax" — synchronous request-response wastes 95% of API calls

**references/context-memory.md — D3: Context and memory** (MOST DETAILED)
- 5 memory patterns with quantitative trade-offs:
  | Pattern | Accuracy | Latency | When RIGHT | When WRONG |
  |---------|----------|---------|-----------|------------|
  | In-context only | 72.9% | 17.12s p95 | Prototypes, privacy | Multi-session |
  | Flat vector store | — | 1.44s | Conversational, personalization | Multi-hop |
  | Tiered (hot/warm/cold) | — | — | Session coherence + long-horizon | Simple prototypes |
  | Knowledge graph + vector | — | — | Entity relationships, temporal | Cold-start domains |
  | Enterprise context layer | — | — | Regulated industries | No existing catalog |
- Hermes rule: "Facts → memory, procedures → skills, temp state → session history only"
- Hermes rule: "Single active memory backend — never multiple conflicting truth sources"
- Claude Code rule: "File-based memory, no vector DB. LLM scans headers, selects up to 5 relevant files"

**references/tool-management.md — D4: Tool loading and management**
- Core rule: ">5 tools → deferred loading, not upfront" (40 MCP tools = 8K-55K tokens wasted)
- Claude Code graduated cost: Hooks (0 tokens) → Skills (low) → Plugins (medium) → MCP (high)
- Tool design: "If agent makes parameter mistakes → poka-yoke the interface" [Claude Code]
- Tool design: "Treat tools as Agent-Computer Interface (ACI) — write docstrings as if for a junior dev"
- Meta-tool pattern: "If agent repeatedly executes same tool sequence → bundle into deterministic meta-tool"

**references/permissions-safety.md — D5: Permission design + MCP security** (D5 + former D8 merged per BA P1-1)
- Claude Code 7-mode spectrum: plan → default → acceptEdits → auto → dontAsk → bypassPermissions → bubble
- Core rule: "Deny-first. Deny rules ALWAYS override allow rules, even when allow is more specific"
- Core rule: "Safety layers must have INDEPENDENT failure modes" (shared constraint defeats N layers)
- Core rule: "Permissions NEVER persist across sessions — trust re-established each session"
- OpenClaw rule: "Atomic approval consumption — one-time token with expiration, no replay"
- Dual-agent pattern: "Untrusted data → quarantined LLM (no tools) processes it, privileged LLM controls execution"
- **MCP-Specific Extensions** (7-item checklist, formerly standalone D8):
  1. Display FULL tool descriptions (hidden `<IMPORTANT>` tags = #1 attack vector) [Elastic, Invariant Labs]
  2. Enforce cross-server boundaries (shadowing attacks) [VulnerableMCP]
  3. Cryptographically verify + pin tool versions (rug-pull defense)
  4. Container sandbox with read-only FS + network isolation + seccomp
  5. Zero Trust + JIT access (time-limited, task-specific credentials)
  6. Dual-LLM for untrusted data (quarantined parser + privileged planner)
  7. Centralized tool registry with reputation scoring + sandbox testing

**references/context-compression.md — D6: Context overflow** (SECOND MOST DETAILED)
- Claude Code 5-layer graduated pipeline: Budget Reduction (always) → Snip (flagged) → Microcompact (always, time-based) → Context Collapse (flagged/overflow) → Auto-Compact (last resort)
- Hermes dual-layer: agent compressor at 50% + gateway hygiene at 85%
- Hermes anti-thrashing: "If last 2 compressions saved <10% each → skip"
- Hermes pre-LLM pruning: "Strip tool outputs >200 chars to 1-line metadata BEFORE calling summarizer"
- Hermes atomic boundaries: "Never split tool_call from tool_result during compression"
- Hermes active task protection: "Always keep most recent user message in uncompressed tail"
- Hermes iterative updates: "Pass previous summary + new turns → update in-place, don't rewrite from scratch"

**references/cost-token-economics.md — D7: Cost and token budgets** (NEW — expert review P0-1)
- Core rule: "Context scarcity IS cost. Every architecture decision has a token/API cost dimension" [Claude Code #3]
- Model routing: simple tasks → cheap model, complex reasoning → capable model (40-60% savings) [OmniRoute]
- Entropy-based lazy loading: skip vector retrieval when LLM uncertainty is low [Research rule #17]
- Budget caps per session: prevent runaway loops from exhausting quotas [Research failure #2: 60% of LLM errors]
- Graduated cost tiers for extensions: Hooks (0 tokens) → Skills (low) → Plugins (medium) → MCP (high) [Claude Code #9]
- Tool cost: 40 MCP tools = 8K-55K tokens just on definitions → deferred loading
- SkillTool (~1x) vs AgentTool (~7x) trade-off: use cheaper option unless context isolation needed [Claude Code #13]
- Tools: tokencost (estimation), LiteLLM (proxy+tracking), Helicone (dashboards), OmniRoute (routing)
- Each D1-D9 decision matrix includes a "cost impact" column

**references/observability.md — D8: Observability in production** (NEW — expert review P0-2)
- Core rule: "The 100x more frequent failure mode than catastrophe is 'agent did something subtly wrong and nobody noticed for 3 days because there were no traces'"
- Structured logging: JSONL append-only to stdout [Claude Code #8, OpenClaw #7]
- Trace correlation IDs across multi-agent handoffs
- Cost dashboards: per-session token cost, per-tool invocation count, p95 latency
- Alert thresholds for runaway loops: consecutive identical tool calls >3 → alert
- Graceful telemetry degradation: telemetry error → fall back to safe defaults, don't crash loop [OpenClaw #7]
- Tools: AgentOps (session replay), OpenLLMetry (OTel-based), Langfuse (self-hostable), Arize Phoenix (trace UI), Helicone (cost proxy)
- AI-assisted trace analysis: "If trace spans hundreds of steps → use auxiliary AI evaluators for block-level responsibility scoring" [Research rule #23]

**references/testing-evaluation.md — D9: Agent testing**
- Core rule: "Non-deterministic agents → stochastic behavior fingerprinting, NOT binary pass/fail"
- Core rule: "Multi-step chains → test each handoff independently with corrupted input"
- Hermes rule: "Self-evolution mutations → 100% test pass + size limits + cache compat + semantic preservation + human review"
- Tools: promptfoo (YAML-driven), DeepEval (20+ metrics), Inspect AI (safety-grade), AgentOps (observability)
- Network isolation: "If evaluating web-enabled agent → completely network-isolate the benchmark (models can find and read their own answer keys)"

**references/production-disasters.md — D10: 7 Production Disasters + Prevention**
Each with full causal chain + single design decision that would have prevented it:
1. PocketOS database wipe (9s) → scoped tokens per environment
2. Cursor MCP tool poisoning → display full tool descriptions
3. Email hijacking (cross-tool shadowing) → cross-server dataflow controls
4. E-commerce stale state → event sourcing / optimistic concurrency
5. Support ticket race condition → hub-spoke canonical state owner
6. Financial trading message ordering → causal consistency verification
7. Customer double-charging → idempotency tokens + deduplication

### 3.5 Language and Style

- Audience is AI agents → imperative third person ("The agent MUST...", "If X → choose Y")
- Every decision matrix entry has [Source: system-name] attribution
- Every rule cites the specific production disaster or system that validates it
- No tutorial explanations — assume the agent understands what "event sourcing" means
- Anti-skip table: excuses agents use to skip architecture decisions

---

## 4. Implementation Steps

### P1: Scaffold (30 min)
1. Create ~/ai-agent-architecture/ directory
2. git init, LICENSE (Apache 2.0), README, CHANGELOG, install.sh
3. Write CAPABILITY.md frontmatter + two-mode routing (/design + /audit)

### P2: Decision References (2.5 hours)
Write each of the 10 reference files. For each:
1. Read the corresponding section in both research findings files
2. Read the relevant source repos/notebooks for deeper context
3. Write the selection matrix + rules + disaster links + source attribution

Priority order (most detailed first):
1. context-memory.md + context-compression.md (core chapters)
2. coordination.md + permissions-safety.md (highest impact)
3. production-disasters.md (7 full causal chains)
4. tool-management.md + mcp-security.md + multi-agent-state.md
5. need-an-agent.md + testing-evaluation.md

### P3: CAPABILITY.md Workflow (45 min)
1. /design mode: D1→D10 sequential walk-through with AskUserQuestion per decision
2. /audit mode: check 10 decisions against existing code/design
3. Anti-skip table (≥4 entries)
4. Output format: Architecture Decision Document / Architecture Audit Report

### P4: Installation & Attribution (30 min)
1. install.sh (same pattern as web-backend)
2. LICENSE-ATTRIBUTION.md (Claude Code/Anthropic, OpenClaw, Hermes/NousResearch, OWASP, Elastic, etc.)
3. Final README.md

---

## 5. Content Sources — MUST Directly Borrow, Not Reinvent

**Primary research files (Blake MUST read these first):**
1. `.tad/evidence/research/ai-agent-architecture-capability-pack/2026-05-07-curated-findings.md` — 24 decision rules + 10 failure modes + tool mapping
2. `.tad/evidence/research/ai-agent-architecture-capability-pack/2026-05-07-three-systems-deep-dive.md` — 10+10+15 rules from OpenClaw/Hermes/Claude Code + 7 disaster causal chains + cross-system comparison

**NotebookLM notebooks for deeper questions:**
- Main: `8da09b3b` (58 sources, broad)
- OpenClaw: `44a28f1c` (14 sources, source code files)
- Hermes: `8ccf8d90` (16 sources, source code files)
- Claude Code: `1e86994e` (14 sources, architecture analysis)

**Process:**
- Step 1: Read both research findings files completely
- Step 2: For each reference file, query the relevant notebook for details (e.g., context-compression.md → query Hermes notebook about anti-thrashing specifics)
- Step 3: Write with [Source: system-name] attribution on every rule
- Step 4: Cross-reference with production-disasters.md to link each skipped decision to its disaster

**NOT acceptable:** Inventing architecture advice not grounded in a source. Every recommendation must trace to Claude Code, OpenClaw, Hermes, Anthropic's guide, or a documented production incident.

---

## 6. Line Budget

| File | Estimated Lines | Purpose |
|------|----------------|---------|
| CAPABILITY.md | ~300 | Pure router + scoping + anti-skip table (no inline decision content) |
| references/ (10 files) | ~3200 total | 10 decisions with matrices + rules + disasters |
| install.sh | ~150 | Multi-agent installer |
| Other (README, LICENSE, etc.) | ~200 | Documentation |
| **Total** | **~3850** | (under 5000 cap) |

Budget per reference file (guidance, not hard caps):
- context-memory.md + context-compression.md: ~500 combined (core chapters, but driven by content density not padding)
- coordination-and-state.md + permissions-safety.md: ~400 each (highest content density)
- production-disasters.md: ~400 (7 full causal chains)
- cost-token-economics.md + observability.md: ~250 each (new, well-sourced)
- tool-management.md + testing-evaluation.md: ~250 each
- need-an-agent.md: ~150 (shortest — simple decision tree)

**D3/D6 boundary rule** (CR P1-1): D3 covers WHAT to remember and WHERE to store it (memory architecture selection). D6 covers WHAT TO DO when the context window fills up (compression pipeline design). Hermes rules 4-9 (dual-layer triggers, anti-thrashing, pre-LLM pruning, atomic boundaries, active task protection, iterative updates) belong in D6. Hermes rules 2-3 (single-active backend, memory vs skill routing) belong in D3.

---

## 7. Acceptance Criteria

- [ ] AC1: ~/ai-agent-architecture/ repo created with all files from §3.2 structure
- [ ] AC2: CAPABILITY.md has YAML frontmatter (name + description) for skill loader
- [ ] AC3: CAPABILITY.md has two modes (/design + /audit) with scoping phase in /design
- [ ] AC4: All 10 reference files exist in references/, each containing a decision matrix
- [ ] AC5: ≥70 `[Source: X]` attribution tags across references/*.md
- [ ] AC6: references/production-disasters.md has 7 causal chains, each using `### Incident N:` heading format, each tagged `[Scope: all]` or `[Scope: multi-agent]`
- [ ] AC7: references/context-compression.md covers all 3 systems (Claude Code 5-layer, Hermes dual-layer + anti-thrashing, OpenClaw fallback-model)
- [ ] AC8: references/context-memory.md has 5-pattern selection matrix with quantitative trade-offs where available
- [ ] AC9: Zero TAD-specific terminology in pack files (excluding LICENSE-ATTRIBUTION.md). Search: `TAD`, `handoff`, `Gate [1-4]`, `Ralph Loop`, `Solution Lead`, `Execution Master`, `/alex`, `/blake`
- [ ] AC10: Total line count ≤5000
- [ ] AC11: install.sh works for --agent=claude-code --dry-run (Phase 1)
- [ ] AC12: CAPABILITY.md has anti-skip table under `### Anti-Skip Table` heading with ≥4 rows (both "excuse" and "legitimate skip condition" columns)
- [ ] AC13: LICENSE-ATTRIBUTION.md credits Anthropic, OpenClaw, NousResearch/Hermes, OWASP, Elastic
- [ ] AC14: git init + initial commit
- [ ] AC15: CAPABILITY.md contains ZERO inline decision matrix TABLE structures (all in references/)
- [ ] AC16: ≥7 of the D1-D9 reference files cross-reference production-disasters.md
- [ ] AC17: references/cost-token-economics.md exists with model routing + budget caps + tool cost analysis
- [ ] AC18: references/observability.md exists with trace strategy + tool recommendations + alert thresholds

---

## 8. Spec Compliance Checklist

| AC# | Verification Method | Expected Evidence |
|-----|-------------------|-------------------|
| AC1 | `ls ~/ai-agent-architecture/ ~/ai-agent-architecture/references/` | 10 .md files in references/ |
| AC2 | `head -5 ~/ai-agent-architecture/CAPABILITY.md` | YAML frontmatter with name + description |
| AC3 | `grep -cE '/design\|/audit\|scoping' ~/ai-agent-architecture/CAPABILITY.md` | ≥4 |
| AC4 | `ls ~/ai-agent-architecture/references/*.md \| wc -l` | 10 |
| AC5 | `grep -rcE '\[Source:' ~/ai-agent-architecture/references/*.md \| awk -F: '{s+=$NF} END{print s}'` | ≥70 |
| AC6 | `grep -cE '^### Incident [0-9]' ~/ai-agent-architecture/references/production-disasters.md` | 7 |
| AC7 | `grep -cE 'Claude Code\|OpenClaw\|Hermes' ~/ai-agent-architecture/references/context-compression.md` | ≥6 |
| AC8 | `grep -cE 'In-context\|vector store\|Tiered\|Knowledge graph\|Enterprise context' ~/ai-agent-architecture/references/context-memory.md` | ≥5 |
| AC9 | `grep -rnE '\bTAD\b\|handoff\|Gate [1-4]\|Ralph Loop\|Solution Lead\|Execution Master\|/alex\|/blake' ~/ai-agent-architecture/ --include='*.md' --include='*.sh' --exclude='LICENSE-ATTRIBUTION.md'` | 0 |
| AC10 | `find ~/ai-agent-architecture/ \( -name '*.md' -o -name '*.sh' \) -exec cat {} + \| wc -l` | ≤5000 |
| AC11 | `bash ~/ai-agent-architecture/install.sh --agent=claude-code --dry-run 2>&1` | Exit 0 |
| AC12 | `sed -n '/Anti-Skip Table/,/^##/p' ~/ai-agent-architecture/CAPABILITY.md \| grep -cE '^\|.*\|.*\|'` | ≥5 |
| AC13 | `grep -cE 'Anthropic\|OpenClaw\|NousResearch\|Hermes\|OWASP\|Elastic' ~/ai-agent-architecture/LICENSE-ATTRIBUTION.md` | ≥5 |
| AC14 | `cd ~/ai-agent-architecture && git log --oneline -1` | Initial commit exists |
| AC15 | `grep -cE '^\| Pattern \|^\| When RIGHT' ~/ai-agent-architecture/CAPABILITY.md` | 0 (no inline decision matrix tables) |
| AC16 | `grep -rcl 'production-disasters' ~/ai-agent-architecture/references/ \| grep -v production-disasters.md \| wc -l` | ≥7 |
| AC17 | `wc -l ~/ai-agent-architecture/references/cost-token-economics.md` | File exists, ≥100 lines |
| AC18 | `wc -l ~/ai-agent-architecture/references/observability.md` | File exists, ≥100 lines |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/capability-pack-ai-agent-architecture/code-reviewer.md
  - .tad/evidence/reviews/blake/capability-pack-ai-agent-architecture/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/capability-pack-ai-agent-architecture/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260507-capability-pack-ai-agent-architecture.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new patterns discovered)
```

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md): CAPABILITY.md 必须有 name + description frontmatter
- **Capability Pack: Multi-Agent Install Pattern** (architecture.md): install.sh 用 --agent flag + Phase 3 stubs
- **DESIGN.md Spec Integration as a Type A Capability** (architecture.md): 外部规范导入用 Type A step model
- **Pack = domain judgment, TAD = process constraint** (capability-packs memory): 不要在 pack 里重新实现 TAD 机制

---

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| backend-architect | P0-1: Missing Cost Management decision | Added D7 cost-token-economics.md (model routing, budget caps, tool cost) | Resolved |
| backend-architect | P0-2: Missing Observability decision | Added D8 observability.md (traces, logging, alerts, dashboards) | Resolved |
| backend-architect | P0-3: AC verification drift (heading formats unspecified) | AC6 now specifies `### Incident N:` format; AC12 uses section-anchored grep | Resolved |
| code-reviewer | P0-1: AC9 `\bAlex\b`/`\bBlake\b` false-positives | Replaced with `Solution Lead`/`Execution Master`/`/alex`/`/blake` | Resolved |
| code-reviewer | P0-2: AC12 counts all table rows not anti-skip | Changed to section-anchored `sed -n '/Anti-Skip/,/^##/p'` | Resolved |
| code-reviewer | P0-3: AC15 false-positive on structural terms | Narrowed to `^\| Pattern \|^\| When RIGHT` (actual matrix table headers) | Resolved |
| code-reviewer | P0-4: Section numbering collision (§7 AC vs §7.x Notes) | Important Notes moved to §10 | Resolved |
| backend-architect | P1-1: D8 MCP → merge into D5 Permissions | Merged; freed slot for Cost (D7) | Resolved |
| backend-architect | P1-3: /design mode needs scoping phase | Added Phase 0 (3-5 upfront questions → skip non-applicable decisions) | Resolved |
| backend-architect | P1-4: Disasters #4-7 are multi-agent only | Added `[Scope: all]` / `[Scope: multi-agent]` tag requirement to AC6 | Resolved |
| code-reviewer | P1-1: D3/D6 boundary unclear | Added explicit boundary rule in §6 Line Budget | Resolved |
| code-reviewer | P1-2: CAPABILITY.md 500 lines too generous | Reduced to ~300 (pure router) | Resolved |
| code-reviewer | P1-4: AC5 threshold too low (50) | Raised to ≥70 | Resolved |
| code-reviewer | P1-5: No cross-reference AC between disasters and decisions | Added AC16: ≥7 references cross-link production-disasters.md | Resolved |

---

## 10. Important Notes

### 10.1 This Pack is Structurally Different
web-backend = 43 rules (lintable, code-time, run scripts to verify)
ai-agent-architecture = 10 decisions (not lintable, design-time, requires constraint analysis)
Blake must NOT copy web-backend's structure. No scripts/ directory. No CONVENTIONS.md. The deliverable is decision matrices with selection criteria, not rule checklists.

### 10.2 Context Compression is the Core Chapter
Research showed all 3 systems' most complex subsystems are context compression. references/context-compression.md + references/context-memory.md together should be ~800-1000 lines (40-50% of references/ budget). Don't under-invest here.

### 10.3 Anti-Patterns
- ❌ Listing frameworks without selection criteria ("LangGraph is stateful" → useless)
- ❌ Generic advice without source attribution ("Consider caching context" → useless)
- ❌ Tutorial-style explanations ("Event sourcing is a pattern where..." → wrong audience)
- ❌ >5000 lines total (context bloat = agent ignores the pack)
- ❌ Inventing rules not grounded in Claude Code / OpenClaw / Hermes / documented incidents
