# Multi-Agent Failure-Mode Rules (MAST taxonomy)
<!-- capability: failure_modes -->

> Why do multi-agent LLM systems fail? Grounded in the MAST study
> ("Why Do Multi-Agent LLM Systems Fail?", arXiv 2503.13657, retrieved 2026-06-13):
> a taxonomy built from **1,600+ annotated execution traces across 7 MAS frameworks**,
> with expert inter-annotator agreement **Cohen's κ = 0.88** and a validated
> LLM-as-judge failure-labeler at **~94% accuracy / 0.77 Cohen's κ**.
> Use this reference to diagnose WHY an existing multi-agent system fails — before
> reaching for a bigger model or a fancier topology.

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| FM1 | MAST = 14 failure modes in 3 categories; measured distribution 42% / 37% / 21% | deterministic |
| FM2 | >40% of MAS failures are SPECIFICATION failures — write explicit subagent specs BEFORE topology tuning | deterministic |
| FM3 | 37% are inter-agent MISALIGNMENT — coordination breakdown, not model weakness | deterministic |
| FM4 | ~21% are VERIFICATION failures — agents stop early / skip output checks; mandate an explicit verifier gate | deterministic |
| FM5 | Gains come from better system DESIGN, not bigger models | deterministic |

---

## Rules

### FM1: The MAST Taxonomy — 14 Failure Modes, 3 Categories, Measured Distribution

MAST classifies every observed multi-agent failure into **14 fine-grained failure modes** grouped into **3 categories**. The measured distribution across the 1,600+ traces:

| Category | Share | What it covers |
|----------|-------|----------------|
| **System design issues** (bad specification) | **42%** | ambiguous/incomplete agent task specs, role definition gaps, step-order and topology mistakes |
| **Inter-agent misalignment** | **37%** | coordination breakdown — agents talk past each other, conflicting decisions, lost context across handoffs |
| **Task verification** | **21%** | premature termination, no/weak output checking, the system declaring success before the job is done |

**Rule**: When triaging a multi-agent failure, classify it into one of these three buckets FIRST. The distribution tells you where to look: a near-even split between spec and coordination, with verification as the long tail. Do not assume the failure is "the model" — the data says it is overwhelmingly design and coordination.

> Source: MAST — arXiv 2503.13657 (retrieved 2026-06-13): 14 modes / 3 categories, 42% / 37% / 21%, 1,600+ traces / 7 frameworks, κ=0.88 IAA, LLM-judge ~94% acc / 0.77 κ.

**determinismLevel**: deterministic — the taxonomy and measured shares are a fixed empirical result.

### FM2: Most Failures Are SPEC Failures — Fix the Spec Before the Topology

The single largest category (**42%**, system design / bad specification) means more than four in ten failures trace back to ambiguous or incomplete subagent task descriptions and role definitions — NOT to the wrong topology or the wrong model.

**Rule**: Before tuning supervisor-vs-swarm, fan-out counts, or swapping in a bigger model, write **explicit, unambiguous task specs** for every subagent: objective, input contract, output contract, tool budget, and stop condition. (Anthropic's own result corroborates: teaching the lead to write detailed subagent task descriptions cut task-completion time ~40% — see orchestration-patterns OW2.) A vague spec is the most likely root cause by the numbers.

> Source: MAST — arXiv 2503.13657 (retrieved 2026-06-13): 42% system-design / bad-specification share.

**determinismLevel**: deterministic — the corrective action follows from the measured category share.

### FM3: 37% Are Inter-Agent Misalignment — Coordination, Not Capability

Inter-agent misalignment (**37%**) is coordination breakdown: agents make conflicting implicit decisions, lose context across handoffs, or fail to integrate each other's outputs. This is the failure class behind the swarm O(n²)/8-10-turn-drift rules (SUP3/SUP4) and the single-writer principle (OW3).

**Rule**: Treat coordination as a first-class design concern, not an emergent property. Share full agent traces (not just final messages) between agents that must integrate work; for tasks needing one coherent artifact, prefer a single-threaded linear agent over conflicting peers (OW3). A bigger model does not fix a coordination protocol that lets two agents make contradictory decisions.

> Source: MAST — arXiv 2503.13657 (retrieved 2026-06-13): 37% inter-agent-misalignment share; pairs with Cognition single-writer principles (orchestration-patterns OW3).

**determinismLevel**: deterministic.

### FM4: ~21% Are VERIFICATION Failures — Mandate an Explicit Verifier Gate

About **21%** of failures are task-verification failures: the system stops before the job is actually done, or skips checking its own output. This is the structural argument for the Supervisor validation gate (SUP1) and for an explicit verifier step.

**Rule**: Every multi-agent workflow must include an explicit verification/quality gate that checks the final output against the original spec BEFORE declaring success — a dedicated verifier agent or a deterministic check, not "the last agent says it's done." Roughly one in five failures is the system stopping early; an explicit gate is the direct mitigation.

> Source: MAST — arXiv 2503.13657 (retrieved 2026-06-13): 21% task-verification share.

**determinismLevel**: deterministic.

### FM5: Improve System DESIGN, Not Model Size

The MAST conclusion is that gains come from better **system design** — clearer specs, better coordination protocols, explicit verification — not from a larger underlying model. The 42% / 37% / 21% split is dominated by design and coordination issues a model upgrade does not touch.

**Rule**: When a multi-agent system underperforms, audit specs (FM2), coordination (FM3), and verification (FM4) BEFORE spending on a bigger/more expensive model. Reserve the model-upgrade lever for cases where the per-step reasoning quality (not the orchestration) is demonstrably the bottleneck.

> Source: MAST — arXiv 2503.13657 (retrieved 2026-06-13): design-over-model-size conclusion.

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **"Just use a bigger model"**: ignores that 42% + 37% = ~79% of failures are spec + coordination, which a model upgrade does not fix (FM5).
- **Topology tuning before spec**: reordering agents while subagent task specs stay vague — attacks the smaller lever, leaves the 42% spec category untouched (FM2).
- **No verifier**: trusting "the last agent says it's done" — ~21% of failures are exactly premature/unchecked termination (FM4).
- **Final-message-only handoffs**: passing only the last message instead of full traces between integrating agents — a direct cause of the 37% misalignment category (FM3).
