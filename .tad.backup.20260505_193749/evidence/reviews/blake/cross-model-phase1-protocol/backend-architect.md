# Layer 2 Expert Review: backend-architect
# Handoff: HANDOFF-20260503-cross-model-phase1-protocol
# Round: 1 (post P0 fixes from code-reviewer)
# Verdict: FAIL — P0=3, P1=6, P2=6

## P0 Issues

### P0-1: SKILL.md body uses bare `notebooklm` (not absolute path)
9 of 9 invocations in command bodies use bare `notebooklm`. Preflight says use absolute path.

### P0-2: Lifecycle state machine: dormant→active and archived→active transitions undefined
*ask updates last_queried but not status. Status field semantics ambiguous (persisted vs derived).

### P0-3: *archive writes to non-existent .tad/research-notebooks/archived/ with no mkdir
Partial-archive corruption possible if history write fails before status update.

## P1 Issues
P1-1: REGISTRY write ordering / atomicity not specified
P1-2: *sync "update to match cloud" can destroy local-only metadata (notes, titles, added dates)
P1-3: fallback_chains references claude_websearch/manual_mermaid/claude_code_reviewer — no catalog entries
P1-4: setup.sh uses `python3` (not `$VENV_PATH/bin/python`) inside venv export step
P1-5: set -e + interactive notebooklm login has no recovery path on abort
P1-6: (web-UI added) placeholder not handled in *curate skill text (only in REGISTRY comment)

## P2 Issues (defer)
P2-1 to P2-6: sync semantics, REGISTRY backup, CLI support hedge, active_notebook clearing, DEFER enforcement, "local truth vs canonical" wording
