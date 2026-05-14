## Evaluation Dimensions

1. **Specificity**: ADEQUATE  
   Mem0 and Letta are concrete anchors, but “notebook ask” is vague. The Anthropic “Dreams API” question is likely malformed: official search surfaces Anthropic API docs and a “dream interpreter” prompt, not a clear Dreams API endpoint/session contract.

2. **Completeness**: INSUFFICIENT  
   Missing evaluation criteria, failure modes, storage/migration strategy, command UX, safety around deleting knowledge, integration with Alex/Blake gates, and measurable success metrics for consolidation quality.

3. **Actionability**: ADEQUATE  
   Some answers could inform design, especially data model and local duplication analysis. But Q5 jumps straight to synthesis without requiring concrete outputs like schema, CLI behavior, retention rules, review workflow, rollback plan, or acceptance tests.

4. **Source Strategy**: INSUFFICIENT  
   GitHub-first is good for Mem0/Letta internals, but docs/issues/releases should also be checked to avoid overfitting to implementation details. “Anthropic docs and blog” is too weak if the API premise is unverified. Local analysis should inspect actual `.tad` files, handoffs, deleted references, and command conventions, not only `architecture.md`.

## Overall Rating

INSUFFICIENT

## 修正后的问题列表

| # | KR | Question | Method |
|---|-----|----------|--------|
| 1 | O2-KR1 | In `mem0ai/mem0`, what is the current memory entry schema, storage backend abstraction, metadata fields, update/version semantics, and deduplication algorithm? Identify exact files/functions and any docs/tests that contradict or clarify behavior. | GitHub code + docs + tests |
| 2 | O2-KR1 | In Letta/MemGPT, what are the actual memory tiers, persistence models, retrieval paths, and mutation triggers? Verify whether “archival → recall → core” promotion/demotion is implemented behavior or conceptual framing. | GitHub code + docs + issues |
| 3 | O2-KR2 | Does Anthropic currently expose an official “Dreams API”? If yes, document endpoint, request/response schema, limits, lifecycle, and examples. If no, replace this dependency with relevant primitives such as Messages API, tool use, files, prompt caching, batch processing, or Claude Code workflows. | Official Anthropic docs only |
| 4 | O2-KR2 | For TAD’s `.tad/project-knowledge/architecture.md`, classify every knowledge entry by type, age, source handoff, referenced files, current file existence, duplication cluster, contradiction risk, and actionability. | Local static analysis |
| 5 | O2-KR2 | Across `.tad/active`, `.tad/archive`, handoffs, gates, and command docs, where would a `*dream` command fit without violating Alex/Blake responsibilities? What files, commands, and gate checkpoints must it touch or avoid? | Local architecture review |
| 6 | O2-KR3 | What should the minimal viable `*dream` command produce: proposed diffs, summaries, deletion candidates, confidence scores, audit log, rollback file, or human approval checklist? Define exact CLI inputs/outputs. | Design synthesis |
| 7 | O2-KR3 | What are the non-negotiable safety rules for pruning knowledge: no silent deletion, preserve source traceability, detect stale file refs, flag contradictions, require Gate 4 acceptance, and support rollback? | Risk analysis |
| 8 | O2-KR3 | What acceptance tests prove the dreaming mechanism works on the existing 70+ entries: dedup rate, stale-reference detection accuracy, summary quality rubric, zero-loss auditability, and command idempotence? | Test plan |