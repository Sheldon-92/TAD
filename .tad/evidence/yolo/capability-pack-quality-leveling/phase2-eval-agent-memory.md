# Phase 2 Behavioral Discriminative Eval — agent-memory

**Date**: 2026-06-13
**Pack**: agent-memory (v0.1.0)
**Fixture**: `.claude/skills/agent-memory/examples/agent-memory-fixture.md`
**Result**: ✅ DISCRIMINATIVE PASS

---

## Fixture parameters

- **discriminative_pattern**: `Memory System ≠ Vector Database|ADD ?/ ?UPDATE ?/ ?DELETE ?/ ?NOOP|NOOP|consolidat[a-z]+ *,? *(and )?scor|temporal tracking|episodic recall confusion|LongMemEval|49\.0%|66\.88|68\.44|94\.8%|74\.0%|1\.44s|context-management-2025-06-27|clear_tool_uses(_20250919)?|compact_20260112|memory_20250818|84% token savings|LOCOMO|Graphiti|Zep|CoALA`
- **min_discriminative**: 3
- **Method**: `grep -oE PATTERN | sort -u | wc -l` on each answer.

## Scenario (from fixture)

"For our support agent's long-term memory, I'm going to embed every conversation turn and store it in Pinecone. On each new message we do a similarity search and stuff the top results into the prompt. That gives the agent memory of the user, right? Also, the conversations get really long and old tool outputs are flooding the context window — I'll just bump max_tokens and write a little summarizer when it gets long. We're on Claude (Anthropic) for the agent. Review the design."

## Results

| Answer | Distinct discriminative markers | Threshold | Outcome |
|--------|--------------------------------|-----------|---------|
| WITH-PACK (SKILL.md rules applied) | **21** | ≥3 | PASS |
| CONTROL (generalist, no pack) | **0** | <3 | PASS |

**discriminative_pass = true** — with-pack (21) ≥ min_discriminative (3) AND control (0) < min_discriminative (3).

### WITH-PACK distinct markers (21)
`1.44s`, `49.0%`, `66.88`, `74.0%`, `84% token savings`, `94.8%`, `ADD / UPDATE / DELETE / NOOP`, `ADD/UPDATE/DELETE/NOOP`, `clear_tool_uses_20250919`, `CoALA`, `compact_20260112`, `consolidation, scor`, `context-management-2025-06-27`, `episodic recall confusion`, `Graphiti`, `LOCOMO`, `LongMemEval`, `Memory System ≠ Vector Database`, `NOOP`, `temporal tracking`, `Zep`

(Note: `sort -u` counts `ADD / UPDATE / DELETE / NOOP` and `ADD/UPDATE/DELETE/NOOP` as two distinct surface forms plus the bare `NOOP`; even discounting the formatting duplicates, the count is far above threshold.)

### CONTROL distinct markers (0)
The generalist answer "approved" the vector-DB-as-memory design, suggested generic retrieval tuning / storage hygiene / a hand-rolled token-threshold summarizer, and emitted ZERO pack-specific markers — exactly the no-pack failure profile the fixture's Anti-Slop Check predicts ("use a vector database", "make sure retrieval is accurate", "write a summarizer").

## Interpretation

The pack is genuinely discriminative: the named cross-cutting rule (Memory System ≠ Vector Database), the Mem0 ADD/UPDATE/DELETE/NOOP reconcile matrix, the consolidation+scoring+temporal-tracking trio, the Anthropic native context-management API anchors (`clear_tool_uses_20250919`, `compact_20260112`, `context-management-2025-06-27`, 84% token savings), the CoALA layer map, and the primary-source benchmark numbers (66.88 / 94.8% / 49.0% / 74.0% / 1.44s) are all markers a no-pack control does not produce. The control instead pattern-matched to generic RAG advice and approved the flawed design.
