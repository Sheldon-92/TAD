# Runtime Compatibility Ledger: OpenCode

**Platform:** opencode
**Ledger Version:** 1
**Last Updated:** 2026-10-06
**Source:** 2026-10-06 Phase 0 probes (.tad/evidence/designs/2026-10-06-p3-phase0-probes.md) + live full-chain transcript (.tad/evidence/live-regression/opencode-20261006.md, PASS) + instance declaration (.tad/project-knowledge/patterns/runtime-adapter-instance-opencode.md)

## Drift Response Policy

When an OpenCode capability changes:

1. **Detected** — Create `.tad/active/ideas/IDEA-{date}-opencode-{surface}-drift.md`
2. **Evaluated** — Classify: protocol impact (Epic), adapter impact (handoff), docs-only (quick fix), accepted limitation (record)
3. **Adopted/Deferred** — Update this ledger. If adopted: handoff. If deferred: record reason, set next_review.

**Fail-closed rule**: Unknown behavior affecting safety/quality/evidence gates → BLOCK adoption until verified.

**Recheck triggers**: Before TAD release, before `*sync`, after OpenCode CLI version bump, after official doc or plugin API changes, monthly cadence; after any change to this runtime's hooks projection artifacts (.opencode/plugins/tad-hooks.ts or the shared .tad/hooks/*.sh behavior source) — a same-round recheck of this ledger is mandatory

## Ledger Entries

| surface | owner | current_behavior | source | runtime_version | last_verified | volatility | next_review | regression_required | fallback_behavior | status |
|---------|-------|------------------|--------|-----------------|---------------|------------|-------------|---------------------|-------------------|--------|
| entry_headless | opencode_adapter | Headless surface is `opencode run --model <id>`; stdin must be closed or the process blocks forever with zero output (Phase 0 first-run evidence) | runtime-adapter-instance-opencode.md dim 1 + 2026-10-06-p3-phase0-probes.md OC-6 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | no | Interactive TUI session | verified |
| skill_loading | opencode_adapter | `.agents/skills/` is a first-class discovery path; `/alex` `/blake` invocation holds | runtime-adapter-instance-opencode.md dim 3 + live-regression/opencode-20261006.md | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | no | Direct file read | verified |
| agents_guidance_AGENTS_md | opencode_adapter | Repository AGENTS.md guidance is read natively by the session | runtime-adapter-instance-opencode.md + live-regression/opencode-20261006.md | opencode 1.18.33 | 2026-10-06 | medium | 2026-12-05 | no | Direct file read | verified |
| hooks | opencode_adapter | Adapter is `.opencode/plugins/tad-hooks.ts` (tad.sh single-file projection); four points session.created, experimental.session.compacting, tool.execute.after on write and edit, session.compacted map to the shared hook scripts | runtime-adapter-instance-opencode.md dim 3 + live-regression/opencode-20261006.md + raw trigger traces | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | Manual gate pre-checks (pre-accept-check.sh) | verified |
| session_start_context_injection | opencode_adapter | R-OC-1: no SessionStart context-injection surface; session.created fires side effects only; the compacting push is partial parity | runtime-adapter-instance-opencode.md dim 6 + live-regression/opencode-20261006.md field 5 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | Compacting-point reminder push | accepted_limitation |
| ask_user_question_hook | opencode_adapter | R-OC-2: the headless surface has no question tool, so ask-user capture is not registered there | runtime-adapter-instance-opencode.md dim 6 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | Numbered-options plain-text fallback | accepted_limitation |
| sandbox_approval_permissions | opencode_adapter | Config `permission` surface is programmable; `edit: deny` verified effective (write and edit vanish from the session tool roster) | runtime-adapter-instance-opencode.md dim 4 + runtime-permission-examples/opencode-permission.json | opencode 1.18.33 | 2026-10-06 | medium | 2026-12-05 | no | Default permission config | verified |
| context_compaction | opencode_adapter | experimental.session.compacting pushes a compact reminder; session.compacted takes the precompact snapshot (handler-level proof; no live compaction event in the baseline session) | runtime-adapter-instance-opencode.md dim 3 + live-regression/opencode-20261006.md field 5 | opencode 1.18.33 | 2026-10-06 | high | 2026-11-05 | yes | session-state.md file-based recovery | verified_partial |
| trace_evidence_capture | opencode_adapter | Plugin invokes the shared scripts writing `.tad/evidence/traces/<date>.jsonl` (same source and format as the Codex surface); 2026-10-06 live trigger rows captured | runtime-adapter-instance-opencode.md dim 6 + live-regression/opencode-20261006.md raw pointer | opencode 1.18.33 | 2026-10-06 | medium | 2026-12-05 | no | Manual evidence collection | verified |
| release_sync_install | opencode_adapter | tad.sh single-file projection of tad-hooks.ts: preflight divergence FATAL, project cmp, rollback symmetric | runtime-adapter-instance-opencode.md dim 3 + live-regression raw phase1-install.log | opencode 1.18.33 | 2026-10-06 | low | 2027-04-04 | no | Manual file copy | verified |
