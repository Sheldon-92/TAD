# Architecture Review: dynamic-research-strategies
**Reviewer**: backend-architect sub-agent
**Date**: 2026-05-09
**Verdict**: PARTIAL-GO → Post-fix reassessment: PASS (P0-2 fixed, P0-1 was false positive, P1s addressed)

## P0-1 Status: FALSE POSITIVE (corrected)
backend-architect claimed Phase 4b re-ask (`alex/SKILL.md:1210`) is a `*research-notebook ask` invocation that triggers step3_5. This is **incorrect**: line 1210 calls raw CLI directly (`~/.tad-notebooklm-venv/bin/notebooklm ask`), NOT the SKILL command. step3_5 is only in the SKILL command.

Protective note added to Phase 4b re-ask comment for future-proofing:
`(Raw CLI call — NOT *research-notebook ask — intentional: avoids nested step3_5 loop. If ever migrated to *research-notebook ask, add --no-follow flag.)`

## P0-2 Fixed: Chain Filename Collision
Added `{uid}` suffix to chain storage path:
- `{date}-chain-{topic_slug}-{uid}.md`
- `{uid}` = first 4 hex chars of md5(seed_question_full_text)
- Collision guard: if file exists at init and seed_question doesn't match, append "-2", "-3"
- CJK handling: if slug ≤4 chars after alphanum filter, use "q" prefix

## P1-1 Addressed: Saturation State in Chain .md
Added to each round's Analysis block: `new_citations: N` and `prev_zero_streak: N`
Compact recovery can rebuild counter by reading last round's Analysis block.

## P1-2 Addressed: Latency Note
Added to Alex SKILL.md Phase 4: "Latency note: 2-3 seeds × max_depth 4 = 8-12 NotebookLM calls (~23-43s each) → ~4-8 min per research item. Inform user before starting Phase 4."

## P1-3 Addressed: so_what Context Cap
Added extraction cap (600 chars total): OBJECTIVES.md KR bullets (max 200 chars/KR, max 3 KRs) | PROJECT_CONTEXT.md "Current Goal" section (max 500 chars) | topic fallback.

## P1-4 Addressed: inside_research_plan Detection
Tightened to require BOTH conditions:
(a) .research/research-state.yaml exists AND phase == "ask"
(b) current notebook_id appears in research-state.yaml's notebook_ids list

## P2 Advisory (open)
P2-1: strategy priority gap_enrichment vs follow_thread in standalone — current order defensible.
P2-2: topic_slug CJK collision — addressed by uid suffix.
