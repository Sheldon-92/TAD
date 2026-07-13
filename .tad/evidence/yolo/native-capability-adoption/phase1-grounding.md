# Phase 1 Grounding — precompact-session-state-hook (Conductor-written, 2026-07-13)

## Authoritative handoff
`.tad/active/handoffs/HANDOFF-20260712-precompact-session-state-hook.md` (v2 — ALREADY expert-reviewed,
6 P0 integrated, Gate 2 PASS; §9.2 has the audit trail). Design reviewers in this workflow are a
RE-VALIDATION vote on v2, not first review.

## Actual code state (verified by Conductor)

### Claude Code CLI
- Installed version: **2.1.172**. PreCompact support in this version is UNKNOWN → T1 spike is the
  friction preflight gate. If unsupported → BLOCKED per handoff §8.4 (report, do not degrade silently).

### .claude/settings.json hooks (current)
- SessionStart: [startup-health.sh, notebook-dormant-sync.sh] (matcher "")
- PreToolUse: Write|Edit prompt-gate (haiku), Skill → pre-accept-check.sh, Skill → pre-gate-check.sh
- PostToolUse: Write|Edit → post-write-sync.sh, AskUserQuestion → (askuser capture)
- **No PreCompact key exists.** Registration = new top-level "PreCompact" array, hook type "command".

### .tad/hooks/startup-health.sh (FR4 target)
- Sources `lib/common.sh` which provides: `read_stdin_json`, `get_json_field ".field"`,
  `safe_count`, `output_response "EventName" "text"`, `output_empty`, `$HAS_JQ`.
- Source guard is at ~L16-19:
  `SOURCE=$(get_json_field ".source" || echo "")` then
  `if [ -n "$SOURCE" ] && [ "$SOURCE" != "null" ] && [ "$SOURCE" != "startup" ]; then output_empty; exit 0; fi`
- FR4 compact branch must be inserted BEFORE this guard (or as an elif on compact), per handoff:
  `source == compact → output_response "SessionStart" "<reminder line>"; exit 0`.
  `source == startup` output must stay byte-identical (AC7 baseline diff).
- Note: this session observed real `SessionStart:compact` hook firing — the event path exists;
  the `source` value spelling must be confirmed by T1(iv).

### .gitignore
- Has a `.tad/memory/` sensitivity block at the tail. FR8 adds `.tad/active/precompact/` (whole dir).

### Layer 1 for this repo
- NO package.json / tsc / npm test. Layer 1 for shell work = `bash -n` on every touched script +
  run the script with synthetic stdin fixtures + (if available) shellcheck. Do NOT report
  npm/tsc as failed — report N/A with the substitute checks.

### Evidence dir
`.tad/evidence/hooks/precompact-snapshot/` (create). YOLO evidence: `.tad/evidence/yolo/native-capability-adoption/`.

## Known constraints (from project knowledge — binding)
- macOS bash 3.2, BSD tools. NO `set -e` in the new hook (FR7). Every `$()` needs `|| fallback`.
- Real file only touched by final `mv` (temp assembly).
- Hook must exit 0 always (fail-open; smoke alarm, not fire suppressor — 2026-04-15 SAFETY).
- Multi-line command output must be flattened to single-line fields (FR1).

## T1 spike — honest-partial expectation (Conductor guidance)
T1 requires a REAL compaction to capture PreCompact stdin. A sub-agent CANNOT trigger interactive
/compact of a live session, and newly-registered hooks may not fire in already-running sessions.
Therefore:
- T1 implementation = register probe (or final hook with a debug tee), document the four questions,
  and capture what is mechanically capturable NOW (e.g., feed synthetic stdin to the script).
- The four T1 answers from a REAL compact are expected to land at the next real /compact by the
  human (Terminal 1). Mark T1(i)(ii)(iii)(iv) as PENDING-REAL-EVENT in the completion report if
  not capturable — this is honest_partial, NOT a failure. AC2 likewise: script-level behavior
  fully tested with synthetic stdin; live-compact evidence marked pending human trigger.
- Design the final hook so the probe is built in: on every run, ALSO copy raw stdin to
  `.tad/evidence/hooks/precompact-snapshot/last-stdin.json` (overwrite) — the first real compact
  then automatically produces the T1 evidence with zero extra ceremony.

## Worktree note
You (Blake) run in an isolated worktree. Commit there normally; Conductor merges after gate.
`.claude/settings.json` is tracked — edit it in the worktree like any file.
