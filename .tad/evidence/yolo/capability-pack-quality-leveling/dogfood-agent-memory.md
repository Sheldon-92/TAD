# Dogfood Judgment — Agent Memory / Context Management Design Review

Date: 2026-06-13
Task: Review a support-agent long-term-memory design (embed every turn → Pinecone → similarity search; bump max_tokens + hand-rolled summarizer for long-context flooding; on Claude/Anthropic).
Judge: independent, blind to which answer used the `agent-memory` skill.

## Verification (WebSearch + skill reference cross-check)

| Claim | Answer | Verdict | Source |
|-------|--------|---------|--------|
| `clear_tool_uses_20250919`, beta header `context-management-2025-06-27`, default trigger 100K input_tokens, keep 3 tool_uses, `exclude_tools`/`clear_at_least` | A1 | CORRECT | Claude context-editing docs; skill CE2 |
| `compact_20260112`, separate header `compact-2026-01-12`, default 150K trigger | A1 (explicit), A2 (header only) | CORRECT | skill CE4 / claude-api skill |
| Compaction supported on Opus 4.8/4.7/4.6 + Sonnet 4.6 | A1 | CORRECT (skill adds Fable 5; A1 covers user's stack) | skill CE4 |
| MUST append full `response.content` (compaction block) not just `.text` | A1 + A2 | CORRECT — both flagged the #1 native-compaction bug | skill CE4 |
| Memory tool `memory_20250818`, `/memories`, no built-in access control, per-user dir + auth, GDPR/CCPA | A1 | CORRECT | skill CE5 |
| 84% token savings + 39% perf on 100-turn agent; 50–70% context reduction | A1 | CORRECT | anthropic.com/news/token-saving-updates; skill CE6 |
| Zep/Graphiti DMR 94.8% vs MemGPT 93.4% | A1 | CORRECT | arXiv 2501.13956; getzep blog |
| Mem0 ADD/UPDATE/DELETE/NOOP extract-reconcile | A1 + A2 | CORRECT | arXiv 2504.19413; mem0 docs |
| CoALA working/episodic/semantic/procedural layers | A1 + A2 | CORRECT | arXiv 2309.02427 |
| 1M context window (Opus 4.x, Sonnet 4.6) | A2 | CORRECT — 1M GA since Mar 2026 | Claude models overview |
| max_tokens is OUTPUT ceiling, capped 64K (Sonnet 4.6) / 128K (Opus 4.7+) | A2 | CORRECT | Claude models overview |
| Put memories AFTER cache breakpoint / system-prompt memories invalidate cache every turn | A2 | CORRECT | Claude prompt-caching docs |
| Retrieved memories degrade answers if irrelevant; threshold + rerank | A2 | CORRECT (well-established) | RAG literature |
| Per-user/tenant scoping of vector query = data-leak prevention | A2 | CORRECT, and a critical real-world point | sound |

### Specific-but-WRONG / imprecise claims

- **A1 — "Organizational (5th) memory layer"**: Canonical CoALA defines 4 layers (working + episodic/semantic/procedural). The "5th organizational layer" is a pack extension, not canonical CoALA. A1 does NOT mis-attribute it to CoALA (frames as design recommendation), so not a hard factual error, but it is the least-grounded claim in either answer and reads as pack-internal doctrine ("Rule MA5") presented with the same authority as verified facts.
- **A2 — "this is a misconception, and it will 400"**: Overstated. Raising `max_tokens` within the model's output cap does NOT return a 400; only requesting *above* the model cap errors. The load-bearing point (max_tokens = output ceiling, does nothing for input/context flooding) is fully correct; the "will 400" is a minor factual overreach.
- **A2 — "max_tokens to ~16000 (non-streaming) / ~64000 (streaming)"**: Reasonable operational guidance (SDKs warn/require streaming for large max_tokens due to timeout), not wrong, but presented as if a hard rule when it's a soft SDK recommendation.

Net: A1 has zero hard-wrong specifics but one weakly-grounded pack-internal layer. A2 has one minor overreach ("will 400"). Neither answer has a correctness-tanking error. Specificity in BOTH is overwhelmingly CORRECT specificity, not hallucinated verbosity.

## Scoring (1–5)

### Answer 1 (clearly the skill-using answer — cites SKILL.md, rule IDs MA2/MA3/MA5, CC/CE rules)
- Correctness: 5 — every verified specific checks out; the one soft spot (5th layer) is framed as recommendation not fact.
- Actionability: 5 — exact config (`clear_at_least`, `exclude_tools`, thresholds), the `response.content` gotcha, the memory-tool security checklist, P0/P1/P2 triage, and a CoALA→storage map.
- Specificity: 5 — names exact API identifiers, default values, benchmark numbers, all verified.
- Completeness: 5 — covers memory architecture (consolidation/scoring/temporal), native pruning vs compaction vs memory tool, security/PII, cost justification, and the layer map.

### Answer 2 (no skill — strong general senior-engineer answer)
- Correctness: 4.5 — one minor overreach ("will 400"); everything else correct, including 1M window and cache-breakpoint topology that A1 omits.
- Actionability: 4.5 — concrete recommended design (two stores, extract-reconcile, threshold+rerank, cache placement, model default). Slightly less API-exact than A1 (says "context editing" generically, no `clear_tool_uses_20250919` identifier or default values).
- Specificity: 4 — correct but less dense on exact API names/defaults; relies more on principle than on verbatim config.
- Completeness: 4.5 — adds TWO things A1 underweights: (1) per-user/tenant scoping as a data-leak risk, (2) prompt-cache breakpoint placement of dynamic memories + retrieval thresholding/reranking. Lighter on memory-tool security and on the consolidation/temporal-tracking depth.

## Verdict

Winner: **Answer 1**, margin **slight**.

Rationale: A1 wins on CORRECT specificity, not verbosity — its edge is real, verified API-level precision (exact identifiers, default trigger/keep values, `clear_at_least`/`exclude_tools`, the `compact_20260112` `response.content` bug, the memory-tool no-access-control warning) that a builder can implement directly, plus deeper memory-architecture reasoning (consolidation/scoring/temporal tracking, verified Zep DMR numbers). Every dense specific survived verification.

But the margin is only slight because A2 is excellent and surfaces two production-critical points A1 underweights or omits: (1) **per-user/tenant scoping of the vector query** — the actual data-leak risk for a *support* agent, which A1 mentions only obliquely via "per-user dir"; and (2) **prompt-cache breakpoint topology** (retrieved memories must go after the breakpoint or you invalidate cache every turn) plus retrieval thresholding/reranking. A2 also correctly states the 1M context window, which reframes the urgency of the flooding problem — A1 never mentions current window size. A2's only blemish is the "will 400" overreach.

If the user's top risk is cross-customer data leakage and prompt-cache cost, A2's omissions-coverage is arguably more valuable; if the user needs implementable native-API config and memory-architecture depth, A1 is stronger. On balance A1's verified-specific density + correctness edge wins, slightly.
