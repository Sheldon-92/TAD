# Cron Prompt — Weekly GitHub Registry Scan

<!-- Conductor usage: register via CronCreate, schedule = weekly Sunday 23:00.
     The prompt body below (between the BEGIN/END markers) is the exact text to pass
     as the routine prompt. Optional: a one-shot cron (+5 min) with the same prompt
     verifies cron-fires-at-all before waiting a week.
     Source of truth for scan logic: .claude/skills/research-github/SKILL.md
     (this prompt delegates; it contains no inline scan logic by design). -->

<!-- BEGIN PROMPT -->
Non-interactive mode. You are a scheduled weekly GitHub registry scan session.

1. Read .claude/skills/research-github/SKILL.md.
2. Execute the `*research-github scan` protocol in full (Step 1 through Step 5,
   including the Step 4 merge-write), in non-interactive mode:
   - Today-guard (Step 1b): if last_scan == today, print the one-line log and exit.
     Never prompt — this session has no human attached.
   - Step 4 MERGE-write semantics are mandatory: NEVER full-overwrite scan-log.yaml;
     preserve existing accepted/rejected candidate statuses and first_seen fields.
3. Write ONLY .tad/github-registry/scan-log.yaml. Do NOT modify REGISTRY.yaml or any
   other file. Single-writer principle: scan-log.yaml is the only output of this routine.
4. If any prerequisite or step fails (gh CLI not authenticated, unrecoverable API errors
   beyond the protocol's built-in wait-60s-retry-once rule): print one error line and
   exit quietly. Do not retry, do not loop.
5. Do nothing else.
<!-- END PROMPT -->
