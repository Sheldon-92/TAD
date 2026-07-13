# Phase 3 Grounding — cloud-scheduled weekly GitHub scan (Conductor-written, 2026-07-13)

## Scope (from Epic Phase 3)
Spike-gated: verify a scheduled agent can run `*research-github scan` headlessly. PASS → weekly
routine writing scan-log.yaml (Alex STEP 3.9 consumes). FAIL → degraded local path (human-decided:
degrade, not drop).

## Actual state (verified by Conductor)

### The scan is a SKILL protocol, not a bash script
- `.claude/skills/research-github/SKILL.md` L330+: `*research-github scan` = LLM-driven steps
  (freshness check + discovery), writes `.tad/github-registry/scan-log.yaml` via MERGE-write
  (never full overwrite — preserves user accept/reject decisions). Single-writer principle:
  scan-log.yaml is the routine's ONLY output; REGISTRY.yaml last_checked is NOT its job.
- Interactive branch exists: today-guard uses AskUserQuestion when last_scan == today. A headless
  run MUST bypass interactivity: same-day re-run → log-and-exit, never prompt (design this in).
- `gh` auth IS required for scan (SKILL L35). Headless cron context must have gh auth available.
- Current scan-log.yaml: `last_scan: null` — routine has NEVER run. Any successful headless run
  is immediately observable (last_scan flips to a date).

### Native scheduling facts (verify in spike, do not trust blindly)
- CronCreate/CronList/CronDelete are native tools available to the MAIN session (not sub-agents).
  Scheduled runs execute as fresh headless sessions in this project. Unknowns for spike:
  (i) does the scheduled session have `gh` CLI + auth (keychain access)? (ii) does it load
  project CLAUDE.md/skills so `*research-github scan` resolves? (iii) MCP/interactive-auth
  services are documented as possibly ABSENT in headless runs — gh is a local CLI, likely fine,
  but PROVE it. (iv) What does the cron prompt look like — it should instruct: run the scan per
  SKILL, non-interactive variant, write scan-log.yaml, do nothing else.
- Spike design: instead of waiting a week, create a one-shot/near-term cron (or run
  `claude -p` headless locally simulating the cron body) to test the scan end-to-end headlessly.
  A local `claude -p "..."` probe is an acceptable EQUIVALENT_SUBSTITUTE for "headless context"
  ONLY for gh-auth/skill-resolution questions; the cron-fires-at-all question needs a real
  scheduled run (can be a +5min one-shot, then CronDelete).

### Degraded path (if spike FAILs)
- Alex STEP 3.9 ALREADY has a staleness WARNING (>14d unscanned → warn; last_scan null → silent).
  Degraded design = document manual `*research-github scan` cadence + OPTIONALLY tighten STEP 3.9
  null-case from silent-skip to a gentle one-line nudge. Keep tiny; no new mechanisms.

### Sub-agent limitation (binding for implementation)
Sub-agents CANNOT call CronCreate (main-session tool). Blake implements: the cron PROMPT text +
non-interactive scan variant (SKILL edit) + spike evidence via `claude -p` probe. The actual
CronCreate registration is executed by the CONDUCTOR (Alex main session) after gate PASS — this
is a sanctioned mechanical execution, record it in completion §Escalations as "Conductor action".

### Evidence dir
`.tad/evidence/yolo/native-capability-adoption/` (phase3-*), spike:
`.tad/evidence/spikes/cron-github-scan-2026-07/`.
