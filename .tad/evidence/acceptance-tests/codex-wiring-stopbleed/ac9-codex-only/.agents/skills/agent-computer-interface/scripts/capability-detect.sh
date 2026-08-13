#!/usr/bin/env bash
# capability-detect.sh — Detect available browser/computer control tools
# Tier 2: CLI tool detection (command -v)
# Tier 3: Process/extension detection (pgrep, current user only)
#
# Tier 1 (MCP tools) is handled by the agent via ToolSearch — NOT in this script.
# MCP tools cannot be detected from a shell script.
#
# Output: JSON summary of detected tools
# Security: only checks current user processes (pgrep -fu, never ps aux)
# Performance: builds JSON in one jq pass, no per-tool subprocess spawning

set -euo pipefail

# Hardcoded allowlist — prevents command injection if called with untrusted input
readonly ALLOWED_CLI_TOOLS="playwright puppeteer firecrawl crawl4ai stagehand browser-use node npx python3"

# Collect CLI tool availability
CLI_DETECTED=""
for tool in $ALLOWED_CLI_TOOLS; do
  if command -v "$tool" >/dev/null 2>&1; then
    version=""
    case "$tool" in
      playwright)  version=$("$tool" --version 2>/dev/null || echo "unknown") ;;
      node)        version=$("$tool" --version 2>/dev/null || echo "unknown") ;;
      npx)         version=$("$tool" --version 2>/dev/null || echo "unknown") ;;
      python3)     version=$("$tool" --version 2>/dev/null | head -1 || echo "unknown") ;;
      *)           version="installed" ;;
    esac
    # Strip common prefixes and sanitize for JSON safety (remove quotes, backslashes, control chars)
    version=$(echo "$version" | sed 's/^[Vv]ersion //; s/^Python //; s/^v//; s/[\"\\]//g' | tr -d '\n\r')
    CLI_DETECTED="${CLI_DETECTED}\"${tool}\":{\"tier\":\"cli\",\"version\":\"${version}\"},"
  fi
done

# Tier 3: Extension/process detection (current user only, no ps aux)
PROCESS_DETECTED=""

CURRENT_USER="$(whoami)"

# Claude in Chrome extension detection (current user only)
if pgrep -fu "$CURRENT_USER" -q "claude.*--chrome" 2>/dev/null; then
  PROCESS_DETECTED="${PROCESS_DETECTED}\"claude-in-chrome\":{\"tier\":\"extension\",\"status\":\"running\"},"
fi

# Chrome with debug port (for DevTools MCP, current user only)
if pgrep -fu "$CURRENT_USER" -q "chrome.*--remote-debugging-port" 2>/dev/null; then
  PROCESS_DETECTED="${PROCESS_DETECTED}\"chrome-devtools\":{\"tier\":\"process\",\"status\":\"debug-mode\"},"
fi

# Browserbase/Stagehand process (current user only, ERE alternation with bare |)
if pgrep -fu "$CURRENT_USER" -q "stagehand|browserbase" 2>/dev/null; then
  PROCESS_DETECTED="${PROCESS_DETECTED}\"stagehand-process\":{\"tier\":\"process\",\"status\":\"running\"},"
fi

# Combine and build JSON
ALL_DETECTED="${CLI_DETECTED}${PROCESS_DETECTED}"
ALL_DETECTED="${ALL_DETECTED%,}"  # strip trailing comma

# Output via jq for pretty-printing (fall back to raw JSON if jq unavailable)
if command -v jq >/dev/null 2>&1; then
  echo "{${ALL_DETECTED}}" | jq .
else
  echo "{${ALL_DETECTED}}"
fi
