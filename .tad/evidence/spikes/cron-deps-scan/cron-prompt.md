# Deps Scan Cron Prompt

Re-register this cron when starting a new session that should run weekly dependency scans.

## Schedule
- **When**: Weekly, Sunday 23:30
- **Offset**: 23 minutes after GitHub Registry scan (23:07) to avoid overlap

## Command
```bash
bash .tad/hooks/lib/deps-scan.sh
```

## Re-register
```
/schedule create with prompt: "Run dependency upstream scan: bash .tad/hooks/lib/deps-scan.sh" --cron "30 23 * * 0"
```

## Notes
- Session-bound: dies when the session ends
- Results written to .tad/dependencies/scan-results.yaml
- Phase 3 (Alex startup) will read scan-results.yaml and flag actionable changes
- No Claude CLI dependency — pure bash + gh/npm/curl + jq/yq
