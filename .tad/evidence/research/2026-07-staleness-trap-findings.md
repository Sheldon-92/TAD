# Staleness Trap — Deep-Ask Findings (O3/KR3 round 4 of 5)

> Notebook: TAD Evolution Research (`37cfefa5-52b3-4a8a-a8e3-a83f32150759`), 45 sources
> Date: 2026-07-05
> Bookkeeping: O3/KR3 round 4 of 5
> Open-question provenance: 2026-06-09 depth-axis findings L90 — "Staleness Trap:
> residue half-life → hallucination anchor; needs autonomous deprecation"

## Question

**Round 4 of 5** against notebook `37cfefa5-52b3-4a8a-a8e3-a83f32150759`:

> How does an agent framework's persistent instruction layer (CLAUDE.md /
> project-knowledge / accumulated residue) stay current as the underlying model's
> capabilities evolve? What staleness-detection, deprecation, and refresh mechanisms
> do the sources describe, and what failure modes follow from stale residue
> (hallucination anchoring, half-life decay)?

## Synthesis Points

### SP1 — Five distinct refresh-mechanism classes exist, but ALL target either session memory or code-structure facts — none targets methodology-layer residue

Cross-source synthesis: the 2026 landscape offers five mechanism classes for keeping
persistent instruction/memory layers current: (1) **async consolidation** — Anthropic
Dreams API and its open replica dream-skill run a 4-phase pipeline (Orient, Gather
Signal, Consolidate, Prune & Index) on a 24h/Stop-hook trigger, scanning ~100 recent
session traces, merging duplicate entries, converting relative dates to absolute, and
pruning MEMORY.md to ≤200 lines / 25KB; (2) **dynamic forgetting + temporal
reasoning** — Mem0's single-pass ADD-only extraction avoids destructive UPDATE/DELETE,
decaying low-relevance entries by weight and ranking dated memories at retrieval time;
(3) **file-hash invalidation** — ArgosBrain / codebase-memory-mcp watch file saves,
hash with XXH3 (~30 GB/s), and incrementally re-parse via Tree-Sitter within
milliseconds; (4) **hard auto-expiry** — GitHub Copilot applies a 28-day hard expiry
to retrieval indexes plus citation validation; (5) **active lint/merge maintenance** —
Louis Wang's self-improving KB ships /kb-lint (weak-entry, broken-backlink, near-
duplicate detection) and /kb-merge (physical merge + Git-archived redirects).
The synthesis: mechanisms (3)-(4) refresh *code-derivable* facts automatically, and
(1)-(2) manage *conversational* memory — but a methodology knowledge base like TAD's
project-knowledge (judgment rules, not code facts) is served only by class (5), which
is the least automated of the five.

Sources: Dreams - Claude API Docs; GitHub - grandamenium/dream-skill; GitHub - mem0ai/mem0; State of AI Agent Memory 2026; ArgosBrain — Memory for Claude Code, Codex, Cursor, GitHub Copilot & MCP coding agents; GitHub - DeusData/codebase-memory-mcp; Codebase-Memory: Tree-Sitter-Based Knowledge Graphs for LLM Code Exploration via MCP; Building a Self-Improving Personal Knowledge Base Powered by LLM — Louis Wang

### SP2 — Stale residue has three compounding failure modes: hallucination anchoring → guess-fail-retry context rot → lost-in-the-middle safety erosion

