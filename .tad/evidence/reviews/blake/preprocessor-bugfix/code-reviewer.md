# Code Review — TASK-20260509-002 Handler Bugfixes

**Reviewer**: code-reviewer sub-agent  
**Date**: 2026-05-09  
**Status**: PASS (P0 fix applied in Round 1)

## Findings

| Severity | ID | Description | Status |
|----------|-----|-------------|--------|
| P0 | CR-P0-1 | `$NF` wrong for GNU md5sum in scholar-handler (returns `-` not hash) | ✅ Fixed: `$1` (matches bilibili-handler.sh reference pattern) |
| P2 | CR-P2-1 | Thread 429 rate-limit silently swallowed without stderr warning | Advisory — graceful degradation acceptable for express fix |

## Empirical Verification

- extract_tweet_id `/(status|articles)/[0-9]+` pattern: correct for 4 URL shapes
- `-H` before `--` in jina-handler.sh: correct (curl treats post-`--` args as URLs)
- `$1` vs `$NF` in awk: `$1` works for both BSD md5 (single field) and GNU md5sum (`<hash>  -`)
- AC1 article mode: 81-line .md verified with real twitterapi.io API call

## Verdict: PASS — P0=0, P1=0, P2=1 (advisory)
