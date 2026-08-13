# Knowledge Graph Construction Rules
<!-- capability: kg_construction -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| KGC1 | Ontology = Top-Down OWL guidance + Bottom-Up LLM refinement (never bottom-up only) | deterministic |
| KGC2 | Classify each entity against the schema AT extraction time (OntologyRAG) to block noise | semi-deterministic |
| KGC3 | Pick the extraction prompting paradigm by text difficulty + token budget | semi-deterministic |
| KGC4 | Schema drift → ontology reasoning (class/property-tree expansion) so queries survive model changes | deterministic |
| KGC5 | Volatile facts → bi-temporal model (Event Time + Ingestion Time) with real-time invalidation | deterministic |
| KGC6 | Selective extraction: full pass on structural regions, metadata-tag the body | semi-deterministic |

---

## Rules

### KGC1: Two-Directional Ontology Engineering

When designing the graph schema, combine both directions — bottom-up-only extraction drifts:

- **Top-Down Guidance:** human experts translate business specs, **competency questions**, and user stories into a formal ontology, typically in **OWL (Web Ontology Language)**.
- **Bottom-Up Refinement:** the LLM dynamically identifies new entities/relationships from source text to expand the schema.

The Ontogenia framework adds **Metacognitive Prompting** (model self-reflection + structural correction during ontology synthesis).

> Source: findings.md §1 "Modern Ontology Engineering" — top-down OWL + competency questions [25, 26], Ontogenia Metacognitive Prompting [26].

**determinismLevel**: deterministic — the two-direction method is a design rule.

### KGC2: Schema Classification at Extraction Time

When extracting, classify each entity against the domain schema **before storing it** — do not store raw extractions unfiltered:

- **OntologyRAG (TrustGraph)** uses the ontological schema at the extraction stage itself, classifying each entity against the domain schema before storing → prevents noise and hallucinations from entering the graph.

A bare zero-shot extract-then-store pipeline lets every hallucinated entity into the graph, where it later fragments traversals.

> Source: findings.md §1 — TrustGraph OntologyRAG classify-before-store [27].

**determinismLevel**: semi-deterministic — classification rule fixed; LLM judgments vary.

### KGC3: Extraction Prompting Paradigm Selection

When writing the extraction prompt, choose the paradigm by text difficulty and token budget:

| Paradigm | Mechanism | Use When | Failure Mode |
|----------|-----------|----------|--------------|
| **Zero-Shot** | Strict output schema + task description, no examples | MVP baseline, clean text, low token budget | Struggles with ambiguous text, jargon, inconsistent formatting |
| **One-Shot / Few-Shot** | Task description + curated raw-text→triple examples | Need standardized output structure or domain style | Example bias — model over-prioritizes entities similar to examples |
| **Chain-of-Thought (CoT)** | Sequential reasoning: identify entities → type them → map edges → output triples | Need high accuracy on relationship **directionality** + schema alignment | Significantly higher output token overhead + latency |
| **Stepwise Decomposition** | Independent sequential tasks: extract → generate candidates → normalize → format | Want debuggability (test each stage) | Orchestrates multiple model calls → more latency |
| **Knowledge Priming** | Generate background context/definitions first, then extract triples | Technical domains needing commonsense/domain bridging | High input token overhead; depends on model pre-training |

**Rule**: Zero-shot is the minimum-viable baseline, NOT the production default for hard text. Upgrade to CoT for directionality-sensitive schemas; Stepwise when you need to debug a noisy stage.

> Source: findings.md §3 "Extraction Prompting Paradigms" table — all five paradigms with advantages + failure modes [31].

**determinismLevel**: semi-deterministic — paradigm choice fixed; extraction output varies.

### KGC4: Schema Drift via Ontology Reasoning

When business logic, entity classifications, or metric definitions change over time (schema drift), a rigid DB schema breaks existing queries. Defend with **ontology reasoning**:

- **Class-tree and property-tree expansion** lets graph queries automatically adapt to evolving data models at query time — resilience against schema changes without rewriting every query.

> Source: findings.md §2 "Schema Drift and Bi-Temporal Modeling" — class-tree/property-tree expansion [29].

**determinismLevel**: deterministic — a structural reasoning capability.

### KGC5: Bi-Temporal Modeling for Volatile Facts

When facts change over time and you need real-time updates without full index recomputation, tag every extracted fact with **two distinct timestamps** (the Graphiti bi-temporal model):

- **Event Time:** when the fact was true in the real world
- **Ingestion Time:** when the agent learned the fact

When a definition changes or a metric is deprecated, the graph executes **real-time fact invalidation** based on these timestamps — avoiding full batch recomputation. In safety-critical domains (military, search-and-rescue, emergency response) this temporal grounding lets frameworks like ReaDS-KG maintain structured decision loops with explicit causal explanations for second- and third-order effects.

> Source: findings.md §2 — Graphiti Event Time vs Ingestion Time + real-time invalidation [27]; ReaDS-KG safety-critical decision loops [9, 30].

**determinismLevel**: deterministic — the two-timestamp model is a fixed design.

### KGC6: Selective Extraction for Token Cost Control

When extracting over a large corpus (GraphRAG cost scales with document volume — see cross-cutting rule), apply **selective extraction**:

- **Structural document preprocessing:** focus full LLM extraction on structural regions where core relationships are established — headers, introductions, party lists, executive summaries.
- **Metadata tagging:** tag detailed body-text chunks with basic metadata pointing back to core entities, **bypassing full extraction passes** on the body to keep cost manageable.

Pair this with proactive guardrails: hard spend limits, pipeline circuit breakers, cost attribution.

> Source: findings.md §3 "Production Spend Management" — selective extraction (structural regions + metadata tagging) [34], extraction-scales-with-document-volume guardrails [34].

**determinismLevel**: semi-deterministic — region selection fixed; extraction varies.

---

## Anti-Patterns

- **Bottom-up-only ontology**: LLM-discovered schema with no top-down OWL guidance drifts and loses competency-question coverage.
- **Extract-then-store with no schema check**: every hallucinated entity enters the graph and fragments later traversals.
- **Zero-shot as the production default**: fine as an MVP baseline, but hard/jargon-heavy text needs CoT or Stepwise.
- **Full extraction over every chunk**: ignores that cost scales with document volume; use selective extraction + metadata tagging.
- **Mutable facts with one timestamp**: without Event vs Ingestion time you cannot invalidate a deprecated fact without a full rebuild.
