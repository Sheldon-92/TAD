# Research Findings: TAD Knowledge Consolidation ("Dreaming")
Date: 2026-05-14
Notebook: tad-evolution-research (37cfefa5)
Sources added: 4 (Dreams API docs, dream-skill repo, VentureBeat, LLM KB blog)

## Q1: Mem0 Conflict Resolution + Lineage
- Mem0 uses ADD-only (never overwrite) + temporal reasoning at retrieval time
- Mem0g (graph variant) has write-time conflict detection before storage
- Metadata: user_id, agent_id, run_id, session_id, timestamp, custom fields
- Dedup algorithm not specified in sources; moved to retrieval-time ranking

## Q2: Offline Batch Consolidation Patterns + Dreams API
- Dreams API contract: input = memory store + 1-100 session transcripts → output = NEW separate memory store
- Original never modified — candidate for human review
- Runs async, minutes to tens of minutes
- Compilation Updates pattern: read existing + inject new (not create duplicate)
- Concept Consolidation: read both, synthesize, update backlinks, archive redundant
- Controlled forgetting: decay mechanism, stale pointer pruning, demotion to secondary files

## Q3: Anthropic API Constraints
- Models: claude-opus-4-7, claude-sonnet-4-6 (1M token context)
- Max 100 sessions per dream job; instruction limit 4096 chars
- Prompt caching: 80-90% cost reduction with stable prefix
- Exceeding context: agent teams (orchestrator-workers) or chunking

## Q4: TAD Local Baseline
- 119 entries, 1118 lines (~30K tokens per session load)
- Categories: PROCESS(33), OTHER(23), PACK(19), CROSS-MODEL(17), HOOK(14), PROTOCOL(9), SHELL(3)
- 1 AMENDED+ORIGINAL pair (should merge)
- Only 1/119 entries Revalidated
- 12 stale file references (point to archived/deleted files)
- 13 entries from Jan-Feb 2026 (3-4 months old, potential staleness)

## Q5+Q6: MVP *dream Command Design (from all sources)
### Input/Output Contract
- NEVER modify in place → produce candidate file for human review
- Human Review Gate mandatory (same as TAD *optimize pattern)

### Non-Negotiable Safety Rules
1. Preserve provenance — never silently delete; archive with redirect
2. Filter transient noise — ignore one-off errors, temp state
3. ADD-only for verified facts; REMOVE only for confirmed-stale

### 4 Core Operations
1. **Deduplicate & Merge** — overlapping concepts → single entry
2. **Temporal Normalization** — relative dates → absolute
3. **Contradiction Resolution** — detect conflicts, keep most recent verified
4. **Prune & Demote** — verbose entries → summary + secondary file

### dream-skill 4-Phase Process (reusable for TAD)
1. **Orient** — read current knowledge file, map what exists
2. **Gather Signal** — grep recent session transcripts for corrections/patterns
3. **Consolidate** — merge new signals, resolve contradictions, normalize dates
4. **Prune & Index** — compress main file to lean index (<200 lines), demote detail to secondary files

## Phase 4c Round 1 Re-Ask Supplement (gap-filling)

### Contradiction Resolution Rule
- No universal rule exists — open research problem
- Dreams API: always-newest (recency wins)
- Mem0: ADD-only, resolve at retrieval time
- LLM KBs: probabilistic judgment (LLM reads + updates)
- TAD design decision needed: for entries with MUST/MANDATORY/VIOLATION → human-must-decide (never auto-resolve safety constraints); for others → newest wins

### Pruning Quantitative Criteria
- dream-skill: hard line count threshold (<200 lines main index)
- LLM KB lint: <3 substantive sentences = "thin article" needing cleanup
- Age-based and citation-based pruning NOT found in sources
- TAD design: entries >10 lines → demote to detail files; main index = title + 1-line summary + link

### Compression Loss Detection
- Sources lack text-comparison check for semantic preservation
- Recommended: "governance-as-code" — deterministic validators (shell/Python)
- TAD design: `grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING'` before vs after — count must be ≥ original
- Additionally: every "Grounded in" file path must still exist post-merge

### Human Review Cost
- Sources unquantified — no data on review time for N changes
- Semi-auto mechanism: git diff + git blame only
- TAD design: auto-approve "obvious" (stale ref removal, date normalization); flag "ambiguous" (merges, contradictions) for human review

## Adversarial Challenge Results
- Phase 0c: Codex INSUFFICIENT, Gemini INSUFFICIENT
- Key correction: paradigm shift from runtime memory → offline batch
- Dreams API confirmed real (Code with Claude 2026-05-06)
- Refined 5 questions → 6 questions
