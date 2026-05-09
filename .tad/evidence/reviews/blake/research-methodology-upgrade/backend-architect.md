# Architecture Review: research-methodology-upgrade (STORM + Elicit + Auto Source + Adaptive)
**Reviewer**: backend-architect sub-agent
**Date**: 2026-05-09
**Handoff**: HANDOFF-20260509-research-methodology-upgrade.md
**Verdict**: PASS (after P1-1 + P1-2 fixes) — final P0=0, P1=0, P2=3

## P1-1 Fixed: Step 3c probe used "most recently added" (wrong after 3-URL loop)
After all 3 URLs added, "most recently added" always describes URL #3. First 2 URLs probed incorrectly.
**Fix**: Changed to use source ID via set-diff + call verify_import_quality(notebook_id, source_id) HELPER per research-notebook/SKILL.md.

## P1-2 Fixed: dynamic_seeds_added not compact-recoverable
Counter lives in conversation context only — lost on compact during long Phase 4 runs.
**Fix**: Added seed_origin: original|dynamic field to chain frontmatter. Recovery: `grep -rl 'seed_origin: dynamic' .tad/evidence/research/ | wc -l`. Added recovery note to both SKILL.md files.

## P2 Advisory (open)
P2-1: Latency worst-case exceeds ~20-30 min estimate. Noted in Phase 4 user message.
P2-2: gap_enrichment lacks consecutive-firing guard (other strategies have it). Design asymmetry documented.
P2-3: Evidence directory split between {notebook_topic}/ (chains) and {slug}/ (other artifacts). Compatible, not conflicting.