Cross-source synthesis of the failure cascade: (a) **hallucination anchoring** — after
a refactor (e.g., `verifyToken` → `validateToken`), an unsynced CLAUDE.md keeps feeding
the old name, and the agent confidently fabricates calls to the dead API ("silent
staleness"; any agent reading it a week later still sees the old definition); Mem0-class
factual stores show the same pattern when a high-retrieval-weight memory (old employer,
old preference) stays confidently wrong; (b) **context-rot cascade** — stale rules that
disagree with the real codebase push the agent into a guess-fail-correct-retry loop
whose error logs and dead code flood the context window; in the 500K-2M token range
this induces context rot that permanently degrades in-session planning; (c)
**lost-in-the-middle safety erosion** — unpruned residue growth pushes core
architecture rules and safety red-lines into the middle of a long prompt where
attention decay makes the agent selectively ignore them (bypassing approval gates,
destructive operations). The three modes compound: anchoring produces retries,
retries produce rot, rot dilutes the very rules that would have stopped the damage.

Sources: ArgosBrain — Memory for Claude Code, Codex, Cursor, GitHub Copilot & MCP coding agents; State of AI Agent Memory 2026; Knowledge Activation: AI Skills as the Institutional Knowledge Primitive for Agentic Software Development; Codebase-Memory: Tree-Sitter-Based Knowledge Graphs for LLM Code Exploration via MCP

### SP3 — Residue half-life is quantified NOWHERE in the corpus; "confident but stale" detection is an explicitly open research problem

Targeted probe result (refinement ask 2): **no source quantifies** a half-life or decay
rate for stale instruction residue — no number for "how quickly accumulated CLAUDE.md /
memory entries become wrong." The gap is stated qualitatively across three independent
sources: Louis Wang names the missing primitive directly ("articles have no freshness
signal; need date-aware lint checks"); ArgosBrain describes "silent staleness" with only
an anecdotal timescale (stale within "a week" of a rename); State of AI Agent Memory
2026 states that even with dynamic forgetting, "detecting when a high-relevance memory
becomes stale (confident but stale) remains an unsolved open research problem." The
2026-06-09 open question ("residue half-life") therefore cannot be answered numerically
from this corpus — the honest answer is that the field itself has not measured it.

Sources: Building a Self-Improving Personal Knowledge Base Powered by LLM — Louis Wang; ArgosBrain — Memory for Claude Code, Codex, Cursor, GitHub Copilot & MCP coding agents; State of AI Agent Memory 2026

### SP4 — Fully autonomous deprecation does not exist in production; every shipped mechanism deliberately retains a human review gate

Targeted probe result: no source describes a production mechanism where an agent
retires stale rules without human review — and two sources argue this is by design,
not immaturity. Dreams never modifies the input store ("you can review the output and
discard it if unsatisfied"); enterprise guidance mandates a three-store layout with
human review gates and promotion workflows before consolidated memories reach the
read-only project store (because dreaming can consolidate poisoned sessions into
long-term memory); DiffMem's LLM-driven "Agent-Driven Pruning" to Git branches is
explicitly listed under Future Vision, not shipped; dream-skill's Phase 4 prune is
structural compaction (line/size budget), not logical retirement of methodology rules.
Synthesis: the 2026-06-09 hypothesis "needs autonomous deprecation" is contradicted by
the corpus consensus — the state of the art is *autonomous candidate generation +
human-gated retirement*, which is also the memory-poisoning defense.

Sources: Dreams - Claude API Docs; GitHub - Growth-Kinetics/DiffMem: Git Based Memory Storage for Conversational AI Agent; GitHub - grandamenium/dream-skill; State of AI Agent Memory 2026

## TAD Implications

Maps to O1/KR3 capability gap: **TAD has no staleness detection for its own
project-knowledge / principles layer** (110 typed entries and growing, monotonic
accumulation, no freshness signal beyond ad-hoc `Revalidated:` lines).

Severity: High
Rationale: (a) SP2 shows the failure cascade lands exactly on TAD's architecture —
CLAUDE.md-class instruction files are the named anchor for hallucination anchoring,
and TAD's L1/L2 knowledge is loaded into every session; (b) SP1 shows no off-the-shelf
mechanism covers methodology-layer residue (the automated classes cover code facts and
chat memory only), so TAD cannot simply adopt a tool; (c) SP3/SP4 show the field has
neither measured half-life nor shipped autonomous deprecation — TAD's existing
human-review-gated SAFETY entries are already aligned with best practice
(three-store-style gating), but the *detection* half (date-aware lint, staleness
candidates) is absent in TAD today. High because the exposure is every session and the
mitigation cannot be bought.

Follow-up candidates (proposals only — NOT executed in this task):
1. Add a date-aware knowledge lint to `/tad-maintain` CHECK mode: flag entries whose
   last revalidation (or git-blame last-touch) exceeds a threshold, emitting a
   staleness-candidate list for human-gated retirement (SP4-compliant: agent proposes,
   human retires).
2. Adopt a Dreams-style consolidation pass for `.tad/project-knowledge/`: agent-drafted
   merge/prune candidates written to a separate review file (input store never
   modified), promoted only at a human gate.

## Provenance

- Notebook: `37cfefa5-52b3-4a8a-a8e3-a83f32150759` (registry id `tad-evolution-research`), 45 sources
- Retrieval date: 2026-07-05
- Tool: notebooklm CLI, version 0.3.4 (`~/.tad-notebooklm-venv/bin/notebooklm`), invoked
  per the research-notebook skill `ask` protocol with explicit `-n` notebook targeting
- Rounds: 1 primary ask + 2 refinement asks (source-title mapping; half-life /
  autonomous-deprecation probe), conversation `d7a16d4d-9e9b-40d3-a2d1-060d2d9fa02b`
- Caveats:
  - Source corpus was curated 2026-05; post-May-2026 developments are NOT covered
    (UNVERIFIED for currency beyond the corpus snapshot).
  - Refinement ask 2 returned citation hyperlinks pointing at corrupted internal file
    paths (a NotebookLM rendering artifact); source TITLES were consistent across both
    refinement asks and are used verbatim — the corrupted link targets were discarded.
  - SP3 and SP4 are negative-coverage findings (absence of evidence in this 45-source
    corpus); they are corpus-scoped claims, not claims about all literature.
