# Code Review — TASK-20260509-001 NotebookLM Source Preprocessor Pipeline

**Reviewer**: code-reviewer sub-agent  
**Date**: 2026-05-09  
**Status**: PASS (Round 2 — all P0s resolved)

## Round 1 Findings

| Severity | ID | Description | Status |
|----------|-----|-------------|--------|
| P0 | CR-P0-1 | `timeout` unavailable on stock macOS → dispatch exits 127 silently | ✅ Fixed: gtimeout/timeout/fallback detection via run_with_timeout() |
| P0 | CR-P0-2 | SKILL Step 3 ignores exit codes outside 0/1/2/10 (127, 124) | ✅ Fixed: else branch added to SKILL dispatch block |
| P0 | CR-P0-3 | Python `-c "...${query}..."` interpolation risk in scholar-handler.sh | ✅ Fixed: switched to `printf '%s' | jq -sRr '@uri'` |
| P1 | CR-P1-1 | UTM regex `s/[?&]utm_*//g` corrupts URLs with utm_source as first param | ✅ Fixed: tr-split per-param + grep -v '^utm_' approach (later superseded by BA-P0-2) |
| P1 | CR-P1-2 | Jina fallback calls jina-handler.sh directly bypassing URL validation | Advisory noted — URL already validated in Step 2, low immediate risk |
| P1 | CR-P1-3 | bilibili md5 truncation incorrect (full 32-char hash, not 8-char) | ✅ Fixed: awk '{print substr($1,1,8)}' |
| P1 | CR-P1-4 | API key trailing newline included in HTTP header | ✅ Fixed: `tr -d '\r\n' < "$KEY_FILE"` |
| P2 | CR-P2-1 | BSD sed `\|` alternation not supported for slug trim | ✅ Fixed: separate sed passes + parameter expansion |

## Round 2 Verdict

All P0 findings resolved. P1s addressed except P1-2 (advisory, low risk). P2s addressed.

**Overall**: PASS — P0=0, P1=1 (advisory), P2=0
