# T1 Spike — Four Questions (HANDOFF-20260712-precompact-session-state-hook §4.2)

Status: **CLOSED — REAL-EVENT VERIFIED 2026-07-13 11:50** (see closure addendum at bottom).
Original status at ship time: honest_partial — PENDING-REAL-EVENT (per Conductor grounding, phase1-grounding.md).
A sub-agent cannot trigger an interactive /compact of a live session, and a newly registered
PreCompact hook may not fire in already-running sessions. The probe is BUILT INTO the shipped
hook: every run tees raw stdin to `last-stdin.json` (overwrite) in this directory, so the first
real compact by the human (Terminal 1) auto-produces the authoritative answers with zero ceremony.

## (i) stdin field names (session_id / trigger / cwd / transcript_path actual spelling)

- **PENDING-REAL-EVENT.** Expected per Claude Code hooks documentation (knowledge base):
  `session_id`, `transcript_path`, `cwd`, `hook_event_name: "PreCompact"`, `trigger`
  (`"manual"` | `"auto"`), `custom_instructions`. `probe-stdin.json` here is a SYNTHETIC
  fixture using those spellings (marked `"_synthetic": true`); all script-level AC runs used it.
- Verification on first real compact: `cat .tad/evidence/hooks/precompact-snapshot/last-stdin.json`.
- Robustness if spelling differs: missing `trigger` renders as
  `Trigger: (unavailable: no-trigger-field)`; missing `session_id` renders as `Session: unknown`.
  The snapshot still lands (fail-open, discriminable).

## (ii) session_id stability across the compaction boundary

- **PENDING-REAL-EVENT.** Compare `last-stdin.json` (pre-compact) with the post-compact
  SessionStart payload at the next real compact.
- Design does NOT depend on the answer (arch F4 already ruled): `Session:` field is diagnostic
  only; readers use newest-wins by filename timestamp.

## (iii) Does PreCompact fire on AUTO compact?

- **untestable-on-demand** (handoff §8.4 pre-authorizes this outcome): auto-compact cannot be
  forced at will from this environment. Mitigation shipped: settings.json matcher is `""`
  (empty = match ALL), which covers both `manual` and `auto` by construction regardless of the
  matcher-value spelling. Residual unknown noted in completion report per handoff T1(iii).

## (iv) SessionStart `source` value set and compact discriminability

- Partially grounded: Conductor observed a real `SessionStart:compact` hook firing
  (phase1-grounding.md — "this session observed real SessionStart:compact"), so `compact` is
  discriminable as a source value. Exact full value set (`startup` / `compact` / `resume` / ...)
  **PENDING-REAL-EVENT**.
- Implementation matches: startup-health.sh branches on `source == "compact"` before the
  non-startup early-exit guard; `startup` path is byte-identical (AC7).

## Friction Preflight item: does this Claude Code (2.1.172) support PreCompact at all?

- **PENDING-REAL-EVENT** — cannot be proven from a sub-agent. Registration is inert if
  unsupported (hook simply never fires; nothing breaks). If the first real /compact produces
  no `last-stdin.json` and no snapshot, treat as BLOCKED per §8.4 and report the version.

---

## REAL-EVENT CLOSURE ADDENDUM — 2026-07-13 11:50 (manual /compact by human, CLI 2.1.207)

Event: user ran `/compact` in session bdae3dff (Terminal 1). Hook fired
(`PreCompact [bash .tad/hooks/precompact-session-snapshot.sh] completed successfully` shown
in CLI output). Note: hook was REGISTERED under 2.1.172; this fire is under 2.1.207.

### (i) stdin field spellings — ✅ CONFIRMED (all expected spellings correct)
`last-stdin.json` (real, non-synthetic):
`session_id`, `transcript_path`, `cwd`, `prompt_id` (bonus field, not in docs guess),
`hook_event_name: "PreCompact"`, `trigger: "manual"`, `custom_instructions: null`.
Zero `(unavailable: ...)` degradations needed.

### (ii) session_id stability across compaction — ✅ STABLE
Pre-compact stdin `session_id` = `bdae3dff-...`; post-compact the SAME session continues under
`bdae3dff-...` (scratchpad path + transcript path unchanged). Diagnostic-only design stands.

### (iii) auto-compact firing — STILL untestable-on-demand (unchanged)
This event was `trigger: "manual"`. Matcher `""` covers auto by construction; residual unknown
remains open per §8.4 pre-authorization. (An earlier snapshot `snapshot-20260713-092738-mainspot.md`
also landed at 09:27 with `Trigger: manual` — a second independent firing; its non-UUID session
value "mainspot" is diagnostic-only per design.)

### (iv) SessionStart source=compact end-to-end — ✅ VERIFIED LIVE
Post-compact context in the SAME session received the reminder line:
"Post-compact: read .tad/active/session-state.md + newest .tad/active/precompact/snapshot-*.md
before continuing." → startup-health.sh compact branch fires on real compact, full chain proven.

### Friction Preflight (PreCompact supported at all?) — ✅ YES on 2.1.207
Snapshot `snapshot-20260713-115028-bdae3dff.md` written with true fields (When/Trigger/Git HEAD
6848246/Git counts/0 active handoffs/0 active epics — all match live repo state at fire time).
Newest-wins reader has 2 snapshots to discriminate; prune-keep-5 not yet exercised (only 2 files).

**AC2a + T1: PASS. No PENDING-REAL-EVENT items remain for Phase 1.**
