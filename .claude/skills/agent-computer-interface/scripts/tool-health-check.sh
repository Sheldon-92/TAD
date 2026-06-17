#!/usr/bin/env bash
# tool-health-check.sh — Check health status of browser/computer control tools
# Checks: last_verified dates in reference files + tool version probes
# Output: OK / STALE / BROKEN per tool
# Cache: results cached to /tmp/tad-tool-health-cache for 24h

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REFS_DIR="${PACK_DIR}/references"
CACHE_FILE="/tmp/tad-tool-health-cache"
CACHE_TTL=86400  # 24 hours in seconds
STALE_THRESHOLD=90  # days before a reference is considered stale

# Check cache validity
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    echo "=== Tool Health Check (cached — $(( cache_age / 60 ))m ago) ==="
    cat "$CACHE_FILE"
    exit 0
  fi
fi

echo "=== Tool Health Check ==="
echo ""

OUTPUT=""

# Check reference file freshness
echo "## Reference File Freshness"
for ref_file in "$REFS_DIR"/*.md; do
  [ -f "$ref_file" ] || continue
  filename=$(basename "$ref_file")

  # Extract last_verified date from file header
  last_verified=$(grep -m1 "^last_verified:" "$ref_file" 2>/dev/null | sed 's/last_verified: *//' || echo "")

  if [ -z "$last_verified" ]; then
    line="STALE: $filename — no last_verified date found"
    echo "  $line"
    OUTPUT="${OUTPUT}${line}\n"
    continue
  fi

  # Calculate days since last_verified (macOS compatible)
  if date -j -f "%Y-%m-%d" "$last_verified" "+%s" >/dev/null 2>&1; then
    verified_epoch=$(date -j -f "%Y-%m-%d" "$last_verified" "+%s")
  else
    # Linux fallback
    verified_epoch=$(date -d "$last_verified" "+%s" 2>/dev/null || echo 0)
  fi

  now_epoch=$(date "+%s")
  days_ago=$(( (now_epoch - verified_epoch) / 86400 ))

  if [ "$days_ago" -gt "$STALE_THRESHOLD" ]; then
    line="STALE: $filename last_verified $last_verified ($days_ago days ago)"
    echo "  $line"
    OUTPUT="${OUTPUT}${line}\n"
  else
    line="OK: $filename last_verified $last_verified ($days_ago days ago)"
    echo "  $line"
    OUTPUT="${OUTPUT}${line}\n"
  fi
done

echo ""

# Check installed tool versions (hardcoded whitelist — no injection risk)
echo "## Installed Tool Status"

readonly HEALTH_CHECK_TOOLS="playwright puppeteer firecrawl crawl4ai node npx python3"

for tool in $HEALTH_CHECK_TOOLS; do
  if command -v "$tool" >/dev/null 2>&1; then
    version=""
    case "$tool" in
      playwright)  version=$("$tool" --version 2>/dev/null || echo "error") ;;
      node)        version=$("$tool" --version 2>/dev/null || echo "error") ;;
      npx)         version=$("$tool" --version 2>/dev/null || echo "error") ;;
      python3)     version=$("$tool" --version 2>/dev/null | head -1 || echo "error") ;;
      *)           version="installed (no --version)" ;;
    esac

    # Strip common prefixes from version output (e.g., "Version 1.54.2" → "1.54.2", "Python 3.14" → "3.14")
    version=$(echo "$version" | sed 's/^[Vv]ersion //; s/^Python //; s/^v//')

    if [ "$version" = "error" ]; then
      line="BROKEN: $tool — command exists but --version failed"
    else
      line="OK: $tool v${version}"
    fi
  else
    line="NOT_FOUND: $tool — not installed"
  fi
  echo "  $line"
  OUTPUT="${OUTPUT}${line}\n"
done

echo ""
echo "=== Check Complete ==="

# Write cache
printf "%b" "$OUTPUT" > "$CACHE_FILE" 2>/dev/null || true
