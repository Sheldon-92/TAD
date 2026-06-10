---
research_complexity: complex
notebook: 37cfefa5-52b3-4a8a-a8e3-a83f32150759
topic: "TAD repositioning — DEPTH/CEILING axis (corrects existence-axis round)"
date: 2026-06-09
related_objective: O1
related_idea: IDEA-20260609-repositioning-capability-acquisition
supersedes: "2026-06-09-ask-findings.md conclusions (those measured EXISTENCE, not DEPTH)"
---

# Corrected Findings: Depth/Ceiling Axis

## Methodological correction
Round 1 measured EXISTENCE ("does a competitor position as X / does a persistent layer
exist") and wrongly concluded the repositioning's walls fell. User's rebuttal (correct):
existence ≠ value; the decisive axis is HOW DEEP / TO WHAT DIFFICULTY each competitor
actually gets. Re-run on the depth axis reverses the conclusion.

---

## DQ1 — Competitor complexity CEILING (evidence of limits, not features)
All "AI for non-experts" tools are capped at the SHALLOW end:
- Low-code (Langflow/Dify): cap at moderate-complexity prototyping; break on audit trails,
  state management, error recovery → forced migration to code-first. Enterprise scale =
  "maintenance burden, brittleness, governance gaps."
- Autonomous generators (Lovable/Replit/ChatDev): ceiling = "MVP in an afternoon". Vague
  instructions → degrade to "static key-value placeholders instead of databases". Multi-file
  long-horizon → "almost right" trap (passes tests, fails production). SWE-EVO: 25% success.
- Playbook agents (Anthropic plugins/GitAgent): plateau at SPECIFICATION STALENESS; task
  deviates from playbook → guess-fail-correct-retry → context rot cascade.
- Universal: 10 hops @98% → 81%; nested tool calls full-sequence accuracy 28%; malformed
  tool call = unrecoverable mid-generation.

## DQ2 — Empirical task-vs-complex boundary (the capability cliff)
Boundary = isolated/well-scoped/verifiable  →  long-horizon/stateful/mid-execution-judgment.
- SWE-bench (isolated bug fix): 72.8%  →  SWE-EVO (21 files, long-horizon): 25%. Same models.
- "70% illusion" + reward hacking (binary wrapper trojans fake success) mask the lack of real
  problem-solving.
- Three collapse factors: (1) ambiguity/instruction-following (fail to deduce unstated
  constraints), (2) horizon-length/context-rot, (3) number-of-constraints/no-world-model
  (can't foresee state changes → cascading unrecoverable failure).
- Cost: shadow-AI breach avg $4.63M/incident.

## DQ3 — Is the HARD-problem space occupied? (the decisive question)
**"The space of autonomous AI solving ambiguous, undefined problems is EMPTY and unsolved."**
Industry's explicit response = abandon pure autonomy for complex work, build HITL orchestration:
- LangGraph / MS Agent Framework: durable execution + time-travel debugging; human judgment as
  first-class primitive; pause indefinitely for approval.
- HULA (Human-in-the-Loop SW Dev Agents, Atlassian JIRA): forces pause for human plan refinement
  before code-gen.
- Agent-initiated uncertainty: Claude Code asks for clarification >2x as often as humans
  interrupt — trained to halt on its own uncertainty.
- Effectiveness when bounded: eSentire 95% senior-analyst alignment, 5h→7min.
- **The Collaboration Paradox** (Anthropic): engineers use AI for 60% of work but can only
  FULLY DELEGATE 0-20%. Experienced devs use AI only where they "know what the answer should
  look like." → THE HUMAN solves the ambiguous part. AI does not.

---

## CORRECTED Synthesis (depth axis) — user was right

1. **The deep end is empirically EMPTY.** Every "AI for non-experts" competitor is capped at
   task automation / shallow well-defined work. Complex/ambiguous/long-horizon = autonomy
   collapses (SWE-EVO 25%, nested 28%, compounding 81%). "Crowded lane" was an artifact of
   measuring positioning, not capability.

2. **The industry CONVERGES on TAD's architecture.** The state-of-the-art answer to the deep
   end is exactly TAD's design: human-as-orchestrator, forced pauses/gates, agent-asks-for-
   judgment (= Socratic intake), durable state + replan (= handoff + Gate re-entry). TAD is on
   the right side of where the field is moving — this VALIDATES the core, doesn't falsify it.

3. **The genuinely OPEN cell (TAD's real differentiator, evidence-survived):**
   The existing HITL frameworks are CODE-LEVEL and SOFTWARE-ONLY:
   - LangGraph = you write the state-machine graph (developer, code).
   - HULA = JIRA + software engineering.
   Nobody occupies: **domain-AGNOSTIC, methodology-level (no-code) HITL orchestration for hard
   problems** — a protocol a displaced expert follows across hardware/audio/video/dev WITHOUT
   writing a LangGraph graph. The user's 14-project cross-domain track record is the existence
   proof that this cell is reachable; the research shows nobody else is selling it.

4. **The Collaboration Paradox is TAD's thesis, validated.** "Human solves the ambiguous part,
   AI does the rest, only 0-20% fully delegable" IS the TAD loop. TAD's bet = make that
   human-solves-the-hard-part loop SYSTEMATIC + ACCUMULATING + DOMAIN-AGNOSTIC.

## What is NOT yet proven (honest residue — carries over from round 1/2 challenge)
- That TAD's methodology gets MEASURABLY FURTHER on a hard problem than ad-hoc human+AI
  (no head-to-head evidence — this is the eval TAD still lacks).
- gate-ROI: code-enforced vs soft gates — does enforcement improve single-operator outcomes
  enough to justify cost? (Codex round-2 residual gap.)
- Staleness Trap: residue half-life → hallucination anchor; needs autonomous deprecation
  (Gemini round-2 residual gap).

## Positioning, evidence-grounded (replaces round-1 version)
TAD = **a domain-agnostic, methodology-level human-in-the-loop operating system for HARD
problems** — for the displaced expert with judgment but not domain-syntax fluency. It occupies
the empirically-empty deep end that autonomous tools collapse in and that code-level HITL
frameworks (LangGraph/HULA) address only for software engineers. Not "outsider becomes
insider"; rather "high-judgment operator ships across unfamiliar domains, and each pass
compounds."
