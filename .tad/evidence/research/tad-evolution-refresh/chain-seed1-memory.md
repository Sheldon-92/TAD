---
seed_origin: original
seed_question: "Memory/retrieval architectures in 2026 AI-agent frameworks: production use + measured evidence"
kr_ref: "tad-evolution O-retrieval KR (incomplete)"
notebook: tad-evolution-research (37cfefa5-52b3-4a8a-a8e3-a83f32150759)
date: 2026-05-31
rounds: [seed, so_what]
---

## Seed: production memory/retrieval architectures (with measured evidence)
- Multi-signal/graph memory (Mem0/Mem0g): fuse semantic + BM25 + entity matching in one scored pass [1]; graph memory with conflict detectors [2,3].
- Actor-aware, multi-scope storage (user_id/agent_id/run_id) — prevents one agent treating another's hallucination as ground truth [4-6].
- Procedural memory + **Atomic Knowledge Units (AKUs)**: structured action-ready skills with tool bindings + governance validators [9-12].
- Two-stage retrieval (reranker second pass) [13]; async offline **"Dreaming"** consolidation + **three-store layout** (org read-only / project read-only / working read-write) [14-16] — note: mirrors TAD's own *dream + 3-tier knowledge.

## Measured evidence vs marketing (LOCOMO benchmark [17])
- Full-context: 72.9% accuracy BUT 9.87s median / 17.12s p95, ~26k tokens [18].
- Mem0g selective: 68.4% (−4.5%) for **91% latency reduction (2.59s p95) + 90% token reduction (~1,800)** [18,19].

## so_what (TERMINAL)
For TAD: the three-store "Dreaming" pattern is convergent evidence for TAD's *dream + project-knowledge tiering. AKUs (next chain) are the most TAD-relevant thread.
