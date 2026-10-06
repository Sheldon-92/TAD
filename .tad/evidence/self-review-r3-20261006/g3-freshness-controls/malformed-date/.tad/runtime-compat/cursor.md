# Runtime Compatibility Ledger: Cursor

**Platform:** cursor
**Ledger Version:** 1
**Last Updated:** 2026-10-06
**Source:** P3 landing artifacts — .tad/evidence/designs/2026-10-06-p3-phase0-probes.md (Phase 0 probes), .tad/evidence/live-regression/cursor-20261006.md (live baseline, PASS, 2026-10-06), .tad/project-knowledge/patterns/runtime-adapter-instance-cursor.md (six-dimension instance declaration)
**Scope note:** Only surfaces declared and evidenced in the instance declaration are listed. Surfaces with no counterpart declaration on this runtime (subagents_custom_agents, mcp, config_toml, codex_cloud on the Codex ledger) are intentionally absent — an unmeasured surface is not listed rather than listed unverified.

## Drift Response Policy

When a Cursor capability changes:

1. **Detected** — Create `.tad/active/ideas/IDEA-{date}-cursor-{surface}-drift.md`
2. **Evaluated** — Classify: protocol impact (Epic), adapter impact (handoff), docs-only (quick fix), accepted limitation (record)
3. **Adopted/Deferred** — Update this ledger. If adopted: handoff. If deferred: record reason, set next_review.

**Fail-closed rule**: Unknown behavior affecting safety/quality/evidence gates → BLOCK adoption until verified.

**Recheck triggers**: Before TAD release, before `*sync`, after Cursor agent version bump, after official doc changes, monthly cadence; after any change to this runtime's hooks projection artifacts (.cursor/hooks.json, .tad/hooks/lib/cursor-session-start.sh, .tad/hooks/lib/cursor-post-write.sh, or the shared .tad/hooks/*.sh behavior source) — a same-round recheck of this ledger is mandatory

## Ledger Entries

| surface | owner | current_behavior | source | runtime_version | last_verified | volatility | next_review | regression_required | fallback_behavior | status |
|---------|-------|------------------|--------|-----------------|---------------|------------|-------------|---------------------|-------------------|--------|
| entry_headless | cursor_adapter | Headless surface is `agent -p --trust`; an untrusted workspace exits 1 with a trust prompt; stdin closed | runtime-adapter-instance-cursor.md dimension 1 + 2026-10-06-p3-phase0-probes.md OC-2 | agent 2026.10.01-e373342 | 2026-10-06 | high | 2026-11-05 | no | Interactive IDE session | verified |
| skill_loading | cursor_adapter | `.agents/skills/` discovery; `/alex` and `/blake` invocation works | runtime-adapter-instance-cursor.md + live-regression/cursor-20261006.md | agent 2026.10.01-e373342 | 2026-10-06 | high | 2026-11-05 | no | Read referenced files directly | verified |
| agents_guidance_AGENTS_md | cursor_adapter | AGENTS.md is read natively by the runtime | runtime-adapter-instance-cursor.md + live-regression/cursor-20261006.md | agent 2026.10.01-e373342 | 2026-10-06 | medium | 2026-12-05 | no | Direct file read | verified |
| hooks | cursor_adapter | `.cursor/hooks.json` (version 1) plus shims `cursor-session-start.sh` / `cursor-post-write.sh`; sessionStart, postToolUse (Write) and preCompact map onto the shared scripts; no entry sets failClosed | runtime-adapter-instance-cursor.md dimension 3 + 2026-10-06-p3-phase0-probes.md OC-2/OC-3/OC-7 + live-regression/cursor-20261006.md | agent 2026.10.01-e373342 | 2026-10-06 | high | 2026-11-05 | yes | Manual gate pre-checks | verified |
| ask_user_question_hook | cursor_adapter | R-CU-1: no question-tool event exists, so ask-user capture has no landing point on this runtime | runtime-adapter-instance-cursor.md dimension 6 | agent 2026.10.01-e373342 | 2026-10-06 | high | 2026-11-05 | yes | Numbered-options plain-text fallback | accepted_limitation |
| sandbox_approval_permissions | cursor_adapter | `.cursor/cli.json` is a programmable declaration surface (vendor-documented); the TAD example is inert and not shipped by the installer (PM ruling D-4), so this surface is declared but not TAD-enforced | runtime-adapter-instance-cursor.md dimension 4 + .tad/templates/runtime-permission-examples/cursor-cli.json | agent 2026.10.01-e373342 | 2026-10-06 | medium | 2026-12-05 | no | Runtime default permissions | verified_partial |
| context_compaction | cursor_adapter | preCompact calls the shared precompact-session-snapshot directly; envelope compatibility verified (OC-7); no compacting-push parity point | runtime-adapter-instance-cursor.md dimension 3 | agent 2026.10.01-e373342 | 2026-10-06 | high | 2026-11-05 | yes | session-state.md file-based recovery | verified_partial |
| trace_evidence_capture | cursor_adapter | Shims call the shared scripts to write `.tad/evidence/traces/<date>.jsonl` (same source and format) | runtime-adapter-instance-cursor.md dimension 6 + live-regression/cursor-20261006.md | agent 2026.10.01-e373342 | 2026-10-06 | medium | 2026-12-05 | no | Manual evidence collection | verified |
| release_sync_install | cursor_adapter | tad.sh projects hooks.json plus shims: preflight, cmp and rollback symmetric | runtime-adapter-instance-cursor.md dimension 3 + live-regression/cursor-20261006.md raw install record | agent 2026.10.01-e373342 | 2026-10-06 | low | 2027-04-04 | no | Manual file copy | verified |
