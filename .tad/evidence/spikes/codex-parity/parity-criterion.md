# Codex-Edition Parity Criterion

Mechanizable semantic-coverage check for Codex editions against Claude source SKILLs.
Designed for Phase 1 prototype; Phase 3 hardens into a release-gate.

## Three Coverage Layers

### Layer 1: Section Coverage (must-cover vs expected-absent)

**Source of truth:** `.tad/portable-rules.md` → Expected-Absent-in-Codex Allowlist.

1. Extract all `*_protocol:` keys from the Claude source SKILL (the `<claude_skill>` argument).
2. Filter out nested/inline keys (indented keys that are sub-fields, not top-level blocks):
   - `per_phase_protocol`, `blocking_in_alex_protocol`, `fallback_protocol`, `honest_partial_protocol`, `archive_protocol` (nested inside test_review_protocol)
3. For each extracted key, check if it appears in the Codex edition (`<codex_edition>` argument):
   - **Present** → COVERED
   - **Absent AND on the expected-absent allowlist** → EXPECTED-ABSENT (not drift)
   - **Absent AND NOT on the allowlist** → MISSING (= drift, FAIL)

**Must-cover set:** all source `*_protocol:` keys NOT on the allowlist.
**Expected-absent allowlist** (from portable-rules.md):
- `yolo_execution_protocol`
- `optimize_protocol`
- `evolve_protocol`
- `dream_protocol`
- `publish_protocol`
- `sync_protocol`
- `sync_add_protocol`
- `sync_list_protocol`
- `lsp_provision_protocol`

### Layer 2: Constraint Coverage

Guard counts on the Codex edition:
- `AskUserQuestion` count MUST be 0 (Claude-only tool stripped)
- `MUST|MANDATORY|VIOLATION` count ≥ **source-derived floor**:
  floor = source count ÷ 10 (rounded down, minimum 10 absolute).
  The source count is extracted at gate time from the `<claude_skill>` argument
  (never a hardcoded constant — ARCH P1-1).
- `anti_rationalization_registry` MUST be present (grep match)
- `forbidden_implementations` MUST be present (grep match)

### Layer 3: Capability-Marker Coverage

**Mechanically extracted from the CURRENT source at gate time** (ARCH P1-1 — not a frozen list):

1. Extract `task_type:` enum values from the source (the values after `task_type:` in validation
   or frontmatter sections). Current set: code, yaml, research, e2e, mixed, deliverable.
2. Extract feature-track markers: tokens introduced since the last edition that represent
   significant protocol additions. Current extraction rule:
   - `deliverable` (non-dev execution track)
   - `research_complexity` (research-engine effort-scaling)
   - `step4_5` or `Pack Awareness` (pack-collision wiring)
3. Each extracted marker MUST appear at least once in the Codex edition.

## Exit-Code Contract (pinned — P1 prototype AND P3 release gate)

| Exit Code | Meaning |
|-----------|---------|
| 0 | Parity — all 3 layers pass |
| 1 | Drift — at least one layer fails (off-allowlist missing section, absent marker, guard fail) |
| 2 | Usage error (wrong args, file not found) |

**Parse errors:** In the P1 prototype, parse errors fail-open with a WARN (reported but exit 0).
The P3 release gate MUST fail-CLOSED on parse error (exit 1) — this is an explicit P3 hardening
item, not carried into P1.

## Renamed/Merged Section Mapping (minimized)

If a source protocol is renamed or merged in the Codex edition, a mapping table here resolves it.
Currently empty — no renames needed for v2.20.0.

| Source Key | Codex Key | Reason |
|------------|-----------|--------|
| (none) | (none) | No renames in v2.20.0 |
