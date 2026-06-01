# Codex Cross-Model Adversarial Review — Synthesis (2026-06-01)

**Reviewer**: Codex (codex-cli 0.130.0) — independent model, adversarial instruction.
**Scope**: 8 new agent-adjacent packs (SKILL.md + references piped to stdin, ~42-54KB each).
**Verdict**: 8/8 FIX-FIRST. All codex quotes verified as REAL pack content (not hallucinated) — spot-checked 8 quotes, all exist verbatim.

## Why this matters
The Claude build+review loop (build agent + 2 adversarial Claude reviewers + fixer) produced 0-P0 packs and passed the discriminative behavioral gate (7/8). But it systematically MISSED a class of **factual / API-correctness errors**. Codex (different training, different blind spots) caught ~30 concrete ones. This is the documented cross-model-review value (architecture.md "Cross-Model Orchestration", "independent second view catches blind spots"). NOTE: "verified" (discriminative gate) means the pack CHANGES agent behavior — it is orthogonal to factual correctness, which this review shows needs a fix pass.

## Triage: 3 categories

### Category A — CONFIRMED concrete defects (code-breaking or factual; FIX) ~30
| Pack | Confirmed-real Cat-A errors |
|------|------------------------------|
| ai-guardrails | `result_type`→`output_type` (Pydantic AI renamed; code fails) · `from rebuff import Rebuff`→`RebuffSdk` · `DeanonymizerEngine`→`DeanonymizeEngine` (Presidio real class) · Presidio Hash uses random salt (not deterministic) · F2 β=2 weights recall **4×** not 2× (math) · OpenAI moderation >8 categories now |
| llm-observability | OTel `gen_ai.client.token.usage` = **Histogram** not Counter (spec) · MLflow alias `@production` not `/production` · STS default **600** rps not 500 · LangSmith not "cloud-only" (self-hosted exists) |
| agent-orchestration | `langgraph` (1.x) vs `langgraph-sdk` (0.3.15) version conflation · Python HITL middleware = **3** decisions (approve/edit/reject); `respond` is JS/frontend · `acceptEdits` is NOT restrictive (use `dontAsk`) · Temporal: HTTP clients belong in Activities not `imports_passed_through()` · directed handoff = `n(n-1)` not `n(n-1)/2` |
| knowledge-graph | GraphRAG Leiden **Level 0 = finest/most-detailed**, higher = broader — pack has it REVERSED (misroutes queries) · RDF-Star `<<...>>` is legacy Turtle-star (RDF 1.2 changed) · workflow `generate_embeddings`→`generate_text_embeddings` |
| agent-memory | `{"role":"system"}` in messages list — Anthropic API rejects (system is top-level) · Letta `core_memory_replace/append` deprecated → memory_insert/replace/rethink |
| rag-retrieval | Voyage uses `input_type=` param not manual `query:`/`passage:` prefix · Cohere embed-v4 has no native sparse/multi-vector · "Voyage 3.5 Dims = Low(3-8×)" is a data error (real: 1024 default) · Pinecone namespace 100k is Standard/Enterprise-plan-specific |
| data-engineering | `write_disposition="replace"` inside a raw-history-PRESERVATION rule (self-contradiction) · 150M-row math omits initial 10M · dlt incremental needs cursor config (not automatic) · GX 1.0 still supports YAML File Data Contexts |
| synthetic-data | "12× faster (≈270%)" mathematically inconsistent · ConTAM overlap metrics REQUIRE corpus access (pack says "without access") · RRHF unnormalized favors **shorter** not longer · Milvus has no native `uint32_vector` (use BINARY_VECTOR) |

### Category B — Over-absolute claims (legit P1, soften with caveat) ~20
"must reside in RAM", "gate on Faithfulness=1.0", "z>4 kill switch", "MUST implement consolidation/scoring/temporal", "AI Gateway mandatory", "HITL mandatory for all tool calls", etc. → reframe as contextual/threat-model-dependent. Real quality improvements; not code-breaking.

### Category C — Unsourced/suspicious specific numbers (anti-slop) ~12
"43% CSAT", "58% task-time", "20-40% XML accuracy", "60% incidents from state-mgmt", "90% SQuADv2 contaminated", "1000× faster", "120ms P95 portable". These trace to `findings.md [N]` (often secondary blogs) — present as benchmark-specific-with-citation or remove. This is the SAME anti-slop risk the build loop was supposed to catch.

## Recommendation
Cat-A is clear, high-value, mostly verifiable → FIX (parallel fix workflow, one agent per pack, given its codex review; verify each against current docs, do NOT blind-apply Cat-B). Cat-B/C = larger judgment pass, optional second round.
