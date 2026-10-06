# Runtime Compatibility Ledger: OpenCode

**Platform:** opencode
**Ledger Version:** 1
**Last Updated:** 2026-10-06
**Source:** P3 landing artifacts — .tad/evidence/designs/2026-10-06-p3-phase0-probes.md (Phase 0 probes), .tad/evidence/live-regression/opencode-20261006.md (live baseline, PASS, 2026-10-06), .tad/project-knowledge/patterns/runtime-adapter-instance-opencode.md (six-dimension instance declaration)
**Scope note:** Only surfaces declared and evidenced in the instance declaration are listed. Surfaces with no counterpart declaration on this runtime (subagents_custom_agents, mcp, config_toml, codex_cloud on the Codex ledger) are intentionally absent — an unmeasured surface is not listed rather than listed unverified.

## Drift Response Policy

When an OpenCode capability changes:

1. **Detected** — Create `.tad/active/ideas/IDEA-{date}-opencode-{surface}-drift.md`
2. **Evaluated** — Classify: protocol impact (Epic), adapter impact (handoff), docs-only (quick fix), accepted limitation (record)
3. **Adopted/Deferred** — Update this ledger. If adopted: handoff. If deferred: record reason, set next_review.

**Fail-closed rule**: Unknown behavior affecting safety/quality/evidence gates → BLOCK adoption until verified.

**Recheck triggers**: Before TAD release, before `*sync`, after OpenCode version bump, after official doc changes, monthly cadence; after any change to this runtime's hooks projection artifacts (.opencode/plugins/tad-hooks.ts or the shared .tad/hooks/*.sh behavior source) — a same-round recheck of this ledger is mandatory

## Ledger Entries

| surface | owner | current_behavior | source | runtime_version | last_verified | volatility | next_review | regression_required | fallback_behavior | status |
|---------|-------|------------------|--------|-----------------|---------------|------------|-------------|---------------------|-------------------|--------|
| entry_headless | opencode_adapter | Headless surface is `opencode run --model <id>`; stdin must be closed (</dev/null) — with stdin left open the process blocks indefinitely with zero output (Phase 0 first-run evidence) | runtime-adapter-instance-opencode.md dimension 1 + 2026-10-06-p3-phase0-probes.md OC-6 | opencode 1.18.33 | not-a-date | high | 2026-11-05 | no | Interactive TUI session | verified |
| skill_loading | opencode_adapter | `.agents/skills/` is a first-party discovery path; `/alex` and `/blake` invocation works | runtime-adapter-instance-opencode.md dimension 3 + live-regression/opencode-20261006.md | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | no | Read referenced files directly | verified |
| agents_guidance_AGENTS_md | opencode_adapter | AGENTS.md is read natively by the runtime | runtime-adapter-instance-opencode.md + live-regression/opencode-20261006.md | opencode 1.18.33 | 2026-10-06 | medium | 2026-12-05 | no | Direct file read | verified |
| hooks | opencode_adapter | Adapter ships as `.opencode/plugins/tad-hooks.ts` (single-file tad.sh projection); four points — session.created, experimental.session.compacting, tool.execute.after (write/edit), session.compacted — map onto the shared `.tad/hooks/*.sh` behavior source | runtime-adapter-instance-opencode.md dimension 3 + live-regression/opencode-20261006.md + raw trigger traces | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | Manual gate pre-checks (pre-accept/pre-gate) | verified |
| session_start_context_injection | opencode_adapter | R-OC-1: no SessionStart context-injection surface; session.created fires side effects only, and the compacting push is partial parity | runtime-adapter-instance-opencode.md dimension 6 + live-regression/opencode-20261006.md field 5 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | Compacting-point reminder push | accepted_limitation |
| ask_user_question_hook | opencode_adapter | R-OC-2: the headless surface has no question tool, so ask-user capture is not registered on this runtime | runtime-adapter-instance-opencode.md dimension 6 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | Numbered-options plain-text fallback | accepted_limitation |
| sandbox_approval_permissions | opencode_adapter | The config `permission` surface is programmable; `edit: deny` verified live (write/edit tools disappear from the session roster) | runtime-adapter-instance-opencode.md dimension 4 + .tad/templates/runtime-permission-examples/opencode-permission.json | opencode 1.18.33 | 2026-10-06 | medium | 2026-12-05 | no | Default permission configuration | verified |
| context_compaction | opencode_adapter | experimental.session.compacting drives a compact reminder push and session.compacted drives a precompact snapshot (handler-level proof; no real compaction event occurred inside the baseline session) | runtime-adapter-instance-opencode.md dimension 3 + live-regression/opencode-20261006.md field 5 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | session-state.md file-based recovery | verified_partial |
| trace_evidence_capture | opencode_adapter | The plugin calls the shared scripts to write `.tad/evidence/traces/<date>.jsonl` (same source and format as the Codex surface); live trigger lines captured 2026-10-06 | runtime-adapter-instance-opencode.md dimension 6 + live-regression/opencode-20261006.md raw pointers | opencode 1.18.33 | 2026-10-06 | medium | 2026-12-05 | no | Manual evidence collection | verified |
| release_sync_install | opencode_adapter | tad.sh single-file-projects tad-hooks.ts: preflight divergence is FATAL, project copy is cmp-checked, rollback is symmetric | runtime-adapter-instance-opencode.md dimension 3 + live-regression/opencode-20261006.md raw phase1-install.log | opencode 1.18.33 | 2026-10-06 | low | 2027-04-04 | no | Manual file copy | verified |
