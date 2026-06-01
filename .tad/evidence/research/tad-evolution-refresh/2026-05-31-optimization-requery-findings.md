---
research_complexity: complex
notebook: tad-evolution-research (37cfefa5-52b3-4a8a-a8e3-a83f32150759, 45 sources)
requeried: 2026-05-31
purpose: Ground the TAD optimization strategy in external agent-framework experience
---

# TAD Optimization — NotebookLM Re-Query Findings (2026-05-31)

Re-query of the `tad-evolution-research` notebook (first re-use since 2026-05-05)
to inform the comprehensive optimization review. 4 ask rounds mapped to the 5
internal audit facets. External evidence **strongly converges** with internal audits.

## Q1 — Context bloat / progressive disclosure
- Mature frameworks (Claude Code, Cursor, Windsurf, Agent SDK) use **progressive
  disclosure / search-then-load**: metadata registry at start (~30-50 tokens/skill),
  intent-gated relevance match promotes full instructions only on demand, heavy
  resources loaded only at execution. **Up to 85% token-overhead reduction.** [Q1 cites 3-6]
- **Atomic Knowledge Units (AKU)**: split instructions into modular SKILL.md, one
  coherent action per file; inject only task-relevant procedural knowledge; avoids
  "context rot" from irrelevant constraints filling the window. [Q1 cites 7-9]
- **Context sharding via sub-agents**: coordinator delegates to isolated sub-agents
  with fresh windows + strict tool subset; only concise summary returns. [Q1 cites 10-12]
- → VALIDATES core-workflow audit #1 (progressive disclosure of alex/SKILL.md).

## Q2 — Self-evolution loop without validation theater
- **Trace-first data flywheel**: log full trajectories, mine failure clusters, distill.
- **Separate working memory from production store**; automated proposals are
  "candidate playbooks" requiring **human approval** before promotion to read-only
  store. ← TAD's *optimize/*evolve human-approval design is architecturally CORRECT.
- Anthropic "Dreaming": batch over **1–100 prior sessions**, merge dups, replace stale,
  extract patterns. ← matches TAD dream-scanner intent.
- **"Token counts and response strings are not observability."** Need **trajectory
  metrics** (why it failed), not just outcome metrics — distributed tracing across
  every tool call / sub-agent handoff / retry. [Q2 cites 2,9]
- LLM-as-judge trust threshold: **≥0.80 Spearman correlation** with 2-3 experts
  scoring **100-200 outputs**. Observability "first PR, not the thirtieth." Build
  eval suites **incrementally from real failures**; canary 5% → 24-48h. [Q2 cites 7-13]
- → VALIDATES self-evolution audit: loop is architecturally right; needs (a) producer-
  contract fix, (b) real data accumulation, (c) trajectory-level telemetry — NOT more machinery.

## Q3 — Skill ecosystem: behavioral eval + collision
- **Behavioral eval**: trajectory + outcome metrics; LLM-judge calibrated to ≥0.80
  Spearman; **CI/CD regression harness measuring pass@k**, blocks deploy on success-
  rate drop. Anthropic "Outcomes" = grader agent against a done-rubric. [Q3 cites 1-8]
- **Rule conflict resolution**: embed **deterministic Validators** in skills (AKU
  schema) — hard pass/fail gate beats conflicting prose; boundary contracts (Pydantic);
  **offline consolidation (Dreaming) detects contradictions before next session.** [Q3 cites 9-12]
- **Context saturation @ 50+**: 58 tools = 55K tokens before work; progressive disclosure
  improves tool-selection 62%→91%; **enforce a tool/skill budget (e.g. max 5)**; unload
  after session; shard via sub-agents. [Q3 cites 13-19]
- → VALIDATES capability-pack audit: behavioral fixtures + RUNNER (missing piece);
  collision detection via offline consolidation scan; max-pack budget (TAD has soft max-2).

## Q4 — What separates kept vs abandoned frameworks (THE strategic signal)
- **#1 cited practice: deep trace-level observability from day one + AGGRESSIVELY
  MINIMIZE abstraction.** "Frameworks that get out of the way survive."
- Teams' top regrets: (1) **extra abstraction layers that obscure prompts/responses**,
  (2) **overengineering simple workflows**, (3) **overestimating need for customization**.
- "The next wave of agent failures won't be about what agents can't do. It'll be about
  what teams can't observe." [Q4 cites 9]
- → Cautions strongly AGAINST the generalization big-bet now (more product = more
  abstraction/scope). Supports leaning TAD down (progressive disclosure + scar-tissue cleanup).

## Net convergence (external ⇄ internal)
1. **Lean the always-loaded protocol** (progressive disclosure) — external #1 pattern +
   internal core-workflow #1. HIGHEST LEVERAGE for "more usable".
2. **Fix data integrity before building more self-evolution** — producer §11 bug +
   honest dormant-until-threshold; loop design already matches best practice.
3. **Behavioral eval RUNNER for packs** — the measurable-quality unlock; external CI/CD
   pass@k + LLM-judge calibration is the proven shape.
4. **Don't over-customize / don't spin a 2nd product yet** — validate demand cheaply first.
