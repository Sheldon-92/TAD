---
name: agent-memory-vector-store-review
description: "Tests Memory≠VectorDB cross-cutting rule + Mem0 ADD/UPDATE/DELETE/NOOP reconcile + consolidation/scoring/temporal-tracking trio + CoALA layer mapping on a naive 'append every turn to a vector DB' memory design"
pack: agent-memory
tests_rules:
  - "Cross-Cutting Rule: Memory System ≠ Vector Database"
  - "MA3: consolidation + scoring + temporal tracking"
  - "ML4: Mem0 four-operation reconcile (ADD/UPDATE/DELETE/NOOP)"
  - "MA1/MA2: CoALA layer classification (Memory Layer Map output shape)"
  - "ML6: primary-source benchmarks (Mem0 LOCOMO 66.88%, Zep DMR 94.8%, LongMemEval landscape)"
  - "CE1-CE6: native context editing / memory tool (clear_tool_uses_20250919, compact_20260112, 84% token savings)"
  - "ML7: file-as-memory (Letta 74.0% LoCoMo)"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers (named rules, pack-introduced
# terms, specific numbers from findings.md + the 2025/2026 deepening). Excludes
# generic nouns any senior engineer emits ("vector database", "embeddings",
# "long-term memory") and any word from the input scenario. These are markers a
# WITH-pack agent produces but a no-pack control does NOT. Refreshed 2026-06-13
# to reward the native-context-management vocabulary added in the Layer B deepening.
discriminative_pattern: "Memory System ≠ Vector Database|ADD ?/ ?UPDATE ?/ ?DELETE ?/ ?NOOP|NOOP|consolidat[a-z]+ *,? *(and )?scor|temporal tracking|episodic recall confusion|LongMemEval|49\\.0%|66\\.88|68\\.44|94\\.8%|74\\.0%|1\\.44s|context-management-2025-06-27|clear_tool_uses(_20250919)?|compact_20260112|memory_20250818|84% token savings|LOCOMO|Graphiti|Zep|CoALA"
min_discriminative: 3
---

# Fixture: "Append Every Turn to a Vector DB" Memory Design Review

## Input Scenario

"For our support agent's long-term memory, I'm going to embed every conversation turn and store it in Pinecone. On each new message we do a similarity search and stuff the top results into the prompt. That gives the agent memory of the user, right? Also, the conversations get really long and old tool outputs are flooding the context window — I'll just bump max_tokens and write a little summarizer when it gets long. We're on Claude (Anthropic) for the agent. Review the design."

## Expected Markers

When an AI agent processes the Input Scenario with the agent-memory pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **Memory System ≠ Vector Database** [structural]: the agent flags that an append-only vector store is NOT memory and names the distinction as the pack's cross-cutting rule — not a generic "consider a database"
   grep pattern: `Memory System ≠ Vector Database|not (a |an )?memory|append.?only|relevance drift|context dilution`
2. **Consolidation + Scoring + Temporal Tracking trio**: the agent prescribes the three cognitive processes a real memory layer must add on top of the vector store
   grep pattern: `consolidat[a-z]+ *,? *(and )?scor|temporal tracking|importance weight|temporal decay`
3. **Mem0 four-operation reconcile** [structural]: the agent prescribes the ADD/UPDATE/DELETE/NOOP extract-reconcile matrix instead of blind append, calling out that "store every turn" has no DELETE/NOOP
   grep pattern: `ADD ?/ ?UPDATE ?/ ?DELETE ?/ ?NOOP|NOOP|extract.?reconcile|episodic recall confusion`
4. **Benchmark reality** : the agent cites concrete primary-source numbers (Mem0 LOCOMO 66.88% / Zep DMR 94.8% / LongMemEval landscape) to puncture "vector DB = memory" — not one bare figure
   grep pattern: `LongMemEval|49\.0%|66\.88|94\.8%|LOCOMO|Graphiti|Zep`
5. **CoALA layer mapping** [structural]: the agent classifies the state into CoALA layers (working/episodic/semantic) rather than dumping everything in one store
   grep pattern: `CoALA|semantic memory|episodic memory|working memory|Memory Layer Map`
6. **Native context management** [structural, NEW]: on the "max_tokens + hand-rolled summarizer" half, the agent names Anthropic's native primitives instead of hand-rolling — context editing (`clear_tool_uses_20250919`, beta header `context-management-2025-06-27`) to PRUNE old tool outputs and/or `compact_20260112` to SUMMARIZE
   grep pattern: `context-management-2025-06-27|clear_tool_uses(_20250919)?|compact_20260112|memory_20250818|84% token savings`

## Verification Command

```bash
grep -oE 'Memory System ≠ Vector Database|ADD ?/ ?UPDATE ?/ ?DELETE ?/ ?NOOP|NOOP|consolidat[a-z]+ *,? *(and )?scor|temporal tracking|episodic recall confusion|LongMemEval|49\.0%|66\.88|94\.8%|74\.0%|context-management-2025-06-27|clear_tool_uses(_20250919)?|compact_20260112|memory_20250818|84% token savings|LOCOMO|Graphiti|CoALA|append.?only|relevance drift' agent-memory-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Memory System ≠ Vector Database" (the pack's named cross-cutting rule — a no-pack agent says "use a vector DB" approvingly)
- ✅ "consolidation + scoring + temporal tracking" (the pack's specific 3 cognitive processes a memory layer must implement)
- ✅ "ADD / UPDATE / DELETE / NOOP" (Mem0's specific 4-operation extract-reconcile matrix — not generic CRUD vocabulary)
- ✅ "episodic recall confusion" (the pack's named failure mode for storing events with the same weight as preferences)
- ✅ Primary-source benchmark numbers — "Mem0 LOCOMO 66.88%", "Zep DMR 94.8%", "LongMemEval 49.0% vs 63.8%" (specific, harness-tagged figures an LLM cannot reproduce from training — not one bare number)
- ✅ "CoALA" + Memory Layer Map (the named framework + the pack's structured classification output shape)
- ✅ "clear_tool_uses_20250919" / "context-management-2025-06-27" / "compact_20260112" / "memory_20250818" (exact Anthropic native context-management API anchors — a no-pack agent says "write a summarizer" instead)
- ✅ "84% token savings" (Anthropic's measured 100-turn-agent figure — a research-landed threshold, not the generic O(N²) argument)
- ❌ "use a vector database" (generic — and the design ALREADY proposes this; restates the input)
- ❌ "store embeddings and do similarity search" (restates the input scenario)
- ❌ "add long-term memory" (generic — any agent says this without the consolidation/scoring/temporal-tracking specifics)
- ❌ "bump max_tokens / write a summarizer" (restates the input — the discriminative move is naming the NATIVE primitives instead)
- ❌ "make sure retrieval is accurate" (generic, non-discriminative)
