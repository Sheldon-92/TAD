# Cross-Agent Parity Check: Source-Condition Feature Markers

**Date:** 2026-06-01
**Linked to:** L2 pack-build-rules "Capability Pack: Design and Build Rules"

---

### Cross-Agent Parity Check: Source-Condition Feature Markers, Not Hardcode — 2026-06-01
- **Context**: P2 codex-parity-phase2-catchup. Layer 3 feature markers (`deliverable`, `research_complexity`, `step4_5`) were hardcoded in parity-check.sh. Blake source has 0 mentions of `research_complexity`/`step4_5` (alex-specific research-engine features). The hardcoded check FAILED blake's edition for markers that never existed in its source.
- **Discovery**: When a parity gate checks BOTH agent editions (alex + blake), feature markers that are agent-specific cause false failures on the other agent. The fix: source-condition each marker (`grep -ci "$marker" "$SOURCE" > 0` → check; else SKIP). This is the Layer-3 analog of the Layer-2 "0-source category → SKIP" pattern (both follow the same principle: don't require what the source doesn't have). Also: `claude -p` with a 326KB source input produces analysis text instead of the raw transformed file — `codex exec --full-auto` via stdin is the reliable headless regen mechanism (~175s, within ≤5min budget).
- **Action**: For any parity/drift check that runs against multiple agent editions: source-condition every checked marker. Hardcoded markers are valid only when the check runs against a single known source. For headless regen: use `codex exec --full-auto` with procedure via stdin, not `claude -p` (which interprets the large input as a question to answer rather than a procedure to execute).
- **Grounded in**: .tad/evidence/spikes/codex-parity/parity-check.sh (Layer 3 source-conditioned fix), .tad/evidence/spikes/codex-parity/p2-constraint-trace.md (headless probe results), COMPLETION-20260601-codex-parity-phase2-catchup.md
