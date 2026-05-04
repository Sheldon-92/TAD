# Backend-Architect Review: NotebookLM CLI Capability Spike

**Date**: 2026-05-04
**Handoff**: HANDOFF-20260504-notebooklm-spike.md
**Reviewer type**: backend-architect (architecture + integration design)

## Verdict: PASS for spike, PHASE 1 DESIGN CONSTRAINTS documented

The spike itself is well-executed (24 data rows, clear verdicts, honest spec deviations). P0 issues below are Phase 1 design requirements, not spike blocking items.

## P0 — Phase 1 Design Requirements

### P0-1: setup-notebooklm.sh pins 0.1.1 — already-shipped regression
- `setup-notebooklm.sh:40` must be updated to `notebooklm-py[browser]==0.3.4`
- Add SKILL preflight version check with error message
- Knowledge entry added to architecture.md (done in this spike)
- **Fix required before Phase 1 ships**

### P0-2: source add-research --mode deep is NOT Tier 1
- 226s blocking + permanently adds 64 sources + NOT idempotent
- Needs AskUserQuestion confirmation, max-sources guard, last_deep_research REGISTRY field
- Move to "Tier 1-Interactive" (not immediate auto-run)
- **Phase 1 SKILL design must implement guardrails**

### P0-3: Stale conversation zero-UUID cannot ship as hardcoded
- `-c 00000000-0000-0000-0000-000000000000` is undocumented server behavior
- Phase 1 must implement two-layer fallback: try without `-c`, fallback to zeros UUID on 31s timeout
- Must log workaround trigger to evidence
- File upstream notebooklm-py issue
- **Phase 1 SKILL design must implement fallback chain**

## P1 — Important for Phase 1 Design

### P1-1: artifact get content gap is a recommendation bug
- `generate report` → artifact but `artifact get` returns metadata only
- Run T13 (artifact export) before shipping `generate report` in Phase 1
- Don't ship "task_id without content" UX

### P1-2: Note commands should be DROPPED from Phase 1
- Notes do NOT participate in ask context (T9 NO-GO)
- Not "Tier 3 later" — wrong tool for SKILL's purpose
- Knowledge findings go to REGISTRY.yaml notes field or handoff evidence dir

### P1-3: Three-way comparison baseline missing
- Run 3-test incumbent baseline before committing Tier 2 commands
- Compare against existing Alex WebSearch workflow

### P1-4: /private/tmp ENOSPC is recurring vulnerability
- Use ~/Library/Caches/tad/research-notebook/ for scratch, not /private/tmp
- Architecture.md entry needed (added in this spike)

## P2 — Suggestions
- P2-1: Version pinning rollback plan
- P2-2: Explicit allowlist of supported commands in SKILL
- P2-3: Latency budget annotation per sub-command (AskUserQuestion for >60s commands)
- P2-4: `*ask` output should note "results from sources only, not personal annotations"

## Key Architectural Validation
- run-phase2b-tests.sh does NOT reference notebooklm — version upgrade has no impact on existing test infrastructure
- setup-notebooklm.sh line 40 is the only version pin that needs updating
